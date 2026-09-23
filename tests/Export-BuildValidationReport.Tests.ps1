#!/usr/bin/env pwsh
BeforeAll {
    $script:Script = Join-Path (Split-Path $PSScriptRoot -Parent) 'azuredevops/Export-BuildValidationReport.ps1'
}

Describe 'Export-BuildValidationReport' {
    It 'parses without error' {
        $errors = $null
        [System.Management.Automation.Language.Parser]::ParseFile($script:Script, [ref]$null, [ref]$errors) | Out-Null
        $errors | Should -BeNullOrEmpty
    }

    It 'declares SupportsShouldProcess' {
        (Get-Content $script:Script -Raw) | Should -Match 'SupportsShouldProcess'
    }

    It 'writes no CSV under -WhatIf (R14: the CSV write must be ShouldProcess-gated like Export-CorporateRootCa.ps1)' {
        # This script calls Test-AzureDevOpsBuildValidation -> Invoke-AzureDevOpsApi -> Get-AzureDevOpsToken,
        # which shells out to az. No test may reach the network, and mocking the module from here does not
        # work: the script itself runs "Import-Module .../ScriptUtils -Force", which reloads a fresh module
        # session state and discards any Pester mock (verified empirically before writing this test -- see
        # task-12-report.md). So instead of mocking, PATH is temporarily cleared for this process only, which
        # makes "az" unresolvable: Invoke-AzCli's own "Get-Command az" check then fails locally and immediately,
        # with zero network I/O, regardless of whether this machine has az installed or a live SSO session.
        # The script's existing per-project try/catch (unchanged by this fix) turns that local failure into a
        # warning and an empty result set, so execution still reaches the new ShouldProcess-gated write below --
        # which is the behaviour under test.
        $out = Join-Path $TestDrive 'report.csv'
        $originalPath = $env:PATH
        try {
            $env:PATH = $TestDrive
            & $script:Script -Organization 'FakeOrg' -Project 'FakeProject' -OutputPath $out -WhatIf `
                -WarningAction SilentlyContinue -ErrorAction SilentlyContinue 3>&1 2>&1 | Out-Null
        }
        finally {
            $env:PATH = $originalPath
        }
        Test-Path $out | Should -BeFalse
    }
}
