---
name: grouped-git-commits
description: Group ALL dirty files by theme and commit each group with clear titles and bodies. Automatically marks incomplete work as WIP. Use when the user asks to add and commit current work cleanly, especially in a dirty worktree.
---

# Grouped Git Commits

Use this skill when the user wants ALL current work added and committed cleanly.

This skill commits **everything** in the worktree, grouped by theme, with automatic
WIP detection for incomplete work.

## What this skill is for

- inspecting the current git worktree before committing
- grouping ALL dirty files by theme/workstream
- staging files by logical group
- splitting commits by topic when multiple workstreams are present
- automatically marking incomplete work with `[WIP]` or `-wip` suffix
- writing multiline commit messages with a short subject and useful body
- committing everything so nothing is lost

## Core workflow

1. Inspect the worktree first.
   - run `git status --short`
   - if needed, inspect `git diff --stat` or targeted diffs to understand grouping

2. Identify ALL commit groupings.
   - group files by theme: framework rules, skills, plans, roles, playbooks, docs
   - prefer one commit per coherent workstream
   - do not mix unrelated themes just because they are all dirty

3. Detect work-in-progress indicators.
   - incomplete plans (missing sections, TODO markers, "draft" in filename)
   - unfinished implementation (commented code, placeholder values, empty files)
   - partial refactors (some files updated, others not)
   - new untracked directories that look exploratory

4. Stage files by group.
   - use explicit path lists for each group
   - for renames or replacements, stage both the removals and additions through
     explicit paths

5. Commit each group with appropriate type.
   - **Complete work**: `type(scope): description`
   - **In-progress work**: `wip(scope): description [WIP]`
   - add a body that explains:
     - what changed or what's being explored
     - why the grouping makes sense
     - any important scope boundaries or next steps

6. Verify the result.
   - run `git status --short`
   - confirm all intended commits landed
   - report if worktree is now clean or if untracked artifacts remain

## Commit shape

### Complete work
```text
type(scope): short summary

- key change or theme
- key change or theme
- notable scope boundary or follow-up
```

### In-progress work
```text
wip(scope): short summary [WIP]

- exploratory change or draft
- incomplete implementation
- next steps: what remains to finish
```

Use multiple commits when there are multiple independent themes.

## WIP Detection Signals

Mark a commit as WIP when ANY of these are true:
- Files contain TODO, FIXME, or XXX comments added in this session
- Plan files are incomplete or missing standard sections
- New directories with exploratory/draft naming
- Partial implementations (some related files changed, others not)
- Placeholder values or commented-out code
- Files in `docs/brainstorming_designs/` or similar exploratory paths
- User explicitly mentioned "in progress" or "draft" in the request

## Guardrails

- Commit EVERYTHING - do not leave dirty files uncommitted
- Do not rewrite or squash existing commits unless the user explicitly asks
- If the grouping is ambiguous, choose the smallest sensible commit split
- Keep the user informed about what is being committed before running the commit
- If a commit contains only renames and reference updates, say so plainly
- Always verify worktree is clean (or only untracked artifacts remain) after commits

## Suggested trigger phrases

- "commit everything"
- "grouped commits" or "/grouped-git-commits"
- "save all current work"
- "commit all dirty files by theme"
