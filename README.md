# useful_scripts

Operator scripts: repository maintenance, Azure DevOps REST helpers,
environment diagnostics and build-agent upkeep. PowerShell 7 only.

## Install

```powershell
./Install.ps1            # adds ScriptUtils to your PowerShell profile
./Install.ps1 -WhatIf    # preview only, writes nothing
./Install.ps1 -Uninstall # removes the block again, leaving the rest of your profile alone
```

Installing is optional — every `.ps1` here runs standalone by path, whether or not
`Install.ps1` has ever been run.

## Module functions (`Modules/ScriptUtils`, v0.8.0)

| Function | Purpose |
|---|---|
| `Invoke-Git` | Runs git and throws on a non-zero exit code (opt out with `-AllowFailure`), so a failed step is never silently followed by more steps against a repo that didn't actually change |
| `Use-Location` | Runs a scriptblock in a directory and always returns to the caller's original location, even when the body throws |
| `Write-ScriptLog` | Timestamped console/file logging; trims the log file to its last 500 lines once it exceeds 1MB |
| `Get-AzureDevOpsToken` | Bearer token for the Azure DevOps REST API, cached in memory for the session only |
| `Invoke-AzureDevOpsApi` | REST wrapper with paging. Use instead of `az rest`, which cannot derive the AAD resource for `dev.azure.com` |
| `Get-AzureDevOpsActiveBuild` | In-progress runs, which a bare `az pipelines build list` hides. Filter with `-DefinitionId <int[]>` (numeric pipeline IDs) |
| `Set-AzureDevOpsPullRequestDescription` | Sets a PR description via REST and verifies the saved length — `az repos pr --description` silently keeps only the first line |
| `Test-AzureDevOpsBuildValidation` | Finds repositories whose PR builds never fire because no Build Validation policy exists on the target branch |
| `Test-AwsSession` | Detects a stale `~/.aws/credentials` file shadowing a live SSO session. Read-only; never runs `aws sso login` |
| `Test-GitBranchMerged` | Whether a branch's work already landed in another branch, by content rather than reachability — so it says "merged" for a squash-merged PR, where `git branch --merged` and `git branch -d` say otherwise |

## Scripts

| Script | Purpose |
|---|---|
| `Install.ps1` | Adds or removes the ScriptUtils import block from your PowerShell profile |
| `git/Update-CcmRefs.ps1` | Bump the CCM (cenit CMake modules) submodule pointer across every project checkout under a root directory |
| `git/Update-AllRepos.ps1` | Fetch and fast-forward every git repository in a directory; returns checkouts stranded on a squash-merged, upstream-deleted branch to their default branch (`-PruneMergedBranches` also deletes the stale branch) |
| `git/Update-ForkedRepos.ps1` | Clone or refresh the forks/mirrors defined in `git/forks.json` (see below) |
| `azuredevops/Export-BuildValidationReport.ps1` | Organisation-wide report of repositories missing PR build validation, optionally to CSV |
| `aws/Export-CorporateRootCa.ps1` | Export TLS-inspection root certificates as a PEM for a `custom-ca.crt` Docker stage |
| `agent/Invoke-PodmanPrune.ps1` | Weekly podman image-cache prune for build agents |
| `agent/Reset-PodmanMachine.ps1` | Recover a wedged or corrupted podman machine (`-StartOnly` for a patient restart first) |

Most mutating scripts support `-WhatIf` — start there. The one exception is
`agent/Invoke-PodmanPrune.ps1`: it runs unattended from Task Scheduler and always
exits 0 rather than prompting.

### `git/forks.json`

Each entry has `name`, `url` (your fork), `upstream`, `localBranch`, `upstreamBranch`,
`mode` and `skip`. `mode: fork` keeps a long-lived clone named `name` and merges
`upstream/<upstreamBranch>` into `localBranch`; `mode: mirror` pushes a throwaway
`--mirror` clone of `upstream` over `url`. A fork entry may add `remote` to name its
upstream remote (default `upstream`). Entries sharing a `name` share one clone, which is
how a fork following two upstreams on two branches is expressed — see `darknet_cenit`.

Build-agent deployment — first install, migrating an agent off the old filename,
verification, and the `Reset-PodmanMachine.ps1` recovery runbook — is documented in
[`agent/README.md`](agent/README.md).

## Renamed in the 2026-08 reorganisation

| Old | New |
|---|---|
| `update-all-ccm-refs.ps1` | `git/Update-CcmRefs.ps1` |
| `forks/update_all_repos.ps1` | `git/Update-AllRepos.ps1` |
| `forks/setup_update_forks.ps1` | `git/Update-ForkedRepos.ps1` |
| `podman-weekly-prune.ps1` | `agent/Invoke-PodmanPrune.ps1` |

Agents already running the old prune script keep working unmodified; see
`agent/README.md` for the one-time migration to the new path and filename.

## Older scripts

Bash helpers from earlier years, kept as they were: source builds of
toolchains and libraries (`build/`), CUPS printer configuration (`cups/`), cluster
and tape utilities (`fermi/`), data-transfer wrappers (`download/`), and a few
one-offs at the root.

## Tests

```powershell
Invoke-Pester ./tests
Invoke-ScriptAnalyzer -Path . -Recurse -Settings ./PSScriptAnalyzerSettings.psd1
```

Both must be clean before committing. CI (`.github/workflows/ci.yml`) runs the
same two on Windows and Ubuntu.

## Conventions

See `CLAUDE.md` for the module-vs-script split, the manifest-drift rule, and the
other conventions established during this reorganisation.
