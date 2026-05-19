# windows_managed_service_data_backup_disk

Opinionated Windows role for the rebuildable non-OS managed service disk on
infrastructure nodes such as `home-lab-auth-hvh-01` and `server-225-win`.

## Public contract

- lifecycle variable:
  - `windows_managed_service_data_backup_disk_state: present|absent`
- optional confidence variables:
  - `windows_managed_service_data_backup_disk_target_model`
  - `windows_managed_service_data_backup_disk_target_serial_number`
- transient destructive approval:
  - `windows_managed_service_data_backup_disk_rebuild_approved`

## Intended layout

- `E:` labeled `backups`
- `F:` labeled `data`
- filesystem: `NTFS`
- allocation unit size: `4096`

Percentages are derived once from the source physical Toshiba disk on
`server-225-win` and baked into the role defaults:

- backup: `39.313758202`
- data: `60.685346181`

These are based on the source physical disk size, not just the sum of the
logical partitions.

## Behavior

`present` has three safe outcomes:

1. already matches expected layout
   - no-op
2. raw or unassigned candidate disk
   - initialize and provision
3. unexpected existing layout
   - fail safe unless the transient rebuild approval is set

`absent` is intentionally not implemented in v1 because destructive teardown of
provisioned service storage needs a separate explicit workflow.

## Preview and apply

Preview first:

```bash
ansible-playbook playbooks/windows_managed_service_data_backup_disk.yml --tags disk_preview
```

Apply only with the explicit apply tag:

```bash
ansible-playbook playbooks/windows_managed_service_data_backup_disk.yml --tags disk_apply --limit home-lab-auth-hvh-01
```

First rebuild of an already-used target disk also needs the transient rebuild
approval, for example:

```bash
ansible-playbook playbooks/windows_managed_service_data_backup_disk.yml \
  --tags disk_apply \
  --limit home-lab-auth-hvh-01 \
  -e windows_managed_service_data_backup_disk_rebuild_approved=true
```
