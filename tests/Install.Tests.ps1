#!/usr/bin/env pwsh
BeforeAll {
    $script:Root    = Split-Path $PSScriptRoot -Parent
    $script:Install = Join-Path $script:Root 'Install.ps1'
}

Describe 'Install.ps1' {
    It 'adds an import block to a fresh profile' {
        $profilePath = Join-Path $TestDrive 'profile.ps1'
        & $script:Install -ProfilePath $profilePath | Out-Null
        $content = Get-Content $profilePath -Raw
        $content | Should -Match 'ScriptUtils'
        $content | Should -Match '# >>> useful_scripts >>>'
    }

    It 'is idempotent' {
        $profilePath = Join-Path $TestDrive 'profile2.ps1'
        & $script:Install -ProfilePath $profilePath | Out-Null
        & $script:Install -ProfilePath $profilePath | Out-Null
        ([regex]::Matches((Get-Content $profilePath -Raw), '# >>> useful_scripts >>>')).Count |
            Should -Be 1
    }

    It 'preserves existing profile content' {
        $profilePath = Join-Path $TestDrive 'profile3.ps1'
        Set-Content $profilePath -Value 'Set-Alias ll Get-ChildItem'
        & $script:Install -ProfilePath $profilePath | Out-Null
        (Get-Content $profilePath -Raw) | Should -Match 'Set-Alias ll Get-ChildItem'
    }

    It 'removes only its own block on -Uninstall' {
        $profilePath = Join-Path $TestDrive 'profile4.ps1'
        Set-Content $profilePath -Value 'Set-Alias ll Get-ChildItem'
        & $script:Install -ProfilePath $profilePath | Out-Null
        & $script:Install -ProfilePath $profilePath -Uninstall | Out-Null
        $content = Get-Content $profilePath -Raw
        $content | Should -Match 'Set-Alias ll Get-ChildItem'
        $content | Should -Not -Match 'useful_scripts'
    }

    It 'writes nothing under -WhatIf' {
        $profilePath = Join-Path $TestDrive 'profile5.ps1'
        & $script:Install -ProfilePath $profilePath -WhatIf | Out-Null
        Test-Path $profilePath | Should -BeFalse
    }
}

Describe 'README' {
    It 'documents every standalone entrypoint script in the repository' {
        # R4: scoped to the standalone entrypoints (git/, azuredevops/, aws/, agent/, and
        # root-level Install.ps1). Modules/ is excluded on purpose: the README documents
        # module functions by function name (e.g. Get-AzureDevOpsToken), not by the
        # filename the function happens to live in, and Private/ helpers are deliberately
        # undocumented there.
        $readme = Get-Content (Join-Path $script:Root 'README.md') -Raw
        $entrypointDirs = @('git', 'azuredevops', 'aws', 'agent')
        $scripts = Get-ChildItem $script:Root -Recurse -Filter '*.ps1' |
            Where-Object { $_.FullName -notmatch '\\tests\\' } |
            Where-Object {
                $relative = $_.FullName.Substring($script:Root.Length).TrimStart('\', '/')
                $topDir = ($relative -split '[\\/]')[0]
                ($topDir -in $entrypointDirs) -or ($relative -eq $_.Name)
            }
        $scripts.Count | Should -BeGreaterThan 0
        foreach ($s in $scripts) {
            $readme | Should -Match ([regex]::Escape($s.Name))
        }
    }

    It 'maps old paths to new ones' {
        $readme = Get-Content (Join-Path $script:Root 'README.md') -Raw
        $readme | Should -Match 'update-all-ccm-refs\.ps1'
        $readme | Should -Match 'setup_update_forks\.ps1'
    }
}
