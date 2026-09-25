#!/usr/bin/env pwsh
BeforeAll {
    Import-Module (Join-Path (Split-Path $PSScriptRoot -Parent) 'Modules/ScriptUtils') -Force
}

Describe 'Get-AzureDevOpsActiveBuild' {
    BeforeEach {
        InModuleScope ScriptUtils {
            Mock Invoke-AzureDevOpsApi {
                @(
                    [pscustomobject]@{
                        id = 11; buildNumber = '20260819.1'; status = 'inProgress'
                        sourceBranch = 'refs/heads/master'; queueTime = '2026-08-19T08:00:00Z'
                        definition = [pscustomobject]@{ name = 'my-app' }
                        _links = [pscustomobject]@{ web = [pscustomobject]@{ href = 'https://example/11' } }
                    }
                )
            }
        }
    }

    It 'always filters on inProgress' {
        InModuleScope ScriptUtils {
            Get-AzureDevOpsActiveBuild -Organization 'Org' -Project 'Proj' | Out-Null
            Should -Invoke Invoke-AzureDevOpsApi -ParameterFilter {
                $Query.statusFilter -eq 'inProgress'
            }
        }
    }

    It 'includes notStarted when asked' {
        InModuleScope ScriptUtils {
            Get-AzureDevOpsActiveBuild -Organization 'Org' -Project 'Proj' -IncludeNotStarted | Out-Null
            Should -Invoke Invoke-AzureDevOpsApi -ParameterFilter {
                $Query.statusFilter -eq 'inProgress,notStarted'
            }
        }
    }

    It 'flattens the definition name and web link' {
        InModuleScope ScriptUtils {
            $b = Get-AzureDevOpsActiveBuild -Organization 'Org' -Project 'Proj'
            $b.Definition   | Should -Be 'my-app'
            $b.Id           | Should -Be 11
            $b.Url          | Should -Be 'https://example/11'
            $b.SourceBranch | Should -Be 'refs/heads/master'
        }
    }

    It 'forwards DefinitionId as comma-delimited definitions query parameter' {
        InModuleScope ScriptUtils {
            Get-AzureDevOpsActiveBuild -Organization 'Org' -Project 'Proj' -DefinitionId 42, 99 | Out-Null
            Should -Invoke Invoke-AzureDevOpsApi -ParameterFilter {
                $Query.definitions -eq '42,99'
            }
        }
    }

    It 'omits definitions query parameter when DefinitionId is not provided' {
        InModuleScope ScriptUtils {
            Get-AzureDevOpsActiveBuild -Organization 'Org' -Project 'Proj' | Out-Null
            Should -Invoke Invoke-AzureDevOpsApi -ParameterFilter {
                -not $Query.ContainsKey('definitions')
            }
        }
    }
}
