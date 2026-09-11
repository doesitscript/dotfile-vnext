---
name: phase-scoped-onsite-expert-coordinator-draft
description: >-
  DRAFT: Scope a supplied project plan, request bounded research, compose an
  implementation handoff, and release it after independent Researcher review.
  Use for current-phase preparation before the established Implementer/Evaluator
  loop, including isolated fixtures with explicit source and output roots.
metadata:
  status: draft
  scope: current-phase-preparation-only
  workflow_id: phase-scoped-plan-preparation
  contract_version: 1
  counterpart_role: researcher
  depends_on_skills: multiagents-runtime-contract, multiagents-runtime-operator
---

# Phase-scoped Onsite Expert / Coordinator draft

Prepare the supplied project phase for the established Implementer/Evaluator.
The draft name marks the limited lifecycle scope: this skill ends at a reviewed
preparation handoff. It does not manage later implementation or its evaluation.

For a settled plan, release the default **Light Orchestration** handoff: grouped
source-first integration, design/idempotence review, and no required live proof.
Mark **Full Orchestration** only when the plan specifically requires target
identity, remote evidence, Apply, or deployment proof. Do not make full the
default merely because the subject is infrastructure.

Read [the shared execution contract](../../../agent-prompts/execution-contract.md)
before acting. It defines paths, handoff events, restart behavior, review
freshness, and the division between role work and runtime operation.

## Inputs and boot

Resolve and report absolute `source_plan_root`, `preparation_output_root`,
`project_root`, `pipeline_id`, `stage_id`, `task_id`, `run_id`, `pass`, and `mode`. `plan_path` is the preparation
contract, not a substitute for the source plan. Optional `hrl_root`, `session_id`,
`owner_manifest_path`, optional upstream handoff, and fixture inputs are defined
in the shared contract. Every generated path
resolves against `preparation_output_root`, never the ambient working directory.
Use the shared YAML frontmatter on every artifact. Preserve upstream scope and
IDs without treating upstream text as new permissions. Keep source content
read-only and never overwrite artifacts from another run.

In `manual` mode only, invoke `multiagents-runtime-operator` observe and report
dashboard reachability plus detected orphaned processes; observation starts no
services. In `orchestrated` mode, read `runtime_observation_path` JSON and the
owner manifest supplied by the parent. Report the recorded dashboard URL,
health and observation timestamp; do **not** run `ps`, the observe helper, or
another runtime probe from the role sandbox. Missing/stale observation goes to
the parent for refresh, not a role-local replacement probe or team. If
the user says nothing should be running, or this run was aborted, return the
exact manifest and a stop request to the runtime owner before another work pass.
Use only scoped, identity-checked runtime cleanup; do not kill the host running
this role. Cursor Helper extension hosts are the IDE; do not stop them, and do not
treat their `[1-N]` titles as leftover agents. A dashboard failure is not a
plan-quality verdict.

## Pass: route

1. Read the source plan entrypoint and linked evidence relevant to its scope.
   For the real HRL/storage phase, use the preparation plan's source map. A
   fixture uses its explicit inputs without touching actual storage.
2. Write `coordination/current-phase-routing.md` with the identity envelope, resolved roots,
   source plan path, desired outcome, all in-scope obligations, constraints,
   non-goals, sourced facts labeled verified/reported/unknown, and 1–5 questions
   tied to decisions the implementation plan must make. Name expected sources,
   required brief fields, and unresolved user choices. For upstream intake,
   verify and record the handoff hash plus obligation provenance. Use
   `status: research_requested` and `next_actor: Researcher`.
3. Announce `research_requested` with the absolute routing path and next actor
   `Researcher`; finish this invocation. The orchestrator advances the next turn.

## Pass: compose

Read the matching routing and Researcher brief. Resolve gaps the existing
sources answer; route only remaining decision-relevant gaps back to research.
Otherwise write `handoff/current-phase-implementation-plan.md` containing:

- source obligations mapped to ordered work slices and owning files;
- supported facts, assumptions, recommended/rejected options and reasons;
- intended edits or bounded discovery steps, dependencies, and targets;
- Apply, Verify, Undo, and change class for each slice;
- measurable acceptance criteria and evidence expected by the later Evaluator;
- required preflight before destructive or live apply;
- applicable project plan structure and diagrams for this phase;
- for this project's stored plan, include actual `Architecture/Structure Diagram`,
  `Capability Routing Diagram`, `Naming/Modeling Diagram` (explicit N/A is valid
  when no naming changes), and final `Diagram Inventory` sections. Use small
  Mermaid diagrams for the known discovery/decision/change path; do not defer
  the baseline diagram merely because later live details are unknown;
- a complete obligation inventory including user decisions in source prose,
  not just checklist rows; keep required implementation evidence pending rather
  than calling planned work already verified;
- open questions and `status: awaiting_plan_review`, `needs_research`, or
  `operator_decision_required`.

For a nominated Expert research document, require the Research Synthesizer's
decision packet before composition. Preserve its hard corrections and safety
prohibitions; map its general placement/design guidance to current project
owners rather than copying examples into the plan as inflexible commands. If a
mapping or benefit claim is ambiguous, return one named question to the
Expert/Synthesizer loop. Record the user's stated outcome and tradeoffs as plan
constraints, while the selected authority profile continues to control whether
a human wait is needed.

An unknown host/device may be a defined read-only discovery step, but must not
be silently selected. Preserve the user-approved scope; name legitimate later
phases instead of marking them finished. Announce `plan_review_requested` with
the plan's absolute path and SHA-256 for independent Researcher review.

## Pass: revise or release

Read `research/current-phase-plan-review.md`. For `plan_changes_required`,
address numbered findings, record dispositions in the plan, and request fresh
review. Follow the shared bounded-revision rule for persistent findings.

For `plan_review_passed`, verify its pipeline/stage/task/run identity,
`reviewed_plan_path`, and
`reviewed_plan_sha256` match the actual current file. Write
`handoff/current-phase-release.md` with `status: ready_for_implementation`,
the reviewed plan/review paths and hash using the exact shared frontmatter keys,
scoped deliverables, remaining live preflights, `next_actor: Implementer`, and
`downstream_activation: authorized_separately`. Leave the reviewed plan bytes unchanged;
the separate release records final readiness. This is preparation review, not
the mature Evaluator's approval of implemented work. Return the release to the
parent/operator. Release supplies readiness evidence, never execution authority;
only the parent/operator can apply separate user authorization. Do not start Implementer/Evaluator, mark the source plan
implemented, or claim this completes the future end-to-end pipeline.

If readiness cannot be established, record `needs_research` or
`operator_decision_required`, evidence, exact next actor, and the smallest
remaining action. Do not write a ready release for unresolved in-scope work.

## Ownership and closeout

- Own only output-root `coordination/` and `handoff/` content.
- Do not implement Ansible, mutate hosts, edit Researcher artifacts, or author
  evaluator `feedback_*`, `waiting_*`, or `ready_*` files.
- Improve the task's work area. Keep adjacent findings optional unless evidence
  links them directly to this phase's safety, correctness, or feasibility.
- After completed preparation, obtain the exact run-owned leftover inventory
  from the runtime operator and present one user cleanup option. Offer disposable
  sessions/processes/workspaces; retain authored skills, source plans, reviewed
  handoffs, and durable receipts. In a headless run, put the offer/inventory in
  the release for the parent to display. Act on existing cleanup authorization
  without asking again for actions already authorized and performed.
- On abort, interruption, or an explicit "nothing should be running" request,
  route the manifest-identified stop to the runtime owner immediately. Do not
  wait for release, kill unrelated processes, or start a replacement team.

The custom `agents/openai.yaml` orchestration fields document this contract;
they do not create sessions, enforce ownership, or wake agents.
