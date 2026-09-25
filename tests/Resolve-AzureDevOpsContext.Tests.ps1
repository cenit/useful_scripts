#!/usr/bin/env pwsh
BeforeAll {
    Import-Module (Join-Path (Split-Path $PSScriptRoot -Parent) 'Modules/ScriptUtils') -Force
}

Describe 'Resolve-AzureDevOpsContext' {
    It 'parses an https URL with an embedded org user' {
        InModuleScope ScriptUtils {
            $r = Resolve-AzureDevOpsContext -RemoteUrl 'https://my-org@dev.azure.com/my-org/useful_scripts/_git/useful_scripts'
            $r.Organization | Should -Be 'my-org'
            $r.Project      | Should -Be 'useful_scripts'
            $r.Repository   | Should -Be 'useful_scripts'
        }
    }

    It 'parses an https URL without an embedded user' {
        InModuleScope ScriptUtils {
            $r = Resolve-AzureDevOpsContext -RemoteUrl 'https://dev.azure.com/other-org/MyApp/_git/MyApp'
            $r.Organization | Should -Be 'other-org'
            $r.Project      | Should -Be 'MyApp'
            $r.Repository   | Should -Be 'MyApp'
        }
    }

    It 'parses a project whose repo name differs' {
        InModuleScope ScriptUtils {
            $r = Resolve-AzureDevOpsContext -RemoteUrl 'https://dev.azure.com/my-org/MyProject/_git/some-other-repo'
            $r.Project    | Should -Be 'MyProject'
            $r.Repository | Should -Be 'some-other-repo'
        }
    }

    It 'parses an ssh URL' {
        InModuleScope ScriptUtils {
            $r = Resolve-AzureDevOpsContext -RemoteUrl 'git@ssh.dev.azure.com:v3/my-org/MyProject/my-repo'
            $r.Organization | Should -Be 'my-org'
            $r.Project      | Should -Be 'MyProject'
            $r.Repository   | Should -Be 'my-repo'
        }
    }

    It 'strips a trailing .git suffix' {
        InModuleScope ScriptUtils {
            (Resolve-AzureDevOpsContext -RemoteUrl 'https://dev.azure.com/Org/Proj/_git/repo.git').Repository |
                Should -Be 'repo'
        }
    }

    It 'throws on a non-Azure-DevOps remote' {
        InModuleScope ScriptUtils {
            { Resolve-AzureDevOpsContext -RemoteUrl 'https://github.com/microsoft/vcpkg' } |
                Should -Throw -ExpectedMessage '*not an Azure DevOps*'
        }
    }

    It 'strips credentials from error message' {
        InModuleScope ScriptUtils {
            $url = 'https://oauth2:FAKE-TOKEN-DO-NOT-USE@github.com/owner/repo'
            $ex = { Resolve-AzureDevOpsContext -RemoteUrl $url } | Should -Throw -PassThru
            $ex.Exception.Message | Should -Not -Match 'FAKE-TOKEN-DO-NOT-USE'
            $ex.Exception.Message | Should -Match 'github\.com'
        }
    }

    It 'redacts the credential in the error message for a <_> remote' -ForEach @('https', 'http', 'ssh') {
        # The original regex was anchored to '^https://', so an http:// or ssh://
        # remote carried its password straight into the exception message.
        InModuleScope ScriptUtils -Parameters @{ Scheme = $_ } {
            param($Scheme)
            $url = "${Scheme}://operator:FAKE-TOKEN-DO-NOT-USE@example.invalid/owner/repo"
            $ex = { Resolve-AzureDevOpsContext -RemoteUrl $url } | Should -Throw -PassThru
            $ex.Exception.Message | Should -Not -Match 'FAKE-TOKEN-DO-NOT-USE'
            $ex.Exception.Message | Should -Not -Match 'operator'
            $ex.Exception.Message | Should -Match 'example\.invalid'
        }
    }
}
