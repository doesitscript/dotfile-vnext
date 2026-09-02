---
title: Multi-agent capability (framework)
status: active
owner: codex-framework
---

# Multi-agent capability

Framework home for **multi-agent coordination** in this repo: reusable
**agent workflow patterns**, a explicit **registry**, and per-workflow **packages**
(role docs, after-action reports, skills linkage).

This is a distinct capability layer — not plan packets, not skills alone.

## Folder map

```text
docs/codex_framework/multi-agent/
├── README.md                          ← you are here (capability index)
├── agent-workflow-registry/           ← REGISTRY: patterns + schema + learnings
│   ├── README.md                      ← catalog of registered workflows
│   ├── workflow-pattern-schema.md     ← required sections for new patterns
│   ├── patterns/                      ← one .md per workflow pattern (contract)
│   └── learnings/                     ← incidents that changed workflow rules
└── workflow-packages/                 ← PACKAGES: mature docs per workflow
    ├── README.md
    └── <workflow-id>/                 ← role docs, AAR, links to pattern + skills
        └── README.md
```

## Concepts

| Term | Meaning | Location |
| --- | --- | --- |
| **Multi-agent capability** | Framework area for role-split agent work | `multi-agent/` |
| **Agent workflow** | Named coordination pattern (roles, gates, completion) | Registry `patterns/<id>.md` |
| **Agent workflow registry** | Catalog + schema + learnings | `agent-workflow-registry/` |
| **Workflow package** | Pattern + role documentation + AAR for one workflow | `workflow-packages/<id>/` |
| **Skills** | Executable agent procedures (Codex/Cursor) | `skills/multi-agent/`, etc. |

**Add a new workflow:** define pattern in registry first (`workflow-pattern-schema.md`),
then add a package folder when role docs or an AAR are needed.

## Registered workflows (index)

| Workflow ID | Status | Pattern | Package | Primary skill |
| --- | --- | --- | --- | --- |
| `evaluator-implementer-loop` | trial | [pattern](agent-workflow-registry/patterns/evaluator-implementer-loop.md) | [package](workflow-packages/evaluator-implementer-loop/README.md) | `multi-agent-implementer` |
| `plan-family-execution-with-validator` | active | [pattern](agent-workflow-registry/patterns/plan-family-execution-with-validator.md) | — | (plan coordinator) |
| `doc-collection-coordinator` | trial | [pattern](agent-workflow-registry/patterns/doc-collection-coordinator.md) | — | `vendor-doc-collection` |
| `hyperv-guest-connectivity-and-ai-stack-order` | active | [pattern](agent-workflow-registry/patterns/hyperv-guest-connectivity-and-ai-stack-order.md) | — | — |

Full registry: [agent-workflow-registry/README.md](agent-workflow-registry/README.md).

## Related surfaces

| Surface | Path |
| --- | --- |
| Skills (implementer) | `skills/multi-agent/` |
| AGENTS.md rule | §31 reusable multi-agent workflows |
| Partner process | `docs/codex_framework/partner_process.md` |
| Legacy redirect | `docs/codex_framework/agent-workflows/README.md` |

## Migration note (2026-09-02)

Former paths:

- `docs/codex_framework/agent-workflows/` → `multi-agent/agent-workflow-registry/`
- `docs/codex_framework/evaluator-implementer-loop/` → `multi-agent/workflow-packages/evaluator-implementer-loop/`
