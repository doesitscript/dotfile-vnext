---
status: trial
owner: codex-framework
applies_to:
  - current-phase-plan-preparation
---

# Phase-scoped plan preparation

Downstream integration: the [storage beta contract](../../../../plans/2026-09-10--hrl-research-consolidation/multi-agent-design/orchestration/implementation-beta-contract.md)
consumes a separately activated, hash-verified preparation release through the
existing Implementer/Evaluator loop. It also defines scoped research-return
requests; new answers do not overwrite the original release. Preparation roles
retain their current boundaries and do not start later roles or grant Apply
authority. The optional Observer is read-only, not a third controller.

## Purpose

Prepare a supplied project phase through two roles: Onsite Expert/Coordinator
and Researcher. Deliver an independently reviewed, hash-bound implementation
plan to the existing Implementer/Evaluator without implementing or launching
those downstream roles. This is a composable middle stage, not a whole pipeline.

## Triggers

Use when a user authorizes these two preparation roles on a source plan, or a
future parent orchestrator supplies an authorized preparation-stage intake.
A file appearing or an old broker session alone is not an activation trigger.

## Roles

| Role | Responsibility and write boundary | Allowed tools | Handoff / completion signal |
| --- | --- | --- | --- |
| Coordinator | Route obligations, compose/revise plan, release; output-root `coordination/` and `handoff/` only | Read source/project/HRL; write owned docs; read runtime observation | Routing `research_requested`; plan `plan_review_requested`; release `ready_for_implementation` |
| Researcher | Bounded evidence research and independent plan review; output-root `research/` only | Read source/project/HRL, targeted authoritative docs/MCP; write owned docs | Brief `research_ready`; hash-bound review `plan_reviewed` |
| External scheduler/runtime owner | Start turns, track named processes, enforce deadlines and scoped stop | Multiagents MCP/broker plus reusable runtime operator | Artifact-validated transition; final owned-process cleanup receipt |

Sources remain read-only. Neither preparation role edits implementation code,
mutates hosts, writes mature evaluator approvals, or creates extra teams.

## Parallel Work

Independent read-only source inspection can overlap, but review begins only
after a complete candidate plan exists. Librarian/domain knowledge is advisory
and task-scoped, not permission to turn adjacent debt into release blockers.

## Serialized Work

`route → research → compose → review-plan → release`; actionable review findings
return to `revise → review-plan`. Single pass per role invocation. The executable
adapter supplies turn scheduling; two ordinary chats use explicit followups.

## Gates

| Gate | Required evidence / pass | Send-back / fallback |
| --- | --- | --- |
| Intake | Source plan and matching pipeline/stage/task/run IDs; optional upstream handoff hash matches | Scope/identity mismatch: do not reuse artifacts; resolve intake |
| Research | Questions tied to obligations and source-backed findings | Relevant missing evidence: bounded research; unavailable tools: source-grounded fallback with limitations |
| Plan review | Researcher checks coverage, evidence, owner surfaces, Apply/Verify/Undo, first executable step, required diagrams; records exact current plan hash | Numbered findings to Coordinator, at most two same-finding correction rounds before evidence-backed reroute; no blind retries |
| Release | Matching IDs/path/current SHA-256 and `plan_review_passed`; no unresolved in-scope preparation blockers | Re-review changed plan; never substitute Coordinator self-approval |
| Runtime closeout | Owner manifest, process identities, current liveness, bounded stop and receipt | Preserve evidence; report exact survivors, never infer successful cleanup from deleting broker rows |

A defined read-only discovery/preflight slice may resolve later live facts; it
must precede any affected mutation. Unrelated project defects are not new gates.
If runtime is unavailable, manual single-pass chats may complete the same
artifact contract; disclose that transport fallback, not orchestrated success.

## Artifacts

Five artifacts under a configurable output root: routing, readiness brief,
implementation plan, independent plan review, release. All use contract version
1 and distinct `pipeline_id`, `stage_id`, `task_id`, `run_id`; runtime session and
owner manifest remain separate. Exact schemas and drop-in prompts live in the
[current execution package](../../../../plans/2026-09-10--hrl-research-consolidation/multi-agent-design/agent-prompts/execution-contract.md),
owned by its [capability manifest](../../../../plans/2026-09-10--hrl-research-consolidation/multi-agent-design/capability.yml).

## Completion Rule

Preparation is complete only when release references the current independently
reviewed plan, identifies the first implementation step, and is returned with
the runtime receipt and one cleanup offer for exact remaining disposable items.
Source plans, skills, reviewed handoffs, and evidence are retained by default.

A future parent may consume this release after checking its schema, identities,
hash and authorization, then invoke the established Implementer/Evaluator with
their existing contracts. `next_actor: Implementer` is a handoff designation,
not a launch command. Upstream intake and downstream execution are intentionally
outside this implementation; do not claim them implemented or alter stable roles.

## Failure Rule

Failed turns, mismatched artifacts, stale hashes, unresolved preparation
findings, or unverified process cleanup prevent the corresponding success
claim. Capture terminal errors, retry only from new evidence, and retain
unsigned artifacts if the gate cannot be satisfied. On abort, stop the exact
owned process tree using identity-checked manifests before deleting session
records; never kill IDE helpers or unrelated teams. An interrupted run is not
permission to launch a replacement team.
