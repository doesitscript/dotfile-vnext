---
name: Plan diagram governance enforcement
lifecycle: in_progress
scope: governance
---

# Plan diagram governance (evaluation)

## Problem

`docs/plans/README.md` Required Diagram Checklist was not in the always-applied rule stack — only linked from `framework-partner-process.mdc`. Agents skipped **Naming/Modeling** diagrams.

## Fix landed

- [docs/codex_framework/plan-governance-dependencies.md](../../codex_framework/plan-governance-dependencies.md) — dependency index
- [.cursor/rules/framework-plan-governance.mdc](../../../.cursor/rules/framework-plan-governance.mdc) — always-applied gate
- Wired references in AGENTS.md, plans/README.md, partner-process, codex_framework/README.md

## Todos (evaluate)

- [ ] **CI:** fail if new `docs/plans/**/README.md` lacks `## Diagram gate receipt`
- [ ] **Skill:** `complete-plan-lifecycle` requires gate receipt before `-implemented` rename
- [x] **Spec:** comprehensive Plan verification receipt — [plan-verification-receipt.md](../../codex_framework/plan-verification-receipt.md); wired in AGENTS.md §20, `docs/plans/README.md`, `framework-partner-process.mdc`, `framework-plan-governance.mdc`
- [ ] **CI:** fail if `lifecycle: implemented` without `## Plan verification receipt` + obligation inventory
- [ ] **Skill:** `complete-plan-lifecycle` rejects checklist-only receipts (skill text updated; enforce in workflow)
- [ ] **Audit:** scan existing `docs/plans/*-incomplete/` for missing Naming/Modeling; backfill as touched
- [ ] **Audit:** migrate checklist-only execute receipts to obligation inventory when plans are touched

## Diagram gate receipt

- [x] Architecture/Structure: this evaluation packet
- [x] Capability Routing: N/A — governance doc only
- [x] Naming/Modeling: N/A — no NetBox object changes
- [x] Diagram Inventory: below

## Diagram Inventory

### Diagrams Included

- None required (governance meta-plan)

### Additional Diagrams Available On Request

- Dependency DAG from plan-governance-dependencies.md
