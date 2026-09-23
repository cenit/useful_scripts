# Build agent scripts

Both scripts here are **self-contained on purpose**. They are copied to
`$HOME\scripts\` on machines that have no checkout of this repository, so they
import nothing from `Modules/`.

## Invoke-PodmanPrune.ps1

Weekly image-cache prune. An unattended agent accumulates dead layers until the
disk fills, and a disk-full event silently truncates a file inside a cached
layer — damage that surfaces much later as `file integrity checksum failed` on
push. Keeps a week of warm cache so normal builds stay fast, and always exits 0
so opportunistic maintenance never shows up as a failed scheduled task.

### First deployment to an agent

Run in an elevated session **on the agent**, as the account that owns the
rootless podman machine — the same account the `vstsagent` service runs as.

```powershell
New-Item -ItemType Directory -Force "$HOME\scripts" | Out-Null
Copy-Item .\agent\Invoke-PodmanPrune.ps1 "$HOME\scripts\"

$pwsh     = 'C:\Program Files\PowerShell\7\pwsh.exe'
$action   = New-ScheduledTaskAction -Execute $pwsh -Argument (
    '-NoProfile -NonInteractive -ExecutionPolicy Bypass -File "{0}\scripts\Invoke-PodmanPrune.ps1"' -f $HOME)
$trigger  = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 4am
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable `
    -ExecutionTimeLimit (New-TimeSpan -Hours 2) -MultipleInstances IgnoreNew

$cred = Get-Credential -UserName $env:USERNAME -Message 'Agent service account'
Register-ScheduledTask -TaskName 'Podman weekly image prune' `
    -Action $action -Trigger $trigger -Settings $settings `
    -User $cred.UserName -Password $cred.GetNetworkCredential().Password -RunLevel Limited `
    -Description 'Prunes podman images unused for >168h. Skips while a pipeline job is running.'
```

`Get-Credential`, not `Read-Host`: the password is typed into a masked prompt and
held as a `SecureString`, so it never appears on screen and never reaches a
PowerShell transcript, which build agents commonly have enabled by policy.

Password logon (not `-LogonType S4U`) is required: the task must reach the
per-user rootless podman machine, which needs a real user profile.

The script also accepts `-LogPath`, `-PodmanPath` and `-KeepHours` overrides
(all optional — the defaults above are correct for a standard agent); they
exist mainly so the script can be exercised in tests without touching a real
log file or a real image store.

### Migrating an agent from the old filename

Agents deployed before this repository was reorganised run
`$HOME\scripts\podman-weekly-prune.ps1`. They keep working — nothing breaks — but
their copy will drift from this one. Migrate each agent once:

```powershell
Unregister-ScheduledTask -TaskName 'Podman weekly image prune' -Confirm:$false
Remove-Item "$HOME\scripts\podman-weekly-prune.ps1" -ErrorAction SilentlyContinue
# then run the first-deployment block above
```

### Verify

```powershell
Start-ScheduledTask -TaskName 'Podman weekly image prune'
Get-Content "$HOME\scripts\podman-weekly-prune.log" -Tail 10
```

## Reset-PodmanMachine.ps1

For when a push fails with `file integrity checksum failed`. At that point the
store metadata is damaged too, so a prune cannot help — it walks the same damaged
metadata.

### Getting it onto the agent

Unlike the prune script this one is run by hand, during an incident, on a machine
that has no checkout of this repository. Copy it across first, from a workstation
that does have the checkout:

```powershell
# from the workstation, once per incident (or once, alongside the prune script)
Copy-Item .\agent\Reset-PodmanMachine.ps1 "\\<agent>\C$\Users\<agent-account>\scripts\"
```

or, in an elevated session **on the agent**, paste the file's contents into
`$HOME\scripts\Reset-PodmanMachine.ps1`. Everything below then runs from
`$HOME\scripts\` on the agent; the repo-relative paths shown are for a
workstation that does have a checkout.

Try a patient restart first; the local machine is slow far more often than it is
broken:

```powershell
.\Reset-PodmanMachine.ps1 -StartOnly       # on the agent, from $HOME\scripts
./agent/Reset-PodmanMachine.ps1 -StartOnly # from a checkout
```

If the store genuinely does not respond, reset it. This destroys every cached
image and the next build is cold:

```powershell
.\Reset-PodmanMachine.ps1 -WhatIf    # preview
.\Reset-PodmanMachine.ps1            # prompts, ConfirmImpact = High
```

`-User` defaults to `user`, which is the rootless account **inside** the WSL
machine that podman's WSL provider creates — it is not the Windows account the
agent service runs as, and passing that instead makes the reset fail exactly when
it is needed. Override it only if the machine's `RemoteUsername`, in
`~/.config/containers/podman/machine/wsl/<machine>.json`, says something else.
`-MachineName` (default `podman-machine-default`) and `-TimeoutSeconds` (default
180) are the other overrides.

Both scripts refuse to run while `Agent.Worker` is active, because prune and reset
both take the image-store lock.
