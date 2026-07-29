---
name: ansible-surface-to-module-discovery
description: >-
  Use when you need Ansible modules for plain-language operational surfaces and
  do not know the FQCN. Use for find Ansible modules for, surface to module
  matrix, don't script this, or Context7 intent search before win_shell. Do not
  use for live deploy after the matrix exists — hand off to ansible-knowledge-gate
  / owning role.
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: "ansible-knowledge-gate"
requires_summary: "Context7 MCP or ansible-doc; plain-language surfaces"
title: Ansible Surface to Module Discovery
technology: ansible
document_type: skill
status: reviewed
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-07-29"
applies_to:
  - ansible
  - windows
tags:
  - skill
  - ansible
  - modules
  - context7
---

# Skill: Ansible Surface to Module Discovery

Turn “I need X on the host” into a **module matrix** before any shell helper.
This is the findability front-door; `ansible-knowledge-gate` owns the full
receipt + implement gate.

## When to use / not use

Use when:

- FQCNs are unknown or contested
- someone reaches for `win_shell` / custom `.ps1` because “there’s no module”
- Phase 2 / plan intermission needs a surface→module deliverable

Do not use when:

- the matrix already exists and the work is role edit/deploy
- the request is install/mutate entry (start `homelab-ansible-first-entry`)

## Workflow

1. List **operational surfaces** in plain language (no FQCN).
2. Grep repo roles for the same surface.
3. Context7: `resolve-library-id` + intent `query-docs` (Pass B). Prefer
   `/ansible-collections/community.windows`, `/ansible-collections/ansible.windows`,
   product libraries.
4. Confirm with `bin/codex-env ansible-doc <fqcn>` for defaults/footguns.
5. Optional: docs.ansible.com collection/module indexes; Galaxy only after
   modules exhausted.
6. Fill the matrix (Fit yes/partial/no). Hand off to `ansible-knowledge-gate`
   knowledge receipt before implement.

Authority for channel order: HRL
`q-and-a/ansible/task-idea-to-module.md` and
`generated/context7/ansible/module-findability/`.

## Matrix template

See `ansible-knowledge-gate/references/intent-to-module-matrix.md`.

## Prohibited

- Skipping to shell when Fit=yes exists
- Inventing module parameters without Context7 or ansible-doc

## Prompt

```text
Use skill ansible-surface-to-module-discovery for <surfaces>, then ansible-knowledge-gate before any role change.
```
