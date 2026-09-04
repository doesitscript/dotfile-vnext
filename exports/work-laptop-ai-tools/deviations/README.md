# Accepted deviations (work-laptop slice)

This directory is the **manifest of accepted configuration differences** between
the work laptop runtime and a “clean” home-lab Mac path. Deviations are not
failures — the workflow accepts them — but each one must be **captured** so we:

1. **Re-apply** the accommodation after reinstall / wipe / role re-run
2. **Recognize** the same class of problem on the next inbound laptop fix
3. **Generalize** the workaround to similar tools in the same `behavior_group`

Authority: edit under parent packet `exports/work-laptop-ai-tools/deviations/`,
then `work-laptop-packet-ops` sync. Do not treat sibling-only edits as lasting
truth.

## Files

| Path | Role |
| --- | --- |
| `register.yaml` | Index of all deviations (ids, groups, status, pointers) |
| `entries/<id>.md` | Full intake: trigger, evidence, accommodation, re-apply, generalize |
| `_entry-template.md` | Copy when registering a new deviation |

## When to add an entry

Inbound feedback from the work laptop (push, PR, merge of laptop commits,
chat “here’s what failed”) that required a **config or role change** because
the laptop differs from the design defaults — even if the fix is temporary.

Skill: `work-laptop-improvement-review` (inbound deviation intake section).

## Status values

| Status | Meaning |
| --- | --- |
| `accepted` | Live accommodation; must re-apply and watch siblings in group |
| `promoted` | Encoded in role/host_vars/skill; entry kept for history + generalize |
| `obsolete` | No longer applies; keep for archaeology |

## Behavior groups (examples)

Reuse these ids so generalization is searchable:

- `npm-global-install` — corporate `~/.npmrc` `prefix=`, nvm vs prefix bin
- `repo-layout-paths` — `Documents/develop` vs `~/develop`
- `sudo-hosts-file` — day-2 skip vs bootstrap hosts
- `litellm-client-keys` — Continue/Cline/Zed empty UI without vault key
- `homebrew-idempotence` — formula already present / link / auto-update noise
- `vault-password-ux` — vault_pass.sh / no `--ask-vault-pass`
- `vscode-extension-path` — GUI PATH lacks nvm
