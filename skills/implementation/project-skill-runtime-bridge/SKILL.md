---
name: project-skill-runtime-bridge
description: "Use when dotfile-vnext project skills under skills/ should be made runtime-discoverable in .cursor/skills through managed symlinks, or when the managed runtime catalog entries need to be refreshed after a skill update. Use for link project skills, refresh runtime skill catalog, or replace stale copied runtime skill folders with managed symlinks."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: ""
requires_summary: "skills/catalog.yaml; .cursor/skills/catalog.yml; scripts/link_project_skills_to_cursor.py"
title: Project Skill Runtime Bridge
technology: cursor
document_type: skill
status: reviewed
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-07-23"
applies_to:
  - cursor
  - codex
  - skills
related:
  - skills/catalog.yaml
  - .cursor/skills/catalog.yml
  - .cursor/skills/README.md
tags:
  - skill
  - runtime
  - symlink
  - skills
---

# Skill: Project Skill Runtime Bridge

Bridge source-controlled project skills into `.cursor/skills` with managed
symlinks instead of copy drift.

## When to use / not use

Use when skills under `skills/` should become runtime-discoverable in the
project’s default Cursor skill location, or when those managed runtime entries
need a refresh after skill edits.

Do not use when a user explicitly wants hand-edited runtime copies preserved.

## Inputs

- `skills/catalog.yaml`
- `.cursor/skills/catalog.yml`
- Managed bridge script

## Workflow

1. Read `skills/catalog.yaml` and select only entries with `runtime_bridge.enabled: true`.
2. For those managed skill names only, move aside stale copied runtime directories or replace stale symlinks.
3. Create per-skill symlinks in `.cursor/skills/<skill-name>` back to the source skill directories under `skills/`.
4. Refresh `.cursor/skills/catalog.yml` so the bridged skills appear in runtime discovery.
5. Verify each bridged runtime path resolves to the expected source directory.

## Handoffs

- none

## Outputs

- Managed symlinks in `.cursor/skills/`
- Runtime catalog entries for bridged project skills
- Backup paths for replaced stale runtime copies when they existed

## Validation

- Symlink targets resolve to `skills/` sources
- Existing unrelated `.cursor/skills/*` entries remain untouched
- `.cursor/skills/catalog.yml` contains the bridged skill entries
- Replaced stale runtime copies are preserved with a timestamped backup suffix

## Failure boundaries

- Stop when a `runtime_bridge` entry points at a missing source path
- Stop when an unexpected filesystem error prevents backing up a stale runtime copy

## Prohibited behavior

- Replacing unrelated existing runtime skills
- Copying project skills into `.cursor/skills` when symlinks are the chosen method
- Editing runtime catalog entries by hand when the script owns them

## Progressive disclosure

- Operator escalation: `skills/_shared/human-escalation.md`
- Load `references/sources-and-precedence.md` when deciding whether to replace an existing target.
- Load `references/related-artifacts.md` for the managed surfaces and command form.
