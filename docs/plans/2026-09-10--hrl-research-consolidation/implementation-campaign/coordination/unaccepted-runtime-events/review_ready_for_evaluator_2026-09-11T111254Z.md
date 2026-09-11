---
contract_version: 1
pipeline_id: hrl-research-consolidation
task_id: hrl-research-consolidation
campaign_id: hrl-storage-implementation-beta-01
stage_id: implementation
run_id: hrl-storage-implementation-beta-01-parent-20260911t104646z-implementer-3
role: implementer
event_id: hrl-storage-implementation-beta-01-parent-20260911t104646z-implementer-3:2
responds_to: "/Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/implementation-campaign/feedback_for_review_by_evaluator_2026-09-11T105852Z.md"
upstream_run_id: hrl-preparation-20260911-r2
upstream_plan_sha256: 2a1466c9c81ea613ec5a916777d834050245169af51546f67f35d44ed7338d2c
status: review-ready
next_actor: Evaluator
mode: orchestrated
session_id: hrl-research-consolidation-implementation-hrl-storage-implementation-beta-01-parent-20260911t104646z-ppid29198
owner_manifest_path: /Users/joshc/develop/oneoffs/hrl-storage-implementation-beta-01-parent-20260911T104646Z/run/owned-processes.json
expert_recommendation_path: /Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/implementation-campaign/eval_feature/response_on-site_expert/2026-09-11T085155Z-onsite-expert-recommendation.md
decision_authority_profile_path: /Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/multi-agent-design/decision-authority-profiles.md
---

# Implementer handoff — exact discovery and S5 owner hardening

## Changed owners/files

- `playbooks/report_storage.yaml`
- `roles/storage_capacity_monitor/{tasks/present.yml,handlers/main.yml,templates/storage-capacity-monitor.sh.j2}`
- `implementation-campaign/{README.md,coordination/implementation-accounting.md}`
- `receipts/2026-09-11T111254Z-s1-s5-discovery-and-monitor.md`

## Evaluator checks requested

1. Re-run the exact dual-target storage report and confirm skipped Windows K3s
   results no longer dereference absent `rc` fields.
2. Confirm fresh identity: slot 0:1 free, no second guest disk/by-id yet, ext4-
   backed overlayfs active, Kubelet swap tolerated but no active swap, and no
   SATA volume has safe spare capacity for the proposed optional lane.
3. Review the monitor's 75/90 hourly behavior, required-versus-optional mount
   handling, 1 GiB journal cap, Alloy fail-closed gate, post-Apply event
   assertions and bounded `absent` cleanup.
4. Confirm this remains source/read-only progress: no live Apply, no existing PV
   rewrite, no containerd template override, and no durable K3s data movement.

## Evidence and current boundary

Receipt: `receipts/2026-09-11T111254Z-s1-s5-discovery-and-monitor.md`.
Fresh exact report, focused production-profile lint, syntax and monitor check
mode exit `0`. Live mutation remains unauthorized, and live Alloy is absent.
The whole campaign is incomplete: S3/S4 migration and Apply evidence, S5 live
route/behavior/undo evidence, S6 closeout and independent approval remain open.

## Fresh verification excerpt

- Exact report: `HOM-LAB-HVH-02 ok=6 changed=0 failed=0` and
  `hom-lab-ctl-k3s-02 ok=13 changed=0 failed=0`; mandatory K3s probes succeeded.
- Monitor check mode: `ok=13 changed=6 failed=0`, with real-Apply-only service
  start and exercises skipped.
- Focused lint: production profile, zero failures/warnings in 14 files.
- Final syntax/diff/artifact checks are rerun after this write and included in
  the completion signal.
