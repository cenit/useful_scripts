#!/usr/bin/env pwsh
<#
    These scripts are placed on PATH as symlinks in %HOME%\bin so they can be run
    by bare name from any directory. PowerShell sets $PSScriptRoot to the
    *symlink's* directory, not the target's, so any path derived from
    $PSScriptRoot silently points into the symlink's folder instead of the
    repository. That breaks the module import, the forks.json lookup, and
    Update-CcmRefs' default scan root.
#>

$script:Root = Split-Path $PSScriptRoot -Parent
$script:ModuleImporters = @(
    'git/Update-AllRepos.ps1'
    'git/Update-CcmRefs.ps1'
    'git/Update-ForkedRepos.ps1'
    'azuredevops/Export-BuildValidationReport.ps1'
)

# Symlink creation needs Developer Mode or elevation; skip the behavioural test
# rather than fail the suite where neither is available. This MUST be evaluated at
# top level: Pester resolves -Skip: during the discovery pass, before any
# BeforeAll runs, so a value set in BeforeAll would always read $null and the
# test would silently skip every time.
$script:CanSymlink = $false
$script:probeDir = Join-Path ([System.IO.Path]::GetTempPath()) ("symcap-" + [guid]::NewGuid().ToString('N').Substring(0, 8))
try {
    New-Item -ItemType Directory -Path $script:probeDir -Force -ErrorAction Stop | Out-Null
    $probeTarget = Join-Path $script:probeDir 'target.txt'
    Set-Content -Path $probeTarget -Value 'x'
    New-Item -ItemType SymbolicLink -Path (Join-Path $script:probeDir 'link.txt') -Target $probeTarget -ErrorAction Stop | Out-Null
    $script:CanSymlink = $true
}
catch {
    $script:CanSymlink = $false
}
finally {
    Remove-Item $script:probeDir -Recurse -Force -ErrorAction SilentlyContinue
}

BeforeAll {
    $script:Root = Split-Path $PSScriptRoot -Parent
}

Describe 'Scripts that import ScriptUtils resolve their own path through a symlink' {
    It '<_> resolves the script directory via ResolvedTarget, not bare $PSScriptRoot' -ForEach $script:ModuleImporters {
        $content = Get-Content (Join-Path $script:Root $_) -Raw

        # It must consult the resolved symlink target...
        $content | Should -Match 'ResolvedTarget'

        # ...and must not import the module off the unresolved $PSScriptRoot.
        $content | Should -Not -Match "Import-Module \(Join-Path \`$PSScriptRoot '\.\./Modules/ScriptUtils'\)"
    }
}

Describe 'Update-AllRepos invoked through a symlink' {
    It 'imports ScriptUtils successfully' -Skip:(-not $script:CanSymlink) {
        $target = Join-Path $script:Root 'git/Update-AllRepos.ps1'
        $linkDir = Join-Path $TestDrive 'bin'
        New-Item -ItemType Directory -Path $linkDir -Force | Out-Null
        $link = Join-Path $linkDir 'Update-AllRepos.ps1'
        New-Item -ItemType SymbolicLink -Path $link -Target $target -ErrorAction Stop | Out-Null

        # An empty directory: the script imports the module, finds no repos, exits.
        $empty = Join-Path $TestDrive 'empty'
        New-Item -ItemType Directory -Path $empty -Force | Out-Null

        $output = & pwsh -NoProfile -File $link -RootDirectory $empty 2>&1 | Out-String

        $output | Should -Not -Match 'no valid module file'
        $output | Should -Not -Match 'ScriptUtils.*was not loaded'
        $LASTEXITCODE | Should -Be 0
    }
}
