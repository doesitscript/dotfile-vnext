---
contract_version: 1
pipeline_id: hrl-research-consolidation
task_id: hrl-research-consolidation
campaign_id: hrl-storage-implementation-beta-01
stage_id: implementation
run_id: hrl-storage-implementation-beta-01-parent-20260911t111945z-evaluator-2
role: evaluator
event_id: hrl-storage-implementation-beta-01-parent-20260911t111945z-evaluator-2:1
responds_to: "/Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/implementation-campaign/review_ready_for_evaluator_2026-09-11T112508Z.md"
upstream_run_id: hrl-preparation-20260911-r2
upstream_plan_sha256: 2a1466c9c81ea613ec5a916777d834050245169af51546f67f35d44ed7338d2c
status: changes-requested
next_actor: Implementer
mode: orchestrated
session_id: hrl-research-consolidation-implementation-hrl-storage-implementation-beta-01-parent-20260911t111945z-ppid57221
owner_manifest_path: /Users/joshc/develop/oneoffs/hrl-storage-implementation-beta-01-parent-20260911T111945Z/run/owned-processes.json
expert_recommendation_path: /Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/implementation-campaign/eval_feature/response_on-site_expert/2026-09-11T085155Z-onsite-expert-recommendation.md
decision_authority_profile_path: /Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/multi-agent-design/decision-authority-profiles.md
---

# Evaluator feedback — S1 report accepted; S5 runtime command is invalid

## Verdict

The S1 cross-platform report correction is accepted on fresh independent
evidence. The exact two-target report completes with every mandatory K3s probe
successful and confirms the bounded claims in the receipt: one 80 GiB fixed
VHDX at SCSI `0:0`, no second guest disk, root at 85%, active DiskPressure,
30 GiB containerd use, 22 GiB local-path/vLLM cache use, and pending workloads.
The skipped-record guard is limited to optional-probe reporting, while the
mandatory-probe assertion remains strict on the Linux K3s target.

The S5 source increment is not runtime-ready. The generated script uses
`df -P --output=pcent "$path"` at
`roles/storage_capacity_monitor/templates/storage-capacity-monitor.sh.j2:25`.
On the selected Ubuntu guest, that exact read-only command returns rc `1` with
`df: options -P and --output are mutually exclusive`. Because the script uses
`set -euo pipefail`, it exits before emitting a capacity event for any mounted
path. This invalidates the receipt's assertion that the oneshot can exercise
the configured mounts and blocks S5 source acceptance. Removing the conflicting
`-P` is a proven narrow correction on this target: `df --output=pcent /`
returns `85%`; the Implementer must encode and test the corrected command rather
than copying this observation as implementation evidence.

This is not whole-campaign sign-off. S3 migration ownership, S4 attachment and
post-attach identity, live S5 deployment/forwarding/disable proof, and S6
closeout remain open. The blocker set changed, so the repeated-blocker research
gate does not apply. No new human design decision is required: the supplied
`lab_recreatable_autonomy` profile validly materializes the evidence-backed
Expert defaults, but it does not authorize live Apply or waive the remaining
identity, safety, receipt, and Evaluator gates.

## Required next Implementer work

- Correct the S5 `df` invocation and add a controller-local or exact-target
  read-only test that proves the rendered command parses a mounted filesystem's
  utilization and that required/optional missing-mount behavior remains
  distinct. Refresh the receipt; syntax and lint alone cannot prove this shell
  runtime path.
- Continue the still-unfinished source work from the prior verdict: implement
  the owned S3 quiesce/copy/integrity/`HF_HUB_CACHE` cutover/reversal path, and
  extend S4 with the adopted data-preserving containerd/new-local-path backing
  sequence without moving durable K3s server/database/TLS/credential data or
  rewriting existing PV paths.
- Keep post-attach guest by-id/serial binding fail-closed. The current report
  still shows no second disk, so no by-id value may be guessed before the
  selected VHDX is attached.
- Compose the existing `logging_alloy` owner before the monitor in the eventual
  authorized Apply path, then capture current-event forwarding/Grafana evidence
  and exercise `storage_capacity_monitor_state: absent`. Do not treat the
  check-mode `storage_capacity_monitor_require_alloy=false` override as the
  production route.
- Refresh the full S1-S6 obligation inventory and issue a new review-ready
  handoff. Repository implementation and read-only discovery remain authorized;
  no live mutation authority is evidenced by this invocation.

## Whole-campaign matrix

| Slice | Status | Evaluator evidence / next gate |
| --- | --- | --- |
| S1 | in progress; current report increment accepted | Exact-target report is current; post-attach identity and post-change baseline remain. |
| S2 | accepted no-change | Current report still supports K3s/kubelet ownership and zero eligible image reclamation; no S2 mutation is justified. |
| S3 | required source and runtime work | Adopted `HF_HUB_CACHE` placement exists only as a decision; owned migration, persistent backing, health, integrity and reversal evidence remain. |
| S4 | source safety accepted; Apply pending | Current report confirms slot `0:1` is free and no second guest disk exists; attachment, by-id/serial binding, mount, migration and post-change evidence remain. |
| S5 | changes requested | `df -P --output=pcent` fails on the exact target; Alloy deployment, monitor Apply, current-event forwarding and absent-path evidence also remain. |
| S6 | in progress | Research/profile lineage and diagrams exist; final HRL/documentation/receipt consolidation and whole-campaign review remain open. |

## Fresh independent evidence

- Intake: `bin/codex-env bun .../check-implementation-handoff.ts .../implementation-campaign`, exit `0`; `intake=verified`, upstream identity matches, and both Apply/approval flags are `false`.
- Target preview: monitor selector plus `--limit hom-lab-ctl-k3s-02`, exit `0`; exactly `hom-lab-ctl-k3s-02`.
- Exact report preview: `--limit 'hom-lab-ctl-k3s-02,HOM-LAB-HVH-02' --list-hosts`, exit `0`; exactly the guest and hypervisor aliases.
- Exact read-only report: same two-target limit with a writable temporary SSH control path, exit `0`; recap is `failed=0 changed=0` for both targets and the mandatory K3s assertion reports success.
- S5 command probe: `df -P --output=pcent /` through `ansible.builtin.command` on `hom-lab-ctl-k3s-02`; Ansible exits `2`, remote command rc is `1`, and GNU `df` reports the two options are mutually exclusive.
- Narrow alternative probe: `df --output=pcent /` on the same target returns rc `0` and `85%`. Ansible reports `CHANGED` because ad-hoc `command` uses its default status; the command itself is read-only.
- Syntax: both `playbooks/report_storage.yaml` and `playbooks/deploy_storage_capacity_monitor.yaml` syntax checks exit `0` and name the expected playbooks.
- Focused lint: offline production profile exits `0` with `0` failures and `0` warnings across 14 files.
- `git diff --check`, exit `0`.

## Reviewed source and receipt state

- Git HEAD: `fb8b1febe7c66281d448a481c80e511c0359461a`; the reviewed campaign and source files remain dirty/untracked within the shared worktree, so this verdict is digest-bound.
- Implementer outbox: `review_ready_for_evaluator_2026-09-11T112508Z.md` = `d9e8ead304a699ef226386e4431209a90a4d6b1490ef4eeab73ef497e18e93c7`.
- Implementer receipt: `receipts/2026-09-11T112508Z-s1-s5-source-review.md` = `1edde88a614d5bc3e3fdd621b087671c80cb9205a1f97610e53098423cf508ab`.
- Campaign README/accounting/authorization/performance adoption = `718a68992e983d40e6773f0b7b6fafa6195dad68cde0027c973111a78ae78423`, `d837a64260a48b6e083551ade678deb96cfff34a2b3671b154980d1bd9f65ef7`, `14e3d8940c4b4e53d7d10bd6e643980012775fd815ebbcb756fa30f7d798d9d3`, `917eec1ad8e48a7312b8edcf7f6c1d8007cad473a5b8201beea37a3ce38c2f2d`.
- Report/monitor playbooks = `a44aa90991a60dc59fdffe274e89bdf3dc153df889c11eb1f1509f20ce16796f`, `5b958de13a3ba84e823be688bdf60bedb40698361415916b4e478f0624bc47ff`.
- Monitor defaults/main/present/absent/handler/script = `adc3e66f1958c9f8656757258613baedd950f77be19db4f61de2c6ad0394c97d`, `aad829115bace7a78cfa97870dc2a4393b206fa5815d6ba08ee961caa3b639ff`, `514f9c4e9f0a3602b12fc20f231ab7ffd555e683dbee760d020238717cf7d94e`, `431c3069e254ab22b4bc70586a20cb3678c22b5ac666f6b27d550264e147a47b`, `9ea31a23ca544cce89594ecd5fed04b549d854e1817e1eb72ee0602094cef3e3`, `821a71b4a92d2df069674bb7b6763966fd63e99eb440eefa9701c63fe2b678a6`.
- The bounded parallel-preflight manifest contains zero jobs and zero rejected jobs; it supplies no implementation or permission evidence.
- The supplied runtime observation binds the parent session to Implementer slot 49 and Evaluator slot 50. Runtime state is transport context, not campaign-quality evidence.

## Apply / Verify / Undo / Change class

- Apply: no managed-host mutation by Evaluator; only read-only report and command probes ran.
- Verify: frozen intake, exact target previews/report, exact failing and corrected-form `df` probes, syntax, focused lint, source digests and whitespace validation.
- Undo: no live state changed. Source changes remain revertible; future reversal must retain the original cache and VHDX data, remove mount/fstab state before exact detach, and preserve retained journal evidence.
- Change class: evaluator-owned governance artifact plus read-only discovery; future S3/S4 migration is destructive-capable and remains fail-closed and authority-gated.

## Sources checked

- Campaign README, implementation accounting, authorization ledger, performance-layout adoption, latest Implementer outbox and receipt.
- Current report/monitor playbooks, monitor role defaults/tasks/handlers/templates, target host vars, and existing `logging_alloy` ownership surfaces.
- Frozen upstream intake checker and upstream snapshots.
- On-site Expert recommendation, decision-authority profiles, role operating contract, and performance research-application/materialization packet.
- Supplied parallel-preflight manifest, parent runtime observation, and ownership manifest.
- Storage Evaluator beta adapter, mature paired-agent Evaluator and child artifact/evidence/repeated-blocker skills, Ansible knowledge gate, plan verification gate, and Superpowers verification-before-completion skill.
