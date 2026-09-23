#!/usr/bin/env pwsh
function Write-ScriptLog {
    <#
    .SYNOPSIS
        Writes a timestamped line to the console and optionally to a log file.
    .DESCRIPTION
        Appends 'yyyy-MM-dd HH:mm:ss  MESSAGE' to the console and, when -LogPath is
        given, to that file. Once the log file exceeds 1MB it is trimmed to its
        last 500 lines before the new line is appended, so long-running scripts
        never grow an unbounded log.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Message,
        [string]$LogPath,
        [ValidateSet('INFO', 'WARN', 'ERROR')][string]$Level = 'INFO'
    )
    $line = '{0}  {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message
    switch ($Level) {
        'WARN'  { Write-Warning $Message }
        'ERROR' { Write-Error $Message -ErrorAction Continue }
        default { Write-Host $line }
    }
    if ($LogPath) {
        if ((Test-Path $LogPath) -and ((Get-Item $LogPath).Length -gt 1MB)) {
            Set-Content -Path $LogPath -Value (Get-Content $LogPath -Tail 500)
        }
        Add-Content -Path $LogPath -Value $line -ErrorAction SilentlyContinue
    }
}
