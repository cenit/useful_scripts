#!/usr/bin/env pwsh

param(
    [switch]$InitSubmodules,
    [string]$rootDirectory = (Get-Location).Path
)

$version = "0.1"
Write-Host "Running setup_update_forks.ps1 version $version" -ForegroundColor Green

if (-not $rootDirectory) {
    $rootDirectory = Get-Location
}

$directories = Get-ChildItem -Path $rootDirectory -Directory

foreach ($dir in $directories) {
  Set-Location $dir.FullName

  if (Test-Path ".git") {
    Write-Host "Updating repository in $dir" -ForegroundColor Cyan
    git fetch --all
    git pull
    $submoduleUpdateCommand = "git submodule update --recursive"
    if ($InitSubmodules) {
      $submoduleUpdateCommand += " --init"
    }
    Invoke-Expression $submoduleUpdateCommand
  }

  Set-Location $rootDirectory
}

Write-Host "All repositories have been updated." -ForegroundColor Green
