# windows_driver_backup

Managed Windows driver backup capability for Windows service nodes.

This role is intentionally separate from
[windows_server_backup](/Users/joshc/develop/dotfile-vnext/roles/windows_server_backup/README.md).
It backs up third-party Windows drivers into the repo-managed backup schema,
not into the native Windows host-recovery path.

Canonical naming and zone contract:

- [docs/backup/backup-naming-contract.md](/Users/joshc/develop/dotfile-vnext/docs/backup/backup-naming-contract.md)

## Apply / Verify / Undo / Change class

- Apply
  Run the dedicated playbook
  [windows_driver_backup.yml](/Users/joshc/develop/dotfile-vnext/playbooks/windows_driver_backup.yml)
  with `--tags driver_backup_apply`.
- Verify
  Use `--tags driver_backup_preview`, inspect the current manifest, and inspect
  the latest run manifest on the host.
- Undo
  Set `windows_driver_backup_state: absent` for the host and re-run the
  dedicated playbook with `--tags driver_backup_apply`.
- Change class
  Steady-state configuration plus a cumulative export capability. `force` is
  intentionally destructive only to the managed driver-export tree owned by
  this role.

## Run Modes

- `auto`
  First run exports all currently installed third-party drivers. Later reruns
  no-op by default if the managed export is already present.
- `incremental`
  Export only newly discovered third-party drivers that have not already been
  backed up into the managed export tree.
- `force`
  Remove and rebuild the managed export tree from the currently installed
  third-party driver set.

## Operator Examples

### Preview

Preview targeting and current host state without mutating anything:

```bash
ansible-playbook playbooks/windows_driver_backup.yml --tags driver_backup_preview
```

Preview one host:

```bash
ansible-playbook playbooks/windows_driver_backup.yml \
  --tags driver_backup_preview \
  --limit HOM-LAB-HVH-01
```

### Apply

Normal apply. On the first run this bootstraps the export. Later reruns no-op
unless you request another run mode:

```bash
ansible-playbook playbooks/windows_driver_backup.yml \
  --tags driver_backup_apply
```

### Incremental

Export only newly unbacked third-party drivers:

```bash
ansible-playbook playbooks/windows_driver_backup.yml \
  --tags driver_backup_apply \
  -e windows_driver_backup_run_mode=incremental
```

### Force

Rebuild the managed export tree from the currently installed third-party
drivers:

```bash
ansible-playbook playbooks/windows_driver_backup.yml \
  --tags driver_backup_apply \
  -e windows_driver_backup_run_mode=force
```

### Removal

Inventory:

```yaml
windows_driver_backup_state: absent
```

Apply:

```bash
ansible-playbook playbooks/windows_driver_backup.yml \
  --tags driver_backup_apply
```

## Managed Outputs

Current managed outputs include:

- current cumulative export root under:
  - `E:\backupsets\castle\home\lab\authoritative\<node>\windows-drivers\driver-export\current\`
- current manifest under:
  - `E:\backup-catalog\castle\home\lab\authoritative\<node>\windows-drivers\driver-export\manifests\current.json`
- latest run pointer under:
  - `E:\backup-catalog\castle\home\lab\authoritative\<node>\windows-drivers\driver-export\runs\latest.json`
- timestamped run manifests under:
  - `E:\backup-catalog\castle\home\lab\authoritative\<node>\windows-drivers\driver-export\runs\`
