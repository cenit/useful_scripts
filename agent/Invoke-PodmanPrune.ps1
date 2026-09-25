#!/usr/bin/env pwsh
#Requires -Version 7.0
<#
.SYNOPSIS
    Weekly podman image-cache prune for this self-hosted Azure DevOps agent.

.DESCRIPTION
    An unattended build agent accumulates dead image layers indefinitely. Left
    alone the store grows until the disk fills, and a disk-full event silently
    truncates a file inside a cached layer - damage that only surfaces later as
    "file integrity checksum failed" when podman reads the layer back to push it.

    Keeps a week of warm cache (--filter until=168h) so normal builds stay fast.
    Always exits 0: this is opportunistic maintenance and must never surface as a
    failed scheduled task.

.PARAMETER LogPath
    Where to append the run log. Defaults to podman-weekly-prune.log next to this
    script. Overridable so tests can point it at a scratch directory instead of
    the deployed script's own folder.
.PARAMETER PodmanPath
    Path to podman.exe. Left empty, it is discovered: PATH first, then the
    per-user and Program Files install locations, because an agent has one or the
    other and a hardcoded per-user path made this script skip silently on a
    system-wide install. Pass it explicitly to pin a binary, or to point at a
    nonexistent path so tests exercise the "podman not found" skip branch without
    touching a real image store.
.PARAMETER KeepHours
    Minimum age, in hours, before an unused image is eligible for pruning.
    Defaults to 168 (one week).

.NOTES
    Repo copy: this file is versioned in useful_scripts; the deployed copy lives
    on each Windows build agent at C:\Users\<agentuser>\scripts\. If you edit the
    repo copy, re-copy it to the agent (the scheduled task points at the deployed
    path, so no re-registration is needed).

    Full deployment instructions, including first-time setup, migrating an agent
    from the old podman-weekly-prune.ps1 filename, and verification steps, live in
    agent/README.md.

    If the store is ALREADY corrupted (push fails with "file integrity checksum
    failed"), a prune is not enough - the store metadata is damaged too and the
    prune walks it. Use agent/Reset-PodmanMachine.ps1 instead.
#>
[CmdletBinding()]
param(
    [string]$LogPath = (Join-Path $PSScriptRoot 'podman-weekly-prune.log'),
    [string]$PodmanPath,
    [int]$KeepHours = 168
)

$ErrorActionPreference = 'Stop'
$logPath = $LogPath

function Write-PruneLog([string]$Message) {
    $line = "{0}  {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message
    Write-Host $line
    Add-Content -Path $logPath -Value $line -ErrorAction SilentlyContinue
}

function Get-PodmanCandidatePath {
    # Podman installs either per-user (the winget default) or system-wide under
    # Program Files, and an agent that has one does not have the other. Probing
    # PATH first honours whatever the operator actually has; the explicit paths
    # cover a service account whose PATH does not carry it.
    #
    # The roots are read defensively: this repo's suite also runs on Linux, where
    # both env vars are null and Join-Path would throw on a null -Path.
    [OutputType([string])]
    param()

    $onPath = Get-Command -Name 'podman.exe' -CommandType Application -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if ($onPath) { return $onPath.Source }

    foreach ($known in @(
            @{ Root = $env:LOCALAPPDATA; Leaf = 'Programs\Podman\podman.exe' },
            @{ Root = $env:ProgramFiles; Leaf = 'RedHat\Podman\podman.exe' }
        )) {
        if (-not $known.Root) { continue }
        $candidate = Join-Path $known.Root $known.Leaf
        if (Test-Path $candidate) { return $candidate }
    }
    return $null
}

try {
    # Keep the log from growing without bound.
    if ((Test-Path $logPath) -and ((Get-Item $logPath).Length -gt 1MB)) {
        Set-Content -Path $logPath -Value (Get-Content $logPath -Tail 500)
    }

    Write-PruneLog '--- weekly prune starting ---'

    # Never fight a running pipeline job: prune takes the image-store lock, so it
    # would either block the build or be blocked by it.
    if (Get-Process -Name 'Agent.Worker' -ErrorAction SilentlyContinue) {
        Write-PruneLog 'SKIP: a pipeline job is running (Agent.Worker active).'
        exit 0
    }

    # An explicit -PodmanPath is honoured verbatim, including a nonexistent one,
    # so the skip branch stays reachable from a test without a real image store.
    $podman = if ($PodmanPath) { $PodmanPath } else { Get-PodmanCandidatePath }
    if (-not $podman -or -not (Test-Path $podman)) {
        Write-PruneLog ("SKIP: podman not found ({0})" -f $(if ($PodmanPath) { $PodmanPath } else { 'not on PATH, nor in the per-user or Program Files install locations' }))
        exit 0
    }

    $running = & $podman machine list --format json 2>&1 | ConvertFrom-Json | Where-Object { $_.Running }
    if (-not $running) {
        Write-PruneLog 'SKIP: no podman machine is running.'
        exit 0
    }

    Write-PruneLog ('before: ' + ((& $podman system df 2>&1 | Select-Object -Skip 1) -join ' | '))

    $removed = & $podman image prune -a -f --filter "until=${KeepHours}h" 2>&1
    Write-PruneLog ("prune exit={0}, entries removed={1}" -f $LASTEXITCODE, ($removed | Measure-Object).Count)

    Write-PruneLog ('after:  ' + ((& $podman system df 2>&1 | Select-Object -Skip 1) -join ' | '))
    Write-PruneLog '--- weekly prune finished ---'
}
catch {
    Write-PruneLog "ERROR: $($_.Exception.Message)"
}
exit 0
