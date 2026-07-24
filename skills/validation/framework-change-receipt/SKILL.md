---
name: framework-change-receipt
description: "Use when framework docs, AGENTS.md, or framework rules were edited and dotfile-vnext needs a lightweight receipt that checks the changed surfaces still point at the right skills and still look governance-safe. Use for framework change receipt, verify the framework reduction patch, or summarize routing-anchor changes."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: "framework-skill-routing-auditor"
requires_summary: "Changed framework files or current diff; expected routing skills"
title: Framework Change Receipt
technology: framework
document_type: skill
status: reviewed
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-07-24"
applies_to:
  - framework
  - validation
  - governance
related:
  - AGENTS.md
  - docs/codex_framework
  - .cursor/rules
  - skills/catalog.yaml
tags:
  - skill
  - validation
  - receipt
  - framework
---

# Skill: Framework Change Receipt

Build a lightweight receipt for framework-surface edits.

## When to use / not use

Use after editing `AGENTS.md`, framework docs, or framework rules, especially
when a reduction pass added routing anchors or trimmed repeated procedure.

Do not use for broad project capability audits with no framework-file edits.

## Inputs

- Changed framework files or current diff
- Expected replacement project skills

## Workflow

1. Run the bundled helper against the changed framework files.
2. Review whether each changed file:
   - still has governance cues
   - now names the expected replacement project skills
   - needs a manual sanity check
3. Record the receipt in the final summary.

## Handoffs

- `framework-skill-routing-auditor`

## Outputs

- Framework change receipt table
- Follow-up warnings for files that still need manual review

## Validation

- The changed files are real framework surfaces
- Routing anchors are visible where expected
- Files with weak or missing signals are flagged instead of waved through

## Failure boundaries

- Stop when the changed-file set is unknown
- Stop when the helper flags a high-risk file with no visible governance or routing signals

## Prohibited behavior

- Claiming a framework reduction is safe without checking the changed files
- Treating recap counts or file names alone as proof
- Hiding a weak framework edit behind a generic "receipt generated" claim

## Progressive disclosure

- Operator escalation: `skills/_shared/human-escalation.md`
- Run `bin/codex-env python skills/validation/framework-change-receipt/scripts/build_framework_change_receipt.py --repo-root "$PWD"`
- Load `references/sources-and-precedence.md` when the receipt output and manual judgment disagree.
- Load `references/related-artifacts.md` for the receipt surfaces.
