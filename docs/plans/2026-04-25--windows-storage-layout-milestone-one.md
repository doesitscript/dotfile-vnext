# Windows Storage Layout Milestone One

Canonical approved plan for introducing a reusable Windows storage-layout
capability while keeping the first executable scope restricted to
`home-lab-auth-hvh-01`.

## Summary

Implement a new Windows storage-layout capability that can:

- identify a target non-OS disk using stable disk facts
- initialize the disk if needed
- partition it into two logical drives using the same proportions as the
  reference physical disk on `hom-lab-ctl-hvh-02`
- format and label the resulting volumes

Milestone one uses `hom-lab-ctl-hvh-02` only as the layout reference source.
Milestone one execution is intentionally guarded so it can run only for
`home-lab-auth-hvh-01` until the layout has been validated there.

This work is explicitly for the non-OS data/backup disk layout and does not
apply to the system disk or the existing `C:` / `D:` boot-and-primary-data
layout.

## Research Basis

Checked and confirmed:

- inventory truth shows both `hom-lab-ctl-hvh-02` and `home-lab-auth-hvh-01` are in
  `windows_hosts`, while `home-lab-auth-hvh-01` is uniquely in `network_server`
- the repo does not already contain a dedicated Windows disk-partitioning role
- Ansible has native collection support for this workflow through:
  - `community.windows.win_disk_facts`
  - `community.windows.win_initialize_disk`
  - `community.windows.win_partition`
  - `community.windows.win_format`

## Approved Direction

### Role shape

Create a new role focused only on Windows disk layout, with a single lifecycle
control point:

- `windows_storage_layout_state: present|absent`

The role should:

- gather Windows disk facts
- identify the target disk from inventory-driven identity placeholders
- assert that the selected disk is not the OS disk
- assert that the selected disk matches the intended host safeguard
- initialize the disk with GPT unless inventory says otherwise
- create two partitions that mirror the reference proportions from
  `hom-lab-ctl-hvh-02`
- assign drive letters and labels for the data and backup volumes
- support a future `absent` path only where safe and intentionally scoped

### Playbook shape

Add a dedicated playbook for this capability rather than folding it into the
backup playbook:

- `playbooks/windows_storage_layout.yml`

Milestone-one execution path should be intentionally narrow:

- first-target play runs only against `home-lab-auth-hvh-01`
- the role remains reusable, but the first playbook entrypoint should not
  casually target `hom-lab-ctl-hvh-02`

Recommended first-pass playbook contract:

- hosts: `network_server`
- include role dynamically
- require `windows_storage_layout_state` to be defined
- expose meaningful tags for focused runs

### Inventory/API shape

Use inventory as the desired-state source of truth.

Milestone-one placeholders are acceptable until the physical server work is
finished. Add inventory variables for:

- `windows_storage_layout_state`
- `windows_storage_layout_allowed_hosts`
- `windows_storage_layout_reference_host`
- `windows_storage_layout_target_disk`
- `windows_storage_layout_partition_style`
- `windows_storage_layout_data_partition`
- `windows_storage_layout_backup_partition`

The disk-identity placeholder structure should support stable selectors such as:

- `serial_number`
- `unique_id`
- `model`
- `friendly_name`
- `physical_location`
- expected approximate size

The first implementation should accept blanks/placeholders for these values and
fail safely until they are populated.

## Safeguards

Milestone one must protect `hom-lab-ctl-hvh-02` from accidental execution.

Required safeguards:

1. The milestone-one playbook targets only `network_server`
2. The role asserts that `inventory_hostname` is in
   `windows_storage_layout_allowed_hosts`
3. The role asserts the selected disk is not the OS/system disk
4. The role asserts the selected disk matches the configured identity
   placeholders closely enough to proceed
5. Partitioning and formatting tasks are tagged so focused runs are possible,
   but tags must not widen host scope by themselves

This keeps the reusable role scalable while making the first operator path safe.

## Reference-Layout Strategy

Use `hom-lab-ctl-hvh-02` as a reference model, not a literal clone source.

Reference work should:

- inspect the one physical disk that currently backs the two logical drives used
  for data and backups
- capture the sizes of those two partitions
- derive the percentage split of the whole physical disk
- apply that percentage split to the new 1 TB disk on `home-lab-auth-hvh-01`

The final partition should typically consume the remaining space after rounding
to avoid leaving unallocated fragments.

## Scope Boundaries

Included in milestone one:

- disk fact gathering
- target disk identification
- disk initialization
- two-partition layout creation
- drive-letter assignment
- formatting and labels
- repo documentation for the storage-layout capability

Explicitly excluded from milestone one:

- changes to the OS disk
- changes to the existing `C:` / `D:` layout
- backup-policy scheduling
- workload-specific backup payloads
- multi-host rollout to `hom-lab-ctl-hvh-02`

## Suggested Variable Direction

Example shape only; exact values can stay placeholder until the server update is
done:

```yaml
windows_storage_layout_state: present
windows_storage_layout_allowed_hosts:
  - home-lab-auth-hvh-01
windows_storage_layout_reference_host: hom-lab-ctl-hvh-02
windows_storage_layout_partition_style: gpt

windows_storage_layout_target_disk:
  serial_number: "TODO-SERIAL"
  unique_id: "TODO-UNIQUE-ID"
  model: "TODO-MODEL"
  physical_location: "TODO-PHYSICAL-LOCATION"
  expected_size_gib: 931

windows_storage_layout_data_partition:
  drive_letter: "D"
  label: "data"
  size_percent: "TODO-FROM-REFERENCE"
  file_system: ntfs

windows_storage_layout_backup_partition:
  drive_letter: "E"
  label: "backups"
  size_percent: "TODO-FROM-REFERENCE"
  file_system: ntfs
```

If the current host already uses `D:` for existing data, the implementation must
reconcile drive-letter reality before apply. That verification belongs in the
live apply phase, not in this plan.

## Implementation Steps

1. Create the new role with defaults, argument specs, README, and `present` /
   `absent` task split
2. Add a milestone-one playbook scoped to `network_server`
3. Add placeholder inventory variables for `home-lab-auth-hvh-01`
4. Add safe assertions for host and disk targeting
5. Add logic to compute and apply the two-partition proportional layout
6. Add static validation
7. Defer live apply until the physical server work is complete

## Apply / Verify / Undo / Change Class

- Apply:
  - `ansible-playbook playbooks/windows_storage_layout.yml --limit home-lab-auth-hvh-01`
- Verify:
  - syntax and lint locally
  - inspect disk facts on the target
  - confirm the selected disk identity matches
  - confirm the resulting partitions, drive letters, labels, and sizes
  - confirm the partition proportions match the reference layout within
    reasonable rounding tolerance
- Undo:
  - manual or explicitly scoped `absent` logic later; do not promise destructive
    rollback until the safe removal behavior is designed
- Change class:
  - idempotent config for fact-driven disk setup, but destructive in effect if
    pointed at the wrong disk, so the host/disk safeguards are mandatory

## Validation Plan

### Phase A — repo-only

- write the role, playbook, inventory placeholders, and docs
- run:
  - `ansible-playbook --syntax-check playbooks/windows_storage_layout.yml`
  - `ansible-lint playbooks/windows_storage_layout.yml`

### Phase B — live reference discovery

- gather live disk facts from `hom-lab-ctl-hvh-02`
- determine the actual source physical disk and the partition percentage split

### Phase C — first target apply

- gather live disk facts from `home-lab-auth-hvh-01`
- populate the target-disk identifiers
- run the milestone-one playbook against `home-lab-auth-hvh-01`
- verify partition outcomes

### Phase D — wider rollout later

- remove or widen the allowed-host safeguard only after milestone-one validation
- evolve the playbook from `network_server`-only execution toward both Windows
  servers when intentional
