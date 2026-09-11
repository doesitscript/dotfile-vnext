---
contract_version: 1
pipeline_id: hrl-research-consolidation
task_id: hrl-research-consolidation
campaign_id: hrl-storage-implementation-beta-01
stage_id: implementation
run_id: hrl-storage-implementation-beta-01-parent-20260911t074328z-implementer-7
role: implementer
event_id: hrl-storage-implementation-beta-01-parent-20260911t074328z-implementer-7:1
responds_to: "/Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/implementation-campaign/feedback_for_review_by_evaluator_2026-09-11T081048Z.md"
upstream_run_id: hrl-preparation-20260911-r2
upstream_plan_sha256: 2a1466c9c81ea613ec5a916777d834050245169af51546f67f35d44ed7338d2c
status: evidence-captured
next_actor: Evaluator
mode: orchestrated
session_id: hrl-research-consolidation-implementation-hrl-storage-implementation-beta-01-parent-20260911t074328z-ppid66027
owner_manifest_path: /Users/joshc/develop/oneoffs/hrl-storage-implementation-beta-01-parent-20260911T074328Z/run/owned-processes.json
---

# S4 source-safety correction receipt

## Corrections

- `deploy_k3s_data_disk.yaml` now uses one `k3s_data_disk_state` to encode
  `present`: Hyper-V attach then guest initialize/mount; and `absent`: guest
  identity check/unmount/fstab removal then Hyper-V exact detach.
- Hyper-V PowerShell receives VM, path, size, type, reserve and controller values
  through `win_powershell.parameters`. Preview rejects existing VHDX size/type
  mismatch, insufficient host free capacity after reserve, an occupied slot, or
  the same path attached at a different slot. Apply rechecks identity before
  attachment. Absent previews and detaches only one exact path+slot match.
- Linux derives partition 1 from the selected whole-disk by-id path, rejects an
  independent partition path, and validates the resolved partition parent
  before filesystem work. Absent verifies disk serial, partition parent, live
  mount source and fstab source before `unmounted` plus `absent_from_fstab`.
- Neither absent role deletes the VHDX, filesystem, retained backup or mountpoint.

## Knowledge and module receipt

Entry door: `ansible-knowledge-gate`; owner playbook/roles are the three paths
above; one-off exception: no. Installed `ansible-doc` confirms
`ansible.posix.mount state=absent_from_fstab` removes fstab intent without
unmounting or deleting the mountpoint, and `ansible.windows.win_powershell`
supports structured `parameters`. The existing module matrix remains:
`win_powershell`, `community.general.parted`, `community.general.filesystem`,
and `ansible.posix.mount`; no shell fallback was introduced.

## Focused safety evidence

- Command: `bin/codex-env ansible-playbook -i inventory/inventory.yaml playbooks/verify_k3s_data_disk_safety.yaml`
  - Exit: `0`; recap: `ok=35 changed=0 unreachable=0 failed=0 rescued=6`.
  - A populated matching Hyper-V preview passed.
  - Expected failures were rescued and then asserted for existing-size mismatch,
    existing-type mismatch, insufficient reserve, same-VM path/slot conflict,
    independent partition selection, and wrong partition parent.
  - Static parsed-contract assertions proved guest absent precedes Hyper-V,
    Hyper-V precedes guest present, exact absent identity validation exists, and
    persistent removal uses `absent_from_fstab`.
- Early command: `bin/codex-env ansible-playbook -i inventory/inventory.yaml playbooks/deploy_k3s_data_disk.yaml --syntax-check`
  - Exit: `0`; output names `playbooks/deploy_k3s_data_disk.yaml`.
- Early command: `bin/codex-env ansible-lint --offline playbooks/deploy_k3s_data_disk.yaml roles/hyperv_vm_data_disk roles/linux_data_disk_mount`
  - Exit: `0`; production profile, zero failures and warnings in 14 processed files.

The fixtures are explicitly synthetic controller-local contract values. They do
not claim a selected live VM/VHDX/device or grant Apply authority. Fresh final
syntax, lint, safety, targeting, handoff and diff checks follow after the outbox.

## Apply / Verify / Undo / Change class

- Apply: repository-only safety corrections; all runtime Apply flags remain
  false and no managed-host mutation ran.
- Verify: controller-local contract fixtures plus final static/syntax/lint gates.
- Undo: revert these source changes. Future runtime undo is encoded as verified
  guest unmount/fstab removal before exact detach, preserving all data surfaces.
- Change class: idempotent desired-state scaffold with destructive-capable paths
  separately gated by identity, backup, reserve and explicit authority.

## Remaining decision

Choose the S3/S4 physical values and backup/outage/Apply authority recorded in
`coordination/decisions-and-authorization.md`, and choose the S5 monitoring
owner/policy. No independent safe live work remains for those slices.
