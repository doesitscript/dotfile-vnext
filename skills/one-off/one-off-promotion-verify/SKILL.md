---
name: one-off-promotion-verify
description: "Use after one-off-promotion Ansible lands to execute-complete: run playbooks on target hosts, fresh smoke probes, plan verification receipt with obligation inventory, and legacy one-off cleanup. Requires Superpowers verification-before-completion. Do not use for discard-only or while trial is still in docs/one_off_tasks."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
title: One-Off Promotion Verify
technology: ansible
document_type: skill
status: reviewed
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-09-02"
depends_on_skills: "homelab-ansible-first-entry, single-host-ansible-rollout"
applies_to:
  - ansible
  - docs/plans
related:
  - docs/codex_framework/plan-verification-receipt.md
  - docs/codex_framework/verification-before-completion-gate.md
  - docs/plans/2026-09-02--codex-multi-terminal-promotion/README.md
tags:
  - skill
  - one-off
  - stable
  - verification
  - ansible
---

# Skill: One-Off Promotion Verify

Close out a one-off **promotion** with live evidence — not repo-only success.

## When to use / not use

Use when:

- Ansible roles/playbooks for a promotion are merged
- the user expects converge + verify (execute-complete)
- closing a promotion plan checklist

Do **not** use when:

- promotion design is not done → `one-off-promotion`
- trial discarded → `one-off-discard-cleanup`

## Mandatory gates (load before claiming pass)

1. Superpowers skill `verification-before-completion`
2. `docs/codex_framework/verification-before-completion-gate.md`
3. `docs/codex_framework/plan-verification-receipt.md`

**Brief handoff turns do not waive fresh probes.**

## Inputs

| Input | Required |
| --- | --- |
| `plan_path` | yes — promotion plan README |
| `playbook` + `tags` + `limit` | yes — from plan Apply row |
| `legacy_cleanup_script` | if promotion added one |
| `smoke_commands` | yes — from plan Verify row |

## Workflow

### 1. Build obligation inventory

From the **full** plan packet (not checklist alone), assign `O-01`, `O-02`, …

Include at minimum:

| ID | Typical obligation |
| --- | --- |
| O-apply | Ansible playbook apply on target host(s) |
| O-artifacts | Promoted files exist on host |
| O-functions | Login-shell functions/binaries available |
| O-smoke | Lane or smoke commands return expected output |
| O-legacy | `*_one_off_tasks` artifacts removed |
| O-idempotent | Second playbook run ok (no spurious fail) |
| O-interactive | TTY checks — `pending` if not automatable |

### 2. Preview / apply

```bash
bin/codex-env ansible-playbook <playbook> --tags <tags> --limit <host>
```

Capture PLAY RECAP (`failed=0`). Re-run for idempotence when in scope.

### 3. Host verification (login shell)

Ansible ad-hoc default shell may **not** load bashrc.d — use login bash:

```bash
bin/codex-env ansible <host> -i inventory/inventory.yaml -m shell \
  -a 'bash -lc "type <fn>; test -f ~/.bashrc.d/<file>"'
```

### 4. Smoke tests

Run plan-defined smokes (e.g. `cx-*-smoke`) **in the current turn**; capture model
lane and expected token in output.

### 5. Legacy cleanup

When the plan includes `scripts/uninstall_*_one_off_legacy.sh`:

- run on target host
- re-probe that `*_one_off_tasks` paths are gone

### 6. Update plan execution receipt

Write evidence tables per obligation. Mark interactive-only rows `pending` with reason.

### 7. Completion rules

| Allowed | Not allowed |
| --- | --- |
| `pass` with this-turn command output | `pass` from prior-turn summary |
| `blocked` / `pending` with evidence | `lifecycle: implemented` on checklist-only |
| `complete-plan-lifecycle` after full receipt | brief status without probes |

## Evidence block template

```markdown
**Evidence (this turn) — O-03:**
- Command: `bash -lc 'cx-hvh01-smoke'`
- Exit: 0
- Proof: model `qwen2.5-coder-1.5b@hvh01` replied `pong`
```

## Outputs

- Updated plan execution receipt / verification receipt section
- Per-obligation pass | pending | blocked
- Optional handoff to `complete-plan-lifecycle`

## Handoffs

| When | Target |
| --- | --- |
| Rollout execution | `single-host-ansible-rollout` (`skills/validation/single-host-ansible-rollout/SKILL.md`) |
| Plan lifecycle close | `complete-plan-lifecycle` (`skills/documentation/complete-plan-lifecycle/SKILL.md`) |

## Validation

- [ ] Playbook PLAY RECAP `failed=0` captured this turn
- [ ] Login-shell probes (`bash -lc`) for functions and files
- [ ] Obligation inventory updated per `docs/codex_framework/plan-verification-receipt.md`
- [ ] Interactive-only checks marked `pending`, not `pass`

## Failure boundaries

- Stop if promotion Ansible not merged — return to `one-off-promotion`
- Stop claiming pass without Superpowers `verification-before-completion` probes this turn
- Do not call `complete-plan-lifecycle` on checklist-only evidence

## Prohibited behavior

- "Run reconvergence yourself" closeout when user requested execute
- Claiming functions exist without `bash -lc`
- Skipping playbook apply when host is reachable
- YAML frontmatter in deployed bash files (re-check promoted sources)

## Progressive disclosure

- `references/sources-and-precedence.md`
- `references/related-artifacts.md`
- `references/obligation-inventory-example.md`
