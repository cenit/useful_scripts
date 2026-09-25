#!/usr/bin/env pwsh
BeforeAll {
    Import-Module (Join-Path (Split-Path $PSScriptRoot -Parent) 'Modules/ScriptUtils') -Force
}

Describe 'Invoke-AzureDevOpsApi URL assembly' {
    It 'builds an org-scoped URL when no project is given' {
        InModuleScope ScriptUtils {
            Mock Get-AzureDevOpsToken { 'fake-token' }
            Mock Invoke-RestMethod { @{ value = @() } }
            Invoke-AzureDevOpsApi -Path 'projects' -Organization 'Org' | Out-Null
            Should -Invoke Invoke-RestMethod -ParameterFilter {
                $Uri -eq 'https://dev.azure.com/Org/_apis/projects?api-version=7.1'
            }
        }
    }

    It 'builds a project-scoped URL' {
        InModuleScope ScriptUtils {
            Mock Get-AzureDevOpsToken { 'fake-token' }
            Mock Invoke-RestMethod { @{ value = @() } }
            Invoke-AzureDevOpsApi -Path 'git/repositories' -Organization 'Org' -Project 'Proj' | Out-Null
            Should -Invoke Invoke-RestMethod -ParameterFilter {
                $Uri -eq 'https://dev.azure.com/Org/Proj/_apis/git/repositories?api-version=7.1'
            }
        }
    }

    It 'appends query parameters' {
        InModuleScope ScriptUtils {
            Mock Get-AzureDevOpsToken { 'fake-token' }
            Mock Invoke-RestMethod { @{ value = @() } }
            Invoke-AzureDevOpsApi -Path 'build/builds' -Organization 'Org' -Project 'Proj' `
                -Query @{ statusFilter = 'inProgress' } | Out-Null
            Should -Invoke Invoke-RestMethod -ParameterFilter {
                $Uri -like '*statusFilter=inProgress*' -and $Uri -like '*api-version=7.1*'
            }
        }
    }

    It 'sends a bearer authorization header' {
        InModuleScope ScriptUtils {
            Mock Get-AzureDevOpsToken { 'fake-token' }
            Mock Invoke-RestMethod { @{ value = @() } }
            Invoke-AzureDevOpsApi -Path 'projects' -Organization 'Org' | Out-Null
            Should -Invoke Invoke-RestMethod -ParameterFilter {
                $Headers.Authorization -eq 'Bearer fake-token'
            }
        }
    }

    It 'rejects a query string in -Path instead of building a malformed URL' {
        # api-version is always appended with '?', so a '?' in -Path yields
        # '...builds/5937?retry=true?api-version=7.1'. Azure DevOps parses that as
        # retry='true?api-version=7.1' and answers "No api-version was supplied" --
        # an error naming the one thing the caller did supply, which sends whoever
        # hits it looking in entirely the wrong place.
        InModuleScope ScriptUtils {
            Mock Get-AzureDevOpsToken { 'fake-token' }
            Mock Invoke-RestMethod { @{ value = @() } }
            { Invoke-AzureDevOpsApi -Path 'build/builds/5937?retry=true' -Organization 'Org' } |
                Should -Throw -ExpectedMessage '*-Query*'
            Should -Not -Invoke Invoke-RestMethod

            # The message has to name the offending path and carry no unrendered
            # format placeholders: -f binds tighter than +, so a multi-fragment
            # message built without parentheses formats only its last fragment and
            # hands the caller a literal '{0}'. Asserting only '*-Query*' let
            # exactly that through once.
            $err = { Invoke-AzureDevOpsApi -Path 'build/builds/5937?retry=true' -Organization 'Org' } |
                Should -Throw -PassThru
            $err.Exception.Message | Should -BeLike '*build/builds/5937?retry=true*'
            $err.Exception.Message | Should -Not -BeLike '*{0}*'
            $err.Exception.Message | Should -Not -BeLike '*{{*'
        }
    }
}

Describe 'Invoke-AzureDevOpsApi paging' {
    It 'follows continuation tokens and concatenates pages' {
        # Invoke-RestMethod's -ResponseHeadersVariable writes into the caller's scope
        # by name, which Pester's Mock does not propagate reliably. Invoke-AzureDevOpsApi
        # goes through the private Invoke-RestCall seam instead, so the mock here returns
        # body and headers together as one object.
        InModuleScope ScriptUtils {
            Mock Get-AzureDevOpsToken { 'fake-token' }
            $script:call = 0
            Mock Invoke-RestCall {
                $script:call++
                if ($script:call -eq 1) {
                    return [pscustomobject]@{
                        Body    = @{ value = @('a', 'b') }
                        Headers = @{ 'x-ms-continuationtoken' = @('tok1') }
                    }
                }
                [pscustomobject]@{
                    Body    = @{ value = @('c') }
                    Headers = @{}
                }
            }
            $result = Invoke-AzureDevOpsApi -Path 'git/repositories' -Organization 'Org' -Collection
            $result | Should -Be @('a', 'b', 'c')
            # -Exactly, always: a bare -Times N asserts "at least N" in Pester, so
            # without it this would also pass if paging never stopped.
            Should -Invoke Invoke-RestCall -Times 2 -Exactly
        }
    }

    It 'does not page when -Collection is absent' {
        InModuleScope ScriptUtils {
            Mock Get-AzureDevOpsToken { 'fake-token' }
            Mock Invoke-RestMethod { @{ value = @('only') } }
            Invoke-AzureDevOpsApi -Path 'projects' -Organization 'Org' | Out-Null
            # -Exactly is the whole assertion here: -Times 1 alone means "at least
            # once" and would pass even if the call paged five times.
            Should -Invoke Invoke-RestMethod -Times 1 -Exactly
        }
    }
}

Describe 'Get-AzureDevOpsToken' {
    It 'requests the Azure DevOps AAD resource id' {
        InModuleScope ScriptUtils {
            $script:AzureDevOpsToken = $null
            Mock Invoke-AzCli { '{"accessToken":"t","expiresOn":"2999-01-01 00:00:00.000000"}' }
            Get-AzureDevOpsToken | Should -Be 't'
            Should -Invoke Invoke-AzCli -ParameterFilter {
                ($Arguments -join ' ') -like '*499b84ac-1321-427f-aa17-267ca6975798*'
            }
        }
    }

    It 'caches the token across calls' {
        InModuleScope ScriptUtils {
            $script:AzureDevOpsToken = $null
            Mock Invoke-AzCli { '{"accessToken":"t","expiresOn":"2999-01-01 00:00:00.000000"}' }
            Get-AzureDevOpsToken | Out-Null
            Get-AzureDevOpsToken | Out-Null
            # -Exactly is the whole assertion here: -Times 1 alone means "at least
            # once" and would pass with no caching at all.
            Should -Invoke Invoke-AzCli -Times 1 -Exactly
        }
    }

    It 're-requests when -Force is given' {
        InModuleScope ScriptUtils {
            $script:AzureDevOpsToken = $null
            Mock Invoke-AzCli { '{"accessToken":"t","expiresOn":"2999-01-01 00:00:00.000000"}' }
            Get-AzureDevOpsToken | Out-Null
            Get-AzureDevOpsToken -Force | Out-Null
            Should -Invoke Invoke-AzCli -Times 2 -Exactly
        }
    }
}
