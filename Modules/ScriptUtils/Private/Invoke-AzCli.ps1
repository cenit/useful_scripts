#!/usr/bin/env pwsh
function Invoke-AzCli {
    <#
    .SYNOPSIS
        Thin wrapper around the az CLI so callers can be unit-tested.
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory)][string[]]$Arguments)

    $az = Get-Command az -ErrorAction SilentlyContinue
    if (-not $az) { throw 'Azure CLI (az) not found on PATH. Install it and run "az login".' }

    $output = & az @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "az $($Arguments -join ' ') failed with exit code $LASTEXITCODE`n$($output -join "`n")"
    }
    $output -join "`n"
}
