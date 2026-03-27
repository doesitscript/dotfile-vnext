---
name: grouped-git-commits
description: Stage only related work, exclude unrelated dirty files, and create one or more grouped multiline git commits with clear titles and bodies. Use when the user asks to add and commit current work cleanly, especially in a dirty worktree.
---

# Grouped Git Commits

Use this skill when the user wants the current work added and committed cleanly.

This skill is for the final git hygiene step after implementation work, not for
routine status checks.

## What this skill is for

- inspecting the current git worktree before committing
- separating related work from unrelated dirty files
- staging only the intended paths
- splitting commits by topic when multiple workstreams are present
- writing multiline commit messages with a short subject and useful body
- reporting what was intentionally excluded

## Core workflow

1. Inspect the worktree first.
   - run `git status --short`
   - if needed, inspect `git diff --stat` or targeted diffs to understand grouping

2. Identify commit groupings.
   - prefer one commit per coherent workstream
   - do not mix unrelated doc, config, feature, or refactor changes just because
     they are all currently dirty

3. Exclude unrelated work.
   - do not stage files outside the current task
   - call out intentionally excluded paths in the final response

4. Stage only the selected files.
   - prefer explicit path lists over `git add -A`
   - for renames or replacements, stage both the removals and additions through
     explicit paths

5. Commit with a multiline message.
   - use a concise subject line
   - add a body that explains:
     - what changed
     - why the grouping makes sense
     - any important scope boundaries

6. Verify the result.
   - run `git status --short`
   - confirm the intended commit landed
   - report any remaining dirty files

## Commit shape

Preferred commit message structure:

```text
type(scope): short summary

- key change or theme
- key change or theme
- notable scope boundary or follow-up
```

Use multiple commits when there are multiple independent themes.

## Guardrails

- Never stage unrelated dirty files just to make the worktree cleaner.
- Do not rewrite or squash existing commits unless the user explicitly asks.
- If the grouping is ambiguous, choose the smallest sensible commit split.
- Keep the user informed about what is being committed before running the commit.
- If a commit contains only renames and reference updates, say so plainly.

## Suggested trigger phrases

- "add related work and commit it"
- "make grouped commits"
- "commit the current framework changes"
- "stage only the related files and use multiline commits"
