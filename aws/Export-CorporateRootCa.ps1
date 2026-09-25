#!/usr/bin/env pwsh
#Requires -Version 7.0
<#
.SYNOPSIS
    Exports corporate TLS-inspection root certificates from the Windows store to a PEM.
.DESCRIPTION
    On a network with TLS inspection every outbound certificate is re-signed by a
    corporate root. Container builds and language runtimes that ship their own trust
    store then fail certificate validation, because that root is trusted by Windows
    but not inside the image.

    This exports the matching roots as a PEM bundle suitable for a "custom-ca.crt"
    COPY stage in a Dockerfile.
.PARAMETER OutputPath
    Destination PEM file. Defaults to ./custom-ca.crt.
.PARAMETER SubjectPattern
    Regex matched against certificate subjects. Defaults to common interception roots.
.PARAMETER All
    Export every root in LocalMachine\Root rather than only matching subjects.
    Produces a large bundle; use when the interception root's name is unknown.
.EXAMPLE
    ./aws/Export-CorporateRootCa.ps1
.EXAMPLE
    ./aws/Export-CorporateRootCa.ps1 -SubjectPattern 'MyCorp' -OutputPath docker/custom-ca.crt
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$OutputPath = './custom-ca.crt',
    [string]$SubjectPattern = 'Zscaler|Proxy|Inspection',
    [switch]$All
)

$ErrorActionPreference = 'Stop'

if (-not $IsWindows) {
    throw 'This script reads the Windows certificate store and only runs on Windows.'
}

$certs = Get-ChildItem -Path 'Cert:\LocalMachine\Root'
if (-not $All) {
    $certs = $certs | Where-Object { $_.Subject -match $SubjectPattern }
}

if (-not $certs) {
    Write-Warning "No certificate in LocalMachine\Root matched '$SubjectPattern'. Re-run with -All to inspect every root, or pass -SubjectPattern."
    return
}

$builder = [System.Text.StringBuilder]::new()
foreach ($cert in $certs) {
    $base64 = [Convert]::ToBase64String($cert.RawData, [Base64FormattingOptions]::InsertLineBreaks)
    [void]$builder.AppendLine("# $($cert.Subject)")
    [void]$builder.AppendLine('-----BEGIN CERTIFICATE-----')
    [void]$builder.AppendLine($base64)
    [void]$builder.AppendLine('-----END CERTIFICATE-----')
}

if ($PSCmdlet.ShouldProcess($OutputPath, "Write $($certs.Count) certificate(s) as PEM")) {
    # ASCII, LF: the file is consumed inside Linux containers.
    $text = $builder.ToString() -replace "`r`n", "`n"
    [System.IO.File]::WriteAllText((New-Item -ItemType File -Path $OutputPath -Force).FullName, $text)
    Write-Host "Wrote $($certs.Count) certificate(s) to $OutputPath" -ForegroundColor Green
}

$certs | Select-Object Subject, Thumbprint, NotAfter
