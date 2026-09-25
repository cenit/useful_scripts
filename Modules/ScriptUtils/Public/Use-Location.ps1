#!/usr/bin/env pwsh
function Use-Location {
    <#
    .SYNOPSIS
        Runs a scriptblock in a directory, always returning to the caller's location.
    .DESCRIPTION
        Push-Location/Pop-Location without a finally block strands the caller's
        session in a subdirectory whenever the body throws. Every directory change
        in this repository goes through this function.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][scriptblock]$ScriptBlock
    )
    Push-Location -Path $Path
    try {
        & $ScriptBlock
    }
    finally {
        Pop-Location
    }
}
