---
name: framework-bulk-reduction-patcher
description: "Use when dotfile-vnext should apply a framework-reduction pass after the routing audit: keep governance in AGENTS.md, framework docs, and framework rules, but trim repeated operator procedure into short routing anchors that point at project skills. Use for apply the framework reduction, patch the bulky framework prose, or do the routing-anchor pass."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: "framework-skill-routing-auditor, framework-change-receipt"
requires_summary: "Repo root; routing audit output; files approved for reduction"
title: Framework Bulk Reduction Patcher
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
  - implementation
  - governance
related:
  - AGENTS.md
  - docs/codex_framework
  - .cursor/rules
  - skills/catalog.yaml
tags:
  - skill
  - implementation
  - routing
  - framework
---

# Skill: Framework Bulk Reduction Patcher

Apply a framework reduction pass without weakening the repo's governance layer.

## When to use / not use

Use when the routing audit already found repeated procedural prose and the next
step is to patch framework surfaces so they route to existing project skills.

Do not use when the repo still needs the audit first, or when the question is
whether a workflow should become a skill at all.

## Inputs

- Repo root
- Routing audit output
- Files approved for reduction

## Workflow

1. Run `framework-skill-routing-auditor` first if current candidate rows are
   missing or stale.
2. Use the bundled helper to group candidate rows by file and procedure family.
3. Patch only the repeated "how" prose.
4. Keep governance, completion gates, and source-of-truth rules in place.
5. Replace long procedural blocks with short routing anchors that name the
   replacement project skills.
6. Finish with `framework-change-receipt`.

## Handoffs

- `framework-skill-routing-auditor`
- `framework-change-receipt`

## Outputs

- Reduced framework prose
- Added routing anchors to project skills
- Candidate summary for the patched files

## Validation

- Governance rules remain intact
- Replacement project skills are named explicitly
- The patched files match the candidate families from the routing audit

## Failure boundaries

- Stop when a reduction would remove a real governance rule
- Stop when the replacement skill is still missing or not trustworthy enough to route to

## Prohibited behavior

- Deleting completion or governance requirements as "bulk"
- Replacing project-specific process with vague references like "use the right skill"
- Shrinking scope by removing user-approved obligations from framework prose

## Progressive disclosure

- Operator escalation: `skills/_shared/human-escalation.md`
- Run `bin/codex-env python skills/implementation/framework-bulk-reduction-patcher/scripts/summarize_framework_reduction_targets.py --repo-root "$PWD"`
- Load `references/patterns.md` for the patch style.
- Load `references/sources-and-precedence.md` when framework prose and audit signals disagree.
- Load `references/related-artifacts.md` for the patched surfaces.
