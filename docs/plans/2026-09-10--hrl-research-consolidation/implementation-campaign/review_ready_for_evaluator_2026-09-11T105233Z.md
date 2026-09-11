---
contract_version: 1
pipeline_id: hrl-research-consolidation
task_id: hrl-research-consolidation
campaign_id: hrl-storage-implementation-beta-01
stage_id: implementation
run_id: hrl-storage-implementation-beta-01-parent-20260911t104646z-implementer-1
role: implementer
event_id: hrl-storage-implementation-beta-01-parent-20260911t104646z-implementer-1:2
responds_to: "/Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/implementation-campaign/feedback_for_review_by_evaluator_2026-09-11T083117Z.md"
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

# Implementer handoff — final S4 source boundaries

## Changed owners and files

- `roles/linux_data_disk_mount/tasks/{present,absent,derive_partition}.yml`
- `roles/hyperv_vm_data_disk/tasks/present.yml`
- `playbooks/verify_k3s_data_disk_safety.yaml`
- `coordination/implementation-accounting.md`
- `README.md` plan verification receipt
- `receipts/2026-09-11T105233Z-s4-final-source-boundaries.md`

## Evaluator checks requested

1. Confirm already-unmounted absent runs use exact `--mountpoint` semantics and
   cannot populate the root filesystem as the selected source.
2. Confirm raw `/dev/sdb` and `/dev/disk/by-id/*-part1` fixtures fail at the
   intended independent input gates before partitioning.
3. Confirm the mutation-capable Hyper-V block receives the selected reserve,
   re-reads host free space, and throws before `New-VHD` when crossed.
4. Re-run intake, syntax, focused lint, controller-local safety, exact limited
   targeting and `git diff --check` against the receipt-bound state.

## Evidence and remaining scope

Evidence: `receipts/2026-09-11T105233Z-s4-final-source-boundaries.md` plus the
fresh verification excerpt below. No live Apply ran. The whole campaign remains
incomplete: post-attach device identity, S3/S4 Apply and cutover evidence, S5
implementation, S6 closeout, and fresh whole-campaign Evaluator approval remain
open.

## Fresh verification excerpt

- Intake checker: exit `0`; `intake=verified`; live Apply and implementation
  approval remain `false`.
- Syntax check: exit `0`; `playbook: playbooks/deploy_k3s_data_disk.yaml`.
- Focused lint: exit `0`; production profile, `0` failures and `0` warnings in
  17 processed files.
- Controller-local safety: exit `0`; `ok=46 changed=0 unreachable=0 failed=0
  rescued=8`. The rescued failures are the eight expected negative fixtures.
- Exact limited target preview: exit `0`; guest plays contain only
  `hom-lab-ctl-k3s-02`, and the Windows play only `HOM-LAB-HVH-02`.
- `git diff --check`: rerun after this handoff write; see completion signal.

Review-state digests:

- Linux present: `f8e71bcbb8b9b7d6fa40364dfb0bbdd4b86ed25cd849ada3e6dd31cd782c09e3`
- Linux absent: `e3a3bb939c0d2ef46f435d61acd646ef457f1f1ce887acd5f92360677862cd55`
- Partition derivation: `a95f328e4c166353b6bd6ef3c4334a6c1d8079caa1a23baf59855d48d5dd5a13`
- Hyper-V present: `7e2306758233c5e61f921a9f61e309d7c7dc2cf2cf9b628b591d968f04eabec2`
- Safety playbook: `e02685bd07c1e46e96fc895d0462db710b661c1e22b10d2fb9d52854cb929ba5`
- Campaign README: `ca112c26046310e9377db74961c9800e595ac5a951d09f229da9e4c91f515a67`
- Accounting: `3f9b95e75d4b328ba63674c02531e88e2599c1d9f56afc84db12843d019c5be4`
- Receipt: `c2aab976b1c55bed57ec4fbfa1ececf58f304656a0f56f830f71f7e6c7b4c5ea`
