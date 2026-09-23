#!/usr/bin/env pwsh
BeforeAll {
    Import-Module (Join-Path (Split-Path $PSScriptRoot -Parent) 'Modules/ScriptUtils') -Force
}

Describe 'Test-AwsSession' {
    It 'flags a static credentials file that shadows SSO' {
        $creds = Join-Path $TestDrive 'credentials'
        Set-Content $creds -Value "[default]`naws_access_key_id = AKIAEXAMPLE`naws_secret_access_key = secret"
        InModuleScope ScriptUtils -Parameters @{ p = $creds } {
            Mock Invoke-AwsCli { '{"Account":"123456789012","Arn":"arn:aws:sts::123456789012:assumed-role/x/y"}' }
            $r = Test-AwsSession -CredentialsPath $p
            $r.HasStaticCredentialsFile | Should -BeTrue
            $r.IsHealthy                | Should -BeFalse
            ($r.Problems -join ' ')     | Should -Match 'credentials'
            ($r.Remediation -join ' ')  | Should -Match 'Remove-Item'
        }
    }

    It 'reports healthy when no static credentials file exists' {
        InModuleScope ScriptUtils -Parameters @{ p = (Join-Path $TestDrive 'absent') } {
            Mock Invoke-AwsCli { '{"Account":"123456789012","Arn":"arn:aws:sts::123456789012:assumed-role/x/y"}' }
            $r = Test-AwsSession -CredentialsPath $p
            $r.HasStaticCredentialsFile | Should -BeFalse
            $r.IsHealthy                | Should -BeTrue
            $r.Account                  | Should -Be '123456789012'
        }
    }

    It 'reports an expired session as unhealthy' {
        InModuleScope ScriptUtils -Parameters @{ p = (Join-Path $TestDrive 'absent') } {
            Mock Invoke-AwsCli { throw 'The SSO session associated with this profile has expired' }
            $r = Test-AwsSession -CredentialsPath $p
            $r.IsHealthy               | Should -BeFalse
            ($r.Problems -join ' ')    | Should -Match 'expired'
            ($r.Remediation -join ' ') | Should -Match 'aws sso login'
        }
    }

    It 'never invokes aws sso login itself' {
        InModuleScope ScriptUtils -Parameters @{ p = (Join-Path $TestDrive 'absent') } {
            Mock Invoke-AwsCli { throw 'expired' }
            Test-AwsSession -CredentialsPath $p | Out-Null
            Should -Invoke Invoke-AwsCli -ParameterFilter { $Arguments -contains 'login' } -Times 0
        }
    }

    It 'ignores a credentials file that contains only comments' {
        $creds = Join-Path $TestDrive 'commented'
        Set-Content $creds -Value "# all commented out`n# aws_access_key_id = X"
        InModuleScope ScriptUtils -Parameters @{ p = $creds } {
            Mock Invoke-AwsCli { '{"Account":"1","Arn":"arn:aws:sts::1:assumed-role/x/y"}' }
            (Test-AwsSession -CredentialsPath $p).HasStaticCredentialsFile | Should -BeFalse
        }
    }
}
