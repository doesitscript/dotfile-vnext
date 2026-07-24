---
name: legacy-runtime-skill-migration
description: "Use when an old .cursor/skills workflow should be migrated into dotfile-vnext's project skill library under skills/, then bridged back into runtime discovery. Use for move this legacy runtime skill into the project store, replace runtime-only authoring with project-owned skills, or de-emphasize a legacy .cursor operational skill after a replacement exists."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: "project-capability-surface-audit, project-skill-runtime-bridge"
requires_summary: "Legacy .cursor skill or workflow in scope; intended replacement path; target store decision"
title: Legacy Runtime Skill Migration
technology: skills
document_type: skill
status: reviewed
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-07-24"
applies_to:
  - skills
  - migration
  - framework
related:
  - skills/catalog.yaml
  - .cursor/skills/catalog.yml
  - docs/codex_framework/README.md
tags:
  - skill
  - implementation
  - migration
  - runtime
---

# Skill: Legacy Runtime Skill Migration

Move narrow runtime-only workflows out of legacy `.cursor/skills` authoring and
into the project skill library under `skills/`, then refresh runtime discovery.

## When to use / not use

Use when an operational workflow already living in `.cursor/skills` should
become a project-owned skill under `skills/`.

Do not use when the surface is a still-active framework workflow that lacks a
clear project-skill replacement.

## Inputs

- Legacy runtime skill in scope
- Replacement target and ownership decision
- Any docs or rules that still point at the legacy surface

## Workflow

1. Start with `project-capability-surface-audit` if the ownership decision is not already clear.
2. Create or refresh the project-owned skill under `skills/`.
3. Register it in `skills/catalog.yaml`, `skills/evals/catalog.yaml`, and `skills/README.md`.
4. Use `project-skill-runtime-bridge` to mirror it back into `.cursor/skills`.
5. Update repo docs to point at the project-owned skill first.
6. Mark the old runtime-only source as transitional, deprecated, or legacy-only rather than deleting it blindly.

## Handoffs

- `project-skill-runtime-bridge`

## Outputs

- Project-owned skill source
- Runtime bridge entry
- Reduced reliance on legacy `.cursor/skills` authoring

## Validation

- The new project skill is the source of truth
- Runtime discovery resolves through a symlink back to `skills/`
- Docs point at the new project surface when the replacement is ready

## Failure boundaries

- Stop when the legacy surface is still serving as a framework workflow with no project-skill replacement
- Stop when the migration would break discovery and the runtime bridge has not been refreshed

## Prohibited behavior

- Treating a bridged runtime symlink as the new authoring source
- Deleting the legacy surface before a project-owned replacement is working
- Migrating broad ambient governance text as if it were just another operational skill

## Progressive disclosure

- Operator escalation: `skills/_shared/human-escalation.md`
- Load `references/sources-and-precedence.md` when migration ownership is unclear.
- Load `references/related-artifacts.md` for the touched project and runtime surfaces.
