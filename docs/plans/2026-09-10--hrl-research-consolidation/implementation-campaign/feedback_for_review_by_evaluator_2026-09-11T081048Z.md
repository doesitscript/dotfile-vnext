---
contract_version: 1
pipeline_id: hrl-research-consolidation
task_id: hrl-research-consolidation
campaign_id: hrl-storage-implementation-beta-01
stage_id: implementation
run_id: hrl-storage-implementation-beta-01-parent-20260911t074328z-evaluator-6
role: evaluator
event_id: hrl-storage-implementation-beta-01-parent-20260911t074328z-evaluator-6:1
responds_to: "/Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/implementation-campaign/review_ready_for_evaluator_2026-09-11T080522Z.md"
upstream_run_id: hrl-preparation-20260911-r2
upstream_plan_sha256: 2a1466c9c81ea613ec5a916777d834050245169af51546f67f35d44ed7338d2c
status: changes-requested
next_actor: Implementer
mode: orchestrated
session_id: hrl-research-consolidation-implementation-hrl-storage-implementation-beta-01-parent-20260911t074328z-ppid66027
owner_manifest_path: /Users/joshc/develop/oneoffs/hrl-storage-implementation-beta-01-parent-20260911T074328Z/run/owned-processes.json
---

# Evaluator feedback — implementation pass 6

Decision: accept the two-role capability boundary, fail-closed defaults,
module-first design, S5 decision package and granular obligation expansion as
useful progress. Do not move to waiting yet: the new S3/S4 scaffold contains
four source-level safety defects that must be corrected before user-selected
values could be applied safely. Whole-campaign approval remains unavailable.

## Reviewed identity and source state

- Reviewed Implementer outbox:
  `review_ready_for_evaluator_2026-09-11T080522Z.md`, SHA-256
  `6cec36d39f8b0d3ba0a68d7bf634f0cd82b311e66effa832756317b7b59fc7d0`.
- Reviewed receipt:
  `receipts/2026-09-11T080420Z-s3-s5-owner-design.md`, SHA-256
  `999c0f9cbc0c8d85d8faf172b23165f8d3213ea85ee97831ba12d444a23b82c4`.
- Git HEAD: `3613377069bcb3ed815f4b0763df0ed6d668692d`.
- Reviewed plan/accounting/authorization digests:
  `3baf146f0f3bde97567f2468de9d84af0affed12e0fe787c9e7bf7ee21512878`,
  `373c5e8d12afcdea52a52c07484cf6b50c6157e4e4eb291bef5afce804d84253`,
  and `41dcc62677e059a77abd6d7d56b861c8a831fad19bb3ffce9466b7ac70ac6b6b`.
- New source reviewed directly: `playbooks/deploy_k3s_data_disk.yaml`, SHA-256
  `331b149a585d327749df11b8786ce74afe46182277e5f6fef3cd30457f544273`,
  all seven files under `roles/hyperv_vm_data_disk/`, and all seven files under
  `roles/linux_data_disk_mount/`. Exact per-file digests were captured during
  this evaluator pass; unrelated worktree state was preserved.
- The intake checker exited `0`, matched campaign and upstream identity, and
  reported no live-Apply authority and no implementation approval.

Project type: managed rollout / destructive-capable storage lifecycle scaffold,
with live mutation separately gated by user authority and verified identity.

## Fresh independent evidence

| Check | Exit | Current evaluator evidence |
| --- | ---: | --- |
| `bin/codex-env ansible-playbook -i inventory/inventory.yaml playbooks/deploy_k3s_data_disk.yaml --syntax-check` | 0 | `playbook: playbooks/deploy_k3s_data_disk.yaml`. |
| `bin/codex-env ansible-lint --offline playbooks/deploy_k3s_data_disk.yaml roles/hyperv_vm_data_disk roles/linux_data_disk_mount` | 0 | Production profile; zero failures and zero warnings in 13 processed files. |
| `bin/codex-env ansible-playbook -i inventory/inventory.yaml playbooks/deploy_k3s_data_disk.yaml --limit 'HOM-LAB-HVH-02,hom-lab-ctl-k3s-02' --list-hosts --list-tags --list-tasks` | 0 | Hyper-V play selects only `HOM-LAB-HVH-02`; guest play selects only `hom-lab-ctl-k3s-02`; role and lifecycle tags are visible. |
| Hyper-V default negative check-mode preflight | expected 2 | Stops on empty VM identity before PowerShell; `changed=0`. |
| Guest default negative check-mode preflight | expected 2 | Stops on empty by-id device before partition/filesystem/mount; `changed=0`. |
| `git diff --check` | 0 | No whitespace errors in current tracked changes. |

The two expected non-zero runs mean the default contracts reject missing input;
they do not exercise populated but internally inconsistent values. Static source
review exposed the following cases beyond those negative tests.

## Blocking source corrections

- **Reverse absent dependency order:** `deploy_k3s_data_disk.yaml` always runs
  the Hyper-V role before the Linux role. With both states set to `absent`, it
  would detach the VHDX before unmounting the guest filesystem, contradicting
  the README and S4-U1. Encode state-aware orchestration so present is attach →
  initialize/mount, while absent is unmount/remove persistent mount intent →
  detach. Do not leave this safety order only in prose.
- **Bind the partition to the selected disk:** the Linux role verifies the
  serial of the resolved `device_by_id`, but accepts an independent
  `partition_path` and passes it directly to `community.general.filesystem` and
  `ansible.posix.mount`. Rejecting only `/dev/sda*` is insufficient: a typo or
  mismatched value could format another non-OS disk. Derive the partition from
  the verified device or resolve it and assert its parent disk and serial match
  the selected device before filesystem creation.
- **Validate existing VHDX identity and host capacity:** the Hyper-V preview
  captures existing size but never asserts size/type equality. If a VHDX already
  exists at the selected path, Apply skips creation and can attach it despite a
  mismatched requested capacity/type. Also capture and gate host-volume free
  capacity/reserve before creating a new fixed or dynamic disk. Check path
  attachment conflicts across the VM, not only whether the requested controller
  slot is empty or matching.
- **Make absent a persistent, identity-checked lifecycle:**
  `ansible.posix.mount state=unmounted` explicitly leaves `/etc/fstab`
  unchanged, so the current absent path can remount on reboot. It also takes
  only a mount path and does not prove the currently mounted source is the
  selected partition/disk. Add read-only absent preview/identity checks, unmount
  only the matching source, and remove the persistent fstab intent while
  preserving filesystem data. Give the Hyper-V absent path an equivalent
  read-only exact attachment preview before detach.

Use `ansible.windows.win_powershell.parameters` for user-selected VM/path values
instead of embedding them directly inside quoted PowerShell source; the
installed and official module contract supports structured parameters and this
avoids quote-breaking input in a destructive-capable role.

## Whole-campaign check matrix

| Slice | Status | Evaluator finding / required evidence |
| --- | --- | --- |
| S1 | in progress; discovery increment accepted | Current map and baseline remain valid; final alignment follows selected S4/S5 design. |
| S2 | accepted no-change conclusion | No external prune/config/restart is justified; this does not resolve capacity. |
| S3 | blocked | Backing gate exists, but cache/PV/PVC cutover, health, integrity and reversal remain unimplemented and decision-gated. |
| S4 | changes requested | Capability scaffold exists but the order, disk/partition identity and persistent absent defects above must be fixed before it is safe to populate or apply. No live Apply occurred. |
| S5 | decision package accepted; blocked on user choices | Host-native journald/Alloy/Loki visibility versus Prometheus-compatible metrics/Alertmanager is a meaningful choice. Cadence, thresholds, mounts, retention and route remain unselected. |
| S6 | in progress | Module matrix and obligation granularity improved; final implementation/verification/docs/HRL evidence remains open. |

## Accepted boundaries

- Separate Hyper-V attachment and Linux mount roles are the correct ownership
  shape; their public `present|absent` interfaces and default `*_apply: false`
  gates should be preserved.
- `community.general.parted`, `community.general.filesystem`,
  `ansible.posix.mount`, and structured `ansible.windows.win_powershell` are
  appropriate module choices for the bounded surfaces.
- The mount role honestly does not claim cache copy or PV/PVC cutover.
- The S5 current-stack-first recommendation is acceptable if the user chooses
  visibility without paging; Prometheus-compatible monitoring remains the
  correct larger option when alert routing is required.
- These are new scaffold-specific findings, not a repeated unchanged blocker
  set; the repeated-blocker research gate does not trigger.

## Next action

Implementer: correct the four S4 safety defects, rerun populated-value read-only
previews and negative tests that exercise size/type mismatch, partition-parent
mismatch and absent ordering/persistence, update receipt/accounting/obligation
rows, and write one fresh `review_ready_for_evaluator_*` artifact. Do not apply
or invent user values. Once source safety is independently accepted and no
other safe work remains, preserve the concrete S3-S5 question and transition
the campaign to a durable evaluator waiting state for those decisions.

## Sources checked

- Campaign README, accounting, authorization ledger, current handoff and
  `receipts/2026-09-11T080420Z-s3-s5-owner-design.md`.
- `playbooks/deploy_k3s_data_disk.yaml` and every file under
  `roles/hyperv_vm_data_disk/` and `roles/linux_data_disk_mount/`.
- Installed `ansible-doc` for `ansible.posix.mount`,
  `community.general.filesystem`, and `community.general.parted`.
- Official `ansible.posix.mount` module contract:
  <https://docs.ansible.com/projects/ansible/latest/collections/ansible/posix/mount_module.html>.
- Official `ansible.windows.win_powershell` module contract:
  <https://docs.ansible.com/projects/ansible/latest/collections/ansible/windows/win_powershell_module.html>.
