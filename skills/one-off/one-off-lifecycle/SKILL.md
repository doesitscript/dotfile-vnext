---
name: one-off-lifecycle
description: "Use as the entry router for the one-off skill family: trial scaffold, promotion, discard cleanup, and promotion verify. Loads the correct member skill for the current lifecycle phase. Do not use for steady-state Ansible work outside one_off_tasks governance."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
title: One-Off Lifecycle
technology: governance
document_type: skill
status: reviewed
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-09-02"
applies_to:
  - docs/one_off_tasks
  - docs/plans
tags:
  - skill
  - one-off
  - stable
  - lifecycle
---

# Skill: One-Off Lifecycle

Router for the four-member **one-off** family under `skills/one-off/`.

## When to use / not use

Use when the task touches `docs/one_off_tasks/` lifecycle and the correct phase
is unclear.

Do **not** use when steady-state Ansible capability work is already scoped —
use `homelab-ansible-first-entry` or `tool-capability-intake`.

## Family members

| Phase | Skill |
| --- | --- |
| Start / extend trial | `one-off-trial-scaffold` |
| Promote to Ansible | `one-off-promotion` |
| Discard trial | `one-off-discard-cleanup` |
| Verify promotion | `one-off-promotion-verify` |

Pack audits: pass explicit `--skill-name one-off-lifecycle` or list all four
members; prefix resolution from `one-off-promotion` alone returns only a subset.

## Inputs

| Input | Required |
| --- | --- |
| `phase` | yes — scaffold \| promote \| discard \| verify |
| `one_off_slug` | yes when a trial folder exists |

## Workflow

1. Read `docs/one_off_tasks/README.md`.
2. Select the member skill from the table above.
3. Follow that skill to completion for the phase.
4. Hand off to the next member when the phase completes.

## Handoffs

See family table — each member owns its downstream handoffs.

## Outputs

- Routed execution via the correct member skill
- No cross-phase work without explicit user approval

## Validation

- [ ] Correct member skill selected for stated phase
- [ ] Governance README consulted before host mutation

## Failure boundaries

- Stop if phase is ambiguous — ask operator (promote vs discard)
- Do not skip verify after promotion execute request

## Prohibited behavior

- Implementing from `docs/plans/*/backup/one-off-source/`
- Assuming pack tooling infers all four skills from promotion alone

## Progressive disclosure

- `skills/one-off/README.md`
