---
name: one-off-discard-cleanup
description: "Use when a docs/one_off_tasks trial is rejected and must be removed without Ansible promotion. Runs uninstall, removes host traces, deletes the one-off folder, and records discard evidence. Do not use when the user approved promotion — use one-off-promotion instead."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
title: One-Off Discard Cleanup
technology: governance
document_type: skill
status: reviewed
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-09-02"
applies_to:
  - docs/one_off_tasks
related:
  - docs/one_off_tasks/README.md
tags:
  - skill
  - one-off
  - stable
  - discard
  - cleanup
---

# Skill: One-Off Discard Cleanup

Remove a one-off trial completely when the operator chooses **discard** over promotion.

## When to use / not use

Use when:

- the user says discard, abandon, tear down, or remove the trial
- a trial failed and should leave no host or repo traces
- cleaning up before starting a fresh trial with a new slug

Do **not** use when:

- promoting to Ansible → `one-off-promotion`
- only removing **legacy** `*_one_off_tasks` after promotion → legacy script in
  promotion plan + `one-off-promotion-verify`

## Inputs

| Input | Required |
| --- | --- |
| `one_off_slug` | yes |
| `target_host` | yes — where install ran |
| `uninstall_script` | yes — `deploy/uninstall_*.sh` path |

## Workflow

### 1. Confirm discard intent

Briefly restate what will be removed (host paths + repo folder). Proceed unless
the user meant promotion.

### 2. Run uninstall on target host

```bash
# From trial README — example shape
docs/one_off_tasks/<slug>/deploy/uninstall_<slug>.sh
```

If uninstall is broken:

- enumerate paths from `deploy/install_*.sh` and README
- remove manually with evidence
- fix uninstall script before deleting repo folder (so future agents have truth)

### 3. Verify host is clean

Run probes **in the current turn** (Superpowers `verification-before-completion`):

```bash
# Example checks — adapt per trial README
test ! -f ~/.bashrc.d/<name>_one_off_tasks.bash
type <trial-function> 2>&1 | grep -q 'not found'
```

Document TTY-only checks as `pending` (operator confirms).

### 4. Delete repo folder

Remove `docs/one_off_tasks/<slug>/` entirely.

Do **not** archive to `docs/plans/` on discard unless the user asks for a short
post-mortem note elsewhere.

### 5. Record discard evidence

Minimal receipt (in conversation or `evolution.md` commit message):

| Step | Result |
| --- | --- |
| Uninstall run | exit code + summary |
| Host probe | pass / pending |
| Repo folder deleted | yes |

### 6. Check for stray host artifacts

If the trial ran multiple iterations, grep the repo for `_one_off_tasks` and
`<slug>` to ensure no orphaned references in bashrc or docs.

## Outputs

- Clean host (or documented `blocked` with evidence)
- Deleted `docs/one_off_tasks/<slug>/`
- Discard receipt

## Prohibited behavior

- Deleting repo folder before uninstall (unless user explicitly accepts host mess)
- Claiming clean without fresh probe output this turn
- Promoting pieces into `roles/` during discard
- Leaving `*_one_off_tasks` files on the host

## Validation

- [ ] Uninstall script ran with captured exit code
- [ ] Host probes show `*_one_off_tasks` paths gone (this turn)
- [ ] `docs/one_off_tasks/<slug>/` deleted from repo

## Failure boundaries

- Stop if user meant promotion — hand off to `one-off-promotion`
- Stop if uninstall failed without documenting `blocked` evidence
- Do not delete repo folder while host artifacts remain without user acceptance

## Handoffs

| Situation | Skill |
| --- | --- |
| Trial might be salvaged | `one-off-trial-scaffold` (new slug) |
| Partial work worth keeping | user decides promotion vs new trial |

## Progressive disclosure

- `references/sources-and-precedence.md`
- `references/related-artifacts.md`
