---
title: Agent workflow registry
status: active
owner: codex-framework
parent: docs/codex_framework/multi-agent/
---

# Agent workflow registry

**Explicit registry** for reusable multi-agent and role-split **workflow patterns**
in this project.

Plans may **select** a workflow; the registry **owns** the pattern (roles, gates,
completion rules). Plan packets describe *what*; patterns describe *how agents
coordinate*.

Parent capability index: [../README.md](../README.md).

## Registry contents

| Path | Purpose |
| --- | --- |
| [workflow-pattern-schema.md](workflow-pattern-schema.md) | Required sections for every new pattern |
| [patterns/](patterns/) | Workflow pattern contracts (one file per workflow ID) |
| [learnings/](learnings/) | Post-incident notes that changed registry rules |

## Workflow packages (optional)

When a pattern needs role documentation, after-action reports, or skill wiring
beyond the pattern file, add:

```text
../workflow-packages/<workflow-id>/
```

See [../workflow-packages/README.md](../workflow-packages/README.md).

## Pattern lifecycle

| Status | Meaning |
| --- | --- |
| `draft` | Documented; not yet used on real work |
| `trial` | In active use; still being corrected |
| `active` | Approved default for new matching work |
| `retired` | Historical only |

## Registered patterns

| ID | Status | Pattern file | Package | Notes |
| --- | --- | --- | --- | --- |
| `evaluator-implementer-loop` | trial | [patterns/evaluator-implementer-loop.md](patterns/evaluator-implementer-loop.md) | [package](../workflow-packages/evaluator-implementer-loop/README.md) | Skill `multi-agent-implementer` |
| `plan-family-execution-with-validator` | active | [patterns/plan-family-execution-with-validator.md](patterns/plan-family-execution-with-validator.md) | — | Coordinator + validator gate |
| `doc-collection-coordinator` | trial | [patterns/doc-collection-coordinator.md](patterns/doc-collection-coordinator.md) | — | Vendor doc collection |
| `hyperv-guest-connectivity-and-ai-stack-order` | active | [patterns/hyperv-guest-connectivity-and-ai-stack-order.md](patterns/hyperv-guest-connectivity-and-ai-stack-order.md) | — | Stack ordering |

## How to add a workflow

1. Pick a **workflow ID** (kebab-case, stable): e.g. `my-new-coordinator-loop`.
2. Copy schema from [workflow-pattern-schema.md](workflow-pattern-schema.md).
3. Create `patterns/<workflow-id>.md` with front matter `status: draft`.
4. Add a row to the table above (this README) and [../README.md](../README.md).
5. When role docs or AAR exist, create `../workflow-packages/<workflow-id>/`.
6. Link skills under `skills/` and catalog entries; reference pattern ID in plan packets.
7. After a successful real run, promote `draft` → `trial` → `active`.

## Rules

- Do not bury reusable multi-agent behavior only inside `docs/plans/`.
- Do not call work complete until the selected workflow's validation gate passes or is explicitly unsigned with evidence.
- If a validator, MCP tool, or subagent fails, narrow and retry — unsigned is not complete.

## Why this exists

AI intake exposed a gap: coordinator and validator lived in plan prose but the
validator was not a hard release gate. This registry separates:

- **Plan** — scope and obligations
- **Workflow pattern** — agent roles and gates
- **Receipt** — proof gates ran
- **Package** — human/agent onboarding for a specific workflow

See [learnings/2026-05-29-ai-intake-validator-gap.md](learnings/2026-05-29-ai-intake-validator-gap.md).
