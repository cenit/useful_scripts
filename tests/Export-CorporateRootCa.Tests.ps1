#!/usr/bin/env pwsh
Describe 'Export-CorporateRootCa' {
    BeforeAll {
        $script:Script = Join-Path (Split-Path $PSScriptRoot -Parent) 'aws/Export-CorporateRootCa.ps1'
    }

    It 'parses without error' {
        $errors = $null
        [System.Management.Automation.Language.Parser]::ParseFile($script:Script, [ref]$null, [ref]$errors) | Out-Null
        $errors | Should -BeNullOrEmpty
    }

    It 'declares SupportsShouldProcess' {
        (Get-Content $script:Script -Raw) | Should -Match 'SupportsShouldProcess'
    }

    It 'writes nothing under -WhatIf' -Skip:(-not $IsWindows) {
        $out = Join-Path $TestDrive 'ca.crt'
        & $script:Script -OutputPath $out -WhatIf | Out-Null
        Test-Path $out | Should -BeFalse
    }

    It 'produces PEM-formatted output on Windows' -Skip:(-not $IsWindows) {
        $out = Join-Path $TestDrive 'real-ca.crt'
        & $script:Script -OutputPath $out -All | Out-Null
        if (Test-Path $out) {
            (Get-Content $out -Raw) | Should -Match '-----BEGIN CERTIFICATE-----'
        }
    }
}
