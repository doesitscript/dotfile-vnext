---
contract_version: 1
pipeline_id: "hrl-research-consolidation"
stage_id: "preparation"
task_id: "hrl-research-consolidation"
run_id: "hrl-preparation-20260911-r2"
mode: "orchestrated"
session_id: "hrl-research-consolidation-preparation-ppid42220"
owner_manifest_path: "/Users/joshc/develop/oneoffs/hrl-research-consolidation-preparation-20260911-r2/runtime/processes-42220.json"
source_plan_root: "/Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation"
preparation_output_root: "/Users/joshc/develop/oneoffs/hrl-research-consolidation-preparation-20260911-r2"
project_root: "/Users/joshc/develop/dotfile-vnext"
status: "ready_for_implementation"
next_actor: "Implementer"
reviewed_plan_path: "/Users/joshc/develop/oneoffs/hrl-research-consolidation-preparation-20260911-r2/handoff/current-phase-implementation-plan.md"
reviewed_plan_sha256: "2a1466c9c81ea613ec5a916777d834050245169af51546f67f35d44ed7338d2c"
plan_review_path: "/Users/joshc/develop/oneoffs/hrl-research-consolidation-preparation-20260911-r2/research/current-phase-plan-review.md"
downstream_activation: "authorized_separately"
---

# Current-phase release

## Readiness evidence

Independent Researcher review passed for the exact implementation-plan path and SHA-256 recorded above. The Coordinator recalculated the current plan SHA-256 as `2a1466c9c81ea613ec5a916777d834050245169af51546f67f35d44ed7338d2c`, matching the review. The review resolves F-01 and records no actionable findings.

This release is preparation readiness evidence only. It is not mature Evaluator approval, does not claim implementation is complete, and grants no Apply authority. `downstream_activation: "authorized_separately"` requires the parent/operator to obtain and verify separate user authorization before supplying the plan to the established Implementer/Evaluator.

## Scoped deliverables

- Routing: `/Users/joshc/develop/oneoffs/hrl-research-consolidation-preparation-20260911-r2/coordination/current-phase-routing.md`.
- Research readiness brief: `/Users/joshc/develop/oneoffs/hrl-research-consolidation-preparation-20260911-r2/research/current-phase-readiness-brief.md`.
- Reviewed implementation plan: `/Users/joshc/develop/oneoffs/hrl-research-consolidation-preparation-20260911-r2/handoff/current-phase-implementation-plan.md`.
- Independent review: `/Users/joshc/develop/oneoffs/hrl-research-consolidation-preparation-20260911-r2/research/current-phase-plan-review.md`.

## First executable step and required live preflights

First executable step, after separate authorization: run slice 1's read-only evidence and Ansible-owner discovery. Capture the exact inventory target; Hyper-V VM/disk attachment; guest block devices, mounts, free space; relevant `k3s`/container-runtime unit/drop-ins and mount dependencies; effective K3s/Kubelet/containerd configuration; node/PVC/StorageClass/events; vLLM image, cache command/content/usage; monitoring/scheduler owner; existing Ansible contracts/tags/collections/quality gates; and backup/rollback location.

No cleanup, cache/PVC change, VHDX/mount change, scheduling, monitoring, or unit/config change may proceed until the receipt establishes target identity, safe owner surface, necessity, rollback path, and the selected change's separate authorization.

## Remaining decisions and permissions

- Operator decisions remain required for any host/device/VHDX/mount target, cache relocation, capacity/threshold/cadence/retention policy, and live change scope.
- The Implementer must use the reviewed plan's discovery outcomes to select or create only a bounded owner surface; historic research values are not current-state authority.
- The Evaluator later requires execution/validation/rollback receipts defined in the reviewed plan. No future role is started by this release.

## Runtime cleanup offer for parent display

Parent observation at `2026-09-11T03:59:47.715216+00:00` recorded no orphaned runtime processes and an active named session. The run-owned manifest is `/Users/joshc/develop/oneoffs/hrl-research-consolidation-preparation-20260911-r2/runtime/processes-42220.json`; it is the sole authority for any lifecycle stop.

One cleanup option: after the parent has consumed this release, ask the runtime operator to identity-check and stop only the manifest-owned process tree/session for run `hrl-preparation-20260911-r2`, then dispose of the preparation runtime workspace if authorized. Retain the source plan, draft skills, reviewed handoff/review, and durable receipts. Do not stop Cursor Helper processes or use name/age-only cleanup.

## Handoff event

Event: `ready_for_implementation`.

Release artifact: `/Users/joshc/develop/oneoffs/hrl-research-consolidation-preparation-20260911-r2/handoff/current-phase-release.md`.

Next actor: parent/operator, then `Implementer` only after separate authorization.
