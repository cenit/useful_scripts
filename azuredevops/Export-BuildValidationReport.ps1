#!/usr/bin/env pwsh
#Requires -Version 7.0
<#
.SYNOPSIS
    Reports repositories whose pull request builds never fire.
.DESCRIPTION
    Sweeps every project in an organisation (or a single project) and reports which
    repositories lack a Build Validation policy on their default branch. Those
    repositories accept pull requests with no CI gate at all.
.PARAMETER Organization
    Azure DevOps organisation. Required - an organisation-wide audit should name its target
    explicitly rather than inferring it from whatever directory the operator happens
    to be standing in.
.PARAMETER Project
    Restrict to one project. Omit to sweep every project in the organisation.
.PARAMETER OutputPath
    Optional CSV destination. Without it, results go to the pipeline.
.PARAMETER NonCompliantOnly
    Emit only repositories that are missing the policy.
.EXAMPLE
    ./azuredevops/Export-BuildValidationReport.ps1 -Organization my-org -NonCompliantOnly
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$Organization,
    [string]$Project,
    [string]$OutputPath,
    [switch]$NonCompliantOnly
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

if (-not $Organization) { throw 'Specify -Organization.' }

$projects = if ($Project) {
    @($Project)
}
else {
    @(Invoke-AzureDevOpsApi -Organization $Organization -Path 'projects' -Collection |
        Select-Object -ExpandProperty name)
}

Write-Host "Auditing $($projects.Count) project(s) in $Organization" -ForegroundColor Cyan

$results = foreach ($p in $projects) {
    Write-Host "  $p" -ForegroundColor DarkGray
    try {
        Test-AzureDevOpsBuildValidation -Organization $Organization -Project $p
    }
    catch {
        Write-Warning "Skipping project '$p': $($_.Exception.Message)"
    }
}

if ($NonCompliantOnly) {
    $results = $results | Where-Object { -not $_.HasBuildValidation }
}

$results = $results | Sort-Object Project, Repository

if ($OutputPath) {
    if ($PSCmdlet.ShouldProcess($OutputPath, "Write $($results.Count) row(s) to CSV")) {
        $results | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding utf8
        Write-Host "Wrote $($results.Count) row(s) to $OutputPath" -ForegroundColor Green
    }
}
else {
    $results
}
