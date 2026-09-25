#!/usr/bin/env pwsh
BeforeAll {
    $script:ModulePath = Join-Path (Split-Path $PSScriptRoot -Parent) 'Modules/ScriptUtils'
    Import-Module $script:ModulePath -Force
}

Describe 'Use-Location' {
    It 'returns to the original directory when the scriptblock throws' {
        $origin = (Get-Location).Path
        $target = [System.IO.Path]::GetTempPath()
        { Use-Location -Path $target -ScriptBlock { throw 'boom' } } | Should -Throw
        (Get-Location).Path | Should -Be $origin
    }

    It 'returns the scriptblock result' {
        Use-Location -Path ([System.IO.Path]::GetTempPath()) -ScriptBlock { 42 } | Should -Be 42
    }
}

Describe 'Invoke-Git' {
    It 'throws when git exits non-zero' {
        { Invoke-Git -Arguments @('rev-parse', '--verify', 'refs/heads/definitely-no-such-branch') } |
            Should -Throw
    }

    It 'does not throw with -AllowFailure' {
        { Invoke-Git -Arguments @('rev-parse', '--verify', 'refs/heads/definitely-no-such-branch') -AllowFailure } |
            Should -Not -Throw
    }

    It 'returns stdout for a successful call' {
        Invoke-Git -Arguments @('rev-parse', '--is-inside-work-tree') | Should -Be 'true'
    }

    It 'sets $LASTEXITCODE non-zero across the module boundary when -AllowFailure absorbs a failure' {
        Invoke-Git -Arguments @('rev-parse', '--verify', 'refs/heads/definitely-no-such-branch') -AllowFailure | Out-Null
        $LASTEXITCODE | Should -Not -Be 0
    }

    It 'sets $LASTEXITCODE to 0 across the module boundary for a succeeding command' {
        Invoke-Git -Arguments @('rev-parse', '--is-inside-work-tree') | Out-Null
        $LASTEXITCODE | Should -Be 0
    }
}

Describe 'Hide-UrlCredential' {
    # FAKE-TOKEN-DO-NOT-USE is deliberately not shaped like any real token format.
    It 'strips userinfo from a <_> URL' -ForEach @('https', 'http', 'ssh') {
        InModuleScope ScriptUtils -Parameters @{ Scheme = $_ } {
            param($Scheme)
            $redacted = Hide-UrlCredential -Text "clone ${Scheme}://operator:FAKE-TOKEN-DO-NOT-USE@example.invalid/o/p"
            $redacted | Should -Be "clone ${Scheme}://example.invalid/o/p"
        }
    }

    It 'leaves a credential-free URL untouched' {
        InModuleScope ScriptUtils {
            Hide-UrlCredential -Text 'https://dev.azure.com/Org/Proj/_git/repo' |
                Should -Be 'https://dev.azure.com/Org/Proj/_git/repo'
        }
    }

    It 'leaves the scp-style remote form untouched (a username, never a password)' {
        InModuleScope ScriptUtils {
            Hide-UrlCredential -Text 'git@ssh.dev.azure.com:v3/Org/Proj/repo' |
                Should -Be 'git@ssh.dev.azure.com:v3/Org/Proj/repo'
        }
    }
}

Describe 'Invoke-Git credential redaction' {
    # `git rev-parse --verify <string>` fails locally with exit 128 and never opens a
    # connection, so these exercise the failure path without any network traffic.
    It 'keeps a <_> credential out of the thrown message' -ForEach @('https', 'http', 'ssh') {
        $url = "${_}://operator:FAKE-TOKEN-DO-NOT-USE@example.invalid/o/p"
        $ex = { Invoke-Git -Arguments @('rev-parse', '--verify', $url) } | Should -Throw -PassThru
        $ex.Exception.Message | Should -Not -Match 'FAKE-TOKEN-DO-NOT-USE'
        $ex.Exception.Message | Should -Not -Match 'operator'
        $ex.Exception.Message | Should -Match 'example\.invalid'
    }

    It 'keeps a credential out of verbose output' {
        $url = 'https://operator:FAKE-TOKEN-DO-NOT-USE@example.invalid/o/p'
        $verbose = Invoke-Git -Arguments @('rev-parse', '--verify', $url) -AllowFailure -Verbose 4>&1 |
            Where-Object { $_ -is [System.Management.Automation.VerboseRecord] }
        "$verbose" | Should -Not -Match 'FAKE-TOKEN-DO-NOT-USE'
        "$verbose" | Should -Match 'example\.invalid'
    }
}

Describe 'Write-ScriptLog' {
    It 'appends a timestamped line to the log file' {
        $log = Join-Path $TestDrive 'test.log'
        Write-ScriptLog -Message 'hello' -LogPath $log
        Get-Content $log | Should -Match '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\s+hello$'
    }

    It 'trims a log larger than 1MB to 500 lines' {
        $log = Join-Path $TestDrive 'big.log'
        Set-Content $log -Value (1..40000 | ForEach-Object { "line $_ padding padding padding padding" })
        (Get-Item $log).Length | Should -BeGreaterThan 1MB
        Write-ScriptLog -Message 'after trim' -LogPath $log
        (Get-Content $log).Count | Should -BeLessOrEqual 501
    }
}

Describe 'Module surface' {
    It 'exports exactly Get-AzureDevOpsActiveBuild, Get-AzureDevOpsToken, Invoke-AzureDevOpsApi, Invoke-Git, Set-AzureDevOpsPullRequestDescription, Test-AzureDevOpsBuildValidation, Test-AwsSession, Test-GitBranchMerged, Use-Location and Write-ScriptLog' {
        $exported = (Get-Module ScriptUtils).ExportedFunctions.Keys
        $exported | Should -Contain 'Get-AzureDevOpsActiveBuild'
        $exported | Should -Contain 'Get-AzureDevOpsToken'
        $exported | Should -Contain 'Invoke-AzureDevOpsApi'
        $exported | Should -Contain 'Invoke-Git'
        $exported | Should -Contain 'Set-AzureDevOpsPullRequestDescription'
        $exported | Should -Contain 'Test-AzureDevOpsBuildValidation'
        $exported | Should -Contain 'Test-AwsSession'
        $exported | Should -Contain 'Test-GitBranchMerged'
        $exported | Should -Contain 'Use-Location'
        $exported | Should -Contain 'Write-ScriptLog'
        @($exported).Count | Should -Be 10
    }
}
