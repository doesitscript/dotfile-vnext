---
contract_version: "1"
pipeline_id: hrl-research-consolidation
task_id: hrl-research-consolidation
campaign_id: hrl-storage-implementation-beta-01
stage_id: implementation
run_id: hrl-storage-implementation-beta-01-parent-20260911t1936z-evaluator-1
upstream_run_id: hrl-preparation-20260911-r2
upstream_plan_sha256: "2a1466c9c81ea613ec5a916777d834050245169af51546f67f35d44ed7338d2c"
role: evaluator
event_id: hrl-storage-implementation-beta-01-parent-20260911t1936z-evaluator-1-hf-cache-review
responds_to: "/Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/implementation-campaign/review_ready_for_evaluator_2026-09-11T184543Z.md"
status: changes_requested
next_actor: implementer
mode: orchestrated
session_id: hrl-research-consolidation-implementation-hrl-storage-implementation-beta-01-parent-20260911t1936z-ppid63149
owner_manifest_path: "/Users/joshc/develop/oneoffs/hrl-storage-implementation-beta-01-parent-20260911t1936z/run/owned-processes.json"
---

# Evaluator feedback — `S3-cache-idempotence` / `FA-hf-cache-desired-state`

The declared HF cache target is present in the touched runtime owner: the
Deployment sets `HF_HUB_CACHE` beneath the configured cache mount, the role
contains no active `TRANSFORMERS_CACHE` or deprecated HF CLI task use, and the
already-selected host-path check gates migration work on repeat runs.

Source quality correction required before approval:

- Complete `roles/k3s_vllm_runtime/meta/argument_specs.yml` for the public
  `k3s_vllm_runtime_*` interface exposed by
  `roles/k3s_vllm_runtime/defaults/main.yml`, or explicitly make any omitted
  variables internal. At minimum, correct the current model default mismatch
  (`Qwen/Qwen3-0.6B` in `meta/argument_specs.yml` versus
  `Qwen/Qwen2.5-Coder-32B-Instruct-AWQ` in `defaults/main.yml`) and document
  the remaining public cache/runtime options with matching types/defaults.

The controller-local syntax validation bundle passed after using owned
temporary Ansible paths; no host, inventory-targeted, Apply, or runtime
operation was performed. Re-submit the same chunk after the argument contract
is aligned, with a refreshed frozen hash and validation result.
