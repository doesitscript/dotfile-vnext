---
entry_scenario: reviewed-preparation-handoff
campaign_id: hrl-storage-implementation-beta-01
deploy_or_apply_claim: no
source_of_truth_root: /Users/joshc/develop/dotfile-vnext
authority: configuration-truth-not-approval
---

# Implementation accounting

This is the seed for the next Implementer pass, not an implementation receipt.

## Source of truth

Project: `/Users/joshc/develop/dotfile-vnext`.
No storage roles, playbooks, inventory or managed hosts changed in this beta
adapter-authoring iteration. Record actual touched paths and actions here as
implementation proceeds; preserve unrelated pre-existing Git changes.

## Designed deliverables

| Deliverable | Source / recreation | Status |
| --- | --- | --- |
| Implementation/Evaluator/Observer project adapters | `../multi-agent-design/{implementer,evaluator,observer}/skills/`, shared contract and launch prompts | Authored; validation in `../multi-agent-design/iteration-beta-validation.md`; no live campaign claim |
| Reviewed upstream snapshot and intake checker | `upstream-manifest.json`, `upstream/`, `../multi-agent-design/runtime/check-implementation-handoff.ts` | Imported byte-for-byte; preparation review only |
| Practical implementation campaign | This README, accounting and authorization ledger | Seeded; Implementer owns subsequent changes |
| Storage/cache/offload/monitoring Ansible capabilities | `playbooks/report_storage.yaml`, `playbooks/deploy_k3s_data_disk.yaml`, `playbooks/verify_k3s_data_disk_safety.yaml`, `roles/{k3s_vllm_runtime,hyperv_vm_data_disk,linux_data_disk_mount}/`, `inventory/host_vars/hom-lab-ctl-k3s-02.yaml`; later monitoring owner remains gated by evidence and user decisions | S2 no-change accepted; state-aware VHDX/guest-mount lifecycle owners and controller-local safety verification exist with mutation disabled and required identity/capacity/backup/authority inputs; vLLM cutover and live mutation remain open |
| HRL and final project documentation | Source entries named in upstream brief; final owned plan | HRL worktree verified clean at `c2d51c27ea513e82100ad82f74430c7cb901473a`; campaign-specific final consolidation remains open |

## Obligation ledger

| ID | State | Current evidence / next work |
| --- | --- | --- |
| S1 | in-progress | Initial receipt plus `receipts/2026-09-11T071803Z-s1-s3-correction.md`: exact map retained; report now fails when mandatory probes fail and exposes `storage_report` / `k3s_storage_report` tags. Monitoring owner remains open. |
| S2 | reviewable-no-change-conclusion | `receipts/2026-09-11T075622Z-s2-owner-and-exact-evidence.md`: K3s owns the generated containerd config, kubelet owns normal image GC, effective thresholds are already 85/80, no custom containerd template exists, and current images have zero eligible reclaim bytes. No config change, external prune, deletion or restart is justified; capacity/offload remains S3/S4. |
| S3 | blocked-on-storage-decision | Existing `k3s_vllm_runtime` present path fails closed without verified backing. The new mount owner stops at persistent backing; workload stop/copy/PV-PVC cutover/health/integrity/reversal remains a distinct required implementation after target/backup selection. |
| S4 | source-safety-reviewable; identity/apply-gated | `playbooks/deploy_k3s_data_disk.yaml` encodes attach → initialize/mount for `present` and unmount/fstab removal → detach for `absent`. Hyper-V now rechecks current free space and the selected reserve immediately before `New-VHD`; Linux requires a whole-disk `/dev/disk/by-id/` path before partition derivation and uses exact `findmnt --mountpoint` semantics for absent. `verify_k3s_data_disk_safety.yaml` exercises populated matching, eight rescued negative fixtures, an already-unmounted source-empty fixture and the apply-capacity boundary with `changed=0`. Selected physical values are adopted; post-attach by-id/serial binding and live Apply remain open. |
| S5 | blocked-on-user-decision | Current stack has journald → Alloy → Loki/Grafana visibility but no proven Prometheus/Alertmanager storage-alert owner. Choose host-native visibility versus a Prometheus-compatible metrics/alerting owner, then cadence, thresholds and route. |
| S6 | in-progress | Context7/local `ansible-doc` module matrix and Apply/Verify/Undo recorded; observed-state diagrams refreshed; HRL worktree is clean at commit `c2d51c27ea513e82100ad82f74430c7cb901473a`. Full implementation receipts remain open. |

Each closed row must cite exact receipts; `blocked` needs a concrete dependency
and next owner. Scope reductions require user authorization. Keep this ledger
aligned with README obligations and all designed deliverables, not just code.

## Routine outputs

- `receipts/2026-09-11T065746Z-s1-storage-discovery.md` — read-only discovery
  and Ansible knowledge receipt; `artifact_review: required`.
- `receipts/2026-09-11T071803Z-s1-s3-correction.md` — evaluator-feedback
  correction, S2 sizing, vLLM gate and HRL disposition; `artifact_review: required`.
- `receipts/2026-09-11T075622Z-s2-owner-and-exact-evidence.md` — exact-command
  S2 owner/config evidence and full S1-S6 obligation inventory refresh;
  `artifact_review: required`.
- `receipts/2026-09-11T080420Z-s3-s5-owner-design.md` — S3/S4 lifecycle
  scaffold, negative preflight evidence, module matrix and S5 decision package;
  `artifact_review: required`.
- `receipts/2026-09-11T082317Z-s4-safety-corrections.md` — state-aware lifecycle
  ordering, VHDX/capacity/path and partition/mount identity corrections plus
  controller-local positive/negative safety evidence; `artifact_review: required`.
- `receipts/2026-09-11T105233Z-s4-final-source-boundaries.md` — exact-mountpoint,
  stable whole-disk input and apply-time reserve corrections with populated
  controller-local evidence; `artifact_review: required`.
- `playbooks/report_storage.yaml` output — routine read-only managed-host output;
  summarized in the receipt rather than stored as a designed product.

Observer snapshots are advisory, not governing inputs or sign-off.

## Deploy / apply status

- Live mutating apply: **no**.
- Verified managed-host results: **read-only S1 results captured for the exact
  guest and Hyper-V aliases; no live mutation**.
- Evaluator implementation approval: **none**.
- Next actor: Evaluator for review of the corrective Implementer pass.
