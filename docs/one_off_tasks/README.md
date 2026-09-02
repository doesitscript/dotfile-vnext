# One-off tasks (`docs/one_off_tasks/`)

**Authority:** temporary, discardable, low-trust work. Not steady-state automation.

## Purpose

This folder holds **snowflake experiments** — work that is:

- intentionally temporary
- try-before-commit on a live machine
- allowed to bypass normal Ansible / plan gates **only while it stays here**
- discardable without regret if it fails

**Default value:** very low. Agents and humans should assume nothing here is production truth.

## What belongs here

| In scope | Out of scope |
| --- | --- |
| Trial scripts with explicit install/uninstall | Normal roles, playbooks, inventory |
| Operator notes for semi-manual probes | Framework rules, runbooks, plan packets |
| Short-lived troubleshooting write-ups | Anything that should survive the next converge |

## Governance rules (mandatory)

### 1. Package layout

Each trial lives in its own subfolder:

```text
docs/one_off_tasks/<short-slug>/
  README.md              # what, why, how to try, how to remove
  deploy/                # files copied to the laptop (optional)
  evolution.md           # now → promote or discard (optional)
```

### 2. Naming on the laptop

Every deployed path, filename, and shell function introduced by a one-off **must** include a
discriminator until promoted, e.g. `*_one_off_tasks` or `codex-homelab_one_off_tasks`.

### 3. Header comment on every deployed file

First lines of every file installed on a managed or operator host:

```bash
# ONE-OFF TRIAL (non-permanent) — source: docs/one_off_tasks/<slug>/deploy/...
# Discardable. Overwritable. Remove via <slug>/deploy/uninstall_*.sh or promotion plan.
```

### 4. No silent persistence

- Do **not** fold one-off behavior into `roles/` without a **plan packet** under `docs/plans/`.
- Do **not** leave one-off installers as the long-term path after the user approves promotion.

### 5. End states (operator decides)

| Outcome | Action |
| --- | --- |
| **Promote** | Plan under `docs/plans/`, implement via Ansible roles/playbooks, **remove** live one-off folder, keep **backup only** inside the plan packet |
| **Discard** | Run uninstall script, delete subfolder, remove host traces |

Promotion means: evaluate piece-by-piece, match existing roles (`shell_config`, `bash_completion`,
`codex_homelab_profiles`, tool install roles), drop `_one_off_tasks` suffixes, converge with
`ansible-playbook`, update docs — **no more wild-west install scripts**.

## Agent instructions

1. Read this file before creating or extending anything under `one_off_tasks/`.
2. Never treat content here as reusable framework guidance.
3. When the user approves promotion, **stop** extending the one-off tree; open or continue the
   promotion plan and implement in `roles/` / `playbooks/`.
4. **Never** implement from `docs/plans/*/backup/one-off-source/` — that tree is archival only.

## Related project surfaces

- Plan promotion rules: `docs/plans/README.md`
- Partner process (Apply / Verify / Undo): `docs/codex_framework/partner_process.md`
- Shell drop pattern: `roles/SHELL-CONFIG-PATTERN.md`
- Promoted example: `docs/plans/2026-09-02--codex-multi-terminal-promotion/`
- **Draft skills** (agent workflows — `status: draft`):
  - `one-off-trial-scaffold` — start a compliant trial
  - `one-off-promotion` — promote to Ansible + plan packet
  - `one-off-discard-cleanup` — discard and remove traces
  - `one-off-promotion-verify` — execute-complete verification

Multi-agent implementer family (evaluator loops): `skills/multi-agent/README.md`

See `skills/one-off/README.md` for the one-off skill family index.

## Subfolders (active)

- **[on-offs/](./on-offs/)** — troubleshooting timelines and tool matrices (not Codex trial).
