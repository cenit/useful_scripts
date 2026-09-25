#!/usr/bin/env pwsh
function Hide-UrlCredential {
    <#
    .SYNOPSIS
        Removes the userinfo part of any URL embedded in a string.
    .DESCRIPTION
        A URL of the form <scheme>://<user>[:<password>]@<host>/... carries a
        credential in plain sight. Anything that echoes a git argument list, a
        remote URL or a subprocess's output can therefore leak a PAT into a
        transcript, a build log or an exception message.

        This strips the whole userinfo segment (user and password alike) for any
        scheme - https, http, ssh, git+ssh - rather than https only, because an
        operator's remote can use any of them.

        The scp-style form (user@host:path) is deliberately left alone: it carries
        a username but never a password, and rewriting it would mangle a remote
        name that is safe to show.
    .PARAMETER Text
        The text to redact. Any number of URLs anywhere in the string are handled.
    .OUTPUTS
        System.String - the text with every <scheme>://userinfo@ reduced to
        <scheme>://.
    .EXAMPLE
        Hide-UrlCredential -Text 'push https://me:secret@dev.azure.com/o/p/_git/r'
        # -> 'push https://dev.azure.com/o/p/_git/r'
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([string]$Text)

    $Text -replace '(?i)\b([a-z][a-z0-9+.-]*://)[^@/\s]+@', '$1'
}
