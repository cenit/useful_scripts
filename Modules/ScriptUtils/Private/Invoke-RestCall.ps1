#!/usr/bin/env pwsh
function Invoke-RestCall {
    <#
    .SYNOPSIS
        Thin wrapper around Invoke-RestMethod that returns the body and response
        headers together.
    .DESCRIPTION
        Invoke-RestMethod's -ResponseHeadersVariable writes the headers into a
        variable in the caller's scope by name, which is awkward to observe from a
        unit test mock. This seam captures the headers itself and returns them
        alongside the body as a single object, so callers such as
        Invoke-AzureDevOpsApi can be unit-tested by mocking one call.
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory)][hashtable]$Parameters)

    $callParams = $Parameters.Clone()
    $callParams.ResponseHeadersVariable = 'headers'
    $body = Invoke-RestMethod @callParams

    [pscustomobject]@{
        Body    = $body
        Headers = $headers
    }
}
