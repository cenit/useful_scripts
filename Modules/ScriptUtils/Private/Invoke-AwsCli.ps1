#!/usr/bin/env pwsh
function Invoke-AwsCli {
    <#
    .SYNOPSIS
        Thin wrapper around the aws CLI so callers can be unit-tested.
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory)][string[]]$Arguments)

    $aws = Get-Command aws -ErrorAction SilentlyContinue
    if (-not $aws) { throw 'AWS CLI (aws) not found on PATH.' }

    $output = & aws @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "aws $($Arguments -join ' ') failed with exit code $LASTEXITCODE`n$($output -join "`n")"
    }
    $output -join "`n"
}
