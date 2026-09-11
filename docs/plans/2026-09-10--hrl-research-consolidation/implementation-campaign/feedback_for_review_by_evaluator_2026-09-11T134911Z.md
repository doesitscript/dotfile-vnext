---
contract_version: 1
pipeline_id: hrl-research-consolidation
task_id: hrl-research-consolidation
campaign_id: hrl-storage-implementation-beta-01
stage_id: implementation
run_id: hrl-storage-implementation-beta-01-parent-20260911t133827z-evaluator-2
role: evaluator
event_id: hrl-storage-implementation-beta-01-parent-20260911t133827z-evaluator-2:1
responds_to: "/Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/implementation-campaign/review_ready_for_evaluator_2026-09-11T134210Z.md"
upstream_run_id: hrl-preparation-20260911-r2
upstream_plan_sha256: 2a1466c9c81ea613ec5a916777d834050245169af51546f67f35d44ed7338d2c
status: changes-requested
next_actor: Implementer
mode: orchestrated
session_id: hrl-research-consolidation-implementation-hrl-storage-implementation-beta-01-parent-20260911t133827z-ppid54261
owner_manifest_path: /Users/joshc/develop/oneoffs/hrl-storage-implementation-beta-01-parent-20260911T133827Z/run/owned-processes.json
expert_recommendation_path: /Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/implementation-campaign/eval_feature/response_on-site_expert/2026-09-11T085155Z-onsite-expert-recommendation.md
decision_authority_profile_path: /Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/multi-agent-design/decision-authority-profiles.md
---

# Evaluator feedback — source package has two reversal safety gaps

## Verdict

Changes are requested. The bounded source package now implements the intended
quiesce/copy/checksum pattern, a real post-cutover vLLM completion request
before optional source cleanup, exact containerd `FSROOT` checking, new-PV-only
local-path routing, and the required data-disk/offload → vLLM → Alloy/monitor
orchestration. The supplied Expert recommendation is applied within the
`lab_recreatable_autonomy` boundary without guessing disk identity or claiming
Apply.

Two failure windows remain unsafe. Both are source-quality blockers because
they can destroy or strand the retained recovery source precisely when a
mutating task fails. The current localhost fixture passes but does not exercise
either window.

## Grouped owner/file findings

### `roles/k3s_storage_offload/**` — blocking

`roles/k3s_storage_offload/tasks/present.yml:120` enters one rescue include for
any failure from the initial K3s stop through the final restart. The retained
backup is not created until the `mv` at line 174. If destination creation,
rsync, or checksum verification fails before that `mv`, the original
containerd tree still occupies the source path and the backup path does not
exist.

`roles/k3s_storage_offload/tasks/restore_containerd.yml:41` nevertheless
removes the source path without a backup-exists/source-is-bind-target guard,
then line 48 attempts to move the nonexistent backup into place. The new
`FSROOT` assertion prevents unmounting an unexpected filesystem, but rc=1
means "not mounted" and currently permits deletion of the intact original
directory. This makes an early copy failure destructive instead of reversible.

Required correction: make the reversal include state-aware. Before removing
the source, prove that the retained backup exists and that the source is the
expected bind target or an empty target created after the original rename. If
the original source still exists and no backup exists, preserve it and only
restore the K3s service. Add a controller-local contract fixture for a failure
before the rename and retain the exact `FSROOT` negative case.

### `roles/k3s_vllm_runtime/**` — blocking

`roles/k3s_vllm_runtime/tasks/present.yml:430` deletes the old cache entries in
a loop, while the rollback fact is not set until line 442 after the loop
finishes. If deletion fails after removing one or more entries, block rescue
restores the previous PVC-backed Deployment but
`restore_previous_deployment.yml` skips the destination-to-source rsync because
`_k3s_vllm_runtime_cache_source_cleanup_completed` is still false. The prior
Deployment can therefore restart against a partially emptied recovery source.

Required correction: mark cleanup as started before the first destructive
item, or make reversal decide from cleanup authority/state and always
checksum-sync the retained destination back when cleanup may have begun. Keep
the completion request before cleanup and preserve its separate destructive
gate. Add a controller-local assertion that a simulated mid-cleanup failure
selects the reverse copy before restoring the old Deployment.

### `playbooks/deploy_k3s_storage_expansion.yaml` and
`playbooks/verify_k3s_storage_offload_safety.yaml`

The orchestration playbook has the intended dependency order and both syntax
checks pass. The localhost fixture also passes with `ok=3 changed=0 failed=0`,
but its assertions currently prove only the happy-path copy/checksum/order
contracts and the unexpected-`FSROOT` check. Extend it with the two failure
windows above; a passing fixture that omits rescue-state safety is insufficient
for this destructive-capable package.

## Controller-local validation receipt

One targeted bundle ran after the owner review:

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

focused parsed-source state:
containerd_reversal_guards={
  'Remove empty containerd bind target': None,
  'Restore retained original containerd tree': None
}
vllm_cleanup_order=[
  'Clear verified old root-backed cache entries',
  'Record completed old cache cleanup for rollback handling'
]
```

The controller emitted its existing `C.UTF-8` startup warning and Ansible's
existing invalid-group-character warning; all commands completed successfully.
No SSH, inventory-targeted Ansible, managed-host Apply, remote probe, or runtime
diagnostic ran.

## Required next Implementer pass

- Make containerd rescue safe before, during, and after the original-tree
  rename; never remove an intact source when no retained backup exists.
- Make vLLM reversal repopulate the source if cleanup starts but fails partway.
- Extend the localhost fixture with both failure-state contracts and refresh
  the governed review-ready handoff.
- Preserve the accepted completion-request, identity, checksum, retention,
  new-PV-only, orchestration, and no-Apply boundaries.

## Apply / Verify / Undo / Change class

- Apply: none; this was a controller-local source evaluation.
- Verify: whitespace, two syntax checks, the localhost safety fixture, and a
  focused parsed-source guard/order check.
- Undo: remove this evaluator artifact only; no owner or live state was changed.
- Change class: evaluator-owned governance feedback for destructive-capable,
  fail-closed desired-state source.

## Sources checked

- Governed Implementer handoff: `review_ready_for_evaluator_2026-09-11T134210Z.md`.
- Directly cited settled Evaluator input: `feedback_for_review_by_evaluator_2026-09-11T113239Z.md`.
- Supplied On-site Expert recommendation and decision-authority profile.
- Full bounded owner batch: `roles/k3s_vllm_runtime/**`,
  `roles/k3s_storage_offload/**`, `playbooks/deploy_k3s_storage_expansion.yaml`,
  and `playbooks/verify_k3s_storage_offload_safety.yaml`.
