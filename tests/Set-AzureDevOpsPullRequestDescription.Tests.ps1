#!/usr/bin/env pwsh
BeforeAll {
    Import-Module (Join-Path (Split-Path $PSScriptRoot -Parent) 'Modules/ScriptUtils') -Force
}

Describe 'Set-AzureDevOpsPullRequestDescription' {
    It 'rejects a description longer than 4000 characters before calling the API' {
        InModuleScope ScriptUtils {
            Mock Invoke-AzureDevOpsApi { throw 'should not be called' }
            { Set-AzureDevOpsPullRequestDescription -PullRequestId 1 -Repository 'r' `
                -Organization 'o' -Project 'p' -Description ('x' * 4001) } |
                Should -Throw -ExpectedMessage '*4000*'
            # The cap ("4000") appears literally in the static text regardless of whether
            # the {0} placeholder actually substitutes. Assert the real character count
            # (4001) is also present, so a broken -f binding (placeholder left as literal
            # "{0}") is caught rather than masked by the message's own wording.
            { Set-AzureDevOpsPullRequestDescription -PullRequestId 1 -Repository 'r' `
                -Organization 'o' -Project 'p' -Description ('x' * 4001) } |
                Should -Throw -ExpectedMessage '*4001*'
            Should -Invoke Invoke-AzureDevOpsApi -Times 0
        }
    }

    It 'refuses a completed pull request with an actionable message' {
        InModuleScope ScriptUtils {
            Mock Invoke-AzureDevOpsApi { [pscustomobject]@{ status = 'completed'; description = '' } } `
                -ParameterFilter { $Method -eq 'Get' }
            { Set-AzureDevOpsPullRequestDescription -PullRequestId 1 -Repository 'r' `
                -Organization 'o' -Project 'p' -Description 'hello' } |
                Should -Throw -ExpectedMessage '*completed*'
        }
    }

    It 'sends a PATCH and verifies the saved length' {
        InModuleScope ScriptUtils {
            # NOTE: deliberately not named $body -- Pester exposes a mocked command's bound
            # parameters (including Invoke-AzureDevOpsApi's -Body) as automatic variables
            # inside the mock scriptblock, and PowerShell variable names are case-insensitive.
            # A local $body here would be shadowed by that -Body parameter (the request
            # hashtable), not the string defined in this test.
            $multilineText = "line one`nline two`nline three"
            Mock Invoke-AzureDevOpsApi { [pscustomobject]@{ status = 'active'; description = $multilineText } } `
                -ParameterFilter { $Method -eq 'Get' }
            Mock Invoke-AzureDevOpsApi { [pscustomobject]@{ description = $multilineText } } `
                -ParameterFilter { $Method -eq 'Patch' }
            { Set-AzureDevOpsPullRequestDescription -PullRequestId 7 -Repository 'r' `
                -Organization 'o' -Project 'p' -Description $multilineText } | Should -Not -Throw
            # -Exactly: a bare -Times 1 means "at least once", which would not catch a
            # retry loop patching the description repeatedly.
            Should -Invoke Invoke-AzureDevOpsApi -ParameterFilter { $Method -eq 'Patch' } -Times 1 -Exactly
        }
    }

    It 'throws when the API saved a truncated description' {
        InModuleScope ScriptUtils {
            Mock Invoke-AzureDevOpsApi { [pscustomobject]@{ status = 'active'; description = 'line one' } } `
                -ParameterFilter { $Method -eq 'Get' }
            Mock Invoke-AzureDevOpsApi { [pscustomobject]@{ description = 'line one' } } `
                -ParameterFilter { $Method -eq 'Patch' }
            { Set-AzureDevOpsPullRequestDescription -PullRequestId 7 -Repository 'r' `
                -Organization 'o' -Project 'p' -Description "line one`nline two" } |
                Should -Throw -ExpectedMessage '*truncat*'
        }
    }

    It 'throws when the API saved a same-length but corrupted description' {
        InModuleScope ScriptUtils {
            Mock Invoke-AzureDevOpsApi { [pscustomobject]@{ status = 'active'; description = 'line one, line two' } } `
                -ParameterFilter { $Method -eq 'Get' }
            Mock Invoke-AzureDevOpsApi { [pscustomobject]@{ description = 'line two, line one' } } `
                -ParameterFilter { $Method -eq 'Patch' }
            { Set-AzureDevOpsPullRequestDescription -PullRequestId 7 -Repository 'r' `
                -Organization 'o' -Project 'p' -Description 'line one, line two' } |
                Should -Throw -ExpectedMessage '*truncat*'
        }
    }

    It 'makes no PATCH call under -WhatIf' {
        InModuleScope ScriptUtils {
            Mock Invoke-AzureDevOpsApi { [pscustomobject]@{ status = 'active'; description = '' } } `
                -ParameterFilter { $Method -eq 'Get' }
            Mock Invoke-AzureDevOpsApi { throw 'PATCH must not run under WhatIf' } `
                -ParameterFilter { $Method -eq 'Patch' }
            Set-AzureDevOpsPullRequestDescription -PullRequestId 7 -Repository 'r' `
                -Organization 'o' -Project 'p' -Description 'hello' -WhatIf
            Should -Invoke Invoke-AzureDevOpsApi -ParameterFilter { $Method -eq 'Patch' } -Times 0
        }
    }
}
