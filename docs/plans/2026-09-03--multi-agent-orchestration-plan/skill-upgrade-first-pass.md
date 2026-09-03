---
title: First Pass - Paired Agent Skill Upgrade For Multiagents
created_at: 2026-09-03
status: active
---

# First Pass - Paired Agent Skill Upgrade For Multiagents

## Purpose

This file breaks out the first implementation pass for the paired-agent skills.
The umbrella orchestration plan stays in `README.md`, but the skill contract
changes should land first because the orchestration layer must target stable
role behavior rather than trying to compensate for ambiguous skill behavior.

## Outcome

After this pass:

- the implementer skill knows how to operate as a single-pass worker inside an
  external orchestrator
- the evaluator skill knows how to operate as a single-pass reviewer inside an
  external orchestrator
- the shared artifact-contract skill documents the durable handoff outputs those
  roles must leave behind
- the repo workflow docs match that upgraded role model

This pass does **not** require a fully finished `multiagents` scenario yet. It
defines the role contract that the later scenario/config work will bind to.

It **does** require a minimal orchestration slice for validation. The staged
ping-pong targets should be run through a deliberately small `multiagents`
configuration that is only large enough to prove role routing, handoff
advancement, and evaluator-owned termination.

It also requires a minimal Codex app-server setup path because the validation
needs a real thread/turn control surface. Phase 1 should use the smallest
app-server-backed shape that can prove the handoff loop without pretending the
full production-facing scenario pack already exists.

## First-pass scope

### In scope

- Clarify role boundaries for evaluator and implementer under external
  orchestration
- Remove any remaining ambiguity about self-scheduling, polling, wake-up logic,
  or hidden loop ownership inside the skills
- Define the durable artifact outputs each role must produce for the next role
- Align repo workflow documentation with the upgraded skill behavior
- Make the skill contract explicit enough that `multiagents` can route by role
  and handoff state without guessing
- Stand up the smallest viable Codex app-server-backed control path needed for
  the staged validation harness

### Out of scope

- Full broker/session configuration
- Final host-rendered `multiagents` scenario pack
- Multi-provider support beyond Codex-first planning
- Rewriting the skills to depend directly on a specific transport implementation

### Required exception for validation

- A **minimal** `multiagents` orchestration setup is in scope for this first
  pass only to support the staged ping-pong validation targets.
- That minimal setup should stay narrow: just enough session, role, and turn
  wiring to prove the skill contract can be orchestrated cleanly.
- A **minimal** Codex app-server setup is also in scope for this first pass so
  the orchestrator has a real thread/turn transport to drive.
- The broader, more durable scenario/config work still belongs to the later
  umbrella-plan pass.

## Phase 1 app-server setup requirement

Phase 1 should explicitly use the source-backed Codex app-server flow captured
in:

- [codex-app-server-protocol-and-setup.md](/Users/joshc/develop/homelab-reference-library/vendor/mcp/context7-style/codex-app-server-protocol-and-setup.md)

At minimum, the implementing agent must define and validate:

- how app-server is started for the validation harness
- which transport is used for the first pass
- the `initialize` then `initialized` handshake
- how role threads are created or resumed
- how `turn/start` and `turn/steer` are used during ping-pong validation
- what output proves each of those steps occurred

## Skill ownership map

| Surface | Owner | Required change |
| --- | --- | --- |
| `global-skills/skills/validation/paired-agent-plan-implementer/SKILL.md` | `global-skills` | Make implementer behavior explicitly orchestrator-friendly and handoff-driven |
| `global-skills/skills/validation/paired-agent-plan-implementer/agents/openai.yaml` | `global-skills` | Add or align provider/role metadata needed for Codex-first paired execution |
| `global-skills/skills/validation/paired-agent-plan-implementer/references/*` | `global-skills` | Update references so they teach the new external-orchestration role model |
| `global-skills/skills/validation/paired-agent-plan-evaluator/SKILL.md` | `global-skills` | Make evaluator behavior explicitly orchestrator-friendly and approval-driven |
| `global-skills/skills/validation/paired-agent-plan-evaluator/agents/openai.yaml` | `global-skills` | Add or align provider/role metadata needed for Codex-first paired execution |
| `global-skills/skills/validation/paired-agent-plan-evaluator/references/*` | `global-skills` | Update references, examples, and evidence guidance for the new model |
| `global-skills/skills/documentation/paired-agent-feedback-artifacts/SKILL.md` | `global-skills` | Keep the durable artifact contract aligned with the upgraded role rules |
| `global-skills/skills/documentation/paired-agent-feedback-artifacts/references/*` | `global-skills` | Update templates and artifact examples to match the new role/handoff contract |
| `docs/codex_framework/multi-agent/agent-workflow-registry/patterns/evaluator-implementer-loop.md` | `dotfile-vnext` | Rewrite the workflow pattern so it matches the skill contract |
| `docs/codex_framework/multi-agent/workflow-packages/evaluator-implementer-loop/*.md` | `dotfile-vnext` | Align role docs and package docs with the upgraded skills |

## Required skill behavior

### Implementer skill must

- operate as one implementer pass per invocation
- read the plan folder and current evaluator state
- perform scoped work only for the current pass
- leave a clean review-ready handoff when re-review is needed
- update implementer-owned evidence and accounting when required by the packet
- stop after the current pass instead of trying to keep itself alive as the
  scheduler

### Implementer skill must not

- poll or watch for evaluator activity as part of its success path
- self-author evaluator-owned artifacts
- treat “my current pass is complete” as equal to “the overall campaign is done”
- hide orchestration gaps behind ad hoc one-off runtime behavior

### Evaluator skill must

- operate as one evaluator pass per invocation
- read the newest implementer-governed review boundary
- write exactly one evaluator-governed state artifact for the current pass
- distinguish `feedback`, `waiting`, and `ready` cleanly
- sign off only on evidence
- stop after the current pass instead of trying to keep itself alive as the
  scheduler

### Evaluator skill must not

- drift into implementer behavior
- self-schedule hidden rechecks as part of the success path
- write `ready` unless the whole scoped scenario is actually closed
- rely on stale assumptions instead of current repo and plan evidence

## Required skill configuration surfaces

The implementation agent should ensure these configuration classes are explicit,
even if some are expressed as frontmatter or references instead of standalone
YAML:

| Config class | Belongs to | Must define |
| --- | --- | --- |
| Role identity | Each skill frontmatter | `evaluation_role`, counterpart role, paired model, supported project types |
| Invocation scope | Each skill instructions | One-pass behavior, stop rule, and handoff boundary |
| Artifact ownership | Shared artifact-contract skill plus both role skills | Which files the implementer may write and which files the evaluator may write |
| External orchestration contract | Each role skill | Explicit statement that orchestration belongs to operator or external orchestrator |
| Handoff contract | Role skills plus artifact-contract skill | What marks review-ready, feedback, waiting, and approval states |
| Completion contract | Role skills plus repo workflow docs | What counts as pass completion versus overall scenario completion |
| Research/escalation contract | Evaluator skill | When repeated blockers require research before another correction pass |
| Provider/role metadata | `agents/openai.yaml` and any related metadata file | Enough metadata for Codex-first orchestration to select the right role behavior |

## Skill-to-orchestrator contract

The later `multiagents` integration should be able to assume the following
without reading the implementer's mind:

| Role event | Skill-side meaning | Orchestrator-side meaning |
| --- | --- | --- |
| Implementer pass starts | Implementer owns current work turn | Route implementer thread/turn |
| Implementer leaves review-ready state | Work is ready for evaluator review | Route evaluator next |
| Evaluator emits feedback | Work is not done; implementer must correct | Route implementer next |
| Evaluator emits waiting | Evaluator has no new state to review yet | Hold or await new implementer state |
| Evaluator emits ready/approval | Scoped work is closed from evaluator perspective | Release or advance to closeout |

## Files the implementation agent should expect to edit

| File | Responsibility |
| --- | --- |
| `/Users/joshc/develop/global-skills/skills/validation/paired-agent-plan-implementer/SKILL.md` | Primary implementer role contract |
| `/Users/joshc/develop/global-skills/skills/validation/paired-agent-plan-implementer/agents/openai.yaml` | Implementer provider/role metadata |
| `/Users/joshc/develop/global-skills/skills/validation/paired-agent-plan-implementer/references/sources-and-precedence.md` | Implementer evidence and precedence guidance |
| `/Users/joshc/develop/global-skills/skills/validation/paired-agent-plan-implementer/references/related-artifacts.md` | Implementer artifact and handoff references |
| `/Users/joshc/develop/global-skills/skills/validation/paired-agent-plan-evaluator/SKILL.md` | Primary evaluator role contract |
| `/Users/joshc/develop/global-skills/skills/validation/paired-agent-plan-evaluator/agents/openai.yaml` | Evaluator provider/role metadata |
| `/Users/joshc/develop/global-skills/skills/validation/paired-agent-plan-evaluator/references/paired-artifact-contract.md` | Evaluator understanding of artifact truth |
| `/Users/joshc/develop/global-skills/skills/validation/paired-agent-plan-evaluator/references/related-artifacts.md` | Evaluator artifact and handoff references |
| `/Users/joshc/develop/global-skills/skills/validation/paired-agent-plan-evaluator/references/worked-example-codex-multi-terminal.md` | Update example to reflect external orchestration assumptions |
| `/Users/joshc/develop/global-skills/skills/documentation/paired-agent-feedback-artifacts/SKILL.md` | Shared durable artifact contract |
| `/Users/joshc/develop/global-skills/skills/documentation/paired-agent-feedback-artifacts/references/artifact-contract.md` | Canonical artifact ownership and meaning |
| `/Users/joshc/develop/global-skills/skills/documentation/paired-agent-feedback-artifacts/references/evaluator-feedback-template.md` | Feedback/approval template alignment |
| `/Users/joshc/develop/dotfile-vnext/docs/codex_framework/multi-agent/agent-workflow-registry/patterns/evaluator-implementer-loop.md` | Repo workflow contract aligned to skill truth |
| `/Users/joshc/develop/dotfile-vnext/docs/codex_framework/multi-agent/workflow-packages/evaluator-implementer-loop/README.md` | Workflow package summary |
| `/Users/joshc/develop/dotfile-vnext/docs/codex_framework/multi-agent/workflow-packages/evaluator-implementer-loop/implementer-role-documentation.md` | Repo-facing implementer behavior |
| `/Users/joshc/develop/dotfile-vnext/docs/codex_framework/multi-agent/workflow-packages/evaluator-implementer-loop/evaluator-role-documentation.md` | Repo-facing evaluator behavior |

## Execution order

1. Update the shared artifact-contract skill so file ownership and state names
   are unambiguous.
2. Update the implementer skill to make its pass boundary and stop rule
   explicit.
3. Update the evaluator skill to make its artifact classes and sign-off rule
   explicit.
4. Update the role metadata files so the two skills are easy to target as
   distinct roles in Codex-first orchestration.
5. Update repo workflow docs so they mirror the upgraded skill behavior.
6. Configure the smallest viable Codex app-server setup needed to support the
   validation harness.
7. Configure the smallest viable `multiagents` orchestration slice needed to
   run the staged ping-pong validation on top of that app-server setup.
8. Only after those changes are stable, wire the broader `multiagents`
   scenario/config layer described in the umbrella plan.

## First validation target

Before broader `multiagents` configuration is considered in scope, the upgraded
skills and workflow docs should satisfy a staged ping-pong coordination target.

That validation is expected to run **through a small `multiagents`
orchestration harness**, not through purely manual user-driven handoff. The
point is to prove the roles can be coordinated by the orchestrator in a limited
test scope before building the fuller production-facing configuration.

That harness should itself run on a minimal but real Codex app-server setup so
the loop proves actual thread/turn orchestration rather than a simulation.

The progression should be:

1. smoke: 2 to 4 handoffs, evaluator ends the loop
2. stability: 10 handoffs
3. acceptance: 20 handoffs, evaluator ends the loop cleanly

This is the first target because it proves the role contract is stable enough
to orchestrate before the project invests in more runtime wiring.

## Ping-pong validation contract

| Item | Requirement |
| --- | --- |
| Roles | Exactly one implementer and one evaluator |
| Work item | One intentionally simple scoped task with repeatable review boundaries |
| Transport | Minimal but real Codex app-server-backed thread/turn transport |
| Smoke target | 2 to 4 consecutive role-to-role handoffs |
| Stability target | 10 consecutive role-to-role handoffs |
| Acceptance target | 20 consecutive role-to-role handoffs |
| Handoff direction | Implementer produces review-ready output; evaluator returns feedback or approval |
| Termination authority | Evaluator only |
| Success condition | Each stage remains coherent for its full handoff count and the final stage ends with evaluator approval |
| Failure condition | Any ambiguous ownership, missing artifact state, or implementer-declared completion ends the trial as failed |

## Validation evidence requirements

The implementing agent must not report the staged ping-pong targets as passed
with summary prose alone. Claims such as "worked as expected" or "the loop
completed successfully" are insufficient by themselves.

For each validation stage, the agent must capture and present concrete evidence:

| Evidence type | Requirement |
| --- | --- |
| Handoff count evidence | Show the exact sequence of handoffs reached in that stage |
| App-server evidence | Show the thread/turn actions or equivalent output that advanced the stage |
| Role-state evidence | Show which role acted on each step and what state it emitted |
| Artifact evidence | Show the review-ready, feedback, waiting, or approval outputs that prove the handoff occurred |
| Termination evidence | Show that the evaluator, not the implementer, ended the loop |
| Failure evidence | If a stage fails, show the exact step and the observable reason it failed |

At minimum, the implementing agent should leave a validation receipt that
includes:

- the stage being tested: smoke, stability, or acceptance
- the exact number of handoffs completed
- the ordered handoff trail
- the app-server setup or call evidence used during the stage
- the concrete output snippet, artifact name, or log line for each handoff
- the final evaluator approval evidence for any passing terminating stage

If the agent cannot show the outputs, artifacts, or logs that prove the stage
passed, the stage must be reported as unverified or failed rather than passed.

## Ping-pong validation sequence

1. Implementer receives the scoped task and leaves a review-ready handoff.
2. Evaluator reads that handoff and either:
   - returns actionable feedback, or
   - if the target count and scoped obligations are satisfied, issues approval
3. Implementer reads evaluator feedback and leaves the next review-ready
   handoff.
4. First prove the smoke target.
5. Then prove the stability target.
6. Then prove the 20-handoff acceptance target.
7. On the final pass, the evaluator issues the terminating approval artifact.

## Why this target matters

If the skills cannot first pass a short smoke loop, then a 10-step stability
loop, and finally a 20-step acceptance loop with evaluator-owned termination,
the later `multiagents` integration would be compensating for an unstable role
contract instead of orchestrating a stable one. That would be the wrong order
of operations.

## Verification

This first pass is successful only if:

- the implementer skill clearly states that orchestration is external
- the evaluator skill clearly states that orchestration is external
- both skills define a one-pass invocation model
- artifact ownership is unambiguous across the three skill packs
- repo workflow docs no longer imply that the roles themselves own the loop
- a minimal Codex app-server setup can be shown and evidenced for the
  validation harness
- a minimal `multiagents` orchestration slice can drive the staged validation
  without the user manually acting as the scheduler between every handoff
- the later orchestration layer can target the skills without inventing missing
  role semantics
- the skill contract is strong enough to support the staged ping-pong targets:
  smoke, stability, and 20-handoff acceptance with evaluator-owned termination
- every claimed passing stage is backed by visible outputs or artifacts rather
  than narrative-only assertions

## Required validation receipt contents

Any agent implementing this pass should leave a validation receipt that makes
review mechanical rather than interpretive.

Required contents:

- stage name
- target handoff count
- actual handoff count reached
- per-handoff evidence references
- evaluator approval evidence when applicable
- explicit pass/fail/unverified status
- any deviation, retry, or interruption encountered during the stage

Prohibited closeout language without evidence:

- "worked as expected"
- "everything passed"
- "the ping-pong loop succeeded"
- any equivalent statement that is not followed by concrete proof

## Relationship to umbrella plan

This file is the first-pass dependency for:

- [README.md](/Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-03--multi-agent-orchestration-plan/README.md)

The umbrella plan should treat this file as the skill-contract slice that must
stabilize before broader scenario/config work is considered done.
