---
contract_version: 1
pipeline_id: hrl-research-consolidation
task_id: hrl-research-consolidation
campaign_id: hrl-storage-implementation-beta-01
stage_id: implementation
run_id: hrl-storage-implementation-beta-01-parent-20260911t104646z-evaluator-2
role: evaluator
event_id: hrl-storage-implementation-beta-01-parent-20260911t104646z-evaluator-2:1
responds_to: "/Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/implementation-campaign/review_ready_for_evaluator_2026-09-11T105233Z.md"
upstream_run_id: hrl-preparation-20260911-r2
upstream_plan_sha256: 2a1466c9c81ea613ec5a916777d834050245169af51546f67f35d44ed7338d2c
status: changes-requested
next_actor: Implementer
mode: orchestrated
session_id: hrl-research-consolidation-implementation-hrl-storage-implementation-beta-01-parent-20260911t104646z-ppid29198
owner_manifest_path: /Users/joshc/develop/oneoffs/hrl-storage-implementation-beta-01-parent-20260911T104646Z/run/owned-processes.json
expert_recommendation_path: /Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/implementation-campaign/eval_feature/response_on-site_expert/2026-09-11T085155Z-onsite-expert-recommendation.md
decision_authority_profile_path: /Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/multi-agent-design/decision-authority-profiles.md
---

# Evaluator feedback — S4 source boundaries accepted; continue campaign

## Verdict

The three bounded S4 source corrections from the prior Evaluator verdict are
accepted on fresh independent evidence. Exact `findmnt --mountpoint` lookups
now keep an already-unmounted path source-empty, stable whole-disk input gates
reject both `/dev/sdb` and `*-part1` before partitioning, and the Hyper-V
creation block re-reads free space with the selected reserve before `New-VHD`.
The controller-local static/negative fixtures are a valid equivalent to the
Expert's suggested mock: they exercise the input assertions and bind the exact
command/script ordering without requiring a managed-host mutation.

This is not whole-campaign sign-off. The adopted performance-layout packet adds
source ownership and evidence work across S3-S5, and no live S3/S4 cutover or
S5 implementation evidence exists. Because review-relevant source changed and
required work remains, the correct artifact is `feedback`, not `waiting` or
`ready`. The blocker set has changed, so the repeated-blocker research gate does
not apply.

## Required next Implementer work

- Continue the authorized read-only discovery: reconfirm Hyper-V slot `0:1`,
  bind the post-attach guest whole-disk by-id/serial only when a disk exists,
  prove ext4/xfs plus overlayfs compatibility for the intended containerd
  backing, and discover the smaller SATA SSD identity/capacity/health and live
  K3s/Kubelet swap contract. Do not guess a disk or path.
- Translate the adopted S3 layout into owned, idempotent Ansible: use
  `HF_HUB_CACHE`, retain token data and the original cache on the durable root
  until health/integrity/capacity checks succeed, and provide explicit
  quiesce/copy/verify/cutover/reversal behavior. Preserve the hard prohibition
  against relocating durable K3s server/database/TLS/credential data.
- Extend the S4 owner for the adopted NVMe uses only after the discovery gates:
  data-preserving containerd bind-mount migration and a separately owned path
  for newly provisioned local-path PVCs. Existing PV paths remain immutable
  until a deliberate migration. Do not add a containerd override unless current
  evidence requires one; if required, preserve the generated K3s base and use
  the containerd 2.x `config-v3.toml.tmpl` contract.
- Implement the adopted S5 current-stack-first owner: hourly `/` and
  `/mnt/k3s-cache` checks at 75/90 through systemd/journald to the existing
  Alloy/Loki/Grafana route, including disable/removal and exercised behavior.
  Keep pod logs on the kubelet-accounted root filesystem. Treat SATA journal,
  swap and compile-cache placement as conditional on the discovery and
  compatibility gates, with safe fallback placement when they do not hold.
- Refresh the full S1-S6 obligation inventory and publish one receipt/outbox
  that distinguishes source-complete, read-only-discovered, live-apply-pending,
  and verified runtime states. The current dispatch authorizes repository work
  and relevant read-only discovery; it does not evidence a live mutation.

No new human design decision is required now: `lab_recreatable_autonomy`
materializes the evidence-backed Expert defaults within this campaign. If all
source and read-only work is exhausted before live mutation authority is
available, the next Implementer handoff should name the exact proposed targets,
commands, backup/reversal and smallest live-Apply authority question.

## Whole-campaign matrix

| Slice | Status | Evaluator evidence / next gate |
| --- | --- | --- |
| S1 | in progress | Exact guest/hypervisor baseline exists; SATA and final monitoring-owner evidence remain. |
| S2 | accepted no-change | K3s/kubelet GC ownership and zero eligible image bytes still support no S2 mutation. |
| S3 | required work | Adopted `HF_HUB_CACHE` placement is documented; owned migration, persistent backing, health, integrity and reversal evidence remain. |
| S4 | source corrections accepted; Apply pending | The three final source boundaries pass; slot freshness, by-id/serial binding, filesystem/overlay proof, authorized Apply and post-change evidence remain. |
| S5 | required work | Current-stack-first policy is selected; timer/reporting owner, conditional SATA/swap work, behavior proof and disable path remain. |
| S6 | in progress | Research lineage and diagrams exist; final receipts, HRL consolidation and independent whole-campaign review remain open. |

## Fresh independent evidence

- Intake: `bin/codex-env bun .../check-implementation-handoff.ts .../implementation-campaign`, exit `0`; `intake=verified`, upstream run/hash match, and the checker grants neither live Apply nor implementation approval.
- Syntax: `bin/codex-env ansible-playbook -i inventory/inventory.yaml playbooks/deploy_k3s_data_disk.yaml --syntax-check`, exit `0`; output names `playbooks/deploy_k3s_data_disk.yaml`.
- Focused lint: `bin/codex-env ansible-lint --offline playbooks/deploy_k3s_data_disk.yaml playbooks/verify_k3s_data_disk_safety.yaml roles/hyperv_vm_data_disk roles/linux_data_disk_mount`, exit `0`; production profile, `0` failures and `0` warnings in 17 processed files.
- Controller-local safety: `bin/codex-env ansible-playbook -i inventory/inventory.yaml playbooks/verify_k3s_data_disk_safety.yaml`, exit `0`; `ok=46 changed=0 unreachable=0 failed=0 rescued=8`. The eight `FAILED` task excerpts are intentional negative assertions and were rescued, proving fail-closed behavior.
- Exact target preview: `bin/codex-env ansible-playbook -i inventory/inventory.yaml playbooks/deploy_k3s_data_disk.yaml --limit 'hom-lab-ctl-k3s-02,HOM-LAB-HVH-02' --list-hosts`, exit `0`; guest plays contain only `hom-lab-ctl-k3s-02`, and the Windows play contains only `HOM-LAB-HVH-02`.
- `git diff --check`, exit `0`.

## Reviewed source and receipt state

- Git HEAD: `8522a765d41aeaa3b0c37930531fce7e63cd7e8a`; relevant campaign/role files remain dirty or untracked inside a broader pre-existing worktree, so this verdict is digest-bound.
- Implementer outbox: `review_ready_for_evaluator_2026-09-11T105233Z.md` = `1610960c28f70d2c5f6acbcd303edcbb220929910ef9c7f969400ac6ef13c3ab`.
- Correction receipt: `receipts/2026-09-11T105233Z-s4-final-source-boundaries.md` = `c2aab976b1c55bed57ec4fbfa1ececf58f304656a0f56f830f71f7e6c7b4c5ea`.
- Campaign README/accounting/authorization/performance adoption: `ca112c26046310e9377db74961c9800e595ac5a951d09f229da9e4c91f515a67`, `3f9b95e75d4b328ba63674c02531e88e2599c1d9f56afc84db12843d019c5be4`, `14e3d8940c4b4e53d7d10bd6e643980012775fd815ebbcb756fa30f7d798d9d3`, `917eec1ad8e48a7312b8edcf7f6c1d8007cad473a5b8201beea37a3ce38c2f2d`.
- Linux present/absent/partition derivation: `f8e71bcbb8b9b7d6fa40364dfb0bbdd4b86ed25cd849ada3e6dd31cd782c09e3`, `e3a3bb939c0d2ef46f435d61acd646ef457f1f1ce887acd5f92360677862cd55`, `a95f328e4c166353b6bd6ef3c4334a6c1d8079caa1a23baf59855d48d5dd5a13`.
- Hyper-V present and safety/deploy playbooks: `7e2306758233c5e61f921a9f61e309d7c7dc2cf2cf9b628b591d968f04eabec2`, `e02685bd07c1e46e96fc895d0462db710b661c1e22b10d2fb9d52854cb929ba5`, `2ea07c51f555cf5d460d91cb8c759ff3a1a7009acac6a3fd0eb7ae584903fe9f`.
- Supplied runtime observation binds this pass to active session `hrl-research-consolidation-implementation-hrl-storage-implementation-beta-01-parent-20260911t104646z-ppid29198`, Implementer slot 47 and Evaluator slot 48. Runtime/dashboard state is transport context, not campaign-quality evidence.

## Apply / Verify / Undo / Change class

- Apply: no managed-host mutation by Evaluator; next work is repo-owned Ansible and read-only discovery until explicit mutation authority is evidenced.
- Verify: frozen intake, source digests, syntax, focused lint, controller-local negative/static safety checks and exact target listing.
- Undo: source changes remain revertible; future live reversal must preserve the original cache and data, unmount/remove fstab before exact detach, and never delete the VHDX as an absent shortcut.
- Change class: idempotent desired-state implementation plus future data-preserving migration; live partition/filesystem/cutover steps are destructive-capable and remain gated.

## Sources checked

- Campaign README, implementation accounting, decisions/authorization, latest Implementer outbox and correction receipt.
- Exact Linux mount and Hyper-V VHDX role owners plus deploy/safety playbooks.
- Supplied On-site Expert recommendation and `lab_recreatable_autonomy` profile.
- Performance research-application packet, materialization brief and adopted layout.
- Frozen upstream intake checker and supplied parent runtime observation/ownership manifest.
