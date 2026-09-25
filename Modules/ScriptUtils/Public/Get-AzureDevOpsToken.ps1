#!/usr/bin/env pwsh
function Get-AzureDevOpsToken {
    <#
    .SYNOPSIS
        Returns a bearer token for the Azure DevOps REST API.
    .DESCRIPTION
        az rest cannot derive the AAD resource for dev.azure.com, so the token is
        acquired explicitly against the well-known Azure DevOps application id and
        used with Invoke-RestMethod.

        The token is cached in memory for the session only. It is never written to
        disk, logged, or included in error output.
    .EXAMPLE
        $headers = @{ Authorization = "Bearer $(Get-AzureDevOpsToken)" }
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([switch]$Force)

    # Well-known, publicly documented Azure DevOps AAD application id.
    $resource = '499b84ac-1321-427f-aa17-267ca6975798'

    if (-not $Force -and $script:AzureDevOpsToken -and
        $script:AzureDevOpsTokenExpiry -gt (Get-Date).AddMinutes(5)) {
        return $script:AzureDevOpsToken
    }

    $json = Invoke-AzCli -Arguments @(
        'account', 'get-access-token', '--resource', $resource, '--output', 'json'
    )
    $parsed = $json | ConvertFrom-Json

    $script:AzureDevOpsToken = $parsed.accessToken
    $script:AzureDevOpsTokenExpiry = try { [datetime]$parsed.expiresOn } catch { (Get-Date).AddMinutes(30) }
    $script:AzureDevOpsToken
}
