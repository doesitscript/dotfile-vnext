---
name: framework-skill-routing-auditor
description: "Use when dotfile-vnext needs a repeatable audit of AGENTS.md, framework docs, and framework rules to find repeated operational procedure that should route to project skills instead of living as bulky prose. Use for framework reduction eval, what should become skill routing, or audit framework docs before another reduction pass."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: "project-capability-surface-audit"
requires_summary: "Repo root; framework surfaces in scope; candidate project skills already in play"
title: Framework Skill Routing Auditor
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
  - docs/codex_framework
  - .cursor/rules
  - skills/catalog.yaml
tags:
  - skill
  - validation
  - routing
  - framework
---

# Skill: Framework Skill Routing Auditor

Audit framework surfaces for repeated operator procedure that should route to
existing project skills instead of being re-explained in ambient prose.

## When to use / not use

Use when the repo needs another reduction pass across `AGENTS.md`, framework
docs, or framework rules, especially to decide what should stay governance and
what should route to project skills.

Do not use when the question is broader capability-surface ownership or runtime
mirror migration across the whole repo. For that, start with
`project-capability-surface-audit`.

## Inputs

- Repo root
- Framework surfaces in scope
- Known project skills already expected to absorb repeated procedure

## Workflow

1. Run the bundled audit helper.
2. Review the reported procedure families and classify each row as:
   - `routed`
   - `partial`
   - `candidate`
3. Keep governance obligations in framework surfaces.
4. Recommend trimming only the repeated "how" prose for `candidate` and
   `partial` rows.
5. If the user asked to execute the reduction, edit the framework surfaces with
   short routing anchors instead of duplicating the operational workflow again.

## Handoffs

- `project-capability-surface-audit`

## Outputs

- Framework routing audit table
- Candidate file/line anchors for reduction
- Suggested project-skill routing per procedure family

## Validation

- Candidate rows cite real files and lines
- Routed rows name existing project skills instead of vague categories
- The audit distinguishes governance requirements from repeatable procedure

## Failure boundaries

- Stop when the candidate route would weaken a real governance rule
- Stop when a repeated procedure cannot be matched honestly to an existing
  project skill

## Prohibited behavior

- Calling a governance rule "bulk" just because it is long
- Recommending reductions without naming the replacement project skill
- Treating runtime mirrors or legacy `.cursor` surfaces as the source of truth

## Progressive disclosure

- Operator escalation: `skills/_shared/human-escalation.md`
- Run `bin/codex-env python skills/validation/framework-skill-routing-auditor/scripts/audit_framework_skill_routing.py --repo-root "$PWD"`
- Load `references/procedure-families.md` for the family map.
- Load `references/sources-and-precedence.md` when framework prose and skill routing disagree.
- Load `references/related-artifacts.md` for the audited surfaces.
