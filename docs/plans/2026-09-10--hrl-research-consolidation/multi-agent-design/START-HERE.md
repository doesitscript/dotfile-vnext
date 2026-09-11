# Use the two preparation roles

## Next stage: implement the storage plan

**Preferred launch:** the first prompt in [the plan launch directory](../launch-directory.md)
starts one parent chat that manages Implementer/Evaluator and observes progress.
No separate Observer chat or manual worker hopping is required.

Preparation has already produced the reviewed handoff below. To move into actual
storage work, use the [beta Implementer / Evaluator / Observer prompts](agent-prompts/implementation-beta-prompts.md)
on the [implementation campaign](../implementation-campaign/README.md). These
project adapters load the existing mature global role packs. The beta intake
checker protects the copied upstream evidence; it does not approve implementation.
See [iteration priorities](iteration_beta_pass.md) and the
[later-stage developer flow](orchestration/implementation-beta-flow.mmd).
The [role operating contract](role-operating-contract.md) captures the next
definition pass: canonical plan ownership, bounded Expert consultation, and
the lab/product authority profiles that now govern the later-stage roles.
The preparation instructions below remain available for new preparation runs.

The two preparation roles are implemented and have completed a real two-agent
run against this source plan, including a requested correction, independent
re-review, hash-bound release, and owned-process teardown. Their `draft` names
are retained as requested; their scope is the preparation stage, not the whole
future pipeline. No storage or managed-host changes were made.

## Use two separate chats

1. Paste [Coordinator prompt](agent-prompts/onsite-expert-coordinator-draft-prompt.md)
   into one agent chat. It loads the [Coordinator skill](multi-agent-onsite-expert/skill-drafts/phase-scoped-onsite-expert-coordinator-draft/SKILL.md)
   and creates scoped routing.
2. Paste [Researcher prompt](agent-prompts/researcher-draft-prompt.md) into a
   second chat after routing exists. It loads the [Researcher skill](researchers/skill-drafts/phase-scoped-researcher-draft/SKILL.md).
3. Use the short followups already in those files: Coordinator `compose`,
   Researcher `review-plan`, Coordinator `release` (or revise/re-review).

Both prompts already include this project's absolute plan folder. For another
plan, change the shared input roots together. Followups are necessary for two
ordinary chats; automatic scheduling requires an external orchestrator. Custom
multiagent metadata is included, but is not an executable scheduler.

## Run the same roles automatically

Use [runtime/README.md](runtime/README.md) and its config example with a fresh
output directory and run ID. The implemented controller starts exactly these
two roles through the multiagents MCP and schedules all passes. It records
pipeline/task/run/session identity, heartbeat, completed-pass receipts and a
process manifest. An independent watchdog stops registered children if the
controller dies. Resume refuses a still-running owner and does not re-run an
already verified release. The source plan does not need resetting for these
isolated-output tests.

## Verified handoff

The output is `handoff/current-phase-implementation-plan.md`, independent review
in `research/current-phase-plan-review.md`, and hash-matched readiness in
`handoff/current-phase-release.md`. That is the handoff point to the existing
Implementer/Evaluator; do not start them on the preparation contract itself.

The [shared contract](agent-prompts/execution-contract.md) defines all passes,
ownership, source discovery, interruption recovery, revision and cleanup.
The [flow diagram](coordination-flow.mmd) shows the coordination.
The [fresh validation receipt](validation-2026-09-11.md) records the successful
run and limitations. The [earlier receipt](runtime-validation-2026-09-10.md) is
historical, not current readiness.

The completed test's [reviewed plan](/Users/joshc/develop/oneoffs/hrl-research-consolidation-preparation-20260911-r2/handoff/current-phase-implementation-plan.md),
[independent review](/Users/joshc/develop/oneoffs/hrl-research-consolidation-preparation-20260911-r2/research/current-phase-plan-review.md),
and [release](/Users/joshc/develop/oneoffs/hrl-research-consolidation-preparation-20260911-r2/handoff/current-phase-release.md)
are ready for the established Implementer/Evaluator handoff. Begin with the
plan's read-only discovery slice: live host/device/policy facts remain to be
established before any mutation. Researcher review is not Evaluator approval
of an implementation. The later roles require separate activation.

The [registered workflow pattern](../../../codex_framework/multi-agent/agent-workflow-registry/patterns/phase-scoped-plan-preparation.md)
and `runtime/handoff.json` define future pipeline integration without modifying
the mature roles. The [developer flow](coordination-flow.mmd) shows that boundary.

Dashboard: http://127.0.0.1:7900 — verified during the run, stopped on completion.
The shared broker/current chat peers were preserved. Archived test records and
workspaces remain; offer their scoped cleanup while preserving reviewed
handoffs, source skills/plans, and evidence.
