#!/usr/bin/env pwsh
function Set-AzureDevOpsPullRequestDescription {
    <#
    .SYNOPSIS
        Sets a pull request description, verifying what was actually saved.
    .DESCRIPTION
        "az repos pr update --description" is a multi-value parameter and silently
        keeps only the first line of a multi-line body. This uses a REST PATCH and
        then re-reads the pull request to assert the saved description matches what
        was sent, because an unverified silent truncation looks exactly like success.

        The server caps descriptions at 4000 characters, and completed pull requests
        are frozen (TF401181). Both are checked up front with actionable messages.
    .EXAMPLE
        Set-AzureDevOpsPullRequestDescription -PullRequestId 42 -Description (Get-Content body.md -Raw)
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][int]$PullRequestId,
        [Parameter(Mandatory)][string]$Description,
        [string]$Repository,
        [string]$Organization,
        [string]$Project,
        [switch]$PassThru
    )

    if ($Description.Length -gt 4000) {
        throw (("Description is {0} characters; Azure DevOps caps pull request " +
                "descriptions at 4000. Put the durable detail in the commit message " +
                "and keep the PR body short.") -f $Description.Length)
    }

    if (-not $Repository -or -not $Organization -or -not $Project) {
        $ctx = Resolve-AzureDevOpsContext
        if (-not $Organization) { $Organization = $ctx.Organization }
        if (-not $Project)      { $Project      = $ctx.Project }
        if (-not $Repository)   { $Repository   = $ctx.Repository }
    }

    $path = "git/repositories/$Repository/pullrequests/$PullRequestId"
    $common = @{ Organization = $Organization; Project = $Project }

    $pr = Invoke-AzureDevOpsApi @common -Path $path -Method Get
    if ($pr.status -ne 'active') {
        throw ("Pull request $PullRequestId is '$($pr.status)', not active. " +
               'Completed pull requests are frozen (TF401181) and cannot be edited.')
    }

    if (-not $PSCmdlet.ShouldProcess("PR $PullRequestId in $Organization/$Project/$Repository",
                                     "Set description ($($Description.Length) chars)")) {
        return
    }

    $updated = Invoke-AzureDevOpsApi @common -Path $path -Method Patch -Body @{ description = $Description }

    $saved = [string]$updated.description
    if ($saved -ne $Description) {
        throw (("Description was truncated or corrupted on save: sent {0} characters, " +
                'server stored {1}, and the content differs. ' +
                'Verify the request body was not split.') -f $Description.Length, $saved.Length)
    }

    Write-Verbose "Saved $($saved.Length) characters to PR $PullRequestId."
    if ($PassThru) { $updated }
}
