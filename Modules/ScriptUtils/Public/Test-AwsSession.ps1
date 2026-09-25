#!/usr/bin/env pwsh
function Test-AwsSession {
    <#
    .SYNOPSIS
        Diagnoses AWS credential state without changing it.
    .DESCRIPTION
        A leftover ~/.aws/credentials file silently takes precedence over a live SSO
        session. The symptom is a permission error immediately after a login that
        appeared to succeed, which sends people to the wrong problem entirely.

        This is strictly read-only and reports remediation rather than performing it.
        It never runs "aws sso login" - that is interactive and belongs to the operator.
    .EXAMPLE
        $s = Test-AwsSession; if (-not $s.IsHealthy) { $s.Remediation }
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', 'CredentialsPath', Justification = 'Parameter is a file path, not a password')]
    param(
        [string]$CredentialsPath = (Join-Path $HOME '.aws/credentials'),
        [switch]$Quiet
    )

    $problems    = [System.Collections.Generic.List[string]]::new()
    $remediation = [System.Collections.Generic.List[string]]::new()

    $hasStatic = $false
    if (Test-Path $CredentialsPath) {
        $meaningful = Get-Content $CredentialsPath |
            Where-Object { $_.Trim() -and -not $_.TrimStart().StartsWith('#') }
        if ($meaningful) {
            $hasStatic = $true
            $problems.Add("A static credentials file at $CredentialsPath silently overrides your SSO session.")
            $remediation.Add("Remove-Item '$CredentialsPath'   # then re-check; SSO config in ~/.aws/config is untouched")
        }
    }

    $identity = $null
    $account  = $null
    try {
        $json = Invoke-AwsCli -Arguments @('sts', 'get-caller-identity', '--output', 'json')
        $parsed  = $json | ConvertFrom-Json
        $identity = $parsed.Arn
        $account  = $parsed.Account
    }
    catch {
        $message = $_.Exception.Message
        if ($message -match 'expired|ExpiredToken|SSOSession') {
            $problems.Add('The SSO session has expired.')
        }
        else {
            $problems.Add("sts get-caller-identity failed: $message")
        }
        $remediation.Add('Run "aws sso login" yourself in an interactive terminal, then re-run this check.')
    }

    $result = [pscustomobject]@{
        IsHealthy                = ($problems.Count -eq 0)
        HasStaticCredentialsFile = $hasStatic
        CredentialsPath          = $CredentialsPath
        Identity                 = $identity
        Account                  = $account
        Problems                 = $problems.ToArray()
        Remediation              = $remediation.ToArray()
    }

    if (-not $Quiet) {
        if ($result.IsHealthy) {
            Write-Host "AWS session healthy: $identity (account $account)" -ForegroundColor Green
        }
        else {
            foreach ($p in $result.Problems)    { Write-Host "PROBLEM: $p" -ForegroundColor Yellow }
            foreach ($r in $result.Remediation) { Write-Host "  FIX:   $r" -ForegroundColor Cyan }
        }
    }

    $result
}
