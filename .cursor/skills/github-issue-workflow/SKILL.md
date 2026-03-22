---
name: github-issue-workflow
description: Create, refine, close, and reference GitHub issues for staged work, next-state improvements, and feature follow-ups. Use when repo docs, role READMEs, intake notes, or partial-state notes should become durable GitHub issues, or when existing issues need to be updated or closed after work lands.
---

# GitHub Issue Workflow

Use this skill when work is real enough to deserve durable tracking outside the
conversation, but not every note deserves a GitHub issue.

## What this skill is for

- turning staged or blocked work into GitHub issues
- turning meaningful brainstorming into durable backlog items when the thought is
  refined enough to survive beyond the current session
- creating issue titles and bodies that scale across projects
- deciding when a role README note is enough vs when GitHub should track it
- closing or updating issues after work lands
- keeping repo docs aligned with issue references when useful

## When to create an issue

Create or update a GitHub issue when at least one of these is true:

- the next step is real, bounded, and likely to be picked up later
- the work spans multiple sessions or contributors
- repo docs would benefit from pointing at an external tracked next step
- a role or node has meaningful staged state that should survive beyond a local note
- the user wants backlog visibility without inventing a custom in-repo tracker
- brainstorming has become concrete enough that a future agent should inherit the
  refined direction instead of rediscovering it from scratch

Do not create an issue by default when:

- the note is purely exploratory or disposable
- the work is fully local and unlikely to be resumed later
- a short role README note already captures the whole state sufficiently

## Where to look first

Check these surfaces before drafting the issue:

1. role README files, especially "where we left off" or staged-state sections
2. role-local `docs/` folders for node- or role-specific logic
3. `docs/intake/` for massaged but not yet active work
4. current inventory/host vars if the issue is about host-specific configuration

## Title strategy

Prefer short scope-first titles:

- `tunnelblick: import router OpenVPN profile on mac-dev`
- `network-server: translate Hyper-V/Multipass intake into Ubuntu VM automation`

Good title shape:

- `<scope>: <next concrete outcome>`

Where scope is usually one of:

- a role name
- a node name
- a capability name

## Label strategy

Labels are not optional for issues created through this skill.

Use this light required schema for every issue:

1. one `type:*` label
2. one `state:*` label
3. one `scope:*` label

Suggested `type:*` values:

- `type:capability`
- `type:feature`
- `type:bug`
- `type:cleanup`
- `type:research`

Suggested `state:*` values:

- `state:staged`
- `state:blocked`
- `state:ready`
- `state:in-progress`
- `state:done`

Suggested `scope:*` values should be specific and stable enough to filter by:

- `scope:tunnelblick`
- `scope:network-server`
- `scope:codex-framework`

Optional extra labels are allowed when they materially help filtering, such as:

- `area:ansible`
- `platform:macos`
- `platform:windows`
- `topic:vm`
- `topic:vpn`

Do not skip labels just because the issue is small. Use the minimum required
three-label schema and add extras only when they improve pickup or triage.

## Issue body strategy

Keep the issue body compact and operational.

Default light schema:

1. `Overview`
2. `Current state`
3. `Primary execution plan`
4. `Blockers / missing inputs`
5. `Definition of done`
6. `Pick-up references`

If the issue is small, those sections can stay very short. The important thing
is that a future agent can pick the work back up without rereading the entire
repo.

Treat the issue as the highest practical planning layer for the work when:

- the work is expected to continue across sessions
- the work has meaningful staged context or a real next step
- the user wants the repo to stop carrying rough backlog state by itself

That does not replace repo notes entirely. It means the issue should hold the
best refined direction, while local docs and READMEs preserve enough context to
work offline or recover if GitHub is unavailable.

## CLI path

Preferred command:

```bash
gh issue create --repo <owner/repo> --title "<title>" --body "<body>" \
  --label "type:..." --label "state:..." --label "scope:..."
```

If `gh` auth is not working:

- do not pretend the issue was created
- draft the title/body locally in the conversation or a requested repo note
- say that `gh` auth is the blocker

When the user is already in the GitHub UI, produce a clean title and body that
can be pasted directly into the issue form.

## Closing issues

Close an issue when:

- the repo work is actually landed
- any needed docs or role notes are updated
- the issue no longer represents real remaining work

Preferred command:

```bash
gh issue close <number> --repo <owner/repo> --comment "<short closeout note>"
```

## Repo-reference pattern

When useful, leave a short note in the relevant repo surface such as:

- `Tracked in GitHub issue #123`

Do this when the issue meaningfully helps future resumption, especially if the
doc, intake note, or role README materially contributed to shaping the issue.
Do not spray issue references everywhere.

Preferred places for issue references:

1. role README files with staged or partial-state notes
2. role-local `docs/` folders for bigger role-specific work
3. `docs/intake/` notes that were used to shape the issue

The goal is:

- the repo note points to the issue for the best refined direction
- the issue points back to the repo note for pickup context
- either side remains useful if the other is temporarily unavailable

## Resume order

When a role README, role-local doc, or intake note references a GitHub issue
created through this workflow:

1. start with the GitHub issue for the best refined direction and current plan
2. use the linked repo notes for implementation context, local state, and offline recovery
3. if GitHub is unavailable, resume from the repo notes and re-research as needed

This is the intended balance:

- GitHub issue = highest practical planning layer
- repo notes = local context and recovery layer

## Default behavior

When the user says things like:

- `create an issue for this capability`
- `make an issue for this feature`
- `capture this in GitHub`

treat that as enough to:

1. identify the scope
2. choose a scope-first title
3. draft the issue in the default light schema
4. choose the required labels
5. include the primary execution plan
6. include the most important repo references for pickup
7. add or recommend short issue references in the repo surfaces that materially
   shaped the issue when that will help future pickup

Do not require the user to pre-format the issue unless something material is
missing.

## Examples

Read [references/examples.md](references/examples.md) when you need concrete
examples of issue shape, titles, or when to elevate staged work into GitHub.
