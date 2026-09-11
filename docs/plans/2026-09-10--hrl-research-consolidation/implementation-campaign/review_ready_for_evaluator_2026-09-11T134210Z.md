---
contract_version: 1
pipeline_id: hrl-research-consolidation
task_id: hrl-research-consolidation
campaign_id: hrl-storage-implementation-beta-01
stage_id: implementation
run_id: hrl-storage-implementation-beta-01-parent-20260911t133827z-implementer-1
role: implementer
event_id: hrl-storage-implementation-beta-01-parent-20260911t133827z-implementer-1:1
responds_to: "/Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/implementation-campaign/feedback_for_review_by_evaluator_2026-09-11T113239Z.md"
upstream_run_id: hrl-preparation-20260911-r2
upstream_plan_sha256: 2a1466c9c81ea613ec5a916777d834050245169af51546f67f35d44ed7338d2c
status: review-ready
next_actor: Evaluator
mode: orchestrated
session_id: hrl-research-consolidation-implementation-hrl-storage-implementation-beta-01-parent-20260911t133827z-ppid54261
owner_manifest_path: /Users/joshc/develop/oneoffs/hrl-storage-implementation-beta-01-parent-20260911T133827Z/run/owned-processes.json
expert_recommendation_path: /Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/implementation-campaign/eval_feature/response_on-site_expert/2026-09-11T085155Z-onsite-expert-recommendation.md
decision_authority_profile_path: /Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/multi-agent-design/decision-authority-profiles.md
---

# Implementer handoff — S3/S4 source package ready for Evaluator review

## Outcome

The bounded K3s storage owner package now encodes the adopted, data-preserving
S3/S4 path. The vLLM cutover quiesces the deployment, copies and checksum-checks
the retained cache, sets `HF_HUB_CACHE` on the host-path deployment, proves the
models endpoint and a real completion request, and only then permits the
separately gated old-cache cleanup. Its rescue path can copy retained data back
before restoring the prior deployment.

Containerd offload retains the original tree, checksum-checks forward and
reverse copies, routes only newly provisioned local-path PVs to the new backing,
and now refuses to unmount a containerd path whose `FSROOT` is not the selected
data-disk destination. The orchestration order remains data disk/offload, vLLM
cutover, then Alloy before capacity monitoring.

## Changed owners presented for review

- `roles/k3s_vllm_runtime/**`
- `roles/k3s_storage_offload/**`
- `playbooks/deploy_k3s_storage_expansion.yaml`
- `playbooks/verify_k3s_storage_offload_safety.yaml`

This pass specifically tightened:

- `roles/k3s_vllm_runtime/tasks/present.yml`
- `roles/k3s_storage_offload/tasks/restore_containerd.yml`
- `playbooks/verify_k3s_storage_offload_safety.yaml`

## Controller-local validation receipt

One targeted bundle ran after the owner change:

```text
git diff --check -- <bounded owner batch>                         exit 0
bin/codex-env ansible-playbook --syntax-check
  playbooks/deploy_k3s_storage_expansion.yaml                     exit 0
bin/codex-env ansible-playbook --syntax-check
  playbooks/verify_k3s_storage_offload_safety.yaml                exit 0
bin/codex-env ansible-playbook -i localhost,
  playbooks/verify_k3s_storage_offload_safety.yaml                exit 0

localhost recap: ok=3 changed=0 unreachable=0 failed=0 skipped=0
contract assertion: All assertions passed
```

The static fixture covers retained-copy and checksum contracts, exact
containerd reversal identity, new-PV-only local-path routing, `HF_HUB_CACHE`,
post-cutover inference before optional cleanup, reversal ownership, and Alloy
before monitoring.

## Mandatory follow-up verification

- No SSH, inventory-targeted Ansible, live discovery, managed-host Apply, or
  runtime diagnostics ran in this Light pass.
- The guest still requires post-attach `/dev/disk/by-id/` and serial discovery;
  no disk identity is guessed in this source package.
- Authorized execution must prove the selected mount, cache integrity, vLLM
  health/inference, containerd/local-path ownership, root utilization,
  `DiskPressure=False`, monitor forwarding, and the monitor `absent` path.
- This artifact requests independent Evaluator review and is not self-approval
  or whole-campaign completion.

## Apply / Verify / Undo / Change class

- Apply: deferred; this pass changed controller-local source only.
- Verify: targeted syntax, static lifecycle-contract fixture, and whitespace
  validation passed as recorded above.
- Undo: revert the three pass-specific source edits; eventual runtime reversal
  remains data-preserving and identity-gated.
- Change class: idempotent desired-state source plus destructive-capable future
  migration guarded by explicit Apply, identity, integrity, retention, and
  independent-review gates.

## Decision application

The `lab_recreatable_autonomy` profile authorizes adoption of the supplied
Expert best recommendation inside this non-production campaign, but does not
grant Apply or permit guessed target identity. This pass applies only that
source-level recommendation and retains the outstanding runtime gates.

## Sources checked

- Latest governed Evaluator feedback:
  `feedback_for_review_by_evaluator_2026-09-11T113239Z.md`.
- Supplied On-site Expert recommendation:
  `2026-09-11T085155Z-onsite-expert-recommendation.md`.
- Supplied decision authority profile:
  `multi-agent-design/decision-authority-profiles.md`.
- The four bounded owner surfaces listed above.
