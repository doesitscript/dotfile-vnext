---
name: scoped-version-bump-commit-push
description: "Use when dotfile-vnext needs a scoped release-style closeout: bump version surfaces, stage only the intended files, commit with a focused message, and push without sweeping unrelated dirty-worktree changes into the same commit. Use for bump the minor version and push this slice, commit just the skill/library change, or close out a scoped tooling workflow cleanly."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: ""
requires_summary: "Target version or bump level; scoped file set; expected branch or remote"
title: Scoped Version Bump Commit Push
technology: git
document_type: skill
status: reviewed
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-07-24"
applies_to:
  - git
  - release
  - documentation
related:
  - VERSION
  - README.md
tags:
  - skill
  - git
  - versioning
  - closeout
---

# Skill: Scoped Version Bump Commit Push

Close out one intended slice cleanly without vacuuming unrelated dirty files
into the same commit.

## When to use / not use

Use when one scoped body of work is ready for a version bump, focused commit,
and push.

Do not use when the user explicitly wants every dirty file grouped and saved, or
when the target version is still undecided.

## Inputs

- Target version or bump level
- Intended file set
- Branch and push target

## Workflow

1. Inspect the current worktree before changing version surfaces.
2. Identify the intended release surfaces, usually `VERSION` plus any repo docs that mirror it.
3. Bump only the scoped version surfaces tied to the slice being closed out.
4. Stage only the intended files and verify the staged diff matches the intended slice.
5. Create a focused commit message that describes the scoped work, not the whole dirty tree.
6. Push to the tracked upstream without force.
7. Report the commit SHA, branch, and pushed range.

## Handoffs

- none

## Outputs

- Updated version surfaces
- Focused commit
- Pushed branch state for the scoped slice

## Validation

- The staged diff excludes unrelated dirty-worktree files
- Version surfaces are internally consistent
- Push success is confirmed from real git output

## Failure boundaries

- Stop when the scoped file set cannot be separated cleanly from unrelated dirty changes
- Stop when push fails and the raw git error has been captured

## Prohibited behavior

- Using `git add .` on a dirty tree for a scoped closeout
- Force-pushing without explicit user direction
- Bumping version files before deciding whether this slice truly warrants it

## Progressive disclosure

- Operator escalation: `skills/_shared/human-escalation.md`
- Load `references/sources-and-precedence.md` when version surfaces disagree.
- Load `references/related-artifacts.md` for common closeout files and checks.
