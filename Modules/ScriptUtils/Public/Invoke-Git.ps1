#!/usr/bin/env pwsh
function Invoke-Git {
    <#
    .SYNOPSIS
        Invokes git and fails loudly on a non-zero exit code.
    .DESCRIPTION
        Bare git calls in a loop hide failures: the loop continues against a repo
        that did not actually update. This wrapper makes every failure terminating
        unless the caller explicitly opts out with -AllowFailure.
    .PARAMETER Arguments
        The git subcommand and its arguments, e.g. @('rev-parse', '--is-inside-work-tree').
    .PARAMETER AllowFailure
        Suppresses the throw on a non-zero exit code. The caller is then responsible
        for checking the result.
    .OUTPUTS
        System.String[] - the stdout (and, since git is invoked with 2>&1, stderr)
        lines produced by the command.
    .NOTES
        Arguments and subprocess output are passed through Hide-UrlCredential
        before they reach verbose output or the exception message: callers pass
        arbitrary remote URLs, and a URL of the form https://user:PAT@host would
        otherwise put the PAT into a transcript or a build log.

        After calling with -AllowFailure, check $LASTEXITCODE (the PowerShell
        automatic variable) to learn the outcome, not any module-scoped variable.
        $LASTEXITCODE is a global automatic variable that git's native invocation
        updates directly, so it is visible to the caller across the module
        boundary. A module-scoped variable such as $script:LastGitExitCode would
        NOT be visible from the calling script's scope and would read $null there.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string[]]$Arguments,
        [switch]$AllowFailure
    )
    $safeArguments = Hide-UrlCredential -Text ($Arguments -join ' ')
    Write-Verbose "git $safeArguments"
    $output = & git @Arguments 2>&1
    $script:LastGitExitCode = $LASTEXITCODE
    if ($LASTEXITCODE -ne 0 -and -not $AllowFailure) {
        # git echoes the remote URL back in its own error text, so the output needs
        # redacting as well as the argument list.
        $safeOutput = Hide-UrlCredential -Text ($output -join "`n")
        throw "git $safeArguments failed with exit code $LASTEXITCODE`n$safeOutput"
    }
    $output
}
