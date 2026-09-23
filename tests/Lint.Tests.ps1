#!/usr/bin/env pwsh

Describe 'PSScriptAnalyzerSettings' {
    It 'exists at repo root' {
        $repoRoot = Split-Path $PSScriptRoot -Parent
        $settingsPath = Join-Path $repoRoot 'PSScriptAnalyzerSettings.psd1'
        $settingsPath | Should -Exist
    }

    It 'parses as valid PowerShell data' {
        $repoRoot = Split-Path $PSScriptRoot -Parent
        $settingsPath = Join-Path $repoRoot 'PSScriptAnalyzerSettings.psd1'
        { Import-PowerShellDataFile $settingsPath } | Should -Not -Throw
    }

    It 'declares Severity key' {
        $repoRoot = Split-Path $PSScriptRoot -Parent
        $settingsPath = Join-Path $repoRoot 'PSScriptAnalyzerSettings.psd1'
        $settings = Import-PowerShellDataFile $settingsPath
        $settings.Keys -contains 'Severity' | Should -Be $true
    }

    It 'declares ExcludeRules key' {
        $repoRoot = Split-Path $PSScriptRoot -Parent
        $settingsPath = Join-Path $repoRoot 'PSScriptAnalyzerSettings.psd1'
        $settings = Import-PowerShellDataFile $settingsPath
        $settings.Keys -contains 'ExcludeRules' | Should -Be $true
    }
}

Describe 'Line endings' {
    It 'declares LF for PowerShell files' {
        $repoRoot = Split-Path $PSScriptRoot -Parent
        $attrs = Get-Content (Join-Path $repoRoot '.gitattributes') -Raw
        $attrs | Should -Match '\*\.ps1\s+text\s+eol=lf'
    }
}

Describe 'PSScriptAnalyzer' {
    It 'reports zero findings across the whole repository' {
        $repoRoot = Split-Path $PSScriptRoot -Parent
        $settingsPath = Join-Path $repoRoot 'PSScriptAnalyzerSettings.psd1'
        $results = Invoke-ScriptAnalyzer -Path $repoRoot -Recurse -Settings $settingsPath
        $summary = $results | ForEach-Object { "$($_.ScriptPath):$($_.Line) $($_.RuleName) - $($_.Message)" }
        $results | Should -BeNullOrEmpty -Because ($summary -join "`n")
    }
}
