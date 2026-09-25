#!/usr/bin/env pwsh
function Invoke-AzureDevOpsApi {
    <#
    .SYNOPSIS
        Calls the Azure DevOps REST API with a bearer token.
    .DESCRIPTION
        Use this instead of "az rest", which cannot derive the AAD resource for
        dev.azure.com and whose cmd.exe wrapper eats ampersands in URLs on Windows.

        Organization and Project default to the current repository's git remote
        rather than to any global CLI configuration.
    .EXAMPLE
        Invoke-AzureDevOpsApi -Path 'git/repositories' -Collection
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Path,
        [string]$Organization,
        [string]$Project,
        [ValidateSet('Get', 'Post', 'Patch', 'Put', 'Delete')][string]$Method = 'Get',
        [object]$Body,
        [string]$ApiVersion = '7.1',
        [hashtable]$Query,
        [switch]$Collection
    )

    # api-version is always appended with '?', so a '?' here would build
    # '...builds/5937?retry=true?api-version=7.1'. Azure DevOps reads that as
    # retry='true?api-version=7.1' and replies "No api-version was supplied" -- an
    # error naming the one thing the caller did supply, which costs whoever hits it
    # a detour through token and version handling before they suspect the path.
    if ($Path.Contains('?')) {
        # Parenthesised before -f on purpose: -f binds tighter than +, so without
        # these the operator would format only the last fragment and ship '{0}'
        # to the caller verbatim.
        throw (("Path must not contain a query string ('{0}'). Pass query parameters via " +
                "-Query instead, e.g. -Path 'build/builds/123' -Query @{{ retry = 'true' }}. " +
                "Left in Path they collide with the appended api-version, and Azure DevOps " +
                "rejects the call with the misleading 'No api-version was supplied'.") -f $Path)
    }

    if (-not $Organization) {
        $ctx = Resolve-AzureDevOpsContext
        $Organization = $ctx.Organization
        if (-not $PSBoundParameters.ContainsKey('Project')) { $Project = $ctx.Project }
    }

    $base = if ($Project) {
        'https://dev.azure.com/{0}/{1}/_apis/{2}' -f $Organization, $Project, $Path.TrimStart('/')
    }
    else {
        'https://dev.azure.com/{0}/_apis/{1}' -f $Organization, $Path.TrimStart('/')
    }

    $params = @{
        Method      = $Method
        Headers     = @{ Authorization = "Bearer $(Get-AzureDevOpsToken)" }
        ContentType = 'application/json'
        ErrorAction = 'Stop'
    }
    if ($null -ne $Body) {
        $params.Body = if ($Body -is [string]) { $Body } else { $Body | ConvertTo-Json -Depth 20 }
    }

    $results = [System.Collections.Generic.List[object]]::new()
    $continuation = $null

    do {
        $pairs = [System.Collections.Generic.List[string]]::new()
        foreach ($k in ($Query.Keys | Sort-Object)) {
            $pairs.Add(('{0}={1}' -f $k, [uri]::EscapeDataString([string]$Query[$k])))
        }
        if ($continuation) {
            $pairs.Add('continuationToken={0}' -f [uri]::EscapeDataString($continuation))
        }
        $pairs.Add("api-version=$ApiVersion")
        $params.Uri = '{0}?{1}' -f $base, ($pairs -join '&')

        $call = Invoke-RestCall -Parameters $params
        $response = $call.Body

        if ($Collection) {
            if ($null -ne $response.value) { $results.AddRange(@($response.value)) }
            else { $results.Add($response) }
            $continuation = @($call.Headers.'x-ms-continuationtoken')[0]
        }
        else {
            return $response
        }
    } while ($continuation)

    $results.ToArray()
}
