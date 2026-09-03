---
title: Evaluator–implementer loop documentation
status: active
owner: codex-framework
applies_to:
  - docs/plans
  - paired-agent-plan-implementer
  - paired-agent-plan-evaluator
created: 2026-09-02
updated: 2026-09-03
reference_plan: docs/plans/2026-09-03--multi-agent-orchestration-plan/
---

# Evaluator–implementer loop

Durable documentation for the **split-role** workflow where one agent
**evaluates** and another **implements** on a plan packet until evaluator
sign-off.

**2026-09-03 update:** Preferred model is **external orchestration** (for
example `multiagents` + Codex app-server). Role skills are single-pass and do
not own folder-watch or polling. Pattern contract:
[`evaluator-implementer-loop.md`](../../agent-workflow-registry/patterns/evaluator-implementer-loop.md).
Alignment discussion:
`docs/plans/2026-09-03--multi-agent-orchestration-plan/discussion/orchestration-agnostic-framing.md`.

Historical notes from the 2026-09-02 multi-terminal promotion remain useful as
AAR/context but are not the preferred control plane.

## Documents

| File | Audience | Contents |
| --- | --- | --- |
| [implementer-role-documentation.md](implementer-role-documentation.md) | Implementer agents & operators | Skills, boot, loop, artifacts you may write |
| [evaluator-role-documentation.md](evaluator-role-documentation.md) | Evaluator operators & audit agents | Evaluator surface, files, scripts implementer must not drive |
| [after-action-report-2026-09-02.md](after-action-report-2026-09-02.md) | Stewards | Session AAR summary (skills + process) |

## Preferred skill entrypoints (global)

| Role | Skill |
| --- | --- |
| Implementer | `paired-agent-plan-implementer` (`global-skills`) |
| Evaluator | `paired-agent-plan-evaluator` (`global-skills`) |
| Artifact contract | `paired-agent-feedback-artifacts` (includes `review_ready_for_evaluator_*`) |

Repo-local `skills/multi-agent/multi-agent-implementer` may still exist as a
project wrapper; prefer the global paired-agent skills for the Codex-first
orchestration plan.

## Capability packet

| Surface | Role |
| --- | --- |
| [`evaluator-implementer-loop.md`](../../agent-workflow-registry/patterns/evaluator-implementer-loop.md) | Reusable workflow contract (external orchestration) |
| Active plan | `docs/plans/2026-09-03--multi-agent-orchestration-plan/` |

## Quick start (implementer)

```text
Use skill paired-agent-plan-implementer on docs/plans/<slug>/
# After the pass: write review_ready_for_evaluator_<timestamp>.md and stop
```

## Quick start (evaluator)

```text
Use skill paired-agent-plan-evaluator on docs/plans/<slug>/
# Write exactly one feedback|waiting|ready artifact and stop
```

Manual operator invocation of each pass is the fallback when an orchestrator is
not yet wired. Prefer the Phase 1 harness in the active plan packet when
available.
