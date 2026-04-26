---
# Windows Driver Export with Ansible (Intake)

## Request Summary

You asked whether Ansible can export existing drivers from a target Windows system and whether that should be added to your current backup work.

You also asked for a written project-facing document that:
- captures what is possible with Ansible core/community
- records what was found in this repo
- proposes a practical path to implement driver export support

## Findings: What Ansible Can and Cannot Do

### Short answer

Yes, this is supported in practice with Ansible, but not through a single dedicated "driver export" module.

### Ansible capability reality

- **Ansible core** does not include a dedicated module like `win_driver_export`.
- **Ansible community collections** (`ansible.windows`, `community.windows`) also do not currently provide a purpose-built driver-export module.
- The supported, idiomatic path is:
  - `ansible.windows.win_powershell` calling:
    - `Export-WindowsDriver -Online -Destination <path>`
  - or `ansible.windows.win_command` calling:
    - `pnputil /export-driver * <path>`

### Native Windows sources this depends on

- `Export-WindowsDriver` (DISM PowerShell cmdlet) exports third-party drivers from the running OS.
- `pnputil /export-driver` exports driver packages from the driver store.

## Project Findings Relevant to Implementation

The current `windows_server_backup` role is already a good home for this capability.

### Existing role shape (important)

The role already has:
- lifecycle and validation pattern (`state`, eligibility assertions, drive checks)
- managed structure creation under:
  - `windows_server_backup_work_root`
  - `windows_server_backup_data_dir`
  - `windows_server_backup_logs_dir`
  - `windows_server_backup_manifests_dir`
- a manifest-writing pattern in `tasks/present.yml`
- one-time action toggle pattern via `windows_server_backup_run_now`

This means driver export can be added cleanly without introducing a separate parallel framework.

### Existing paths that can host driver-export artifacts

Likely best default destination for exported drivers in this repo's current structure:
- `{{ windows_server_backup_data_dir }}\drivers-export`

Likely best destination for metadata/manifests:
- `{{ windows_server_backup_manifests_dir }}\driver-export-manifest.json`

## Recommended Design for This Repo

### Interface additions (role defaults + argument specs)

Recommended new variables:

- `windows_server_backup_export_drivers_now: false`
  - transient switch, same pattern as `windows_server_backup_run_now`
- `windows_server_backup_driver_export_tool: "export_windowsdriver"`
  - choices: `export_windowsdriver`, `pnputil`
- `windows_server_backup_driver_export_root: "{{ windows_server_backup_data_dir }}\\drivers-export"`
- `windows_server_backup_driver_export_manifest_path: "{{ windows_server_backup_manifests_dir }}\\driver-export-manifest.json"`

### Task flow (present path)

When `windows_server_backup_export_drivers_now | bool`:

1. Assert no conflicting precondition (optional but preferred for operator clarity).
2. Ensure export directory exists.
3. Execute export:
   - `Export-WindowsDriver -Online -Destination ...`
   - fallback option for `pnputil /export-driver * ...`
4. Collect summary details:
   - count of exported `.inf` files
   - tool used
   - destination path
   - timestamp
5. Write manifest JSON into `windows_server_backup_manifests_dir`.
6. Print concise summary via debug message.

### Why this should live in `windows_server_backup`

- The role already owns backup baseline and backup-adjacent artifact structure.
- Driver export is backup-adjacent operational data.
- Keeping it here avoids fragmenting operator workflow across multiple tiny roles.

## Implementation Safety Notes

- Driver export can be storage-heavy; destination hygiene should be explicit.
- Use a deterministic path and manifest for traceability.
- Keep this as opt-in (`*_export_drivers_now`) instead of always-on.
- Do not assume this replaces full system backup; this is a complementary artifact.

## Practical Operator Use (Target Outcome)

After implementation, expected use should look like:

- normal baseline runs unchanged
- ad-hoc export trigger when desired:
  - run role/playbook with `-e windows_server_backup_export_drivers_now=true`

This mirrors the existing `windows_server_backup_run_now` behavior pattern and keeps steady-state inventory clean.

## Decision Snapshot

- **Feasible with current Ansible ecosystem:** Yes
- **Requires custom role tasks in this repo:** Yes
- **Best placement in this repo:** `roles/windows_server_backup/tasks/present.yml` + defaults/argument specs
- **Risk level:** low to moderate (mostly artifact size and path hygiene)

## Next Suggested Step

Implement driver export in `windows_server_backup` as an optional execution path with:
- explicit variables
- manifest output
- tool choice (`Export-WindowsDriver` first, `pnputil` optional)

This keeps your backup program cohesive while adding a valuable recovery artifact.
