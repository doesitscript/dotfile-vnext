---
contract_version: 1
pipeline_id: hrl-research-consolidation
task_id: hrl-research-consolidation
campaign_id: hrl-storage-implementation-beta-01
stage_id: implementation
run_id: hrl-storage-implementation-beta-01-parent-20260911t104646z-implementer-3
role: implementer
event_id: hrl-storage-implementation-beta-01-parent-20260911t104646z-implementer-3:1
responds_to: "/Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/implementation-campaign/feedback_for_review_by_evaluator_2026-09-11T105852Z.md"
upstream_run_id: hrl-preparation-20260911-r2
upstream_plan_sha256: 2a1466c9c81ea613ec5a916777d834050245169af51546f67f35d44ed7338d2c
status: evidence-captured
next_actor: Evaluator
mode: orchestrated
session_id: hrl-research-consolidation-implementation-hrl-storage-implementation-beta-01-parent-20260911t104646z-ppid29198
owner_manifest_path: /Users/joshc/develop/oneoffs/hrl-storage-implementation-beta-01-parent-20260911T104646Z/run/owned-processes.json
expert_recommendation_path: /Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/implementation-campaign/eval_feature/response_on-site_expert/2026-09-11T085155Z-onsite-expert-recommendation.md
decision_authority_profile_path: /Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/multi-agent-design/decision-authority-profiles.md
---

# S1/S5 discovery and current-stack monitor receipt

## Recommendation disposition

Under `lab_recreatable_autonomy`, this pass applies the Expert's current-stack-
first monitoring recommendation to the existing Ansible owner. It preserves the
hard prohibitions: no durable K3s server/database/TLS/credential movement, no
existing-PV rewrite, no containerd override, and no speculative SATA allocation.
The intake checker reports both live Apply and implementation approval `false`,
so all target interaction in this pass was read-only.

## Exact target and discovery

- Classified target: `hom-lab-ctl-k3s-02`, execution role `k3s-ai-plane`,
  runtime plane `k3s_node`, policy compliant. Hypervisor alias:
  `HOM-LAB-HVH-02`.
- Hyper-V: VM `hom-lab-ctl-k3s-02` is running with only its fixed 80 GiB system
  VHDX at SCSI 0:0. SCSI 0:1 is therefore reconfirmed free.
- Guest: only `/dev/sda` exists; `/dev/sda1` is ext4 and backs `/`. There is no
  second disk and thus no honest `/dev/disk/by-id/`/serial binding yet.
- Compatibility: the live containerd root and overlay snapshotter operate on
  the ext4 root, and the kernel advertises overlayfs. No XFS selection is made.
- Capacity/pressure: `/` is 85% used with 12 GiB free; K3s reports DiskPressure
  and failed image garbage collection. Containerd uses 30 GiB; local-path
  storage and the vLLM HF cache use 22 GiB.
- Swap contract: Kubelet reports `failSwapOn: false`, `memorySwap: {}`, and
  `swapon --show` is empty. No swap change is selected.
- SATA fallback: physical disks are healthy, but the mounted candidate volumes
  have only 0.3 GiB, 0 GiB (warning), and 23.2 GiB free. This is not safe
  allocation evidence, so SATA journal/swap/compile-cache placement remains
  unselected. The selected fallback is a 1 GiB journal cap on root.
- Logging route: `alloy.service` is `not-found`/inactive on the guest. The
  repository owns `logging_alloy`, but the live journald → Alloy → Loki/Grafana
  route cannot be claimed until that owner is applied and verified.

## Owner and source changes

- `playbooks/report_storage.yaml` now ignores skipped cross-platform loop
  records lacking `rc` and gates K3s-only summaries/assertions to K3s Linux.
- Existing `roles/storage_capacity_monitor` is hardened so a missing required
  mount makes the oneshot fail, optional `/mnt/k3s-cache` remains observable
  before S4 creates it, and check mode renders artifacts without trying to
  start a not-yet-installed unit or restart journald.
- The existing owner retains hourly cadence, 75/90 thresholds, structured
  journald messages, `present|absent`, root journal cap, Alloy prerequisite,
  post-Apply oneshot exercise and one-event-per-mount assertions.

## Module matrix

| Surface | Owner/module | Fit |
| --- | --- | --- |
| Managed files and units | `ansible.builtin.template`, `ansible.builtin.file` | idempotent owner |
| Timer/service lifecycle | `ansible.builtin.systemd_service` | native systemd lifecycle |
| Alloy prerequisite | `ansible.builtin.service_facts` + `assert` | fail closed |
| Read-only discovery/evidence | `command`, `win_powershell`, report playbook | exact aliases; changed false |

## Apply / Verify / Undo / Change class

- Apply: no live mutation. Future order is `playbooks/logging.yaml --tags
  logging_alloy` for the exact target, then
  `playbooks/deploy_storage_capacity_monitor.yaml --limit
  hom-lab-ctl-k3s-02`.
- Verify: exact report, syntax, production-profile lint and monitor check mode.
  Real Apply additionally runs the oneshot and asserts a journal event for each
  configured mount; forwarding and Grafana visibility remain required.
- Undo: set `storage_capacity_monitor_state: absent` and rerun the same limited
  playbook. It stops/disables the timer and removes only role-owned units,
  executable and journal drop-in; retained journal evidence is not deleted.
- Change class: idempotent configuration, currently source-only and Apply-gated.

## Verification and failure record

- Exact report, final rerun: exit `0`; both targets show `failed=0 changed=0`;
  every mandatory K3s probe succeeded.
- Monitor check mode with `storage_capacity_monitor_require_alloy=false`: exit
  `0`; target `failed=0`; six managed artifacts render as changes without live
  writes. The override isolates source rendering; it is not the production
  contract, which still requires Alloy.
- Focused lint: `ansible-lint --offline ...`; exit `0`, production profile,
  zero failures/warnings in 14 files.
- Syntax: both affected playbooks exit `0` under `bin/codex-env`.

Two informed corrections preceded those results. The first report rerun still
failed because skipped Windows loop records had no `rc`; filtering to defined
`rc` records fixed the exact expression. The first monitor check-mode run
failed because systemd cannot start a unit that check mode has not written;
service start and post-Apply exercises are now correctly real-Apply-only.
The first lint invocation never linted: dependency installation attempted a
forbidden write below `~/.ansible`; offline mode reused installed collections.

## Remaining obligations

S3 data-preserving HF cache cutover is open. S4 attachment, post-attach by-id/
serial binding, filesystem/mount and containerd/local-path migrations are open.
S5 live Alloy deployment, monitor Apply, exercised forwarding/dashboard proof
and absent-path proof are open. S6 whole-campaign closeout remains open.
Independent Evaluator review is mandatory.
