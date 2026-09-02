---
name: one-off-promotion
description: "Use when the user approves promoting a docs/one_off_tasks trial into managed Ansible. Creates plan packet with backup/one-off-source archive, promotion map, role/playbook implementation, host_vars wiring, legacy cleanup script, and stops extending the live one-off tree. Do not use for discard-only or for trials still in active iteration without promotion approval."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
title: One-Off Promotion
technology: ansible
document_type: skill
status: reviewed
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-09-02"
depends_on_skills: "one-off-trial-scaffold, tool-capability-intake, tool-playbook-placement-advisor, homelab-ansible-first-entry, one-off-promotion-verify"
applies_to:
  - docs/one_off_tasks
  - docs/plans
  - ansible
related:
  - docs/one_off_tasks/README.md
  - docs/plans/README.md
  - docs/plans/2026-09-02--codex-multi-terminal-promotion/README.md
tags:
  - skill
  - one-off
  - stable
  - promotion
  - ansible
---

# Skill: One-Off Promotion

Promote a governed one-off trial into **idempotent Ansible** with a durable plan
packet. The live one-off folder is removed; archival copy lives only under the plan.

## When to use / not use

Use when the operator says **promote**, **make this Ansible**, or **stop one-off /
converge for real**.

Do **not** use when:

- the trial is still iterating — stay in `one-off-trial-scaffold`
- the outcome is **discard** — `one-off-discard-cleanup`
- verification-only after promotion landed — `one-off-promotion-verify`

## Inputs

| Input | Required |
| --- | --- |
| `one_off_slug` | yes — `docs/one_off_tasks/<slug>/` |
| `plan_slug` | yes — `docs/plans/YYYY-MM-DD--<slug>-promotion/` |
| `target_hosts` | yes — inventory hostnames |
| `capability_id` | yes — stable identifier for the promoted capability |

## Workflow

### Phase 0 — Stop one-off extension

Once promotion is approved:

- **Do not** add features to the live one-off tree
- **Do not** implement from any prior `backup/one-off-source/` (archival only)

### Phase 1 — Plan packet

Create `docs/plans/YYYY-MM-DD--<slug>-promotion/README.md` with:

| Section | Content |
| --- | --- |
| Frontmatter | `scope: implementation`, `depends_on_plans` if any |
| Capability Packet Boundary | owner roles, owned files, integration anchors |
| Apply / Verify / Undo / Change class | playbook commands, smoke checks, **real** undo per artifact (see Phase 3) |
| Disposition ledger | full one-off inventory with status per artifact (not a short map only) |
| Checklist | trackable rows with evidence column |

Follow `docs/plans/README.md` and diagram gate when architecture changes.

### Phase 2 — Archive (freeze, do not implement from)

```text
docs/plans/<plan>/backup/
  README.md              # ARCHIVAL — DO NOT USE FOR IMPLEMENTATION
  one-off-source/        # full copy of live one_off_tasks/<slug>/
```

`backup/README.md` must state agents must not copy or execute from this tree.

### Phase 3 — Ansible design

1. Run `homelab-ansible-first-entry` (`print_entry_doors.py`) before inventing structure.
2. Run `tool-capability-intake` / `tool-playbook-placement-advisor` per component.
3. Prefer **extend existing roles** over new ones when the promotion map says so:
   - shell drops → `common/shell_config` / `roles/*/files/bashrc.d/`
   - tool install → dedicated role (`fzf_tab_completion` pattern)
   - product config → owner role (`codex_homelab_profiles` pattern)
4. Wire `*_state: present` in **host_vars** for commissioned hosts; conservative `defaults/`.
5. Add playbook tags; preserve `present|absent` on roles **only where absent actually removes every owned artifact**.
6. **Undo contract:** document the real removal path for each owned file. Static
   `roles/*/files/bashrc.d/*.bash` copied by `common/shell_config` are **not**
   removed by role `absent` alone — use state-aware deploy from the owning role,
   extend `shell_config` with a manifest, or explicit absent tasks that delete
   host paths. Cross-check reference promotions against
   `docs/plans/2026-09-02--codex-multi-terminal-promotion/AI-CORRECTION-EVALUATION.md`.

### Phase 4 — Strip trial naming

Promoted artifacts drop `_one_off_tasks` suffixes. Update:

- bashrc.d basenames
- `~/bin` launcher names
- `~/.codex/*.config.toml` SSOT names per parent plan

### Phase 5 — Legacy host cleanup script

Add `scripts/uninstall_<slug>_one_off_legacy.sh` that:

- removes every `*_one_off_tasks` path the trial may have left on hosts
- is safe to re-run
- prints the converge playbook command for managed state

Reference: `scripts/uninstall_codex_multi_terminal_one_off_legacy.sh`

### Phase 6 — Remove live one-off folder

Delete `docs/one_off_tasks/<slug>/` from the repo after archive + Ansible land.

### Phase 7 — Execute and verify

Hand off to `one-off-promotion-verify` — **do not** call promotion done without
live apply + receipt.

## Disposition ledger (required)

Use statuses: `Promoted`, `Promoted with reshape`, `Retired and replaced`,
`Retired with no managed replacement`, `Open gap`.

See `references/promotion-map-template.md` — not a two-row shortcut map.

## Outputs

- Plan packet with `backup/one-off-source/`
- Ansible roles/tasks/playbooks/host_vars
- Legacy uninstall script
- Deleted live `docs/one_off_tasks/<slug>/`

## Validation

- [ ] Plan packet includes full disposition ledger covering every archived one-off path
- [ ] Apply command lists all required tags (`shell_config`, `bash_completion`, owning roles)
- [ ] Undo row names real removal mechanism per artifact class (not generic `absent` only)
- [ ] `backup/one-off-source/` frozen; live `docs/one_off_tasks/<slug>/` deleted

## Failure boundaries

- Stop if trial is still actively extending — return to `one-off-trial-scaffold`
- Stop if implementing from `backup/one-off-source/`
- Stop before execute-complete — hand off to `one-off-promotion-verify`

## Prohibited behavior

- Implementing from `backup/one-off-source/`
- Leaving live one-off folder after promotion
- Repo-only edits labeled execute-complete
- Checklist-only verification (use plan verification receipt)
- Keeping snowflake install scripts as the steady-state path
- Teaching that role `absent` alone removes static `bashrc.d` from `common/shell_config`

## Handoffs

| Phase | Skill |
| --- | --- |
| Trial still running | `one-off-trial-scaffold` |
| Live apply + receipt | `one-off-promotion-verify` |
| Plan lifecycle close | `complete-plan-lifecycle` |

## Progressive disclosure

- `references/sources-and-precedence.md`
- `references/related-artifacts.md`
- `references/promotion-map-template.md`
