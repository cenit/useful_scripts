# Changelog

All notable changes to this repository are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Changed
- The `forks/setup_update_forks.ps1` repository list now lives in
  `git/forks.json`, read by `git/Update-ForkedRepos.ps1`. The darknet special
  case (two upstreams merged into two branches) is expressed as two entries
  sharing a clone.
- CI runs on GitHub Actions (`.github/workflows/ci.yml`).

### Fixed
- `Update-AllRepos.ps1` reported a repository as failed whenever its checkout sat
  on a branch whose upstream had been deleted — the ordinary end state of a
  squash-merged pull request, since `--prune` removes the ref the branch tracks
  and `git pull --ff-only` then has nothing to fast-forward to. It now returns
  such a checkout to its default branch, and warns and leaves it alone instead
  when the branch's work is *not* in the default branch (an abandoned PR), when
  the working tree is dirty, or when no default branch can be resolved.

### Added
- `Update-ForkedRepos.ps1` accepts an optional per-entry `remote` naming the
  upstream remote, and adds a missing upstream remote to an existing clone
  instead of failing on the fetch.
- `Test-GitBranchMerged` answers "has this branch already landed?" by content
  rather than reachability, so a squash-merged branch reads as merged. Git's own
  reachability check — the one behind `git branch --merged` and `git branch -d` —
  cannot: a squash merge replaces the branch's commits with one new commit
  carrying a different SHA and no parent link back.
- `Update-AllRepos.ps1 -PruneMergedBranches` deletes the stale local branch after
  returning the checkout to its default branch. Opt-in, because deleting branches
  is the only irreversible thing the script does.
- `tests/ScriptUtils.Manifest.Tests.ps1` fails the build on drift between the
  files in `Public/`, `FunctionsToExport` and `FileList`, which was previously
  silent until an importer hit a missing function.

## [1.0.0] - 2026-08-19

### Fixed
- `Update-CcmRefs.ps1` (formerly `update-all-ccm-refs.ps1`) imported a
  `utils.psm1` that has never existed in this repository, so it threw at import
  and had never run successfully.
- `Update-CcmRefs.ps1` fed git's own error text into `git checkout` when a
  submodule had no `origin/HEAD`: `Invoke-Git -AllowFailure` returns stderr on
  failure, so the `'master'` fallback could never fire. The same idiom defect
  made a failed `git status` look like a moved submodule pointer.
- `Update-ForkedRepos.ps1` could merge and push onto whatever branch happened to
  be checked out when the checkout gate was declined, and ran both `git fetch`
  calls - including `--prune`, which deletes remote-tracking refs - under
  `-WhatIf`.
- `Reset-PodmanMachine.ps1` defaulted `-User` to the Windows account name, but
  podman's WSL provider provisions a rootless user literally named `user`, so
  the documented recovery failed exactly when it was needed.
- CI: the Pester job now installs PSScriptAnalyzer, which `tests/Lint.Tests.ps1`
  needs, instead of relying on the hosted image shipping it.

### Security
- `Invoke-Git` and `Resolve-AzureDevOpsContext` redact URL credentials through a
  shared `Hide-UrlCredential` helper before anything reaches verbose output or an
  exception message, for every scheme rather than `https://` only.
- `agent/README.md` uses `Get-Credential` instead of a plaintext `Read-Host`
  prompt for the scheduled-task password.

### Added
- `Modules/ScriptUtils` with Azure DevOps REST, AWS session and git helpers.
- CI: PSScriptAnalyzer lint gate plus a Pester matrix on Windows and Ubuntu.
- Repo scaffolding: `LICENSE`, `CHANGELOG.md`, `CLAUDE.md`, `.gitattributes`.

### Changed
- Scripts renamed to approved-verb PascalCase and grouped by domain.
