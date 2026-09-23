#!/usr/bin/env pwsh
function Resolve-AzureDevOpsContext {
    <#
    .SYNOPSIS
        Derives the Azure DevOps organisation, project and repository from a git remote.
    .DESCRIPTION
        A user often works across several organisations, so the Azure CLI's global
        default is not trustworthy. Deriving context from the remote of the repo you
        are actually standing in removes a whole class of "ran it against the wrong
        organisation" mistakes.
    #>
    [CmdletBinding()]
    param(
        [string]$RemoteUrl,
        [string]$Path = (Get-Location).Path
    )

    if (-not $RemoteUrl) {
        $RemoteUrl = (Use-Location -Path $Path -ScriptBlock {
            Invoke-Git -Arguments @('remote', 'get-url', 'origin')
        }) | Select-Object -First 1
    }

    $RemoteUrl = "$RemoteUrl".Trim()

    # https://[user@]dev.azure.com/<org>/<project>/_git/<repo>
    $https = [regex]'^https://(?:[^@/]+@)?dev\.azure\.com/([^/]+)/([^/]+)/_git/([^/]+?)(?:\.git)?/?$'
    # git@ssh.dev.azure.com:v3/<org>/<project>/<repo>
    $ssh   = [regex]'^git@ssh\.dev\.azure\.com:v3/([^/]+)/([^/]+)/([^/]+?)(?:\.git)?/?$'

    foreach ($pattern in @($https, $ssh)) {
        $m = $pattern.Match($RemoteUrl)
        if ($m.Success) {
            return [pscustomobject]@{
                Organization = $m.Groups[1].Value
                Project      = $m.Groups[2].Value
                Repository   = $m.Groups[3].Value
            }
        }
    }

    # Strip userinfo (credentials) from the URL before including it in the error
    # message. Hide-UrlCredential handles every scheme, not just https: an operator's
    # remote can be http:// or ssh:// and those carry credentials just as readily.
    $sanitized = Hide-UrlCredential -Text $RemoteUrl
    throw "Remote '$sanitized' is not an Azure DevOps repository URL."
}
