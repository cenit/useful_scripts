#! /usr/bin/env pwsh

<#

.SYNOPSIS
        update-all-ccm-refs
        Created By: Stefano Sinigardi
        Created Date: February 18, 2019
        Last Modified Date: December 14, 2022

.DESCRIPTION
Update ccm refs in all cloned repositories

.PARAMETER DisableInteractive
Disable script interactivity (useful for CI runs)

.EXAMPLE
.\update-all-ccm-refs

#>

<#
Copyright (c) Stefano Sinigardi

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
#>

param (
  [switch]$DisableCCMUpdate = $false,
  [switch]$DisableInteractive = $false
)

$global:DisableInteractive = $DisableInteractive

$update_all_ccm_refs_ps1_version = "1.0.0"

Import-Module -Name $PSScriptRoot/utils.psm1 -Force

Write-Host "Update script version ${update_all_ccm_refs_ps1_version}, utils module version ${utils_psm1_version}"

$GIT_EXE = Get-Command "git" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Definition
if (-Not $GIT_EXE) {
  MyThrow("Could not find git, please install it")
}
else {
  Write-Host "Using git from ${GIT_EXE}"
}

Get-ChildItem $PSScriptRoot/.. -Directory | ForEach-Object {
  Push-Location $_.FullName
  Write-Host $_.FullName
  git pull
  git submodule update --recursive

  if (-Not $DisableCCMUpdate) {
    $CCMRepoArray = @("cmake", "ci", "ccm") | ForEach-Object { Get-ChildItem -Directory . -Filter $_ }
    ForEach ($CCMRepo in $CCMRepoArray) {
      $CCMRepoLeaf = Split-Path $CCMRepo -Leaf
      Write-Host "Updating ccm submodule ($CCMRepoLeaf) if necessary"
      Set-Location "$CCMRepo"
      git checkout master
      git pull
      Set-Location ..
      git add $CCMRepoLeaf
      git commit -m "Update ccm submodule"
      git push
    }
  }

  Pop-Location
}
