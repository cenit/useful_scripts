#!/usr/bin/env pwsh
#Requires -Version 7.0
<#
.SYNOPSIS
    Recovers a wedged or corrupted rootless podman machine on a build agent.
.DESCRIPTION
    A disk-full event truncates a file inside a cached layer. The damage only
    surfaces later as "file integrity checksum failed" when podman reads the layer
    back to push it. A prune does not help at that point: the store metadata is
    damaged too, and the prune walks that metadata.

    The only reliable recovery is a full store reset inside the machine. That
    destroys every cached image, so the next build is cold.

    Use -StartOnly first: the local machine is slow rather than broken more often
    than not, and a patient restart avoids throwing the cache away needlessly.
.PARAMETER MachineName
    Podman machine to operate on. Defaults to podman-machine-default.
.PARAMETER User
    Rootless user *inside* the WSL machine, which podman's WSL provider provisions
    as literally "user" - not the Windows account name. Override only if the
    machine's RemoteUsername (see ~/.config/containers/podman/machine/wsl/<machine>.json)
    says otherwise.
.PARAMETER StartOnly
    Attempt a patient start and report health. Never resets.
.PARAMETER TimeoutSeconds
    How long to wait for the machine to report running. Defaults to 180.
.PARAMETER PodmanPath
    Path to podman.exe. Left empty, it is discovered: PATH first, then the
    per-user and Program Files install locations. Pass it explicitly to pin a
    specific binary.
.EXAMPLE
    ./agent/Reset-PodmanMachine.ps1 -StartOnly
.EXAMPLE
    ./agent/Reset-PodmanMachine.ps1 -WhatIf
#>
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param(
    [string]$MachineName = 'podman-machine-default',
    [string]$User = 'user',
    [switch]$StartOnly,
    [int]$TimeoutSeconds = 180,
    [string]$PodmanPath
)

$ErrorActionPreference = 'Stop'

function Write-Step([string]$Message) {
    Write-Host ('{0}  {1}' -f (Get-Date -Format 'HH:mm:ss'), $Message) -ForegroundColor Cyan
}

function Get-PodmanCandidatePath {
    # Podman installs either per-user (the winget default) or system-wide under
    # Program Files, and an agent that has one does not have the other. Probing
    # PATH first honours whatever the operator actually has; the explicit paths
    # cover a service account whose PATH does not carry it.
    #
    # The roots are read defensively: this repo's suite also runs on Linux, where
    # both env vars are null and Join-Path would throw on a null -Path before any
    # of this could report something useful.
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

$podman = if ($PodmanPath) { $PodmanPath } else { Get-PodmanCandidatePath }
if (-not $podman -or -not (Test-Path $podman)) {
    throw ('podman.exe not found on PATH, nor in the per-user or Program Files install ' +
        'locations. Pass -PodmanPath to override.')
}

if (Get-Process -Name 'Agent.Worker' -ErrorAction SilentlyContinue) {
    throw 'A pipeline job is running (Agent.Worker active). Refusing to touch the image store.'
}

Write-Step 'Checking machine state'
$machine = & $podman machine list --format json 2>&1 | ConvertFrom-Json |
    Where-Object { $_.Name -eq $MachineName }
if (-not $machine) { throw "No podman machine named '$MachineName'." }

if (-not $machine.Running) {
    if ($PSCmdlet.ShouldProcess($MachineName, 'start machine')) {
        Write-Step "Starting $MachineName (this is routinely slow; waiting up to ${TimeoutSeconds}s)"
        & $podman machine start $MachineName 2>&1 | Write-Verbose

        $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
        while ((Get-Date) -lt $deadline) {
            Start-Sleep -Seconds 5
            $state = & $podman machine list --format json 2>&1 | ConvertFrom-Json |
                Where-Object { $_.Name -eq $MachineName }
            if ($state.Running) { Write-Step 'Machine is running.'; break }
        }
        if (-not $state.Running) { throw "Machine did not start within ${TimeoutSeconds}s." }
    }
}
else {
    Write-Step 'Machine already running.'
}

Write-Step 'Probing the image store'
& $podman images --format json 2>&1 | Out-Null
$storeHealthy = ($LASTEXITCODE -eq 0)

if ($storeHealthy) {
    Write-Step 'Image store responds normally.'
    if ($StartOnly) { return }
    Write-Warning 'Store appears healthy. Reset anyway only if pushes fail with "file integrity checksum failed".'
}

if ($StartOnly) {
    throw 'Image store is not responding, and -StartOnly was specified. Re-run without it to reset.'
}

if ($PSCmdlet.ShouldProcess("$MachineName (user $User)", 'podman system reset -f - DESTROYS ALL CACHED IMAGES')) {
    Write-Step 'Resetting the store inside the machine'
    wsl -d $MachineName -u $User -- podman system reset -f
    if ($LASTEXITCODE -ne 0) { throw "podman system reset failed with exit code $LASTEXITCODE" }
    Write-Step 'Reset complete. The next build will be cold.'
}
