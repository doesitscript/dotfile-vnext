# windows_server_backup

First-milestone Windows Server Backup baseline for managed Windows hosts.

> Status: active but intentionally incomplete. This role is the current
> first-milestone baseline for Windows backup capability in the repo. It is
> meant to install and shape the baseline safely, not to represent a finished
> Windows backup program yet.

Canonical naming and zone contract:

- [docs/backup/backup-naming-contract.md](/Users/joshc/develop/dotfile-vnext/docs/backup/backup-naming-contract.md)

Current active scope:

- install `Windows-Server-Backup`
- validate the intended backup target drive
- create the repo-managed backup working structure under the accepted zones:
  - `native-host-recovery`
  - `backupsets`
  - `backup-catalog`
  - `staging`
- write a host-local README describing the managed baseline
- optionally trigger a one-time async manual native host-recovery backup run
- create a scheduled automatic native host-recovery backup task that uses a
  day-based cadence gate

## Apply / Verify / Undo / Change class

- Apply
  Run the dedicated playbook [windows_server_backup.yml](/Users/joshc/develop/dotfile-vnext/playbooks/windows_server_backup.yml)
  directly. `backup_apply` is now an optional explicit tag, not a required gate.
- Verify
  Use `--tags backup_preview`, inspect the scheduled task, inspect the run
  manifests under the backup catalog, and check `Get-WBJob` / `Get-WBSummary`
  on the host.
- Undo
  Set `windows_server_backup_state: absent` for the host and re-run the
  dedicated playbook.
- Change class
  Steady-state configuration with an explicitly triggered destructive/expensive
  side path only when a manual backup run is requested.

Current validation status:

- the milestone-one `present` path has been used as active repo work
- the broader backup program beyond this baseline is still in progress
- service-specific payload backups are not yet part of the active managed scope
- one-time async host-recovery triggering is active scope
- the role now manages an automatic scheduled-task wrapper for native
  host-recovery backups using a top-level interval-in-days variable
- the `absent` path removes the host-recovery payload, repo-managed backup
  context, scheduled task, run manifests, and backup feature by default, but
  still leaves the shared top-level zone roots in place

Current milestone-one physical direction:

- `E:\WindowsImageBackup\` for the native Windows host-recovery path
- `E:\backupsets\...` for repo-managed backup artifacts
- `E:\backup-catalog\...` for metadata and manifests
- `F:\staging\...` for temporary backup workspace

Not yet in active execution:

- service-specific backup targets for Postgres, ClickHouse, Redis, or MinIO

The role uses VSS copy mode for the one-time trigger path so later
service-specific application backups can coexist without this host-recovery
backup aggressively behaving like the only backup authority for app logs.

Those future service-target tasks are preserved in:

- `tasks/future_service_targets.yml`

## Lifecycle note

This dedicated playbook/role pair is intended to remain the user-facing
lifecycle surface for Windows backup capability on a host.

- `present`
  applies the Windows backup baseline, ensures the automatic scheduled task,
  and can optionally trigger a one-time manual native host-recovery backup
- `absent`
  removes the owned baseline work and host-recovery payload created by this
  capability on that host

## Preview vs apply

Use these as two different operating modes of the same playbook:

- `preview`
  Read-only inspection. This shows whether a host is in scope, what state the
  backup capability is in, whether an automatic backup is healthy or missing,
  whether a backup job is currently running, and what apply would do next. It
  does not create, remove, seed, reconcile, or trigger backups.
- `apply`
  Real lifecycle execution. This enforces the host's desired
  `windows_server_backup_state`, ensures the scheduled task and managed
  structure exist, seeds missing automatic backup state when configured to do
  so, reconciles managed automatic state when needed, and can trigger a manual
  backup only when explicitly requested.

In practice:

- use preview when you want to inspect safely before touching anything
- use apply when you want the host to converge to its desired backup state

Technical note:

- `--tags backup_preview`
  selects the preview-only tasks. Those tasks are tagged `never` plus
  `backup_preview`, so they run only when that tag is requested.
- plain playbook run
  uses Ansible's default task selection, so the normal apply path runs and the
  preview-only tasks stay skipped.

Commands:

```bash
ansible-playbook playbooks/windows_server_backup.yml --tags backup_preview --limit network-server-win
ansible-playbook playbooks/windows_server_backup.yml --limit network-server-win
```

## Manual vs automatic runs

Windows Server Backup does not expose a strong native custom label field for
individual backup versions, so this role stores the operator-facing backup name
and description in repo-managed run manifests.

- manual run controls:
  - `windows_server_backup_manual_run_now`
  - `windows_server_backup_manual_name`
  - `windows_server_backup_manual_description`
- automatic cadence control:
  - `windows_server_backup_automatic_interval_days`
  - `windows_server_backup_automatic_seed_if_missing`

The automatic cadence ignores manual backups when deciding whether a new
automatic run is due. Automatic retention keeps the newest automatic backup
plus the configured number of previous automatic backups.

### Automatic behavior

Automatic backups are intentionally managed separately from the manual
playbook-trigger path.

- the playbook ensures the automatic scheduled task exists
- by default, the apply path also seeds the first automatic backup immediately
  if the automatic task is managed but no automatic backup manifest exists yet
- that seed/reconcile start is launched in the background so apply can return
  with runtime status instead of waiting for the full backup to finish
- the scheduled task uses a stable anchor date plus the configured start time,
  so normal reruns do not report false changes just because the calendar date
  moved forward
- if the managed automatic manifest drifts from native backup reality, the
  playbook clears the managed automatic manifest state it owns and reseeds a
  clean automatic baseline instead of trying to repair a half-broken state
- that scheduled task wakes up daily at the configured start time
- the runner script then checks whether the configured number of days has
  elapsed since the last automatic backup
- if the interval has not elapsed, it exits without creating a backup
- if the interval has elapsed, it creates one automatic native host-recovery
  backup
- manual backups do not reset or satisfy the automatic interval
- automatic retention only applies to automatic backups

So the scheduled task is the controller, while
`windows_server_backup_automatic_interval_days` is what actually determines how
often an automatic backup occurs.

`windows_server_backup_automatic_seed_if_missing: true` closes the common
first-run gap by starting the first automatic backup during apply when the
managed automatic task exists but no automatic backup manifest has been created
yet.

The automatic reconcile logic now treats the automatic backup as healthy only
when the managed automatic manifest and an actual native backup version agree.
If that managed state is missing, incomplete, invalid, or drifted, the role
clears only the repo-managed automatic manifest state it owns and recreates a
clean automatic baseline. It does not try to partially repair the automatic
state in place.

This is normal rerun behavior, not a special recovery mode. Re-running the
playbook is expected to be safe:

- healthy state -> no-op
- missing automatic state -> seed the first automatic backup
- drifted managed automatic state -> clear the managed automatic catalog state
  and recreate a clean automatic baseline
- backup already running -> defer automatic reconciliation for that run

The preview and post-apply runtime summaries now report this as an explicit
decision map:

- automatic reconcile legend:
  - `healthy -> noop`
  - `missing -> seed`
  - `drifted -> reconcile`
  - `running -> defer`
- current automatic decision line:
  - preview: `If apply ran now automatic reconcile decision: <state> -> <action>`
  - apply: `This run automatic reconcile decision: <state> -> <action>`

That means the left side is the evaluated automatic state and the right side is
the resulting reconcile action the capability would take or did take.

After apply, the role also emits a runtime validation summary so the operator
can immediately see whether a backup job is running, how long it has been
running, current operation and progress, recent native backup versions, and
target-volume capacity posture. The preview path now surfaces the same core
runtime details before apply, including current job timing, percent complete,
payload bytes processed, and backup-target free space.

### Current default cadence

Current inventory default on `network-server-win`:

- `windows_server_backup_automatic_interval_days: 7`

That means the intended automatic cadence is one automatic backup every 7 days.

## Operator Examples

### Preview

Preview targeting and current host state without mutating anything:

```bash
ansible-playbook playbooks/windows_server_backup.yml --tags backup_preview
```

Preview only the first target host:

```bash
ansible-playbook playbooks/windows_server_backup.yml \
  --tags backup_preview \
  --limit network-server-win
```

### Baseline apply

Apply the managed Windows backup baseline without triggering a manual backup:

```bash
ansible-playbook playbooks/windows_server_backup.yml \
  --limit network-server-win
```

### Manual backup examples

Manual backup with generated name and generated description:

```bash
ansible-playbook playbooks/windows_server_backup.yml \
  --limit network-server-win \
  -e windows_server_backup_manual_run_now=true
```

Manual backup with generated name and custom description:

```bash
ansible-playbook playbooks/windows_server_backup.yml \
  --limit network-server-win \
  -e windows_server_backup_manual_run_now=true \
  -e 'windows_server_backup_manual_description=Before storage stack refactor'
```

Manual backup with custom name and custom description:

```bash
ansible-playbook playbooks/windows_server_backup.yml \
  --limit network-server-win \
  -e windows_server_backup_manual_run_now=true \
  -e 'windows_server_backup_manual_name=pre-refactor-checkpoint' \
  -e 'windows_server_backup_manual_description=Before storage stack refactor'
```

Manual backup with custom name only:

```bash
ansible-playbook playbooks/windows_server_backup.yml \
  --limit network-server-win \
  -e windows_server_backup_manual_run_now=true \
  -e 'windows_server_backup_manual_name=pre-refactor-checkpoint'
```

### Automatic cadence examples

Keep the normal one-week cadence from inventory:

```yaml
windows_server_backup_automatic_interval_days: 7
windows_server_backup_automatic_seed_if_missing: true
```

Temporarily test a three-week cadence without editing inventory:

```bash
ansible-playbook playbooks/windows_server_backup.yml \
  --limit network-server-win \
  -e windows_server_backup_automatic_interval_days=21
```

Disable first-run automatic seeding for a run:

```bash
ansible-playbook playbooks/windows_server_backup.yml \
  --limit network-server-win \
  -e windows_server_backup_automatic_seed_if_missing=false
```

### Removal

Remove the managed Windows backup capability from the host:

Inventory:

```yaml
windows_server_backup_state: absent
```

Apply:

```bash
ansible-playbook playbooks/windows_server_backup.yml \
  --limit network-server-win
```

## Managed outputs

Current managed outputs include:

- native Windows host-recovery payload under `E:\WindowsImageBackup\`
- scheduled task:
  - `\castle\backup\WindowsServerBackupNativeHostRecoveryAutomatic`
- manual run manifests under:
  - `E:\backup-catalog\castle\home\lab\authoritative\network-server\runs\manual\`
- automatic run manifests under:
  - `E:\backup-catalog\castle\home\lab\authoritative\network-server\runs\automatic\`
- latest manual pointer:
  - `E:\backup-catalog\castle\home\lab\authoritative\network-server\runs\manual\latest.json`
- latest automatic pointer:
  - `E:\backup-catalog\castle\home\lab\authoritative\network-server\runs\automatic\latest.json`

Example manual manifest shape:

```json
{
  "schema": "castle.backup.native-host-recovery.v1",
  "mode": "manual",
  "backup_name": "native-host-recovery-manual-network-server-20260426T023009Z",
  "description": "Manual native-host-recovery backup for network-server requested by Ansible at 2026-04-26T02:30:09Z"
}
```

Example automatic manifest shape:

```json
{
  "schema": "castle.backup.native-host-recovery.v1",
  "mode": "automatic",
  "backup_name": "native-host-recovery-automatic-network-server-20260426T001500Z",
  "description": "Automatic native-host-recovery backup for network-server on a 7-day cadence."
}
```

## Verification examples

Read-only preview:

```bash
ansible-playbook playbooks/windows_server_backup.yml \
  --tags backup_preview \
  --limit network-server-win
```

Live job status:

```powershell
Get-WBJob | Select-Object JobState, StartTime, EndTime, CurrentOperation, PercentComplete
```

Summary:

```powershell
Get-WBSummary | Select-Object LastBackupTime, LastSuccessfulBackupTime, NextBackupTime, NumberOfVersions
```

Scheduled task:

```powershell
Get-ScheduledTask |
  Where-Object { $_.TaskName -eq "WindowsServerBackupNativeHostRecoveryAutomatic" } |
  Select-Object TaskName, TaskPath, State
```

The playbook should stay dedicated to the backup capability rather than being
merged into an unrelated multi-purpose server playbook.
