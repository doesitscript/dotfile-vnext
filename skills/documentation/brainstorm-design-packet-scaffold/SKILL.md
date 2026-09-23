---
name: brainstorm-design-packet-scaffold
description: "Use when capturing a conversation idea into docs/brainstorming_designs/ as a dated folder packet—especially operator proposal vs AI assessment (operator-proposal-*.md + *-wip-ai-human-plan.md). Do not use for governed docs/plans/ packets, one-off trials, or implementing the brainstorm."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
title: Brainstorm Design Packet Scaffold
technology: governance
document_type: skill
status: reviewed
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-09-23"
applies_to:
  - docs/brainstorming_designs
related:
  - docs/brainstorming_designs/README.md
tags:
  - skill
  - brainstorm
  - scaffold
  - documentation
---

# Skill: Brainstorm Design Packet Scaffold

Scaffold a **brainstorm packet** under `docs/brainstorming_designs/`. Ideas here
are not active repo truth until promoted.

## When to use / not use

Use when:

- the user asks to create a brainstorm folder / brainstorming_designs entry
- they want their proposal in one file and an AI assessment / WIP plan in another
- a conversation idea should be parked without implementing it

Do **not** use when:

- they asked for a governed plan under `docs/plans/` → plan governance /
  `complete-plan-lifecycle` paths
- they asked for a try-before-Ansible trial → `one-off-trial-scaffold`
- they asked to **implement** the idea → stop scaffolding; use Ansible-first /
  plan execute flows instead

## Inputs

| Input | Required |
| --- | --- |
| Short capability slug | yes — kebab-case, prefer product-neutral |
| Operator idea text | yes if dual-file; else single plan body |
| Dual-file vs single | no — default dual when they contrast “my idea” vs “your assessment” |

## Workflow

1. Read `docs/brainstorming_designs/README.md` (folder naming + **Creating a new
   packet** checklist). That README is authority.
2. Create `docs/brainstorming_designs/YYYY-MM-DD--<slug>/` with:
   - `README.md` (intent, file table, not-for-execute)
   - `.aiignore` (same shape as sibling packets: ignore `*` keep git)
   - Dual default: `operator-proposal-<slug>.md` +
     `<topic>-wip-ai-human-plan.md`
   - Or single: `<topic>-plan.md`
3. Operator file: preserve intent; clarify only for readability.
4. WIP AI–human plan: assessment, gaps, draft Apply/Verify/Undo, promotion gate;
   `execution_status: not_started`; no live apply.
5. Append a row to the Active packet index in the brainstorming README.
6. Reply with the folder path and file table. Do not implement from the packet.

## Outputs

- New packet folder with README + `.aiignore` + plan file(s)
- Updated active index row in `docs/brainstorming_designs/README.md`

## Validation

- Folder name matches `YYYY-MM-DD--…-patterns/` (or documented exception)
- README states brainstorm / not approved scope
- No `docs/plans/` promotion unless user asked

## Failure boundaries

- Missing slug or empty idea → ask once, then scaffold with provisional slug
- User meant one-off trial or governed plan → redirect; do not put those here

## Prohibited behavior

- Do not treat brainstorm plans as execute-complete
- Do not invent selected model IDs / host targeting as stronger than
  `pending_research` when resources were not researched
- Do not skip the operator-proposal file when the user asked for a split

## Progressive disclosure

- Authority checklist: `docs/brainstorming_designs/README.md`
- Example dual-file packet:
  `docs/brainstorming_designs/2026-09-23--vllm-idle-desktop-usability-patterns/`
- `references/sources-and-precedence.md`
- `references/related-artifacts.md`
