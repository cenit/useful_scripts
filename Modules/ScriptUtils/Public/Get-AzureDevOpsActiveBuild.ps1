#!/usr/bin/env pwsh
function Get-AzureDevOpsActiveBuild {
    <#
    .SYNOPSIS
        Lists pipeline runs that are currently in progress.
    .DESCRIPTION
        A bare "az pipelines build list" hides in-progress runs, which makes a
        running build look like one that never started. Re-queueing on that
        assumption creates duplicate runs. This always sets statusFilter.
    .PARAMETER DefinitionId
        Numeric definition IDs to filter by. These are the numeric pipeline
        identifiers (found in the pipeline URL as "definitionId", or in API
        responses within the definition object). Accepts multiple values.
    .EXAMPLE
        Get-AzureDevOpsActiveBuild | Format-Table Definition, BuildNumber, SourceBranch
    .EXAMPLE
        Get-AzureDevOpsActiveBuild -DefinitionId 42
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject[]])]
    param(
        [string]$Organization,
        [string]$Project,
        [int[]]$DefinitionId,
        [switch]$IncludeNotStarted
    )

    $query = @{ statusFilter = if ($IncludeNotStarted) { 'inProgress,notStarted' } else { 'inProgress' } }
    if ($DefinitionId) { $query.definitions = $DefinitionId -join ',' }

    $params = @{ Path = 'build/builds'; Query = $query; Collection = $true }
    if ($Organization) { $params.Organization = $Organization }
    if ($Project)      { $params.Project      = $Project }

    Invoke-AzureDevOpsApi @params | ForEach-Object {
        [pscustomobject]@{
            Id           = $_.id
            BuildNumber  = $_.buildNumber
            Definition   = $_.definition.name
            Status       = $_.status
            SourceBranch = $_.sourceBranch
            QueueTime    = $_.queueTime
            Url          = $_._links.web.href
        }
    }
}
