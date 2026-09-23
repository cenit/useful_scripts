#!/usr/bin/env pwsh
Describe '.github/workflows/ci.yml' {
    BeforeAll {
        $script:Path = Join-Path (Split-Path $PSScriptRoot -Parent) '.github/workflows/ci.yml'
        $script:Text = Get-Content $script:Path -Raw
    }

    It 'exists' { Test-Path $script:Path | Should -BeTrue }

    It 'runs the analyzer with the repo settings file' {
        $script:Text | Should -Match 'PSScriptAnalyzerSettings\.psd1'
    }

    It 'installs PSScriptAnalyzer in both jobs that need it' {
        # tests/Lint.Tests.ps1 runs Invoke-ScriptAnalyzer, so the Pester job needs the
        # module too - it must not rely on the hosted image happening to ship it.
        ([regex]::Matches($script:Text, 'Install-Module PSScriptAnalyzer')).Count | Should -Be 2
    }

    It 'fails the build on failed tests rather than deferring' {
        $script:Text | Should -Match '\$cfg\.Run\.Exit\s*=\s*\$true'
    }

    It 'tests on both Windows and Ubuntu' {
        $script:Text | Should -Match 'windows-latest'
        $script:Text | Should -Match 'ubuntu-latest'
    }

    It 'does not persist credentials - no job pushes' {
        $script:Text | Should -Not -Match 'persist-credentials:\s*true'
        ([regex]::Matches($script:Text, 'persist-credentials:\s*false')).Count | Should -Be 2
    }

    It 'grants the token read-only access' {
        $script:Text | Should -Match '(?m)^permissions:\s*\n\s+contents:\s*read'
    }

    It 'does not disable TLS verification' {
        $script:Text | Should -Not -Match 'GIT_SSL_NO_VERIFY'
    }
}
