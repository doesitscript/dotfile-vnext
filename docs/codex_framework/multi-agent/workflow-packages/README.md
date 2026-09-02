---
title: Agent workflow packages
status: active
owner: codex-framework
parent: docs/codex_framework/multi-agent/
---

# Workflow packages

A **workflow package** is the documentation bundle for one registered workflow
ID. It complements the **pattern** in the registry; it does not replace it.

## Pattern vs package

| | Registry pattern | Workflow package |
| --- | --- | --- |
| **Path** | `agent-workflow-registry/patterns/<id>.md` | `workflow-packages/<id>/` |
| **Contains** | Roles, gates, completion/failure rules (schema) | Role guides, AAR, onboarding, skill links |
| **Required** | Yes, to register a workflow | Optional until maturation needs it |
| **Audience** | Agents selecting a workflow | Implementer/evaluator onboarding |

## Package layout (convention)

```text
workflow-packages/<workflow-id>/
  README.md                           # Index + links to pattern and skills
  implementer-role-documentation.md   # When applicable
  evaluator-role-documentation.md     # When applicable
  after-action-report-<date>.md       # After first real run
```

Not every workflow needs every file. Start with `README.md` + pattern link.

## Current packages

| Workflow ID | README |
| --- | --- |
| `evaluator-implementer-loop` | [evaluator-implementer-loop/README.md](evaluator-implementer-loop/README.md) |

## How to add a package

1. Ensure `agent-workflow-registry/patterns/<workflow-id>.md` exists.
2. Create `workflow-packages/<workflow-id>/README.md` linking pattern + skills.
3. Add role docs and AAR as the workflow matures.
4. Register the package in [agent-workflow-registry/README.md](../agent-workflow-registry/README.md) and [../README.md](../README.md).
