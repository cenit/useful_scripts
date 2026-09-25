# useful_scripts

Operator scripts. PowerShell 7 only.

## Module or script?

- **Module function** (`Modules/ScriptUtils/Public/`) if it is a building block,
  composable, or something you would call at an interactive prompt.
- **`.ps1` script** if it is scheduled, deployed to a machine, or walks the
  filesystem performing mutations.

`Modules/ScriptUtils/Private/` holds helpers that are not exported — extend one of
those instead of duplicating REST/CLI-invocation logic in a new `Public/` function.

`Install.ps1` at the repo root is the one exception to the domain grouping below: it
bootstraps the module into a user's profile, so it lives at the root rather than
under `git/`, `azuredevops/`, `aws/` or `agent/`.

## Rules

- Approved verbs, PascalCase `Verb-Noun.ps1`. No snake_case, no kebab-case.
- Every new `Public/` function must be added to **both** `FunctionsToExport` and
  `FileList` in `ScriptUtils.psd1`, with a `ModuleVersion` bump. Drift between
  those two lists is silent — nothing fails until a caller tries to import a
  function that was added to `FileList` but never exported, or vice versa.
- Every git call goes through `Invoke-Git`, which checks the exit code and throws
  unless the caller passes `-AllowFailure`. Never shell out to `git` directly in a
  loop over repositories — a swallowed failure there looks identical to success.
  After `-AllowFailure`, branch on `$LASTEXITCODE`, never on the returned value:
  `Invoke-Git` runs git with `2>&1`, so on failure the return value is git's own
  error text. `if (-not $result) { <fallback> }` can therefore never fire, and the
  error message flows on into the next git call as if it were data.
- `Invoke-Git` and `Resolve-AzureDevOpsContext` pass arguments, output and remote
  URLs through the private `Hide-UrlCredential` before logging or throwing.
  Anything new that echoes a remote URL must do the same — a URL of the form
  `https://user:PAT@host` otherwise lands in a transcript or a build log.
- Every directory change goes through `Use-Location`, which pops back to the
  caller's location in a `finally`, even when the body throws. Never pair
  `Push-Location`/`Pop-Location` by hand.
- Every state-mutating function or script declares
  `[CmdletBinding(SupportsShouldProcess)]` and gates its mutation behind
  `$PSCmdlet.ShouldProcess(...)`. The one deliberate exception is
  `agent/Invoke-PodmanPrune.ps1` — it runs unattended from Task Scheduler with
  nobody to prompt, and always exits 0 instead.
- Never use `az rest` against `dev.azure.com` — it cannot derive the AAD resource
  for that host, and its cmd.exe wrapper eats `&` in URLs on Windows anyway. Use
  `Invoke-AzureDevOpsApi`.
- Never resolve the Azure DevOps organisation or project from Azure CLI defaults.
  Organisations differ per project; `Resolve-AzureDevOpsContext`
  reads the git remote of the repository you are actually standing in instead.
- Diagnostic functions (`Test-AwsSession`, `Test-AzureDevOpsBuildValidation`)
  report and instruct. They never perform interactive logins or otherwise mutate
  state on your behalf — `Test-AwsSession` will tell you to run
  `aws sso login` yourself, never run it for you.
- The Azure DevOps token (`Get-AzureDevOpsToken`) is cached in memory only, for
  the session. Never write it to disk, a log, or error output.

## Scripts under `agent/` are deliberately self-contained

They are copied to `$HOME\scripts\` on machines with no checkout of this
repository, so they import nothing from `Modules/` — duplicated helpers there
(e.g. the `Write-PruneLog` function inside `Invoke-PodmanPrune.ps1`) are
intentional, not an oversight to "fix" by wiring in `Write-ScriptLog`. Their
filenames are referenced by Task Scheduler entries on live agents, so renaming one
requires the migration steps documented in `agent/README.md`, not just a `git mv`.

## Testing hazards

- `Install.ps1` modifies a real user's PowerShell profile. Every test for it must
  pass an explicit `-ProfilePath` pointing under Pester's `$TestDrive`. Never
  invoke it without `-ProfilePath`, and never against `$PROFILE` itself, even to
  "just preview" — use `-WhatIf` against a `$TestDrive` path instead.
- Tests that exercise the git-walking scripts (`git/Update-CcmRefs.ps1`,
  `git/Update-AllRepos.ps1`, `git/Update-ForkedRepos.ps1`) build real local/bare
  git fixtures under `$TestDrive` rather than mocking git — a mocked `git` can't
  prove `$PSCmdlet.ShouldProcess` actually resolves inside a `Use-Location`
  scriptblock, or that a merge conflict really aborts without pushing.
- Pester v5 resolves `-ForEach` during the discovery pass, before any `BeforeAll`
  runs. Any `$script:`-scoped variable an `-ForEach` array depends on must be set
  as a plain top-level statement (not only inside `BeforeAll`); see
  `tests/GitScripts.Tests.ps1` for the pattern (set once at top level for
  discovery, and again inside `BeforeAll` for anything referenced directly by an
  `It` body during the run phase).

## Before committing

```powershell
Invoke-Pester ./tests
Invoke-ScriptAnalyzer -Path . -Recurse -Settings ./PSScriptAnalyzerSettings.psd1
```

Both must be clean. `tests/Lint.Tests.ps1` already asserts the analyzer run
returns zero findings repo-wide — fix a finding at its source, never suppress it
with an inline `SuppressMessageAttribute` unless the rule is a genuine false
positive (see `Test-AwsSession.ps1`'s suppression of
`PSAvoidUsingPlainTextForPassword` on a parameter that is a file path, not a
credential, for the one existing example of a justified exception).
