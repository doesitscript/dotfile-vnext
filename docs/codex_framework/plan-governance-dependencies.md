# Plan governance dependency index

**Canonical checklist:** [docs/plans/README.md](../plans/README.md) — section **Required Diagram Checklist**

**Diagram gate receipt template:** [.cursor/rules/framework-partner-process.mdc](../../.cursor/rules/framework-partner-process.mdc) — Mandatory Diagram Requirements

**Plan verification receipt (execute/complete):** [plan-verification-receipt.md](plan-verification-receipt.md) — obligation inventory + evidence for the full plan packet, not checklist-only

## Upstream authorities

| Authority | Defines |
|-----------|---------|
| [framework-partner-process.mdc](../../.cursor/rules/framework-partner-process.mdc) | Pre-Save Diagram Gate, promotion, execute vs lifecycle |
| [AGENTS.md](../../AGENTS.md) | Bootstrap, working contract, execute approval |
| [capability_introduction_checklist.md](capability_introduction_checklist.md) | Promoted plans, live apply when execute approved |
| [framework-plan-governance.mdc](../../.cursor/rules/framework-plan-governance.mdc) | Always-on reminder to open this index + README checklist |

## Consumers (MUST read Required Diagram Checklist when…)

| Consumer | Trigger |
|----------|---------|
| Saving or promoting `docs/plans/**/README.md` | Always; Required NetBox Slice when `netbox_scope: true` or services/naming in scope |
| Conversational `<proposed_plan>` with implementation scope | Always |
| [capability_introduction_checklist.md](capability_introduction_checklist.md) item 9 | New capability + plan packet |
| [complete-plan-lifecycle skill](../../.cursor/skills/complete-plan-lifecycle/SKILL.md) | Completing or renaming plan packets — requires Plan verification receipt |
| [plan-verification-receipt.md](plan-verification-receipt.md) | Execute, status report, or `lifecycle: implemented` |
| [framework-knowledge-and-research.mdc](../../.cursor/rules/framework-knowledge-and-research.mdc) | Naming schema work tied to a stored plan |

## Evaluation packet

[docs/plans/2026-05-27--plan-diagram-governance-incomplete/README.md](../plans/2026-05-27--plan-diagram-governance-incomplete/README.md) — decide CI/skill enforcement.

## Not the same as Ansible lifecycle

Plans describe work. `role_name_state: present|absent` applies to **Ansible capabilities**, not to plan folders. Plan folders use `-incomplete` / `lifecycle: in_progress` in frontmatter — not `present`.
