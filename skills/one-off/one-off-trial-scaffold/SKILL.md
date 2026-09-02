---
name: one-off-trial-scaffold
description: "Use when starting or extending a try-before-commit experiment under docs/one_off_tasks/. Scaffolds package layout, *_one_off_tasks naming, deployed-file headers, install/uninstall scripts, and evolution notes. Do not use when the user already approved promotion to Ansible — use one-off-promotion instead."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
title: One-Off Trial Scaffold
technology: governance
document_type: skill
status: reviewed
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-09-02"
applies_to:
  - docs/one_off_tasks
  - bootstrap
related:
  - docs/one_off_tasks/README.md
  - docs/plans/README.md
tags:
  - skill
  - one-off
  - stable
  - scaffold
---

# Skill: One-Off Trial Scaffold

Create or extend a **governed one-off trial** — snowflake work that is explicitly
temporary until promoted or discarded.

## When to use / not use

Use when:

- the user wants to try something on a live machine before Ansible commitment
- extending an existing trial under `docs/one_off_tasks/<slug>/`
- adding install/uninstall paths for a new experiment

Do **not** use when:

- the user approved **promotion** → `one-off-promotion`
- the user wants **discard only** → `one-off-discard-cleanup`
- the work is already steady-state Ansible → `homelab-ansible-first-entry` /
  `tool-capability-intake`

## Inputs

| Input | Required |
| --- | --- |
| `slug` | yes — short kebab-case folder name |
| `target_host` | yes — e.g. `mac-dev` |
| `deploy_paths` | yes — what lands on the host |
| `parent_plan` | no — link if trial supports a future plan |

## Workflow

### 1. Read governance

Load `docs/one_off_tasks/README.md` before creating files.

### 2. Scaffold package layout

```text
docs/one_off_tasks/<slug>/
  README.md           # what, why, try, remove, promotion candidate map
  evolution.md        # now → promote | discard decision log
  deploy/
    install_<slug>.sh
    uninstall_<slug>.sh
    ...               # staged host files
```

### 3. Enforce naming on the host

Every deployed path, filename, and shell function **must** include a discriminator
until promoted, e.g. `*_one_off_tasks` or `<tool>_one_off_tasks`.

### 4. Header on every deployed file

First lines of every host-installed file:

```bash
# ONE-OFF TRIAL (non-permanent) — source: docs/one_off_tasks/<slug>/deploy/...
# Discardable. Overwritable. Remove via deploy/uninstall_<slug>.sh or promotion plan.
```

### 5. Install / uninstall contract

| Script | Must do |
| --- | --- |
| `install_*.sh` | Copy/link only from `deploy/`; idempotent where cheap |
| `uninstall_*.sh` | Remove every path the install created; safe to re-run |

Document in README:

- exact install command
- exact uninstall command
- what a **new terminal** or re-source is required for

### 6. Record promotion candidates

In `README.md` or `evolution.md`, list which existing roles the trial might merge into:

- `common/shell_config` / `bashrc.d`
- `common/bash_completion`
- dedicated tool role (new or existing)
- product-specific role (e.g. `codex_homelab_profiles`)

Do **not** implement in `roles/` while still in one-off mode.

### 7. Prohibited behavior

- No silent persistence into `roles/` without a plan packet
- No dropping `_one_off_tasks` suffixes before promotion
- No treating `docs/one_off_tasks/` content as framework guidance
- No YAML frontmatter (`---`) in bash/shell deploy files

## Outputs

- Governed trial folder under `docs/one_off_tasks/<slug>/`
- Install + uninstall scripts with documented operator commands
- Promotion candidate table for a future `one-off-promotion` run

## Handoffs

| Next step | Skill |
| --- | --- |
| User approves promotion | `one-off-promotion` |
| User rejects trial | `one-off-discard-cleanup` |
| Tool becomes Ansible capability | `tool-capability-intake` |

## Validation

- [ ] README states try / remove / promotion path
- [ ] All host paths use `_one_off_tasks` (or documented discriminator)
- [ ] Every deployed file has the ONE-OFF TRIAL header
- [ ] Uninstall removes all install artifacts (dry-run list in README)

## Failure boundaries

- Stop if install would write outside documented `deploy/` paths without user approval
- Stop if trial naming omits `_one_off_tasks` discriminator
- Stop if user approved promotion — hand off to `one-off-promotion` instead

## Progressive disclosure

- `references/sources-and-precedence.md`
- `references/related-artifacts.md`
