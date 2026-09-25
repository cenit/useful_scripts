#!/usr/bin/env pwsh
BeforeAll {
    Import-Module (Join-Path (Split-Path $PSScriptRoot -Parent) 'Modules/ScriptUtils') -Force
}

Describe 'Test-AzureDevOpsBuildValidation' {
    It 'reports a repo with a matching build validation policy as compliant' {
        InModuleScope ScriptUtils {
            Mock Invoke-AzureDevOpsApi {
                @([pscustomobject]@{ id = 'repo-guid'; name = 'my-app'; defaultBranch = 'refs/heads/master' })
            } -ParameterFilter { $Path -eq 'git/repositories' }
            Mock Invoke-AzureDevOpsApi {
                @([pscustomobject]@{
                    isEnabled = $true; isBlocking = $true
                    type = [pscustomobject]@{ id = '0609b952-1397-4640-95ec-e00a01b2c241' }
                    settings = [pscustomobject]@{
                        scope = @([pscustomobject]@{ repositoryId = 'repo-guid'; refName = 'refs/heads/master' })
                    }
                })
            } -ParameterFilter { $Path -like '*policy/configurations*' }

            $r = Test-AzureDevOpsBuildValidation -Organization 'Org' -Project 'Proj'
            $r.Repository         | Should -Be 'my-app'
            $r.HasBuildValidation | Should -BeTrue
        }
    }

    It 'reports a repo with no policies as non-compliant' {
        InModuleScope ScriptUtils {
            Mock Invoke-AzureDevOpsApi {
                @([pscustomobject]@{ id = 'repo-guid'; name = 'my-app'; defaultBranch = 'refs/heads/master' })
            } -ParameterFilter { $Path -eq 'git/repositories' }
            Mock Invoke-AzureDevOpsApi { @() } -ParameterFilter { $Path -like '*policy/configurations*' }

            (Test-AzureDevOpsBuildValidation -Organization 'Org' -Project 'Proj').HasBuildValidation |
                Should -BeFalse
        }
    }

    It 'ignores a policy scoped to a different branch' {
        InModuleScope ScriptUtils {
            Mock Invoke-AzureDevOpsApi {
                @([pscustomobject]@{ id = 'repo-guid'; name = 'my-app'; defaultBranch = 'refs/heads/master' })
            } -ParameterFilter { $Path -eq 'git/repositories' }
            Mock Invoke-AzureDevOpsApi {
                @([pscustomobject]@{
                    isEnabled = $true; isBlocking = $true
                    type = [pscustomobject]@{ id = '0609b952-1397-4640-95ec-e00a01b2c241' }
                    settings = [pscustomobject]@{
                        scope = @([pscustomobject]@{ repositoryId = 'repo-guid'; refName = 'refs/heads/dev' })
                    }
                })
            } -ParameterFilter { $Path -like '*policy/configurations*' }

            (Test-AzureDevOpsBuildValidation -Organization 'Org' -Project 'Proj').HasBuildValidation |
                Should -BeFalse
        }
    }

    It 'ignores a disabled policy' {
        InModuleScope ScriptUtils {
            Mock Invoke-AzureDevOpsApi {
                @([pscustomobject]@{ id = 'repo-guid'; name = 'my-app'; defaultBranch = 'refs/heads/master' })
            } -ParameterFilter { $Path -eq 'git/repositories' }
            Mock Invoke-AzureDevOpsApi {
                @([pscustomobject]@{
                    isEnabled = $false; isBlocking = $true
                    type = [pscustomobject]@{ id = '0609b952-1397-4640-95ec-e00a01b2c241' }
                    settings = [pscustomobject]@{
                        scope = @([pscustomobject]@{ repositoryId = 'repo-guid'; refName = 'refs/heads/master' })
                    }
                })
            } -ParameterFilter { $Path -like '*policy/configurations*' }

            (Test-AzureDevOpsBuildValidation -Organization 'Org' -Project 'Proj').HasBuildValidation |
                Should -BeFalse
        }
    }

    It 'handles a repo with no default branch' {
        InModuleScope ScriptUtils {
            Mock Invoke-AzureDevOpsApi {
                @([pscustomobject]@{ id = 'repo-guid'; name = 'empty-repo'; defaultBranch = $null })
            } -ParameterFilter { $Path -eq 'git/repositories' }
            Mock Invoke-AzureDevOpsApi { @() } -ParameterFilter { $Path -like '*policy/configurations*' }

            $r = Test-AzureDevOpsBuildValidation -Organization 'Org' -Project 'Proj'
            $r.HasBuildValidation | Should -BeFalse
            $r.DefaultBranch      | Should -BeNullOrEmpty
        }
    }
}
