---
title: Evaluator–implementer loop documentation
status: active
owner: codex-framework
applies_to:
  - docs/plans
  - multi-agent-implementer
  - evaluator-simple-loop
created: 2026-09-02
reference_plan: docs/plans/2026-09-02--codex-multi-terminal-promotion/
---

# Evaluator–implementer loop

Durable documentation for the **split-role** workflow where one agent (or
automated loop) **evaluates** and another **implements** corrections on a plan
packet until evaluator sign-off.

This folder matures the pattern first exercised during the **codex
multi-terminal promotion** (2026-09-02).

## Documents

| File | Audience | Contents |
| --- | --- | --- |
| [implementer-role-documentation.md](implementer-role-documentation.md) | Implementer agents & operators | Skills, boot, loop, artifacts you may write |
| [evaluator-role-documentation.md](evaluator-role-documentation.md) | Evaluator operators & audit agents | Evaluator surface, files, scripts implementer must not drive |
| [after-action-report-2026-09-02.md](after-action-report-2026-09-02.md) | Stewards | Session AAR summary (skills + process) |

## Capability packet

| Surface | Role |
| --- | --- |
| [`skills/multi-agent/multi-agent-implementer/capability.yml`](../../../../../skills/multi-agent/multi-agent-implementer/capability.yml) | Machine-readable capability manifest for the project-owned implementer family |
| [`skills/multi-agent/README.md`](../../../../../skills/multi-agent/README.md) | Family index and operator entrypoint |
| [`evaluator-implementer-loop.md`](../../agent-workflow-registry/patterns/evaluator-implementer-loop.md) | Reusable workflow contract |

## Related repo surfaces

| Surface | Path |
| --- | --- |
| **Parent skill (start here)** | `skills/multi-agent/multi-agent-implementer/SKILL.md` |
| Skill family index | `skills/multi-agent/README.md` |
| Capability manifest | `skills/multi-agent/multi-agent-implementer/capability.yml` |
| Pattern (workflow schema) | `docs/codex_framework/multi-agent/agent-workflow-registry/patterns/evaluator-implementer-loop.md` |
| Workflow package (this folder) | `docs/codex_framework/multi-agent/workflow-packages/evaluator-implementer-loop/` |
| Plan packet AAR (full) | `docs/plans/2026-09-02--codex-multi-terminal-promotion/AFTER-ACTION-REPORT-skills-and-evaluator-implementer-loop.md` |
| Plan-local paired docs | `docs/plans/2026-09-02--codex-multi-terminal-promotion/documentation/` |
| Reference run | `docs/plans/2026-09-02--codex-multi-terminal-promotion/` |

## Quick start (implementer)

```text
Use skill multi-agent-implementer on docs/plans/<slug>/
```

Omit the path when already inside the plan packet — `resolve_plan_dir.py` auto-detects.

## Quick start (evaluator operator)

Run separately from the implementer session:

```bash
docs/plans/<slug>/scripts/evaluator_simple_loop.sh
```

Implementer agents must **not** run this script. See evaluator-role-documentation.md.
