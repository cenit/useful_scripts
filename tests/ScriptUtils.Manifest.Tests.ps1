#!/usr/bin/env pwsh
# Drift between the files on disk, FunctionsToExport and FileList is silent: nothing
# fails until a caller imports the module and finds a function missing, which happens
# on someone else's machine, long after the commit that caused it.
BeforeAll {
    $script:ModuleRoot = Join-Path (Split-Path $PSScriptRoot -Parent) 'Modules/ScriptUtils'
    $script:Manifest = Import-PowerShellDataFile (Join-Path $script:ModuleRoot 'ScriptUtils.psd1')
    $script:PublicNames = @(
        Get-ChildItem -Path (Join-Path $script:ModuleRoot 'Public') -Filter '*.ps1' |
            Select-Object -ExpandProperty BaseName
    )
}

Describe 'ScriptUtils.psd1' {
    It 'exports exactly the functions present in Public/' {
        # ScriptUtils.psm1 dot-sources Public/*.ps1 and exports by BaseName, so a file
        # missing from FunctionsToExport is loaded but unreachable to an importer.
        ($script:Manifest.FunctionsToExport | Sort-Object) |
            Should -Be ($script:PublicNames | Sort-Object)
    }

    It 'lists every module file in FileList' {
        $onDisk = @(
            Get-ChildItem -Path $script:ModuleRoot -Recurse -File -Include '*.ps1', '*.psm1' |
                ForEach-Object {
                    $_.FullName.Substring($script:ModuleRoot.Length).TrimStart('\', '/') -replace '\\', '/'
                }
        )
        ($script:Manifest.FileList | Sort-Object) | Should -Be ($onDisk | Sort-Object)
    }

    It 'is a valid manifest that Test-ModuleManifest accepts' {
        { Test-ModuleManifest (Join-Path $script:ModuleRoot 'ScriptUtils.psd1') -ErrorAction Stop } |
            Should -Not -Throw
    }
}
