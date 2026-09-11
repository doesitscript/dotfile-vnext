---
contract_version: 1
pipeline_id: hrl-research-consolidation
task_id: hrl-research-consolidation
campaign_id: hrl-storage-implementation-beta-01
stage_id: implementation
run_id: hrl-storage-implementation-beta-01-parent-20260911t131549z-implementer-1
role: implementer
event_id: hrl-storage-implementation-beta-01-parent-20260911t131549z-implementer-1:1
responds_to: "/Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/implementation-campaign/feedback_for_review_by_evaluator_2026-09-11T113239Z.md"
upstream_run_id: hrl-preparation-20260911-r2
upstream_plan_sha256: 2a1466c9c81ea613ec5a916777d834050245169af51546f67f35d44ed7338d2c
status: evidence-captured
next_actor: Evaluator
mode: orchestrated
session_id: hrl-research-consolidation-implementation-hrl-storage-implementation-beta-01-parent-20260911t131549z-ppid22456
owner_manifest_path: /Users/joshc/develop/oneoffs/hrl-storage-implementation-beta-01-parent-20260911T131549Z/run/owned-processes.json
expert_recommendation_path: /Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/implementation-campaign/eval_feature/response_on-site_expert/2026-09-11T085155Z-onsite-expert-recommendation.md
decision_authority_profile_path: /Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/multi-agent-design/decision-authority-profiles.md
---

# S3-S5 source owner batch receipt

## Authority and preflight

The bounded parallel-preflight manifest contains zero jobs and zero rejected
jobs, so it supplied no implementation or permission evidence. The
`lab_recreatable_autonomy` profile authorizes adoption of the Expert's bounded
technical defaults, but this pass performs repository implementation and
read-only target resolution only. Live Apply remains unauthorized.

All five attempted peer `set_summary` updates were rejected because the peer
tool requested approval while the session approval policy is `never`. This
receipt preserves that visibility limitation; it did not stop source work.

## Implemented and reviewed owners

- S3: `k3s_vllm_runtime` now resolves the retained PVC/PV source, verifies the
  exact mounted backing and free-space floor, quiesces the Deployment, performs
  a non-deleting checksum copy, sets `HF_HUB_CACHE`, verifies readiness,
  `/health`, `/v1/models`, DiskPressure and root margin, and restores the prior
  Deployment definition on failure. A rerun that already uses the exact selected
  host path skips the one-time migration gate.
- S4: `k3s_storage_offload` moves only the K3s agent containerd tree behind a
  verified ext4/xfs bind mount, retains the original tree and local-path
  ConfigMap, routes only newly provisioned local-path PVs, verifies bind FSROOT,
  and reverses before the guest disk is unmounted. K3s server/database/TLS and
  credential trees and existing PV paths are not moved or rewritten.
- Dependency order: `deploy_k3s_storage_expansion.yaml` imports data-disk
  attach/mount/offload, vLLM cutover, then Alloy/capacity monitoring. The
  data-disk absent path reverses offload before unmount and detach.
- S5: the prior `df --output=pcent` correction remains intact;
  `deploy_storage_capacity_monitor.yaml` now composes `logging_alloy` before
  the monitor. The central Loki endpoint was moved to the active
  `inventory/group_vars/all/` surface and resolves to the logging server.

## Fresh targeted validation

| Check | Exit | Relevant result |
| --- | ---: | --- |
| Exact inventory variable projection | 0 | S3/S4 state is `present`; all mutation gates remain `false`; selected paths match the adopted NVMe layout |
| Umbrella `--list-hosts --list-tasks --list-tags` with exact two-host limit | 0 | Windows disk play selects only `HOM-LAB-HVH-02`; guest plays select only `hom-lab-ctl-k3s-02`; order is disk/mount/offload → vLLM → Alloy/monitor |
| Umbrella syntax check | 0 | names `playbooks/deploy_k3s_storage_expansion.yaml` |
| vLLM cache migration fixture | 0 | `ok=14 changed=7 failed=0`; copy, convergence, retained source, cutover and reversal assertions pass |
| K3s storage offload fixture | 0 | `ok=3 changed=0 failed=0`; quiesce/copy/verify/reversal, new-PV-only and ordering assertions pass |
| Storage monitor shell fixture | 0 | `ok=11 changed=5 failed=0`; 85% parses and optional/required missing mounts remain distinct |
| Focused production lint | 0 | `0 failure(s), 0 warning(s)` across 59 processed files |
| Narrow Alloy endpoint probe | 0 | resolves `http://192.168.50.158:3100/loki/api/v1/push` |
| Final focused lint | 0 | `0 failure(s), 0 warning(s)` across 57 processed files |
| Final syntax and `git diff --check` | 0 | umbrella playbook named; no whitespace errors |

Two fixture defects were corrected after reading their full errors: an
overbroad assertion rejected every restore task named for the retained PVC, and
a second assertion searched top-level tasks for a nested cleanup task. The next
informed run passed. Six fatal lint findings were trailing blank lines in the
new S4 role and were removed before lint passed. Shell startup continued to warn
that `C.UTF-8` is unavailable after three environment/shell attempts; all proving
commands ran through `bin/codex-env` and their Ansible runtime used UTF-8.

## Full S1-S6 disposition

| Slice | Current state | Remaining gate |
| --- | --- | --- |
| S1 | accepted current report increment; in progress | post-attach by-id/serial and post-change baseline |
| S2 | accepted no-change | none unless current evidence changes |
| S3 | source reviewable | S4 backing, authorized cutover, live readiness/health/models/pressure/root-margin and reversal evidence |
| S4 | source reviewable | authorized attach, post-attach identity, mount, offload integrity, K3s/imagefs and live reversal evidence |
| S5 | source reviewable | live Alloy/monitor Apply, current-event Loki/Grafana proof and `absent` exercise |
| S6 | in progress | final HRL/documentation consolidation and whole-campaign review |

## Apply / Verify / Undo / Change class

- Apply: repository source only; no managed-host mutation.
- Verify: exact target/variable preview, controller-local fixtures, syntax,
  focused production lint, endpoint resolution and whitespace validation.
- Undo: source changes are revertible. Runtime reversal retains the original
  cache/PVC, containerd tree, local-path ConfigMap and VHDX data; offload
  reversal precedes unmount/detach.
- Change class: idempotent desired-state source implementation with future
  destructive-capable migration still exact-target, identity and Apply gated.

## Limitations

No VHDX attachment, guest disk initialization, cache/containerd migration,
Alloy/monitor deployment, forwarding/Grafana proof, monitor removal or live
reversal ran. The campaign remains incomplete and requires independent
Evaluator review.
