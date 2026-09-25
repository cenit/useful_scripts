#!/usr/bin/env pwsh
# $script:Root/$script:Scripts must be plain top-level statements, not inside BeforeAll:
# -ForEach below is resolved at Pester's *discovery* pass, which runs the file's
# top-level code but does not invoke BeforeAll (that's run-phase only). A BeforeAll
# here would leave $script:Scripts unset ($null) during discovery, and Pester would
# silently generate zero tests for the -ForEach block below instead of failing loudly.
$script:Root = Split-Path $PSScriptRoot -Parent
$script:Scripts = @(
    (Join-Path $script:Root 'git/Update-CcmRefs.ps1'),
    (Join-Path $script:Root 'git/Update-AllRepos.ps1'),
    (Join-Path $script:Root 'git/Update-ForkedRepos.ps1')
)

BeforeAll {
    # Re-set for the run phase: the top-level assignment above only lives in the
    # discovery-phase scope. Pester invokes It bodies against a separate run-phase
    # scope, so anything an It body needs (as opposed to -ForEach, which only needs
    # the discovery-time value) must also be (re)established here.
    $script:Root = Split-Path $PSScriptRoot -Parent
    $script:Scripts = @(
        (Join-Path $script:Root 'git/Update-CcmRefs.ps1'),
        (Join-Path $script:Root 'git/Update-AllRepos.ps1'),
        (Join-Path $script:Root 'git/Update-ForkedRepos.ps1')
    )

    function New-TestGitRepo {
        [CmdletBinding(SupportsShouldProcess)]
        param([Parameter(Mandatory)][string]$Path)
        if (-not $PSCmdlet.ShouldProcess($Path, 'init test git repo')) { return }
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        Push-Location $Path
        try {
            git init --quiet
            git config user.email t@example.com
            git config user.name Test
        }
        finally {
            Pop-Location
        }
    }

    function New-TestBareRepo {
        [CmdletBinding(SupportsShouldProcess)]
        param([Parameter(Mandatory)][string]$Path)
        if (-not $PSCmdlet.ShouldProcess($Path, 'init test bare repo')) { return }
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        Push-Location $Path
        try {
            git init --quiet --bare
        }
        finally {
            Pop-Location
        }
    }

    function Add-TestCommit {
        param([Parameter(Mandatory)][string]$Path, [Parameter(Mandatory)][string]$File, [Parameter(Mandatory)][string]$Content, [string]$Message = 'commit')
        Push-Location $Path
        try {
            Set-Content -Path $File -Value $Content
            git add $File
            git commit --quiet -m $Message
        }
        finally {
            Pop-Location
        }
    }

    # Reproduces the state a remote squash-merge leaves behind: a clone still parked on
    # the PR branch, whose remote counterpart has been deleted. -Squashed first lands the
    # same content on master as one unrelated commit (what Azure DevOps does when the PR
    # completes); without it the branch's work never landed, i.e. an abandoned PR.
    # -NoOriginHead removes the clone's origin/HEAD so the default-branch fallback is
    # exercised instead of the symbolic ref.
    function New-GoneBranchFixture {
        [CmdletBinding(SupportsShouldProcess)]
        param(
            [Parameter(Mandatory)][string]$Path,
            [switch]$Squashed,
            [switch]$NoOriginHead
        )
        if (-not $PSCmdlet.ShouldProcess($Path, 'build gone-branch fixture')) { return }
        New-Item -ItemType Directory -Path $Path -Force | Out-Null

        $remote = Join-Path $Path 'remote.git'
        New-TestBareRepo -Path $remote

        $seed = Join-Path $Path 'seed'
        New-TestGitRepo -Path $seed
        Add-TestCommit -Path $seed -File 'README.md' -Content 'v1' -Message init
        Push-Location $seed
        git push --quiet $remote HEAD:master
        Pop-Location
        # Without this the clone has no origin/HEAD to read and every case would silently
        # exercise the fallback path rather than the one it means to.
        git -C $remote symbolic-ref HEAD refs/heads/master

        $clonesRoot = Join-Path $Path 'clones'
        New-Item -ItemType Directory -Path $clonesRoot -Force | Out-Null
        $clone = Join-Path $clonesRoot 'repo-a'
        git clone --quiet $remote $clone
        git -C $clone config user.email t@example.com
        git -C $clone config user.name Test
        if ($NoOriginHead) { git -C $clone remote set-head origin -d | Out-Null }

        # The PR branch, pushed so it gets a real upstream that pruning can later orphan.
        git -C $clone checkout --quiet -b feature
        Add-TestCommit -Path $clone -File 'feature.txt' -Content 'work' -Message 'feature work'
        git -C $clone push --quiet -u $remote feature:feature 2>&1 | Out-Null
        # push -u against a URL records the URL, not 'origin'; rewrite the upstream to the
        # remote-tracking ref so `%(upstream:track)` can report [gone] once it is pruned.
        git -C $clone config branch.feature.remote origin
        git -C $clone config branch.feature.merge refs/heads/feature
        git -C $clone fetch --quiet origin

        if ($Squashed) {
            # The squash: identical resulting content, one commit, unrelated SHA, no
            # parent link to the branch. This is what makes `git branch -d` refuse.
            Add-TestCommit -Path $seed -File 'feature.txt' -Content 'work' -Message 'Merged PR 1: feature work'
            Push-Location $seed
            git push --quiet $remote HEAD:master
            Pop-Location
        }

        # ADO deletes the source branch on completion; the clone only learns on --prune.
        git -C $remote branch -D feature | Out-Null

        [pscustomobject]@{
            Remote     = $remote
            ClonesRoot = $clonesRoot
            Clone      = $clone
        }
    }
}

Describe 'Git scripts' {
    It '<_> parses without error' -ForEach $script:Scripts {
        $errors = $null
        [System.Management.Automation.Language.Parser]::ParseFile($_, [ref]$null, [ref]$errors) | Out-Null
        $errors | Should -BeNullOrEmpty
    }

    It '<_> declares SupportsShouldProcess' -ForEach $script:Scripts {
        (Get-Content $_ -Raw) | Should -Match 'SupportsShouldProcess'
    }

    It '<_> imports no module that does not exist' -ForEach $script:Scripts {
        $content = Get-Content $_ -Raw
        if ($content -match "Import-Module[^\r\n]*?['`"]?([^\s'`"]+\.psm1)") {
            Test-Path (Join-Path (Split-Path $_ -Parent) $Matches[1]) | Should -BeTrue
        }
    }

    It '<_> uses no Invoke-Expression' -ForEach $script:Scripts {
        (Get-Content $_ -Raw) | Should -Not -Match 'Invoke-Expression'
    }
}

Describe 'Update-CcmRefs' {
    It 'runs under -WhatIf without pushing' {
        # Built on the same working-remote fixture as "actually pulls..." below, not a
        # remote-less sandbox: a repo with no remote configured fails `git pull --ff-only`
        # regardless of -WhatIf, that failure is swallowed by the script's own try/catch,
        # and HEAD ends up unchanged either way -- indistinguishable from a correctly
        # -WhatIf-gated run. Only a remote that has genuinely advanced, checked against a
        # HEAD that must NOT move, proves -WhatIf actually blocked the pull.
        $sandbox = Join-Path $TestDrive 'fleet'
        New-Item -ItemType Directory -Path $sandbox -Force | Out-Null

        $remote = Join-Path $sandbox 'remote.git'
        New-TestBareRepo -Path $remote

        $seed = Join-Path $sandbox 'seed'
        New-TestGitRepo -Path $seed
        Add-TestCommit -Path $seed -File 'README.md' -Content 'v1' -Message init
        Push-Location $seed
        git push --quiet $remote HEAD:master
        Pop-Location

        $clonesRoot = Join-Path $sandbox 'clones'
        New-Item -ItemType Directory -Path $clonesRoot -Force | Out-Null
        Push-Location $clonesRoot
        git clone --quiet $remote repo-a
        Pop-Location
        Push-Location (Join-Path $clonesRoot 'repo-a')
        git checkout --quiet master
        $before = git rev-parse HEAD
        Pop-Location

        # Advance the remote past the clone so -WhatIf has something real to (not) pull.
        Add-TestCommit -Path $seed -File 'README.md' -Content 'v2' -Message advance
        Push-Location $seed
        git push --quiet $remote HEAD:master
        Pop-Location

        & (Join-Path $script:Root 'git/Update-CcmRefs.ps1') -RootDirectory $clonesRoot -WhatIf `
            -ErrorAction SilentlyContinue | Out-Null

        Push-Location (Join-Path $clonesRoot 'repo-a')
        git rev-parse HEAD | Should -Be $before
        Pop-Location
    }

    It 'returns the caller to the original directory even when a repo fails' {
        $origin = (Get-Location).Path
        $sandbox = Join-Path $TestDrive 'broken'
        New-Item -ItemType Directory -Path (Join-Path $sandbox 'not-a-repo') -Force | Out-Null
        & (Join-Path $script:Root 'git/Update-CcmRefs.ps1') -RootDirectory $sandbox -WhatIf `
            -ErrorAction SilentlyContinue | Out-Null
        (Get-Location).Path | Should -Be $origin
    }

    It 'actually pulls when run without -WhatIf, proving $PSCmdlet.ShouldProcess resolves inside Use-Location' {
        # This is the load-bearing test: a broken $PSCmdlet binding inside the Use-Location
        # scriptblock (e.g. it resolving to $null) would throw on ShouldProcess, get swallowed
        # by the script's own try/catch as a warning, and produce exactly the same "nothing
        # changed" result as a correctly-working -WhatIf run. Only a real, non-WhatIf pull that
        # actually advances the clone's HEAD proves ShouldProcess returned $true and let the
        # git calls run.
        $sandbox = Join-Path $TestDrive 'live'
        New-Item -ItemType Directory -Path $sandbox -Force | Out-Null

        $remote = Join-Path $sandbox 'remote.git'
        New-TestBareRepo -Path $remote

        $seed = Join-Path $sandbox 'seed'
        New-TestGitRepo -Path $seed
        Add-TestCommit -Path $seed -File 'README.md' -Content 'v1' -Message init
        Push-Location $seed
        git push --quiet $remote HEAD:master
        Pop-Location

        $clonesRoot = Join-Path $sandbox 'clones'
        New-Item -ItemType Directory -Path $clonesRoot -Force | Out-Null
        Push-Location $clonesRoot
        git clone --quiet $remote repo-a
        Pop-Location
        Push-Location (Join-Path $clonesRoot 'repo-a')
        git checkout --quiet master
        Pop-Location

        # Advance the remote past the clone so a real "pull" has something to do.
        Add-TestCommit -Path $seed -File 'README.md' -Content 'v2' -Message advance
        Push-Location $seed
        git push --quiet $remote HEAD:master
        Pop-Location
        Push-Location $seed
        $newHead = git rev-parse HEAD
        Pop-Location

        $warnings = & (Join-Path $script:Root 'git/Update-CcmRefs.ps1') -RootDirectory $clonesRoot -SkipCcmUpdate `
            -WarningVariable +capturedWarnings -WarningAction SilentlyContinue 3>&1

        Push-Location (Join-Path $clonesRoot 'repo-a')
        $after = git rev-parse HEAD
        Pop-Location

        $after | Should -Be $newHead
        ($warnings -join "`n") | Should -Not -Match 'null-valued expression'
    }

    It 'falls back to master when a submodule has no origin/HEAD, instead of checking out git error text' {
        # Invoke-Git returns git's *stderr text* on failure (it runs git with 2>&1), so a
        # `-not $branch` fallback test can never fire: the old code passed
        # "fatal: ref refs/remotes/origin/HEAD is not a symbolic ref" to `git checkout`.
        # The submodule below is left on a branch other than master with origin/HEAD
        # deleted, so only a working fallback can land it back on master.
        $sandbox = Join-Path $TestDrive 'ccm-head'
        New-Item -ItemType Directory -Path $sandbox -Force | Out-Null

        $parentRemote = Join-Path $sandbox 'parent.git'
        New-TestBareRepo -Path $parentRemote
        $parentSeed = Join-Path $sandbox 'parent-seed'
        New-TestGitRepo -Path $parentSeed
        # The nested ccm clone is ignored, so `git status --porcelain -- ccm` stays clean
        # and the run never reaches the commit/push branch of the script.
        Add-TestCommit -Path $parentSeed -File '.gitignore' -Content 'ccm/' -Message init
        Push-Location $parentSeed
        git push --quiet $parentRemote HEAD:master
        Pop-Location
        git -C $parentRemote symbolic-ref HEAD refs/heads/master

        $ccmRemote = Join-Path $sandbox 'ccm.git'
        New-TestBareRepo -Path $ccmRemote
        $ccmSeed = Join-Path $sandbox 'ccm-seed'
        New-TestGitRepo -Path $ccmSeed
        Add-TestCommit -Path $ccmSeed -File 'CCM.psd1' -Content 'v1' -Message init
        Push-Location $ccmSeed
        git push --quiet $ccmRemote HEAD:master
        Pop-Location
        git -C $ccmRemote symbolic-ref HEAD refs/heads/master

        $clonesRoot = Join-Path $sandbox 'clones'
        New-Item -ItemType Directory -Path $clonesRoot -Force | Out-Null
        $project = Join-Path $clonesRoot 'proj'
        git clone --quiet $parentRemote $project
        $ccm = Join-Path $project 'ccm'
        git clone --quiet $ccmRemote $ccm
        # Unset origin/HEAD (the real-world case: a clone made with --no-checkout, an old
        # clone, or a remote whose default branch was never recorded) and park the
        # submodule on a different branch so a successful fallback checkout is visible.
        git -C $ccm remote set-head origin -d
        git -C $ccm checkout --quiet -b scratch

        # -WarningVariable, not 3>&1: -WarningAction SilentlyContinue drops the records
        # before a stream redirect can see them, which would make the assertion below
        # vacuous. The old code turned the failed symbolic-ref into exactly such a warning.
        & (Join-Path $script:Root 'git/Update-CcmRefs.ps1') -RootDirectory $clonesRoot `
            -WarningVariable ccmWarnings -WarningAction SilentlyContinue 2>&1 | Out-Null

        git -C $ccm branch --show-current | Should -Be 'master'
        ($ccmWarnings -join "`n") | Should -Not -Match 'not a symbolic ref'
    }
}

Describe 'forks.json' {
    It 'is valid JSON with the required keys' {
        $forks = Get-Content (Join-Path $script:Root 'git/forks.json') -Raw | ConvertFrom-Json
        $forks.Count | Should -BeGreaterThan 0
        foreach ($f in $forks) {
            $f.name     | Should -Not -BeNullOrEmpty
            $f.url      | Should -Not -BeNullOrEmpty
            $f.upstream | Should -Not -BeNullOrEmpty
            $f.mode     | Should -BeIn @('fork', 'mirror')
        }
    }
}

Describe 'Update-ForkedRepos merge behaviour' {
    BeforeEach {
        $script:work = Join-Path $TestDrive ([Guid]::NewGuid().ToString())
        New-Item -ItemType Directory -Path $script:work -Force | Out-Null
    }

    It 'pushes after a clean, non-conflicting merge from upstream (R2: must not treat success as a conflict)' {
        $upstreamBare = Join-Path $script:work 'upstream.git'
        $originBare = Join-Path $script:work 'origin.git'
        New-TestBareRepo -Path $upstreamBare
        New-TestBareRepo -Path $originBare

        $seed = Join-Path $script:work 'seed'
        New-TestGitRepo -Path $seed
        Add-TestCommit -Path $seed -File 'README.md' -Content 'v1' -Message init
        Push-Location $seed
        git push --quiet $upstreamBare HEAD:master
        git push --quiet $originBare HEAD:master
        Pop-Location

        # Upstream progresses with a change that does not touch anything origin has changed.
        Add-TestCommit -Path $seed -File 'feature.txt' -Content 'new upstream feature' -Message 'upstream progress'
        Push-Location $seed
        git push --quiet $upstreamBare HEAD:master
        $upstreamHead = git rev-parse HEAD
        Pop-Location

        $forksJson = Join-Path $script:work 'forks.json'
        @(
            @{
                name           = 'test-fork'
                url            = $originBare
                upstream       = $upstreamBare
                localBranch    = 'master'
                upstreamBranch = 'master'
                mode           = 'fork'
                skip           = $false
            }
        ) | ConvertTo-Json | Set-Content -Path $forksJson

        $workingDirectory = Join-Path $script:work 'clones'
        New-Item -ItemType Directory -Path $workingDirectory -Force | Out-Null

        & (Join-Path $script:Root 'git/Update-ForkedRepos.ps1') -ConfigPath $forksJson `
            -WorkingDirectory $workingDirectory -ErrorAction SilentlyContinue 2>&1 | Out-Null

        # A successful merge must have been pushed back to origin.
        $originHead = git -C $originBare rev-parse master
        $originHead | Should -Be $upstreamHead
    }

    It 'aborts and does not push when the merge from upstream conflicts' {
        $upstreamBare = Join-Path $script:work 'upstream.git'
        $originBare = Join-Path $script:work 'origin.git'
        New-TestBareRepo -Path $upstreamBare
        New-TestBareRepo -Path $originBare

        $seed = Join-Path $script:work 'seed'
        New-TestGitRepo -Path $seed
        Add-TestCommit -Path $seed -File 'README.md' -Content 'v1' -Message init
        Push-Location $seed
        git push --quiet $upstreamBare HEAD:master
        git push --quiet $originBare HEAD:master
        Pop-Location

        # Upstream changes README.md.
        Add-TestCommit -Path $seed -File 'README.md' -Content 'upstream-change' -Message 'upstream edit'
        Push-Location $seed
        git push --quiet $upstreamBare HEAD:master
        Pop-Location

        # Origin diverges with a conflicting change to the same file, committed directly to origin.
        $originSeed = Join-Path $script:work 'origin-seed'
        Push-Location $script:work
        git clone --quiet $originBare origin-seed
        Pop-Location
        Push-Location $originSeed
        git config user.email t@example.com
        git config user.name Test
        Pop-Location
        Add-TestCommit -Path $originSeed -File 'README.md' -Content 'origin-change' -Message 'origin edit'
        Push-Location $originSeed
        git push --quiet origin HEAD:master
        $originConflictingHead = git rev-parse HEAD
        Pop-Location

        $forksJson = Join-Path $script:work 'forks.json'
        @(
            @{
                name           = 'test-fork'
                url            = $originBare
                upstream       = $upstreamBare
                localBranch    = 'master'
                upstreamBranch = 'master'
                mode           = 'fork'
                skip           = $false
            }
        ) | ConvertTo-Json | Set-Content -Path $forksJson

        $workingDirectory = Join-Path $script:work 'clones'
        New-Item -ItemType Directory -Path $workingDirectory -Force | Out-Null

        & (Join-Path $script:Root 'git/Update-ForkedRepos.ps1') -ConfigPath $forksJson `
            -WorkingDirectory $workingDirectory -ErrorAction SilentlyContinue 2>&1 | Out-Null

        # Origin must be untouched: the conflicting merge must never have been pushed.
        $originHead = git -C $originBare rev-parse master
        $originHead | Should -Be $originConflictingHead

        # The clone's working tree must not be left mid-merge.
        Test-Path (Join-Path $workingDirectory 'test-fork/.git/MERGE_HEAD') | Should -BeFalse
    }

    It 'does not checkout, merge, or push on an already-cloned repo under -WhatIf' {
        # This is the script's normal repeat-run case (the repo is already cloned), which is
        # exactly the path where the checkout used to run unconditionally, before the
        # merge/push ShouldProcess gate. -WhatIf must block that checkout too.
        $upstreamBare = Join-Path $script:work 'upstream.git'
        $originBare = Join-Path $script:work 'origin.git'
        New-TestBareRepo -Path $upstreamBare
        New-TestBareRepo -Path $originBare

        $seed = Join-Path $script:work 'seed'
        New-TestGitRepo -Path $seed
        Add-TestCommit -Path $seed -File 'README.md' -Content 'v1' -Message init
        Push-Location $seed
        git push --quiet $upstreamBare HEAD:master
        git push --quiet $originBare HEAD:master
        Pop-Location

        # Upstream progresses, same as a normal repeat run would see.
        Add-TestCommit -Path $seed -File 'feature.txt' -Content 'new upstream feature' -Message 'upstream progress'
        Push-Location $seed
        git push --quiet $upstreamBare HEAD:master
        Pop-Location

        $workingDirectory = Join-Path $script:work 'clones'
        New-Item -ItemType Directory -Path $workingDirectory -Force | Out-Null
        $target = Join-Path $workingDirectory 'test-fork'

        # Pre-existing clone: simulates a repeat run against a repo the script already knows.
        git clone --quiet $originBare $target
        # A remote-tracking ref that `git fetch --prune origin` would delete. It proves the
        # fetch is gated too, not just the checkout and the merge: --prune is a real local
        # mutation and both fetches talk to the network.
        git -C $originBare branch doomed master
        git -C $target fetch --quiet origin
        git -C $originBare branch -D doomed | Out-Null
        Push-Location $target
        git remote add upstream $upstreamBare
        # Leave the working tree on a DIFFERENT branch than forks.json's localBranch (master)
        # with its own unique commit, so an unconditional `git checkout master` would be a
        # real, detectable mutation of both the current branch and HEAD.
        git checkout --quiet -b scratch
        Set-Content -Path 'scratch.txt' -Value 'local work in progress'
        git add scratch.txt
        git commit --quiet -m 'local scratch work'
        $beforeBranch = git branch --show-current
        $beforeHead = git rev-parse HEAD
        Pop-Location
        $originHeadBefore = git -C $originBare rev-parse master

        $forksJson = Join-Path $script:work 'forks.json'
        @(
            @{
                name           = 'test-fork'
                url            = $originBare
                upstream       = $upstreamBare
                localBranch    = 'master'
                upstreamBranch = 'master'
                mode           = 'fork'
                skip           = $false
            }
        ) | ConvertTo-Json | Set-Content -Path $forksJson

        & (Join-Path $script:Root 'git/Update-ForkedRepos.ps1') -ConfigPath $forksJson `
            -WorkingDirectory $workingDirectory -WhatIf -ErrorAction SilentlyContinue 2>&1 | Out-Null

        Push-Location $target
        git branch --show-current | Should -Be $beforeBranch
        git rev-parse HEAD | Should -Be $beforeHead
        Pop-Location

        # Origin must not have received a push either.
        $originHeadAfter = git -C $originBare rev-parse master
        $originHeadAfter | Should -Be $originHeadBefore

        # The stale remote-tracking ref must survive: `fetch --prune origin` was gated.
        git -C $target rev-parse --verify --quiet refs/remotes/origin/doomed |
            Should -Not -BeNullOrEmpty
    }

    It 'refuses to merge and push when HEAD is not on the configured localBranch' {
        # The checkout and the merge/push sit behind separate ShouldProcess gates, so under
        # -Confirm an operator can answer N to the checkout and Y to the merge. Pester
        # cannot answer interactive confirmation prompts, so this reproduces the same end
        # state the other way: localBranch names a tag, `git checkout` succeeds into a
        # detached HEAD, and the merge/push would land on no branch at all.
        $upstreamBare = Join-Path $script:work 'upstream.git'
        $originBare = Join-Path $script:work 'origin.git'
        New-TestBareRepo -Path $upstreamBare
        New-TestBareRepo -Path $originBare

        $seed = Join-Path $script:work 'seed'
        New-TestGitRepo -Path $seed
        Add-TestCommit -Path $seed -File 'README.md' -Content 'v1' -Message init
        Push-Location $seed
        git push --quiet $upstreamBare HEAD:master
        git push --quiet $originBare HEAD:master
        Pop-Location

        # Upstream progresses, so a merge would really have something to bring in.
        Add-TestCommit -Path $seed -File 'feature.txt' -Content 'new upstream feature' -Message 'upstream progress'
        Push-Location $seed
        git push --quiet $upstreamBare HEAD:master
        Pop-Location

        $workingDirectory = Join-Path $script:work 'clones'
        New-Item -ItemType Directory -Path $workingDirectory -Force | Out-Null
        $target = Join-Path $workingDirectory 'test-fork'
        git clone --quiet $originBare $target
        git -C $target remote add upstream $upstreamBare
        git -C $target tag v1
        # Without this, a push from a detached HEAD fails on its own and the damage would
        # be hidden by luck. With it, an unguarded run really does land the wrong-branch
        # merge on origin/master - which is what the assertions below must rule out.
        git -C $target config remote.origin.push HEAD:refs/heads/master
        $originHeadBefore = git -C $originBare rev-parse master

        $forksJson = Join-Path $script:work 'forks.json'
        @(
            @{
                name           = 'test-fork'
                url            = $originBare
                upstream       = $upstreamBare
                localBranch    = 'v1'
                upstreamBranch = 'master'
                mode           = 'fork'
                skip           = $false
            }
        ) | ConvertTo-Json | Set-Content -Path $forksJson

        & (Join-Path $script:Root 'git/Update-ForkedRepos.ps1') -ConfigPath $forksJson `
            -WorkingDirectory $workingDirectory -WarningVariable forkWarnings `
            -WarningAction SilentlyContinue 2>&1 | Out-Null

        # Nothing merged, nothing pushed: this is the damage the guard exists to prevent.
        git -C $originBare rev-parse master | Should -Be $originHeadBefore
        Test-Path (Join-Path $target '.git/MERGE_HEAD') | Should -BeFalse

        # ...and it was the guard that stopped it, not some unrelated git failure.
        ($forkWarnings -join "`n") | Should -Match "expected 'v1'"
    }

    It 'merges two upstreams into two branches of one clone via the optional remote key' {
        # A fork that tracks two upstreams (one per local branch) is expressed as two
        # entries sharing a name, each naming its own remote. The second entry finds the
        # clone already present and must add its remote itself rather than assume
        # 'upstream' exists and points at the right place.
        $upstreamA = Join-Path $script:work 'upstream-a.git'
        $upstreamB = Join-Path $script:work 'upstream-b.git'
        $originBare = Join-Path $script:work 'origin.git'
        New-TestBareRepo -Path $upstreamA
        New-TestBareRepo -Path $upstreamB
        New-TestBareRepo -Path $originBare

        $seed = Join-Path $script:work 'seed'
        New-TestGitRepo -Path $seed
        Add-TestCommit -Path $seed -File 'README.md' -Content 'v1' -Message init
        Push-Location $seed
        git push --quiet $upstreamA HEAD:master
        git push --quiet $upstreamB HEAD:master
        git push --quiet $originBare HEAD:master
        git push --quiet $originBare HEAD:refs/heads/dev/b
        Pop-Location
        git -C $originBare symbolic-ref HEAD refs/heads/master

        Add-TestCommit -Path $seed -File 'a.txt' -Content 'from a' -Message 'upstream a progress'
        Push-Location $seed
        git push --quiet $upstreamA HEAD:master
        $headA = git rev-parse HEAD
        git reset --quiet --hard HEAD~1
        Pop-Location
        Add-TestCommit -Path $seed -File 'b.txt' -Content 'from b' -Message 'upstream b progress'
        Push-Location $seed
        git push --quiet $upstreamB HEAD:master
        $headB = git rev-parse HEAD
        Pop-Location

        $forksJson = Join-Path $script:work 'forks.json'
        @(
            @{ name = 'multi'; url = $originBare; upstream = $upstreamA; remote = 'upstream_a'
               localBranch = 'master'; upstreamBranch = 'master'; mode = 'fork'; skip = $false },
            @{ name = 'multi'; url = $originBare; upstream = $upstreamB; remote = 'upstream_b'
               localBranch = 'dev/b'; upstreamBranch = 'master'; mode = 'fork'; skip = $false }
        ) | ConvertTo-Json | Set-Content -Path $forksJson

        $workingDirectory = Join-Path $script:work 'clones'
        New-Item -ItemType Directory -Path $workingDirectory -Force | Out-Null

        & (Join-Path $script:Root 'git/Update-ForkedRepos.ps1') -ConfigPath $forksJson `
            -WorkingDirectory $workingDirectory -WarningVariable forkWarnings `
            -WarningAction SilentlyContinue 2>&1 | Out-Null

        ($forkWarnings -join "`n") | Should -BeNullOrEmpty
        git -C $originBare rev-parse master | Should -Be $headA
        git -C $originBare rev-parse dev/b  | Should -Be $headB
    }
}

Describe 'Update-AllRepos gone-upstream recovery' {
    BeforeEach {
        $script:work = Join-Path $TestDrive ([Guid]::NewGuid().ToString())
    }

    It 'recovers a checkout whose branch was squash-merged and deleted upstream, instead of reporting it failed' {
        # The everyday case for a squash-and-delete PR workflow. `git pull --ff-only` on a
        # branch with no upstream left fails, the script's try/catch used to turn that into
        # a "Failed:" line, and the operator was told a completed, merged PR was a broken
        # repository. Asserting only "did not fail" would pass against a script that
        # skipped the repo entirely, so the branch and HEAD are both checked.
        $fixture = New-GoneBranchFixture -Path $script:work -Squashed
        $expected = git -C $fixture.Remote rev-parse master

        $output = & (Join-Path $script:Root 'git/Update-AllRepos.ps1') -RootDirectory $fixture.ClonesRoot `
            -WarningVariable goneWarnings -WarningAction SilentlyContinue 6>&1

        git -C $fixture.Clone branch --show-current | Should -Be 'master'
        git -C $fixture.Clone rev-parse HEAD | Should -Be $expected
        ($output -join "`n") | Should -Not -Match 'Failed:'
        ($goneWarnings -join "`n") | Should -BeNullOrEmpty

        # Recovery alone must not delete anything: that is opt-in via -PruneMergedBranches.
        git -C $fixture.Clone branch --format='%(refname:short)' | Should -Contain 'feature'
    }

    It 'finds the default branch when the clone has no origin/HEAD' {
        # Old clones, and clones made with --no-checkout, have no origin/HEAD symbolic ref.
        # Update-CcmRefs already had a bug where the failed symbolic-ref call's *error text*
        # was passed to git as a branch name; the same trap is live here.
        $fixture = New-GoneBranchFixture -Path $script:work -Squashed -NoOriginHead

        & (Join-Path $script:Root 'git/Update-AllRepos.ps1') -RootDirectory $fixture.ClonesRoot `
            -WarningVariable headWarnings -WarningAction SilentlyContinue 6>&1 | Out-Null

        git -C $fixture.Clone branch --show-current | Should -Be 'master'
        ($headWarnings -join "`n") | Should -Not -Match 'not a symbolic ref'
    }

    It 'leaves a gone branch alone, with a warning, when its work never landed on master' {
        # An abandoned or force-deleted PR branch. The commits exist nowhere else, so
        # moving off the branch (and, with -PruneMergedBranches, deleting it) would be the
        # one genuinely destructive thing this script could do.
        $fixture = New-GoneBranchFixture -Path $script:work
        $before = git -C $fixture.Clone rev-parse HEAD

        & (Join-Path $script:Root 'git/Update-AllRepos.ps1') -RootDirectory $fixture.ClonesRoot `
            -PruneMergedBranches -WarningVariable unmergedWarnings -WarningAction SilentlyContinue 6>&1 | Out-Null

        git -C $fixture.Clone branch --show-current | Should -Be 'feature'
        git -C $fixture.Clone rev-parse HEAD | Should -Be $before
        git -C $fixture.Clone branch --format='%(refname:short)' | Should -Contain 'feature'
        ($unmergedWarnings -join "`n") | Should -Match 'not in'
    }

    It 'does not move a checkout that has uncommitted changes' {
        # Switching branches under someone's work in progress is silent damage: git will
        # happily carry a dirty file across, or refuse halfway and leave the repo in a
        # state the operator did not ask for.
        $fixture = New-GoneBranchFixture -Path $script:work -Squashed
        Set-Content -Path (Join-Path $fixture.Clone 'wip.txt') -Value 'uncommitted work'

        & (Join-Path $script:Root 'git/Update-AllRepos.ps1') -RootDirectory $fixture.ClonesRoot `
            -PruneMergedBranches -WarningVariable dirtyWarnings -WarningAction SilentlyContinue 6>&1 | Out-Null

        git -C $fixture.Clone branch --show-current | Should -Be 'feature'
        Get-Content (Join-Path $fixture.Clone 'wip.txt') | Should -Be 'uncommitted work'
        ($dirtyWarnings -join "`n") | Should -Match 'uncommitted'
    }

    It 'deletes the stale branch under -PruneMergedBranches, which git branch -d would refuse' {
        $fixture = New-GoneBranchFixture -Path $script:work -Squashed

        # Prove the premise first: git's own safe delete refuses this branch, because its
        # commits are unreachable from master even though the content is all there. If
        # this ever starts succeeding, the whole content-based check is unnecessary.
        git -C $fixture.Clone branch -d feature 2>&1 | Out-Null
        $LASTEXITCODE | Should -Not -Be 0

        & (Join-Path $script:Root 'git/Update-AllRepos.ps1') -RootDirectory $fixture.ClonesRoot `
            -PruneMergedBranches -WarningAction SilentlyContinue 6>&1 | Out-Null

        git -C $fixture.Clone branch --show-current | Should -Be 'master'
        git -C $fixture.Clone branch --format='%(refname:short)' | Should -Not -Contain 'feature'
    }

    It 'neither switches branches nor deletes under -WhatIf' {
        $fixture = New-GoneBranchFixture -Path $script:work -Squashed
        $before = git -C $fixture.Clone rev-parse HEAD

        & (Join-Path $script:Root 'git/Update-AllRepos.ps1') -RootDirectory $fixture.ClonesRoot `
            -PruneMergedBranches -WhatIf -WarningAction SilentlyContinue 6>&1 | Out-Null

        git -C $fixture.Clone branch --show-current | Should -Be 'feature'
        git -C $fixture.Clone rev-parse HEAD | Should -Be $before
        git -C $fixture.Clone branch --format='%(refname:short)' | Should -Contain 'feature'
    }
}
