---
name: context7-intake-or-emulate
description: "Use when documentation intake for homelab-reference-library should prefer Context7 when a valid library ID exists, but still land a durable best-effort entry when Context7 cannot resolve the library. Use for source-intake notes, fallback labeling, or honest repo-vs-Context7 routing."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: ""
requires_summary: "Library root; target technology; Context7 resolution outcome"
title: Context7 Intake Or Emulate
technology: documentation
document_type: skill
status: draft
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-07-24"
applies_to:
  - context7
  - documentation
  - homelab-reference-library
related:
  - /Users/joshc/develop/homelab-reference-library/notes/investigations/dstl8-source-intake.md
  - /Users/joshc/develop/homelab-reference-library/notes/investigations/stern-source-intake.md
tags:
  - skill
  - context7
  - intake
  - documentation
---

# Skill: Context7 Intake Or Emulate

Create honest intake notes that prefer Context7 but do not block on missing library IDs.

## When to use / not use

Use when:

- a library/tool should be added to `homelab-reference-library`
- Context7 may or may not have a resolvable library ID
- the intake result needs explicit provenance and fallback labeling

Do not use when:

- the work is only to execute an already-registered library build flow elsewhere
- the task is not producing a durable intake artifact

## Inputs

- Library root
- Target technology or repo
- Context7 resolution result

## Workflow

1. Read `references/fallback-rules.md`.
2. Try Context7 first.
3. If Context7 resolves a usable library ID, record it plainly and proceed with a normal Context7-backed intake note.
4. If Context7 does not resolve a usable library ID, switch to `best-effort emulated intake` and document the fallback source honestly.
5. Use the bundled note writer to scaffold the investigation note:

```bash
python3 skills/documentation/context7-intake-or-emulate/scripts/write_intake_note.py \
  --library-root /Users/joshc/develop/homelab-reference-library \
  --slug your-topic-slug \
  --title "Your Topic Intake" \
  --technology your-topic \
  --mode emulated
```

## Handoffs

- none

## Outputs

- Durable intake note scaffold
- Honest Context7 or emulated label
- Follow-up slots for source selection and observed doc surface

## Validation

- The note clearly says whether the result was Context7-backed or emulated
- Resolve attempts are preserved
- Selected sources are official when available

## Failure boundaries

- Stop when neither Context7 nor an official fallback source can be identified honestly

## Prohibited behavior

- Presenting repo-only fallback work as normal indexed Context7 output
- Hiding missing library-ID resolution

## Progressive disclosure

- Operator escalation: `skills/_shared/human-escalation.md`
- Load `references/fallback-rules.md` before writing the note.
- Shared helper: `skills/_shared/automation-memory/shared_automation.py`
