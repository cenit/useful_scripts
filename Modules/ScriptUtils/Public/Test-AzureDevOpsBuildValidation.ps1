#!/usr/bin/env pwsh
function Test-AzureDevOpsBuildValidation {
    <#
    .SYNOPSIS
        Reports which repositories have no PR build validation policy.
    .DESCRIPTION
        YAML "pr:" triggers are inert on Azure Repos. A PR build only runs when a
        Build Validation branch policy exists on the target branch, so a repository
        can have a healthy pipeline whose PR builds have never fired. This reports
        one row per repository so the gap is visible.
    .EXAMPLE
        Test-AzureDevOpsBuildValidation -Organization my-org -Project MyProject |
            Where-Object { -not $_.HasBuildValidation }
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject[]])]
    param(
        [string]$Organization,
        [string]$Project,
        [string]$Repository
    )

    # Documented Azure DevOps policy type id for Build Validation.
    $buildValidationTypeId = '0609b952-1397-4640-95ec-e00a01b2c241'

    $common = @{}
    if ($Organization) { $common.Organization = $Organization }
    if ($Project)      { $common.Project      = $Project }

    $repos = @(Invoke-AzureDevOpsApi @common -Path 'git/repositories' -Collection)
    if ($Repository) { $repos = @($repos | Where-Object { $_.name -eq $Repository }) }

    $policies = @(Invoke-AzureDevOpsApi @common -Path 'policy/configurations' -Collection)

    foreach ($repo in $repos) {
        $matching = @(
            $policies | Where-Object {
                $_.isEnabled -and
                $_.type.id -eq $buildValidationTypeId -and
                $repo.defaultBranch -and
                @($_.settings.scope | Where-Object {
                    $_.repositoryId -eq $repo.id -and $_.refName -eq $repo.defaultBranch
                }).Count -gt 0
            }
        )

        [pscustomobject]@{
            Project            = if ($Project) { $Project } else { $repo.project.name }
            Repository         = $repo.name
            DefaultBranch      = $repo.defaultBranch
            HasBuildValidation = ($matching.Count -gt 0)
            PolicyCount        = $matching.Count
        }
    }
}
