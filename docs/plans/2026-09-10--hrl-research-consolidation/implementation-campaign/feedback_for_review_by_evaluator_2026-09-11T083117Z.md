---
contract_version: 1
pipeline_id: hrl-research-consolidation
task_id: hrl-research-consolidation
campaign_id: hrl-storage-implementation-beta-01
stage_id: implementation
run_id: hrl-storage-implementation-beta-01-parent-20260911t074328z-evaluator-8
role: evaluator
event_id: hrl-storage-implementation-beta-01-parent-20260911t074328z-evaluator-8:1
responds_to: "/Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/implementation-campaign/review_ready_for_evaluator_2026-09-11T082546Z.md"
upstream_run_id: hrl-preparation-20260911-r2
upstream_plan_sha256: 2a1466c9c81ea613ec5a916777d834050245169af51546f67f35d44ed7338d2c
status: changes-requested
next_actor: Implementer
mode: orchestrated
session_id: hrl-research-consolidation-implementation-hrl-storage-implementation-beta-01-parent-20260911t074328z-ppid66027
owner_manifest_path: /Users/joshc/develop/oneoffs/hrl-storage-implementation-beta-01-parent-20260911T074328Z/run/owned-processes.json
---

# Evaluator feedback — S4 safety correction review

## Verdict

The new implementation materially closes the four findings from the prior
Evaluator pass: lifecycle direction is encoded in one entrypoint, partition 1
is derived and parent-checked, VHDX preview checks size/type/reserve/attachment,
and absent paths preview identity and remove persistent mount intent. Structured
PowerShell parameters are also used. The blocker set therefore changed and the
repeated-blocker research gate does not apply.

S4 is not yet source-safe enough to move to a user-decision-only wait state.
Three bounded corrections remain in the changed owners. No live Apply was
authorized or performed, and this artifact is not whole-campaign sign-off.

## Blocking corrections

- `roles/linux_data_disk_mount/tasks/absent.yml`: replace the live-source
  `findmnt --target <path>` lookup with an exact mountpoint lookup and test the
  already-unmounted rerun. `--target` deliberately returns the filesystem that
  contains any path. On `hom-lab-ctl-k3s-02`, `--target /tmp` returned
  `/dev/sda1`, while `--mountpoint /tmp` returned no match. Because the role
  preserves the mount directory, its second absent run can misclassify the root
  filesystem as the selected live mount and fail the identity assertion. This
  violates the promised idempotent absent lifecycle.
- `roles/linux_data_disk_mount/tasks/{present,absent,derive_partition}.yml`:
  enforce that `linux_data_disk_mount_device_by_id` is actually a stable
  whole-disk path under `/dev/disk/by-id/`, not merely a nonempty string without
  a `-partN` suffix. A value such as `/dev/sdb` currently passes the input gate;
  the role can partition that disk and only afterward fail while resolving the
  incorrectly derived `/dev/sdb-part1`. Add a populated negative fixture proving
  an unstable/raw device path is rejected before `community.general.parted`.
- `roles/hyperv_vm_data_disk/tasks/present.yml`: enforce the selected host
  free-space reserve again inside the mutation-capable PowerShell operation,
  immediately before a new VHDX is created. The apply operation currently omits
  `HostReserveBytes` and does not read current free space; a fixed VHDX can
  consume the selected reserve if host free space changes after preview. Extend
  the safety fixture/static contract to prove the mutation operation accepts and
  checks the reserve, in addition to the preview check.

## Whole-campaign matrix

| Slice | Status | Evaluator evidence |
| --- | --- | --- |
| S1 | in progress | Prior target/owner discovery remains reviewable; monitoring ownership is open. |
| S2 | accepted no-change | Existing K3s/kubelet GC ownership and zero eligible reclaim bytes still support no S2 mutation. |
| S3 | blocked | Persistent-backing scaffold exists; target, backup, cutover, health, integrity and reversal evidence remain open. |
| S4 | changes requested | Prior four defects are materially corrected; the three safety/idempotence gaps above remain before physical selection and Apply. |
| S5 | blocked on user decision | The current-stack-first versus metrics/Alertmanager decision package is reviewable, but owner/policy values remain unselected. |
| S6 | in progress | Research/module/docs/diagram closeout cannot finish before S3-S5 and live verification close. |

## Fresh independent evidence

- Intake checker: exit `0`; campaign/upstream identity verified; live Apply and
  implementation approval remain `false`.
- Syntax: `deploy_k3s_data_disk.yaml --syntax-check`, exit `0`.
- Focused lint: production profile, `0` failures and `0` warnings across 17
  processed files, exit `0`.
- Controller-local safety playbook: exit `0`, `ok=35 changed=0 failed=0
  rescued=6`; the six expected negative assertions were rescued. This confirms
  the implemented fixtures but does not exercise the three gaps above.
- Target/task listing: exit `0`; guest plays resolve only
  `hom-lab-ctl-k3s-02`, and the Hyper-V play resolves only `HOM-LAB-HVH-02`.
- Default absent check-mode negative gate: exit `2`, `changed=0`; the guest
  missing-selection assertion stopped execution before the Hyper-V play. This
  was expected fail-closed behavior, not live lifecycle proof.
- Exact-mount semantics: read-only `findmnt --target /tmp` on the guest returned
  `/dev/sda1`; `findmnt --mountpoint /tmp` returned no match. The initial ad-hoc
  exact check surfaced expected rc `1`; the corrected probe accepted rc `1` and
  exited `0`. No host state was mutated despite Ansible shell's generic
  `CHANGED` label.
- `git diff --check`: exit `0`.

## Reviewed source state

- Git HEAD: `3613377069bcb3ed815f4b0763df0ed6d668692d`; relevant campaign and
  implementation owners remain untracked/dirty within the broader pre-existing
  worktree, so the following file digests bind this verdict.
- Implementer outbox: `7d28ec390387a0311cf92ea698d7b550851d95497f838b8d3213223b8b4a58ab`.
- Correction receipt: `381fad61ef14734a626d69580e65efd8452a936db41c5396f14459c2073c4db8`.
- Campaign README/accounting/authorization: `4c1b1bad9888e86bf9d65d863b24cc4a0fa9355ce5c38029ee633091a2bf3c1b`,
  `38c8d26f4c23b999e5e80feb2c8f34ed55726c3b85dab7c4ebb60b2a161a80d7`,
  `9d40b2e801b20b4505ff43080d62fa2fe2693c0a77ecd42c89afa9dc06da456a`.
- Deploy/safety playbooks: `2ea07c51f555cf5d460d91cb8c759ff3a1a7009acac6a3fd0eb7ae584903fe9f`,
  `bf59692f4e4c277d2ff6c6a341ea4e1c548206b6d06f7aed8c2872df74ff93ad`.
- Hyper-V present/absent tasks: `54c3853bb74ee14e5ffbebfff1c1fa7de6a483ba7321d782827edba93a746395`,
  `cf7ddaa3e96138d3a2b40190f784bd824c707a6534656025372bbc7912afc60e`.
- Linux present/absent/partition-derivation tasks:
  `4ed832dd76200ee83e6c9ef369eb776770955670c0f7fff968d09e772d6b89ed`,
  `85ab8da84276c704f58d226e569ad14974dcffe6842c9c6c1903307b28391735`,
  `7a820b87fb34147250c56923353cd67491ef941c7ebbd61de1b703aef636448b`.

## Next Implementer action

Correct the three source boundaries, extend the populated controller-local
negative/static checks, rerun syntax/lint/safety/targeting and publish one fresh
receipt and outbox. Do not perform live Apply. If those corrections pass and no
other independent work remains, the next Evaluator pass should write a durable
waiting artifact containing the existing concrete S3/S4 and S5 user questions.

## Sources checked

- Current campaign README, accounting, authorization ledger, implementer outbox,
  correction receipt, entrypoint, safety playbook and both lifecycle roles.
- Installed Ansible syntax/lint/runtime behavior through `bin/codex-env`.
- util-linux `findmnt(8)` documentation: `--target` finds the containing
  filesystem; `--mountpoint` is the strict mountpoint lookup.
- Ansible `win_powershell`, `mount`, `filesystem` and `parted` module contracts
  consulted through the project knowledge gate and prior current-source review.
