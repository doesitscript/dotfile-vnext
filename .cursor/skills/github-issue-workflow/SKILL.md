---
name: github-issue-workflow
description: Create, refine, close, and reference GitHub issues for concrete brainstorming, resumable work, next-state improvements, and feature follow-ups.
---

# GitHub Issue Workflow

Use this skill when brainstorming, partial-state notes, or real follow-up work
have become concrete enough to deserve durable GitHub tracking outside the
conversation, but not every note deserves an issue.

This skill fits a lightweight GitHub-backed planning style well, especially for
solo or small-team work where GitHub issues are being adapted into the main
feature/bug/follow-up planning area.

## What this skill is for

- turning concrete or blocked work into GitHub issues
- turning meaningful brainstorming into durable backlog items when the thought is
  refined enough to survive beyond the current session
- creating issue titles and bodies that scale across projects
- deciding when a role README note is enough vs when GitHub should track it
- closing or updating issues after work lands
- keeping repo docs aligned with issue references when useful

## Suggested framework roles

Suggested owners:

- `Planner / Steward`
  decides whether the conversation has become concrete enough to preserve as a
  durable issue
- `Researcher`
  gathers the best repo context and shapes the issue body
- `Executor`
  performs the GitHub operation and aligns repo references when needed

These can be separate agents or separate steps in one agent workflow.

## Typical trigger phrases

Examples:

- "Make this a GitHub issue"
- "Turn this brainstorming into a durable direction"
- "Capture this follow-up in the backlog"
- "Update the issue now that the work landed"

## Suggested workflow placement

This skill is designed to be reusable across projects.

Suggested placement in a project workflow:

- planning / stewardship step
  Decide whether the work should stay local or be elevated into a GitHub issue.
- research step
  Gather the right repo notes, intake docs, role READMEs, and current-state
  references so the issue body is actually useful.
- execution step
  Create, update, label, reference, or close the issue once the shape is ready.

If a project uses named roles or agents, a good default mapping is:

- planner / steward agent
  decides that the issue should exist
- researcher agent
  drafts the issue from the available repo context
- executor agent
  performs the GitHub operation and keeps repo references aligned

These do not have to be separate agents. They can be separate steps in a single
agent workflow. The important part is the concept:

- decide
- draft
- execute

This skill is trigger-based, not ambient.

Use it when:

- the user explicitly asks for issue creation, update, or closure
- brainstorming or planning has become concrete enough that future pickup should
  not depend on rediscovering the same context
- the repo has meaningful resumable work that should be tracked beyond local
  notes
- execution is about to perform a real GitHub operation

Do not keep invoking it just because a topic exists in the repo. Once the
current GitHub state is already known, do not re-check or re-draft unless new
work, a new decision point, or an explicit user request makes that useful.

If a repo note or README already points at an issue and that note is being used
to start implementation, treat the issue read as a one-time hydration step:

1. read the issue once to load the best refined direction
2. continue implementation from that issue + local repo context
3. do not keep calling back to GitHub during the same work stretch unless:
   - you are about to update or close the issue
   - the direction may have changed
   - new evidence means the issue should be revised
   - the user explicitly asks for another issue check

Think of it like this:

- first issue read = load the current plan into working memory
- repeated issue reads = only when state may have changed or needs to change

## When to create an issue

Create or update a GitHub issue when at least one of these is true:

- the next step is real, bounded, and likely to be picked up later
- the work spans multiple sessions or contributors
- repo docs would benefit from pointing at an external tracked next step
- a role or node has meaningful partial-state or resumable work that should
  survive beyond a local note
- the user wants backlog visibility without inventing a custom in-repo tracker
- brainstorming has become concrete enough that a future agent should inherit the
  refined direction instead of rediscovering it from scratch

Do not create an issue by default when:

- the note is purely exploratory or disposable
- the work is fully local and unlikely to be resumed later
- a short role README note already captures the whole state sufficiently

## General lifecycle handling

Use the skill loosely but intentionally:

- create an issue when the work becomes real enough to deserve durable tracking
- update an issue when direction changes or useful learning should be preserved
- close an issue when the work lands or is no longer real remaining work

You do not need a perfectly modeled edge-case taxonomy to use this skill well.

## Where to look first

Check these surfaces before drafting the issue:

1. role README files, especially "where we left off" or partial-state sections
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

Use a GitHub issue as the higher-level roadmap and tracking layer for the work when:

- the work is expected to continue across sessions
- the work has meaningful concrete context or a real next step
- the user wants the repo to stop carrying rough backlog state by itself

That does not replace repo plans. The intended model is:

- repo plan under `docs/plans/` = canonical detailed plan
- GitHub issue = higher-level roadmap and tracking layer
- local docs and READMEs = implementation context and recovery layer

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

1. start with the repo plan for the full refined direction and current plan
2. use the linked GitHub issue for roadmap state and tracking context
3. use linked repo notes for implementation context, local state, and offline recovery
4. if GitHub is unavailable, resume from the repo plan and local notes and re-research as needed

This is the intended balance:

- repo plan = canonical detailed planning layer
- GitHub issue = higher-level roadmap and tracking layer
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
examples of issue shape, titles, or when to elevate resumable work into GitHub.
