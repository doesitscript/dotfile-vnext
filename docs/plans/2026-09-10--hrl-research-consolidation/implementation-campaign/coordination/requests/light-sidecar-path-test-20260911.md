---
contract_version: 1
pipeline_id: hrl-research-consolidation
task_id: hrl-research-consolidation
campaign_id: hrl-storage-implementation-beta-01
stage_id: implementation
role: implementer
status: requested
next_actor: onsite-expert
mode: orchestrated
session_id: null
owner_manifest_path: null
---

# Light sidecar path-test request

## Exact question

For the first Light functional area that can be implemented without live
Apply, what is the smallest project-owned Ansible mechanism and placement that
should be used when the refined handoff leaves a residual owner ambiguity?

## Known evidence

- The refined handoff selects `FA-hf-cache-desired-state` and
  `FA-capacity-signal` as source-first Light areas.
- Existing project owners must be extended; no unowned parallel configuration
  or live host mutation is allowed in Light.
- The campaign uses `lab_recreatable_autonomy`; exact target identity and
  Apply gates remain mandatory, but this exercise needs only source-local work.

## Affected owners

`roles/k3s_vllm_runtime/**`, `roles/storage_capacity_monitor/**`, and the
smallest related playbook/template surface selected by the recommendation.

## Acceptance test

Return one Best recommendation naming a single non-overlapping owner chunk,
its mechanism/placement, the source-local validation to run, and any hard
correction from the refined handoff that must be preserved. The Implementer
must apply that answer to one chunk and produce a fresh review-ready handoff.

## return_to

implementer
