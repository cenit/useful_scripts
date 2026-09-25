#!/usr/bin/env pwsh
#Requires -Version 7.0
<#
.SYNOPSIS
    Clones or refreshes the forked repositories defined in forks.json.
.DESCRIPTION
    Two modes per entry. "fork" keeps a long-lived clone with an
    "upstream" remote and merges upstream into the local branch. "mirror" does a
    throwaway --mirror clone of the upstream and pushes it wholesale.

    A merge conflict aborts that repository and moves on, rather than pushing a
    half-merged tree.

    A "fork" entry may set "remote" to name the upstream remote (default "upstream").
    Entries that share a name share one clone, so a fork that follows two upstreams -
    one per local branch - is written as two entries with different remotes and
    localBranch values. -Name then selects all of them.
.PARAMETER Name
    Process only the entry with this name.
.PARAMETER ConfigPath
    Path to forks.json. Defaults to the copy beside this script.
.PARAMETER WorkingDirectory
    Where clones live. Defaults to the current directory.
.EXAMPLE
    ./git/Update-ForkedRepos.ps1 -WhatIf
.EXAMPLE
    ./git/Update-ForkedRepos.ps1 -Name vcpkg_cenit
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$Name,
    [string]$ConfigPath,
    [string]$WorkingDirectory = (Get-Location).Path
)

$ErrorActionPreference = 'Stop'

# When this script is invoked through a symlink on PATH (e.g. %HOME%\bin), PowerShell
# sets $PSScriptRoot to the symlink's directory, not the target's. Resolve the link so
# the module import and forks.json point at the repository rather than wherever the link
# happens to live. The default is applied here rather than in param() because param
# defaults are evaluated before the body runs.
$ScriptRoot = if ($PSCommandPath -and (Get-Item $PSCommandPath).ResolvedTarget) {
    Split-Path (Get-Item $PSCommandPath).ResolvedTarget -Parent
}
else { $PSScriptRoot }

if (-not $ConfigPath) { $ConfigPath = Join-Path $ScriptRoot 'forks.json' }

Import-Module (Join-Path $ScriptRoot '../Modules/ScriptUtils') -Force

$repos = @(Get-Content $ConfigPath -Raw | ConvertFrom-Json)
if ($Name) { $repos = @($repos | Where-Object { $_.name -eq $Name }) }
if (-not $repos) { throw "No repository matched '$Name' in $ConfigPath." }

foreach ($repo in $repos) {
    if ($repo.skip) {
        Write-Host "Skipping $($repo.name)" -ForegroundColor Yellow
        continue
    }

    Write-Host "--- $($repo.name) [$($repo.mode)]" -ForegroundColor Cyan
    $target = Join-Path $WorkingDirectory $repo.name

    try {
        if ($repo.mode -eq 'mirror') {
            if (Test-Path $target) {
                if ($PSCmdlet.ShouldProcess($target, 'remove stale mirror clone')) {
                    Remove-Item -Recurse -Force $target
                }
            }
            if ($PSCmdlet.ShouldProcess($repo.name, 'mirror clone and push')) {
                Invoke-Git -Arguments @('clone', '--mirror', $repo.upstream, $target)
                Use-Location -Path $target -ScriptBlock {
                    Invoke-Git -Arguments @('remote', 'set-url', '--push', 'origin', $repo.url)
                    Invoke-Git -Arguments @('push', '--mirror')
                }
                Remove-Item -Recurse -Force $target
            }
            continue
        }

        if (-not (Test-Path $target)) {
            if ($PSCmdlet.ShouldProcess($repo.name, 'clone')) {
                Invoke-Git -Arguments @('clone', $repo.url, $target)
            }
            else { continue }
        }

        $remote = if ($repo.PSObject.Properties['remote'] -and $repo.remote) { $repo.remote } else { 'upstream' }

        Use-Location -Path $target -ScriptBlock {
            # Added here rather than only after a fresh clone: a later entry sharing this
            # clone brings its own remote, and an existing clone may predate this entry.
            $null = Invoke-Git -Arguments @('remote', 'get-url', $remote) -AllowFailure
            if ($LASTEXITCODE -ne 0 -and $PSCmdlet.ShouldProcess($repo.name, "add remote $remote")) {
                Invoke-Git -Arguments @('remote', 'add', $remote, $repo.upstream)
            }

            # --prune deletes remote-tracking refs and both fetches talk to the network,
            # so neither may run under -WhatIf.
            if ($PSCmdlet.ShouldProcess($repo.name, 'fetch --prune origin')) {
                Invoke-Git -Arguments @('fetch', '--prune', 'origin')
            }

            # checkout is a real local mutation (it can move HEAD and the working tree) on
            # what is normally a repeat run against an already-cloned repo, so it needs its
            # own gate rather than running unconditionally before the merge/push gate below.
            if ($PSCmdlet.ShouldProcess($repo.name, "checkout $($repo.localBranch)")) {
                Invoke-Git -Arguments @('checkout', $repo.localBranch)
            }

            if ($PSCmdlet.ShouldProcess($repo.name, "fetch $remote")) {
                Invoke-Git -Arguments @('fetch', $remote)
            }

            if ($PSCmdlet.ShouldProcess($repo.name, "merge $remote/$($repo.upstreamBranch) and push")) {
                # The checkout above has its own gate, and under -Confirm an operator can
                # decline it and still accept this one - or localBranch may name a tag,
                # leaving a detached HEAD. Either way the merge and push would land on
                # whatever happens to be checked out. Verify before mutating anything.
                $current = "$(Invoke-Git -Arguments @('branch', '--show-current') | Select-Object -First 1)".Trim()
                if ($current -ne $repo.localBranch) {
                    throw "on '$current', expected '$($repo.localBranch)'; skipping merge/push"
                }

                $null = Invoke-Git -Arguments @('merge', "$remote/$($repo.upstreamBranch)") -AllowFailure
                if ($LASTEXITCODE -ne 0) {
                    Invoke-Git -Arguments @('merge', '--abort') -AllowFailure | Out-Null
                    throw "merge from $remote/$($repo.upstreamBranch) conflicted; merge aborted, nothing pushed"
                }
                Invoke-Git -Arguments @('push')
            }
        }
    }
    catch {
        Write-Warning "$($repo.name): $($_.Exception.Message)"
    }
}

Write-Host 'Done.' -ForegroundColor Green
