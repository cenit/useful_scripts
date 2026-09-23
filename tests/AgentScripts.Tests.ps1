#!/usr/bin/env pwsh
# NOTE: these path variables are assigned twice on purpose.
# Pester evaluates `-ForEach` arguments during the discovery pass, before any
# BeforeAll body has run, so the plain top-level assignment below (not inside
# BeforeAll) is what makes -ForEach see real paths instead of $null. But
# top-level assignments outside a block do not survive into the later Run
# pass, so direct `$script:...` references inside a plain `It` body (the ones
# below that don't use -ForEach) would see $null unless the same assignment
# also runs from a BeforeAll, which Pester re-invokes just before Run.
$script:Root  = Split-Path $PSScriptRoot -Parent
$script:Prune = Join-Path $script:Root 'agent/Invoke-PodmanPrune.ps1'
$script:Reset = Join-Path $script:Root 'agent/Reset-PodmanMachine.ps1'

BeforeAll {
    $script:Root  = Split-Path $PSScriptRoot -Parent
    $script:Prune = Join-Path $script:Root 'agent/Invoke-PodmanPrune.ps1'
    $script:Reset = Join-Path $script:Root 'agent/Reset-PodmanMachine.ps1'
}

Describe 'Agent scripts' {
    It '<_> parses without error' -ForEach @($script:Prune, $script:Reset) {
        $errors = $null
        [System.Management.Automation.Language.Parser]::ParseFile($_, [ref]$null, [ref]$errors) | Out-Null
        $errors | Should -BeNullOrEmpty
    }

    It '<_> is self-contained (imports no repo module)' -ForEach @($script:Prune, $script:Reset) {
        (Get-Content $_ -Raw) | Should -Not -Match 'ScriptUtils'
    }

    It '<_> requires PowerShell 7, not 5.1' -ForEach @($script:Prune, $script:Reset) {
        $content = Get-Content $_ -Raw
        $content | Should -Not -Match '#Requires -Version 5\.1'
        $content | Should -Match '#Requires -Version 7\.0'
    }
}

Describe 'Invoke-PodmanPrune' {
    It 'always exits zero so a scheduled task never reports failure' {
        (Get-Content $script:Prune -Raw) | Should -Match '(?s)catch\s*\{.*\}\s*exit 0'
    }

    It 'skips while a pipeline job is running' {
        (Get-Content $script:Prune -Raw) | Should -Match 'Agent\.Worker'
    }

    It 'runs to completion on a machine with no podman' {
        & pwsh -NoProfile -File $script:Prune -LogPath (Join-Path $TestDrive 'p.log') -PodmanPath (Join-Path $TestDrive 'no-such-podman.exe') | Out-Null
        $LASTEXITCODE | Should -Be 0
    }
}

Describe 'Reset-PodmanMachine' {
    It 'declares SupportsShouldProcess' {
        (Get-Content $script:Reset -Raw) | Should -Match 'SupportsShouldProcess'
    }

    It 'has ConfirmImpact High because it destroys the image store' {
        (Get-Content $script:Reset -Raw) | Should -Match "ConfirmImpact\s*=\s*'High'"
    }

    It 'fails with an actionable message when podman is nowhere to be found' {
        # -PodmanPath is honoured verbatim, so this never touches a real install.
        $stderr = & pwsh -NoProfile -Command "& '$script:Reset' -StartOnly -PodmanPath '$(Join-Path $TestDrive 'no-such-podman.exe')'" 2>&1 |
            Out-String
        $stderr | Should -Match 'podman\.exe not found'
        $stderr | Should -Match '-PodmanPath'
    }
}

Describe 'podman discovery' {
    # Regression: both scripts hardcoded the per-user install path, so on a machine
    # with a system-wide install Reset-PodmanMachine threw and Invoke-PodmanPrune
    # skipped silently while reporting success.
    It '<_> does not hardcode the per-user path as the only candidate' -ForEach @($script:Prune, $script:Reset) {
        $content = Get-Content $_ -Raw
        $content | Should -Match 'Get-Command -Name ''podman\.exe'''
        $content | Should -Match 'ProgramFiles'
    }

    It '<_> exposes -PodmanPath so an operator can pin the binary' -ForEach @($script:Prune, $script:Reset) {
        (Get-Content $_ -Raw) | Should -Match '\[string\]\$PodmanPath'
    }
}

Describe 'agent/README.md' {
    It 'documents the scheduled task re-registration' {
        $readme = Get-Content (Join-Path $script:Root 'agent/README.md') -Raw
        $readme | Should -Match 'Unregister-ScheduledTask'
        $readme | Should -Match 'Invoke-PodmanPrune\.ps1'
    }
}
