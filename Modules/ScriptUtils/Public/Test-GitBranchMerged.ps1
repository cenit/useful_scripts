#!/usr/bin/env pwsh
function Test-GitBranchMerged {
    <#
    .SYNOPSIS
        Reports whether a branch's work is already contained in another branch, including
        when it landed as a squash merge.
    .DESCRIPTION
        `git branch --merged` and `git branch -d` both answer by reachability: is the
        branch tip an ancestor of the target? A squash merge replaces a branch's commits
        with a single new commit that has a different SHA and no parent link back to the
        branch, so reachability reports "not merged" for work that is demonstrably
        already in. That is why `git branch -d` refuses to clean up after a completed,
        squash-merged pull request.

        This answers by content instead. It first asks the cheap reachability question,
        which settles fast-forwards and real merge commits. Failing that it replays the
        whole branch as one commit on top of its merge base - the exact shape a squash
        merge produces - and asks `git cherry` whether an equivalent patch already exists
        in the target. That is the same patch-id comparison git uses to spot
        already-applied commits during a rebase, so it survives the SHA rewrite.

        Every failure path returns $false. Callers use this to decide whether deleting a
        branch is safe, so an error has to read as "not merged": that leaves a stale
        branch behind, whereas an error reading as "merged" destroys work.
    .PARAMETER Branch
        The branch whose work is in question, e.g. 'feature/x'.
    .PARAMETER Into
        The branch it may have landed in, e.g. 'origin/master'.
    .OUTPUTS
        System.Boolean
    .EXAMPLE
        Test-GitBranchMerged -Branch 'fix/typo' -Into 'origin/master'

        True even when the PR was squashed, where `git branch --merged` says otherwise.
    .NOTES
        Runs against the current location, like Invoke-Git.

        The probe writes one dangling commit object via `git commit-tree`. Nothing
        references it and `git gc` collects it in due course; this is the standard
        technique for the question and needs no cleanup.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)][string]$Branch,
        [Parameter(Mandatory)][string]$Into
    )

    # Reachability first. Besides being cheap, this is the only thing that correctly
    # settles a branch carrying no commits of its own: replaying such a branch yields an
    # empty diff, and an empty patch has no patch-id for `git cherry` to match.
    Invoke-Git -Arguments @('merge-base', '--is-ancestor', $Branch, $Into) -AllowFailure | Out-Null
    if ($LASTEXITCODE -eq 0) { return $true }

    # Invoke-Git runs git with 2>&1, so on failure its *return value* is git's error text,
    # not $null or an empty string. Only $LASTEXITCODE separates an answer from an error -
    # a truthiness test on the output would happily carry "fatal: ..." on as a SHA.
    $mergeBase = Invoke-Git -Arguments @('merge-base', $Into, $Branch) -AllowFailure
    if ($LASTEXITCODE -ne 0) { return $false }
    $mergeBase = "$($mergeBase | Select-Object -First 1)".Trim()

    $tree = Invoke-Git -Arguments @('rev-parse', "${Branch}^{tree}") -AllowFailure
    if ($LASTEXITCODE -ne 0) { return $false }
    $tree = "$($tree | Select-Object -First 1)".Trim()

    $probe = Invoke-Git -Arguments @('commit-tree', $tree, '-p', $mergeBase, '-m', 'squash-merge probe') -AllowFailure
    if ($LASTEXITCODE -ne 0) { return $false }
    $probe = "$($probe | Select-Object -First 1)".Trim()

    $cherry = Invoke-Git -Arguments @('cherry', $Into, $probe) -AllowFailure
    if ($LASTEXITCODE -ne 0) { return $false }

    # `git cherry` prefixes '-' when an equivalent patch is already in $Into, '+' when it
    # is not. The probe commit is brand new and unreachable from $Into, so exactly one
    # line is expected; no output at all means something went wrong that did not set a
    # non-zero exit code, and the safe reading of that is "not merged".
    $lines = @($cherry) | Where-Object { "$_".Trim() }
    if (-not $lines) { return $false }
    -not ($lines -match '^\s*\+')
}
