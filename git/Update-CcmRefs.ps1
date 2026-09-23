#!/usr/bin/env pwsh
#Requires -Version 7.0
<#
.SYNOPSIS
    Bumps the CCM submodule pointer across every cloned project in a directory.
.DESCRIPTION
    Walks each immediate subdirectory of -RootDirectory, pulls it, and if it has a
    CCM submodule (named ccm, ci or cmake), fast-forwards that submodule to the tip
    of its default branch and commits the new pointer.

    Repositories with no such submodule are skipped rather than committed, and every
    git call is checked, so a failure in one repository does not silently corrupt
    the next.
.PARAMETER RootDirectory
    Directory whose subdirectories are the project checkouts. Defaults to the parent
    of this repository, matching the historical layout.
.PARAMETER SkipCcmUpdate
    Pull the repositories but leave submodule pointers alone.
.EXAMPLE
    ./git/Update-CcmRefs.ps1 -WhatIf
.EXAMPLE
    ./git/Update-CcmRefs.ps1 -RootDirectory C:\code
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$RootDirectory,
    [switch]$SkipCcmUpdate
)

$ErrorActionPreference = 'Stop'

# When this script is invoked through a symlink on PATH (e.g. %HOME%\bin), PowerShell
# sets $PSScriptRoot to the symlink's directory, not the target's. Resolve the link so
# the module import and the default scan root point at the repository rather than
# wherever the link happens to live. Defaults are applied here rather than in param()
# because param defaults are evaluated before the body runs.
$ScriptRoot = if ($PSCommandPath -and (Get-Item $PSCommandPath).ResolvedTarget) {
    Split-Path (Get-Item $PSCommandPath).ResolvedTarget -Parent
}
else { $PSScriptRoot }

if (-not $RootDirectory) { $RootDirectory = Join-Path $ScriptRoot '..' '..' }

Import-Module (Join-Path $ScriptRoot '../Modules/ScriptUtils') -Force

$RootDirectory = (Resolve-Path $RootDirectory).Path
Write-Host "Scanning $RootDirectory (SkipCcmUpdate: $SkipCcmUpdate)" -ForegroundColor Cyan

$submoduleNames = @('ccm', 'ci', 'cmake')

foreach ($dir in Get-ChildItem -Path $RootDirectory -Directory) {
    if (-not (Test-Path (Join-Path $dir.FullName '.git'))) {
        Write-Verbose "Skipping $($dir.Name): not a git repository."
        continue
    }

    Write-Host "--- $($dir.Name)" -ForegroundColor Cyan
    try {
        Use-Location -Path $dir.FullName -ScriptBlock {
            if ($PSCmdlet.ShouldProcess($dir.Name, 'git pull')) {
                Invoke-Git -Arguments @('pull', '--ff-only')
                Invoke-Git -Arguments @('submodule', 'update', '--recursive')
            }

            if ($SkipCcmUpdate) { return }

            foreach ($name in $submoduleNames) {
                $sub = Join-Path $dir.FullName $name
                if (-not (Test-Path (Join-Path $sub '.git'))) { continue }

                Write-Host "    submodule: $name" -ForegroundColor DarkGray
                Use-Location -Path $sub -ScriptBlock {
                    # Invoke-Git runs git with 2>&1, so on failure its *return value* is
                    # git's error text, not $null. Testing the output for emptiness can
                    # therefore never select the fallback, and would feed
                    # "fatal: ref refs/remotes/origin/HEAD is not a symbolic ref" straight
                    # into `git checkout`. The exit code is the only reliable signal.
                    $originHead = Invoke-Git -Arguments @('symbolic-ref', '--short', 'refs/remotes/origin/HEAD') -AllowFailure
                    $branch = if ($LASTEXITCODE -eq 0) {
                        "$($originHead | Select-Object -First 1)".Trim() -replace '^origin/', ''
                    }
                    else { '' }
                    if (-not $branch) { $branch = 'master' }
                    if ($PSCmdlet.ShouldProcess("$name -> $branch", 'checkout and pull')) {
                        Invoke-Git -Arguments @('checkout', $branch)
                        Invoke-Git -Arguments @('pull', '--ff-only')
                    }
                }

                # Only commit when the pointer actually moved. Same idiom hazard as the
                # symbolic-ref call above: a failed `git status` returns its error text,
                # which reads as "dirty" and would commit and push on the strength of an
                # error. Check the exit code first and let a real failure surface.
                $status = Invoke-Git -Arguments @('status', '--porcelain', '--', $name) -AllowFailure
                if ($LASTEXITCODE -ne 0) {
                    throw "git status failed for submodule '$name': $($status -join ' ')"
                }
                if (-not $status) {
                    Write-Host "    already current" -ForegroundColor DarkGray
                    continue
                }

                if ($PSCmdlet.ShouldProcess("$($dir.Name)/$name", 'commit and push submodule bump')) {
                    Invoke-Git -Arguments @('add', $name)
                    Invoke-Git -Arguments @('commit', '-m', "Update $name submodule")
                    Invoke-Git -Arguments @('push')
                }
            }
        }
    }
    catch {
        Write-Warning "$($dir.Name): $($_.Exception.Message)"
    }
}

Write-Host 'Done.' -ForegroundColor Green
