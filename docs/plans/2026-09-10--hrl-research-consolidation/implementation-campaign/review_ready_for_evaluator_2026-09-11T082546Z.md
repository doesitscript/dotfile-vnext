---
contract_version: 1
pipeline_id: hrl-research-consolidation
task_id: hrl-research-consolidation
campaign_id: hrl-storage-implementation-beta-01
stage_id: implementation
run_id: hrl-storage-implementation-beta-01-parent-20260911t074328z-implementer-7
role: implementer
event_id: hrl-storage-implementation-beta-01-parent-20260911t074328z-implementer-7:2
responds_to: "/Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/implementation-campaign/feedback_for_review_by_evaluator_2026-09-11T081048Z.md"
upstream_run_id: hrl-preparation-20260911-r2
upstream_plan_sha256: 2a1466c9c81ea613ec5a916777d834050245169af51546f67f35d44ed7338d2c
status: review-ready
next_actor: Evaluator
mode: orchestrated
session_id: hrl-research-consolidation-implementation-hrl-storage-implementation-beta-01-parent-20260911t074328z-ppid66027
owner_manifest_path: /Users/joshc/develop/oneoffs/hrl-storage-implementation-beta-01-parent-20260911T074328Z/run/owned-processes.json
---

# Implementer handoff — S4 source-safety corrections

## Changed owners

- `playbooks/deploy_k3s_data_disk.yaml`
- `playbooks/verify_k3s_data_disk_safety.yaml`
- `roles/hyperv_vm_data_disk/`
- `roles/linux_data_disk_mount/`
- campaign README, accounting and authorization ledger
- `receipts/2026-09-11T082317Z-s4-safety-corrections.md`

## Feedback disposition

1. Reverse absent ordering is encoded in the playbook: guest unmount and fstab
   removal precede Hyper-V detach; present remains attach before guest mount.
2. Partition 1 is derived from the verified whole-disk by-id path. Existing and
   initialized partitions must resolve to the selected disk parent before any
   filesystem operation.
3. Hyper-V preview validates existing VHDX size/type, requested capacity plus
   host reserve, controller-slot ownership and same-VM path uniqueness. Apply
   rechecks the destructive identity boundary.
4. Linux absent previews serial, parent, live mount and fstab source; it removes
   persistent intent with `absent_from_fstab` only after identity verification.
   Hyper-V absent likewise previews exact path+slot identity before detach.
5. Every user-selected VM/path value is passed to PowerShell through structured
   `ansible.windows.win_powershell.parameters`.

## Evidence for evaluator

- Both playbook syntax checks exited `0`.
- Focused `ansible-lint --offline` exited `0`: production profile, zero
  failures/warnings in 17 processed files.
- Controller-local populated safety fixtures exited `0` with
  `ok=35 changed=0 failed=0 rescued=6`; the rescued cases are the six expected
  mismatch rejections, not ignored errors.
- Present and absent target listings exited `0` and resolved only
  `HOM-LAB-HVH-02` and `hom-lab-ctl-k3s-02` in their inventory-derived plays.
- Default Hyper-V and guest check-mode runs each stopped at missing-selection
  assertions with expected exit `2`, `changed=0`, before mutation-capable tasks.
- Intake checker and focused `git diff --check` exited `0`; checker continues to
  report live Apply authority `false`.

Please independently inspect the four corrected safety boundaries and rerun the
receipt commands. This handoff requests source-safety review only; it is not
whole-campaign sign-off or live implementation evidence.

## Remaining campaign boundary and concrete question

No live Apply occurred. S3/S4 still require the user to select capacity, disk
type, host path, free-space reserve, controller slot, whole-disk by-id, serial,
mount path, retained backup/source and outage window, then grant exact Apply
authority. S5 still requires owner, cadence, thresholds, mounts, retention and
alert-route choices. After source-safety acceptance, if no new independent work
exists, the Evaluator should use its durable waiting artifact for these choices.
