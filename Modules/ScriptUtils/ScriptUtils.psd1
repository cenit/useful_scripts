@{
    RootModule        = 'ScriptUtils.psm1'
    ModuleVersion     = '0.8.0'
    GUID              = 'b7e4c1a2-5f3d-4e8b-9c6a-1d2f3e4a5b6c'
    Author            = 'Stefano Sinigardi'
    Description       = 'Shared helpers for the useful_scripts operator scripts.'
    PowerShellVersion = '7.0'
    FunctionsToExport = @(
        'Get-AzureDevOpsActiveBuild',
        'Get-AzureDevOpsToken',
        'Invoke-AzureDevOpsApi',
        'Invoke-Git',
        'Set-AzureDevOpsPullRequestDescription',
        'Test-AzureDevOpsBuildValidation',
        'Test-AwsSession',
        'Test-GitBranchMerged',
        'Use-Location',
        'Write-ScriptLog'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    FileList          = @(
        'ScriptUtils.psm1',
        'Private/Hide-UrlCredential.ps1',
        'Private/Invoke-AzCli.ps1',
        'Private/Invoke-AwsCli.ps1',
        'Private/Invoke-RestCall.ps1',
        'Private/Resolve-AzureDevOpsContext.ps1',
        'Public/Get-AzureDevOpsActiveBuild.ps1',
        'Public/Get-AzureDevOpsToken.ps1',
        'Public/Invoke-AzureDevOpsApi.ps1',
        'Public/Invoke-Git.ps1',
        'Public/Set-AzureDevOpsPullRequestDescription.ps1',
        'Public/Test-AzureDevOpsBuildValidation.ps1',
        'Public/Test-AwsSession.ps1',
        'Public/Test-GitBranchMerged.ps1',
        'Public/Use-Location.ps1',
        'Public/Write-ScriptLog.ps1'
    )
}
