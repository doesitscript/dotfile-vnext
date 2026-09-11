---
contract_version: 1
pipeline_id: hrl-research-consolidation
task_id: hrl-research-consolidation
campaign_id: hrl-storage-implementation-beta-01
stage_id: implementation
run_id: hrl-storage-implementation-beta-01-parent-20260911t133827z-implementer-3
role: implementer
event_id: hrl-storage-implementation-beta-01-parent-20260911t133827z-implementer-3:1
responds_to: "/Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/implementation-campaign/feedback_for_review_by_evaluator_2026-09-11T134911Z.md"
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

# Implementer handoff — S3/S4 failure-window corrections ready for review

## Outcome

Both Evaluator-identified reversal gaps are corrected within the bounded owner
batch.

Containerd rescue now inspects the retained backup and source independently.
When a copy or checksum failure occurs before the original-tree rename, the
backup is absent and the intact unmounted source is preserved; the rescue only
returns K3s to `started`. When a retained backup exists, the role accepts only
the selected bind `FSROOT`, a missing target, or a verified empty unmounted
target. It rechecks that the underlying target is empty after unmount before
removal and gates both removal and the backup rename on backup existence.

The vLLM cutover now records cleanup as started before deleting the first old
cache entry. Any later rescue therefore checksum-syncs the retained destination
back to the source before restoring the prior Deployment, including a
mid-cleanup failure. The accepted inference-before-cleanup and separate
destructive cleanup gate remain unchanged.

## Changed owners presented for review

- `roles/k3s_vllm_runtime/**`
- `roles/k3s_storage_offload/**`
- `playbooks/deploy_k3s_storage_expansion.yaml`
- `playbooks/verify_k3s_storage_offload_safety.yaml`

This pass specifically changed:

- `roles/k3s_storage_offload/tasks/restore_containerd.yml`
- `roles/k3s_vllm_runtime/tasks/present.yml`
- `roles/k3s_vllm_runtime/tasks/restore_previous_deployment.yml`
- `playbooks/verify_k3s_storage_offload_safety.yaml`

## Controller-local validation receipt

One targeted post-change bundle completed:

```text
git diff --check -- <bounded owner batch>                         exit 0
bin/codex-env ansible-playbook --syntax-check
  playbooks/deploy_k3s_storage_expansion.yaml                     exit 0
bin/codex-env ansible-playbook --syntax-check
  playbooks/verify_k3s_storage_offload_safety.yaml                exit 0
bin/codex-env ansible-playbook -i localhost,
  playbooks/verify_k3s_storage_offload_safety.yaml                exit 0

localhost recap: ok=4 changed=0 unreachable=0 failed=0 skipped=0
contract assertion: All assertions passed
```

The fixture now models both destructive failure windows: an early containerd
copy failure with `backup_exists=false`, `source_exists=true`, `mount_rc=1`,
and a mid-cache-cleanup failure with `cleanup_started=true` while
`cleanup_completed=false`. It asserts that source removal/rename require the
retained backup and that reverse copy precedes restoration of the prior vLLM
Deployment.

The controller emitted the known `C.UTF-8` startup warning and Ansible's
existing invalid-group-character warning; every validation command exited 0.

## Mandatory follow-up verification

- No SSH, inventory-targeted Ansible, live discovery, managed-host Apply, or
  runtime diagnostics ran in this Light pass.
- Post-attach `/dev/disk/by-id/` and serial discovery remains mandatory; this
  pass does not guess target disk identity.
- Authorized runtime execution must still exercise early/mid-failure reversal
  behavior where safely reproducible and prove mount identity, cache integrity,
  vLLM health/inference, containerd/local-path ownership, root utilization,
  `DiskPressure=False`, monitor forwarding, and monitor `absent` behavior.
- This is an independent-review request, not self-approval or whole-campaign
  completion.

## Apply / Verify / Undo / Change class

- Apply: none; controller-local source only.
- Verify: whitespace, two assigned-playbook syntax checks, and the expanded
  localhost failure-window contract fixture passed.
- Undo: revert the four pass-specific owner edits; no live state was changed.
- Change class: idempotent desired-state source with destructive-capable future
  migration protected by explicit Apply, state, identity, integrity, retained
  recovery data, and independent Evaluator gates.

## Decision application

The `lab_recreatable_autonomy` profile supports the Expert's data-preserving
best recommendation inside this campaign. It does not grant Apply or weaken
the exact-identity, reversal, receipt, or Evaluator requirements; those gates
remain explicit.

## Sources checked

- Latest governed Evaluator feedback:
  `feedback_for_review_by_evaluator_2026-09-11T134911Z.md`.
- Its directly cited settled Evaluator input:
  `feedback_for_review_by_evaluator_2026-09-11T113239Z.md`.
- Supplied On-site Expert recommendation:
  `2026-09-11T085155Z-onsite-expert-recommendation.md`.
- Supplied decision authority profile:
  `multi-agent-design/decision-authority-profiles.md`.
- The four bounded owner surfaces listed above.
