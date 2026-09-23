#!/usr/bin/env pwsh
#Requires -Version 7.0
<#
.SYNOPSIS
    Fetches and fast-forwards every git repository in a directory.
.DESCRIPTION
    Walks each immediate subdirectory of -RootDirectory, fetches it with --prune and
    fast-forwards it.

    A checkout parked on a branch whose upstream has been deleted - the ordinary end
    state of a squash-merged pull request - cannot be fast-forwarded at all, because
    --prune has just removed the ref it tracks. Rather than reporting such a repository
    as failed, this returns it to its default branch when the branch's work has
    demonstrably landed there, and leaves it alone with a warning when it has not.
.PARAMETER RootDirectory
    Directory whose subdirectories are checkouts. Defaults to the current directory.
.PARAMETER InitSubmodules
    Also initialise submodules that have never been checked out.
.PARAMETER PruneMergedBranches
    After returning a checkout to its default branch, also delete the stale local
    branch. Off by default: deleting branches is the only irreversible thing this
    script does, and a leftover branch costs nothing.
.EXAMPLE
    ./git/Update-AllRepos.ps1 -RootDirectory C:\code -InitSubmodules
.EXAMPLE
    ./git/Update-AllRepos.ps1 -RootDirectory C:\code -PruneMergedBranches -WhatIf
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$RootDirectory = (Get-Location).Path,
    [switch]$InitSubmodules,
    [switch]$PruneMergedBranches
)

$ErrorActionPreference = 'Stop'

# When this script is invoked through a symlink on PATH (e.g. %HOME%\bin), PowerShell
# sets $PSScriptRoot to the symlink's directory, not the target's. Resolve the link so
# the module import points at the repository rather than wherever the link happens to live.
$ScriptRoot = if ($PSCommandPath -and (Get-Item $PSCommandPath).ResolvedTarget) {
    Split-Path (Get-Item $PSCommandPath).ResolvedTarget -Parent
}
else { $PSScriptRoot }

Import-Module (Join-Path $ScriptRoot '../Modules/ScriptUtils') -Force

$RootDirectory = (Resolve-Path $RootDirectory).Path
Write-Host "Scanning $RootDirectory (InitSubmodules: $InitSubmodules, PruneMergedBranches: $PruneMergedBranches)" -ForegroundColor Cyan
$failed = [System.Collections.Generic.List[string]]::new()

foreach ($dir in Get-ChildItem -Path $RootDirectory -Directory) {
    if (-not (Test-Path (Join-Path $dir.FullName '.git'))) { continue }

    Write-Host "--- $($dir.Name)" -ForegroundColor Cyan
    try {
        Use-Location -Path $dir.FullName -ScriptBlock {
            if ($PSCmdlet.ShouldProcess($dir.Name, 'fetch and fast-forward')) {
                Invoke-Git -Arguments @('fetch', '--all', '--prune')

                $branch = "$(Invoke-Git -Arguments @('branch', '--show-current') | Select-Object -First 1)".Trim()
                $track = ''
                if ($branch) {
                    # '[gone]' is git's own word for "this branch tracks an upstream that no
                    # longer exists" - the state --prune leaves behind once a merged PR's
                    # source branch is deleted on the server.
                    $trackOutput = Invoke-Git -Arguments @('for-each-ref', '--format=%(upstream:track)', "refs/heads/$branch") -AllowFailure
                    if ($LASTEXITCODE -eq 0) { $track = "$($trackOutput | Select-Object -First 1)".Trim() }
                }

                if ($track -ne '[gone]') {
                    Invoke-Git -Arguments @('pull', '--ff-only')
                }
                else {
                    # Never move a checkout out from under work in progress.
                    $dirty = Invoke-Git -Arguments @('status', '--porcelain') -AllowFailure
                    if ($LASTEXITCODE -ne 0) {
                        throw "git status failed: $($dirty -join ' ')"
                    }

                    if ($dirty) {
                        Write-Warning "$($dir.Name): '$branch' was deleted upstream, but the working tree has uncommitted changes - left alone."
                    }
                    else {
                        # Invoke-Git runs git with 2>&1, so a failed symbolic-ref returns
                        # git's error text rather than nothing. Only the exit code may
                        # decide here, or "fatal: ref refs/remotes/origin/HEAD is not a
                        # symbolic ref" ends up being handed to `git checkout` as a branch.
                        $defaultBranch = ''
                        $originHead = Invoke-Git -Arguments @('symbolic-ref', '--short', 'refs/remotes/origin/HEAD') -AllowFailure
                        if ($LASTEXITCODE -eq 0) {
                            $defaultBranch = "$($originHead | Select-Object -First 1)".Trim() -replace '^origin/', ''
                        }
                        if (-not $defaultBranch) {
                            # Old clones and --no-checkout clones have no origin/HEAD.
                            foreach ($candidate in @('master', 'main')) {
                                Invoke-Git -Arguments @('rev-parse', '--verify', '--quiet', "refs/remotes/origin/$candidate") -AllowFailure | Out-Null
                                if ($LASTEXITCODE -eq 0) { $defaultBranch = $candidate; break }
                            }
                        }

                        if (-not $defaultBranch) {
                            Write-Warning "$($dir.Name): '$branch' was deleted upstream and no default branch could be resolved - left alone."
                        }
                        elseif (-not (Test-GitBranchMerged -Branch $branch -Into "origin/$defaultBranch")) {
                            # An abandoned PR, or a branch deleted before it merged. Its
                            # commits exist nowhere else, so this is the one case where
                            # touching the checkout would destroy work.
                            Write-Warning "$($dir.Name): '$branch' was deleted upstream but its work is not in origin/$defaultBranch - left alone."
                        }
                        elseif ($PSCmdlet.ShouldProcess("$($dir.Name): $branch -> $defaultBranch", 'return to default branch after upstream merge')) {
                            Invoke-Git -Arguments @('checkout', $defaultBranch)
                            Invoke-Git -Arguments @('pull', '--ff-only')
                            Write-Host "    '$branch' was merged and deleted upstream; now on $defaultBranch" -ForegroundColor DarkGray

                            if ($PruneMergedBranches -and $PSCmdlet.ShouldProcess("$($dir.Name): $branch", 'delete merged local branch')) {
                                # -D rather than -d deliberately: git's -d check is the
                                # reachability one a squash merge defeats, so -d refuses
                                # exactly the branches this is here to clean up.
                                # Test-GitBranchMerged has already proved by content that
                                # the work landed - the check -d cannot make.
                                $deleted = Invoke-Git -Arguments @('branch', '-D', $branch) -AllowFailure
                                if ($LASTEXITCODE -ne 0) {
                                    # Usually: the branch is checked out in another worktree.
                                    Write-Warning "$($dir.Name): could not delete '$branch': $($deleted -join ' ')"
                                }
                            }
                        }
                    }
                }

                $submoduleArgs = @('submodule', 'update', '--recursive')
                if ($InitSubmodules) { $submoduleArgs += '--init' }
                Invoke-Git -Arguments $submoduleArgs
            }
        }
    }
    catch {
        Write-Warning "$($dir.Name): $($_.Exception.Message)"
        $failed.Add($dir.Name)
    }
}

if ($failed.Count -gt 0) {
    Write-Host "Failed: $($failed -join ', ')" -ForegroundColor Yellow
}
else {
    Write-Host 'All repositories updated.' -ForegroundColor Green
}
