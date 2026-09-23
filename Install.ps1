#!/usr/bin/env pwsh
#Requires -Version 7.0
<#
.SYNOPSIS
    Makes ScriptUtils available in every PowerShell session.
.DESCRIPTION
    Appends a guarded Import-Module block to your profile, delimited by marker
    comments so re-running is a no-op and -Uninstall removes exactly this block and
    nothing else.

    The .ps1 entrypoints under git/, azuredevops/, aws/ and agent/ stay runnable by
    path whether or not you install.
.PARAMETER ProfilePath
    Profile to modify. Defaults to $PROFILE.CurrentUserAllHosts.
.PARAMETER Uninstall
    Remove the block instead of adding it.
.EXAMPLE
    ./Install.ps1
.EXAMPLE
    ./Install.ps1 -Uninstall
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$ProfilePath = $PROFILE.CurrentUserAllHosts,
    [switch]$Uninstall
)

$ErrorActionPreference = 'Stop'

$startMarker = '# >>> useful_scripts >>>'
$endMarker   = '# <<< useful_scripts <<<'
$modulePath  = Join-Path $PSScriptRoot 'Modules/ScriptUtils'

$existing = if (Test-Path $ProfilePath) { Get-Content $ProfilePath -Raw } else { '' }

# Strip any previous block first; this is what makes install idempotent.
$pattern = '(?ms)^' + [regex]::Escape($startMarker) + '.*?' + [regex]::Escape($endMarker) + '\r?\n?'
$stripped = [regex]::Replace($existing, $pattern, '')

if ($Uninstall) {
    if ($PSCmdlet.ShouldProcess($ProfilePath, 'remove the useful_scripts block')) {
        Set-Content -Path $ProfilePath -Value $stripped.TrimEnd() -NoNewline
        Write-Host "Removed the useful_scripts block from $ProfilePath" -ForegroundColor Green
    }
    return
}

$block = @"
$startMarker
Import-Module '$modulePath' -ErrorAction SilentlyContinue
$endMarker
"@

$new = if ($stripped.Trim()) { $stripped.TrimEnd() + "`n`n" + $block } else { $block }

if ($PSCmdlet.ShouldProcess($ProfilePath, 'add the useful_scripts import block')) {
    $dir = Split-Path $ProfilePath -Parent
    if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Set-Content -Path $ProfilePath -Value $new
    Write-Host "Installed to $ProfilePath" -ForegroundColor Green
    Write-Host 'Open a new session, or run:' -ForegroundColor DarkGray
    Write-Host "  Import-Module '$modulePath' -Force" -ForegroundColor DarkGray
}
