#!/usr/bin/env pwsh
BeforeAll {
    Import-Module (Join-Path (Split-Path $PSScriptRoot -Parent) 'Modules/ScriptUtils') -Force

    # Real repositories, never a mocked git. The entire reason this function exists is
    # that it disagrees with `git branch --merged` about squash-merged branches, and
    # only real commits carrying real patch-ids can demonstrate that disagreement.
    function New-MergeFixture {
        [CmdletBinding(SupportsShouldProcess)]
        param([Parameter(Mandatory)][string]$Path)
        if (-not $PSCmdlet.ShouldProcess($Path, 'init merge fixture repo')) { return }
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        Push-Location $Path
        try {
            git init --quiet
            # Pin the initial branch name explicitly rather than relying on init.defaultBranch,
            # which differs between git versions and between developer machines.
            git symbolic-ref HEAD refs/heads/master
            git config user.email t@example.com
            git config user.name Test
            Set-Content -Path 'README.md' -Value 'v1'
            git add README.md
            git commit --quiet -m init
        }
        finally { Pop-Location }
    }

    function Add-FixtureCommit {
        param(
            [Parameter(Mandatory)][string]$Path,
            [Parameter(Mandatory)][string]$File,
            [Parameter(Mandatory)][string]$Content,
            [Parameter(Mandatory)][string]$Message
        )
        Push-Location $Path
        try {
            Set-Content -Path $File -Value $Content
            git add $File
            git commit --quiet -m $Message
        }
        finally { Pop-Location }
    }
}

Describe 'Test-GitBranchMerged' {
    BeforeEach {
        $script:repo = Join-Path $TestDrive ([Guid]::NewGuid().ToString())
        New-MergeFixture -Path $script:repo
    }

    It 'reports a squash-merged branch as merged, where git branch --merged does not' {
        # The load-bearing case, and the whole reason for the function: an ADO squash
        # merge replaces the branch's commits with one new commit that has a different
        # SHA and no parent link back to the branch. Reachability therefore says "not
        # merged" about work that is provably already in, which is what makes
        # `git branch -d` refuse and what used to strand these checkouts.
        Push-Location $script:repo
        try {
            git checkout --quiet -b feature
        }
        finally { Pop-Location }
        Add-FixtureCommit -Path $script:repo -File 'feature.txt' -Content 'work' -Message 'feature part 1'

        Push-Location $script:repo
        try {
            git checkout --quiet master
        }
        finally { Pop-Location }
        # The squash: same resulting content, one commit, unrelated SHA.
        Add-FixtureCommit -Path $script:repo -File 'feature.txt' -Content 'work' -Message 'Merged PR 1: feature'

        Push-Location $script:repo
        try {
            Test-GitBranchMerged -Branch 'feature' -Into 'master' | Should -BeTrue

            # ...and git's own reachability answer is the opposite. Without this
            # assertion the test would still pass against a naive implementation that
            # just shelled out to `git branch --merged`, which is precisely the
            # implementation that does not work.
            $reachable = git branch --merged master --format='%(refname:short)'
            $reachable | Should -Not -Contain 'feature'
        }
        finally { Pop-Location }
    }

    It 'reports a branch whose work never landed as not merged' {
        # The abandoned-PR case. Answering "merged" here would delete real work.
        Push-Location $script:repo
        try {
            git checkout --quiet -b abandoned
        }
        finally { Pop-Location }
        Add-FixtureCommit -Path $script:repo -File 'abandoned.txt' -Content 'never merged' -Message 'wip'

        Push-Location $script:repo
        try {
            Test-GitBranchMerged -Branch 'abandoned' -Into 'master' | Should -BeFalse
        }
        finally { Pop-Location }
    }

    It 'reports a branch that landed as a real merge commit as merged' {
        # Not every PR is squashed - a plain merge keeps the original SHAs, and the
        # cheap reachability short-circuit must handle it without the patch-id probe.
        Push-Location $script:repo
        try {
            git checkout --quiet -b real-merge
        }
        finally { Pop-Location }
        Add-FixtureCommit -Path $script:repo -File 'merged.txt' -Content 'work' -Message 'work'

        Push-Location $script:repo
        try {
            git checkout --quiet master
            git merge --quiet --no-ff -m 'Merge pull request 1' real-merge
            Test-GitBranchMerged -Branch 'real-merge' -Into 'master' | Should -BeTrue
        }
        finally { Pop-Location }
    }

    It 'reports a branch carrying no commits of its own as merged' {
        # Guards the empty-patch edge of the commit-tree probe: replaying a branch that
        # equals its own merge base produces a commit with an empty diff, and an empty
        # patch has no patch-id for `git cherry` to match. Without the reachability
        # short-circuit this returns "not merged" and the stale branch is never cleaned.
        Push-Location $script:repo
        try {
            git branch stale-copy master
            Test-GitBranchMerged -Branch 'stale-copy' -Into 'master' | Should -BeTrue
        }
        finally { Pop-Location }
    }

    It 'reports a branch as not merged when only part of its work landed' {
        # A squash-merged branch that then gained a new local commit. The probe replays
        # the branch as a single patch, so the extra commit makes that patch differ from
        # the squashed one on master - which must read as "not merged", because deleting
        # here would lose the commit that came after the PR.
        Push-Location $script:repo
        try {
            git checkout --quiet -b partial
        }
        finally { Pop-Location }
        Add-FixtureCommit -Path $script:repo -File 'landed.txt' -Content 'work' -Message 'landed work'

        Push-Location $script:repo
        try {
            git checkout --quiet master
        }
        finally { Pop-Location }
        Add-FixtureCommit -Path $script:repo -File 'landed.txt' -Content 'work' -Message 'Merged PR 2: landed work'

        Push-Location $script:repo
        try {
            git checkout --quiet partial
        }
        finally { Pop-Location }
        Add-FixtureCommit -Path $script:repo -File 'extra.txt' -Content 'after the PR' -Message 'local follow-up'

        Push-Location $script:repo
        try {
            Test-GitBranchMerged -Branch 'partial' -Into 'master' | Should -BeFalse
        }
        finally { Pop-Location }
    }

    It 'returns false instead of throwing when the branch does not exist' {
        # Every failure path must fall to "not merged". A caller is about to decide
        # whether to delete a branch, so an error that reads as "merged" destroys work,
        # while an error that reads as "not merged" merely leaves a branch behind.
        Push-Location $script:repo
        try {
            { Test-GitBranchMerged -Branch 'no-such-branch' -Into 'master' } | Should -Not -Throw
            Test-GitBranchMerged -Branch 'no-such-branch' -Into 'master' | Should -BeFalse
        }
        finally { Pop-Location }
    }
}
