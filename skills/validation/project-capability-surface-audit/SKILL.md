---
name: project-capability-surface-audit
description: "Use when dotfile-vnext should be audited for overlap or drift across AGENTS.md, framework rules, project skills, runtime-bridged skills, and legacy .cursor/skills surfaces. Use for capability surface audit, what should be a rule vs project skill vs global skill, or evaluate duplicate operational patterns before migration."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: "tool-playbook-placement-advisor, project-skill-runtime-bridge"
requires_summary: "Target repo scope; known overlapping surfaces or migration goal"
title: Project Capability Surface Audit
technology: framework
document_type: skill
status: reviewed
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-07-24"
applies_to:
  - framework
  - skills
  - validation
  - governance
related:
  - AGENTS.md
  - .cursor/rules
  - skills/catalog.yaml
  - .cursor/skills/catalog.yml
tags:
  - skill
  - validation
  - audit
  - governance
---

# Skill: Project Capability Surface Audit

Inventory the repo's capability surfaces and classify what should stay ambient,
what should move into project skills, what belongs global, and what is legacy.

## When to use / not use

Use when the repo needs a capability inventory, overlap audit, or migration
recommendation across rules, skills, and runtime mirrors.

Do not use when the target is only one concrete tool role with no broader
framework or skill-surface question.

## Inputs

- Repo scope and known pain points
- Any named rules, skills, or legacy runtime surfaces already under suspicion

## Workflow

1. Inventory the current surfaces:
   - `AGENTS.md`
   - active framework rules
   - project `skills/catalog.yaml`
   - runtime `.cursor/skills/catalog.yml`
   - obvious legacy `.cursor/skills/*` one-offs
2. Classify each surface as:
   - ambient governance
   - project-owned operational workflow
   - global reusable workflow
   - runtime mirror
   - legacy transitional surface
3. Identify duplicate operational patterns and weak ownership boundaries.
4. Recommend keep/migrate/deprecate decisions before editing anything.
5. If the user asked to execute the migration, hand off to `legacy-runtime-skill-migration` or the appropriate project skill builder.

## Handoffs

- `legacy-runtime-skill-migration`
- `project-skill-runtime-bridge`

## Outputs

- Capability surface inventory
- Overlap and drift findings
- Recommended migration list

## Validation

- The audit distinguishes ambient governance from narrow operational workflow
- Runtime mirrors are not mistaken for the authoring source of truth
- Legacy surfaces are identified explicitly rather than by vibe

## Failure boundaries

- Stop when the target surface list is incomplete and the missing area would change the migration decision
- Stop when a candidate surface is owned by another repo and that ownership is unresolved

## Prohibited behavior

- Treating `.cursor/skills` runtime mirrors as the project source of truth
- Recommending migration without inventorying the current surfaces first
- Deleting legacy surfaces before a replacement path is named

## Progressive disclosure

- Operator escalation: `skills/_shared/human-escalation.md`
- Run `bin/codex-env python skills/validation/project-capability-surface-audit/scripts/inventory_capability_surfaces.py`
- Load `references/sources-and-precedence.md` when classification signals disagree.
- Load `references/related-artifacts.md` for the audited surfaces.
