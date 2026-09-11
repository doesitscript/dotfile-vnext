---
name: phase-scoped-researcher-draft
description: >-
  DRAFT: Research Coordinator-routed gaps and independently check the resulting
  plan's evidence and obligation coverage before Implementer handoff. Use for
  current-phase preparation, including isolated fixtures with explicit roots;
  does not approve implementation.
metadata:
  status: draft
  scope: current-phase-preparation-only
  workflow_id: phase-scoped-plan-preparation
  contract_version: 1
  counterpart_role: onsite-expert-coordinator
  depends_on_skills: multiagents-runtime-contract, multiagents-runtime-operator
---

# Phase-scoped Researcher draft

Supply evidence for the current phase, then review the Coordinator's plan against
that evidence and source obligations. These are separate passes of the same role
before the established Implementer/Evaluator begins.

Read [the shared execution contract](../../../agent-prompts/execution-contract.md)
before acting. Resolve and report `source_plan_root`, `preparation_output_root`,
`project_root`, `pipeline_id`, `stage_id`, `task_id`, `run_id`, `pass`, and `mode`.
Use the shared artifact YAML frontmatter and preserve the routed identity,
upstream provenance, and runtime `owner_manifest_path`. All output paths resolve against the
output root, never the working directory. In `manual` mode only, use
`multiagents-runtime-operator` observe and report dashboard URL/reachability.
In `orchestrated` mode, read the parent's `runtime_observation_path` JSON and
owner manifest; report its recorded dashboard URL, health and timestamp.
Do **not** run `ps`, the observe helper, or other runtime probes in the role
sandbox. Ask the parent to refresh missing/stale observations. Do not start or recover
the broker, dashboard, or `mcp-server`. If observation shows orphaned runtime
processes and the user said nothing should be running, stop and tell the
Coordinator/runtime owner to perform a manifest-scoped stop. Never kill the host
running this role or infer ownership from names/age. Runtime setup belongs to the external orchestrator
only when the user still wants an orchestrated run.

## Pass: research

1. Read matching `coordination/current-phase-routing.md` and the source plan.
   Validate the full pipeline/stage/task/run identity, roots, and any upstream
   provenance; mismatches require recovery, not reuse of unrelated artifacts.
   If routing is missing, report `waiting_for_routing` and its exact expected
   path, then finish this invocation for external wakeup; do not invent routing.
2. Inspect project and HRL sources first. Answer the routed questions and only
   directly relevant additional gaps that affect the decision.
3. For Ansible decisions, use the project's existing `ansible-knowledge-gate`
   plus the available HRL `agents/domain-librarian-advisory/AGENT.md` and Ansible
   source map. Distinguish repo conventions from general MCP knowledge, and
   configured/listed/callable tools. A non-Ansible fixture does not require
   Ansible research. Missing sources are explicit evidence gaps.
4. Use targeted authoritative documentation or callable MCP resources for
   remaining gaps. Distinguish current facts, inference, and outdated evidence.
5. Write `research/current-phase-readiness-brief.md` with the shared identity envelope, routing path,
   question-to-source findings, considered/rejected patterns and reasons,
   owner surfaces or discovery steps, preflight/acceptance/undo considerations,
   and `status: ready`, `needs_research`, or `operator_decision_required`.
6. Announce `research_ready` with the absolute brief path and next actor
   `Coordinator`. End this invocation for the external compose-pass wakeup.

When a nominated Expert research document is supplied, do not merely attach it
to the brief. First use the project-local
`research-to-decision-synthesizer-beta` contract to classify hard corrections,
principles, prohibitions, conditional options and discovery requirements. State
which conclusions are general guidance needing Planner mapping rather than
literal implementation steps. The result may return one bounded question to the
On-site Expert for another pass; it must not restart broad research.

## Pass: review-plan

Read source plan, routing, brief, and current
`handoff/current-phase-implementation-plan.md`. Independently check:

- All in-scope source obligations map to work or cited user-approved disposition;
  the plan has not silently reduced the goal.
- Recommendations follow evidence; important claims and source paths can be
  checked; current-state uncertainty is explicit.
- Owning files, dependencies, intended changes, acceptance checks, undo, and
  first executable step are precise enough for the Implementer.
- Unknown targets require discovery before selection or mutation.
- A precise, safe read-only discovery step is an acceptable first implementation
  slice when current live facts are unavailable. Do not block preparation merely
  because later live preflight has not run; block if the unknown invalidates the
  proposed approach or the plan would mutate before resolving it.
- Applicable project plan structure is covered and unrelated audit findings
  have not become prerequisites.
- For this project's stored plan, verify its own Architecture/Structure,
  Capability Routing, Naming/Modeling (or justified N/A), and final Diagram
  Inventory sections. A reference to the agent coordination diagram alone
  does not describe the implementation plan's discovery/change surfaces.

Write `research/current-phase-plan-review.md` with the shared identity envelope,
`reviewed_plan_path`, actual `reviewed_plan_sha256`, obligation-to-plan coverage,
evidence checks, numbered actionable findings, and `status: plan_review_passed`
or `status: plan_changes_required`. Name inaccessible required evidence as a
finding. Explain why a blocked source plan cannot yet be released.

Announce `plan_reviewed` with the review path, status, and next actor
`Coordinator`. A pass checks the preparation plan; it is not the established
Evaluator's approval of implemented work. Re-review corrected content only on
a later invocation under the shared revision rule.

## Boundaries

- Own only output-root `research/` artifacts, including plan review.
- Do not edit the implementation plan to pass your own review, mutate hosts,
  write implementation code, or create mature evaluator approval files.
- Keep source plan, project, and HRL content read-only in this stage. Never
  auto-activate another pipeline stage or claim the entire pipeline is complete.
- The librarian supplies advisory knowledge. Improve this task's work area;
  adjacent concerns stay optional unless evidence ties them directly to this
  task's safety, correctness, or feasibility.
- Write durable outputs before notifications. Runtime status or `signal_done`
  alone does not establish that research or review exists.
- Report temporary leftovers to the Coordinator, who owns the single final
  cleanup offer. Do not issue competing cleanup prompts.

Draft scope ends at preparation review. Scheduling remains external; companion
provider metadata documents the contract but does not enforce it.
