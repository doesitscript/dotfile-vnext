---
name: work-laptop-day2-apply
description: "Use when applying or verifying the work-laptop-ai-tools sibling on the corporate Mac after a git pull: playbook with --skip-tags hosts_file, vault_pass, Continue/Cline/cx-* checks. Do not invent ad-hoc SSH/scp applies. Do not use for parent packet design edits (edit packet then work-laptop-packet-ops)."
---

# Skill: Work-laptop day-2 apply

Canonical **on-laptop** loop after parent/sibling changes land on GitHub.
Design authority stays the parent packet; this skill runs against the sibling
checkout on the work Mac (`a805120` / `MLLXLJJ2XVFJ`).

## When to use / not use

Use when:

- user asks to pull + apply / converge the work laptop
- Continue/Cline/`cx-*` look wrong after a packet push
- diagnosing playbook failures on the laptop (hosts_file sudo, vault, npm)

Do not use when:

- editing design in `dotfile-vnext/exports/work-laptop-ai-tools/` (then
  `work-laptop-packet-ops` sync + push; laptop pull is separate)
- hydrating vault on the **home** Mac (`work-laptop-vault-hydrate`)
- first bootstrap (use packet `bootstrap/` scripts)

## Authority

| Layer | Path |
| --- | --- |
| Design | parent `exports/work-laptop-ai-tools/` |
| Runtime checkout | `~/Documents/develop/work-laptop-ai-tools` (sibling) |
| Vault on laptop | sibling `vault/shared.vault.yml` + `vault_pass.sh` → `.vault_pass` |

## Workflow (on the work laptop)

```bash
cd ~/Documents/develop/work-laptop-ai-tools
git pull

# Day-to-day: skip hosts_file (needs --ask-become-pass; laptop hosts already set)
.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml --skip-tags hosts_file

# Hosts refresh only when catalog names change:
# .venv/bin/ansible-playbook playbook.yaml -i inventory.yaml --tags hosts_file --ask-become-pass
```

Vault: `ansible.cfg` → `vault_pass.sh` → `.vault_pass` (same password as parent).
Do **not** pass `--ask-vault-pass` unless that chain is broken.

After apply:

1. New shell (or `source ~/.bashrc.d/codex-multi-terminal.bash`)
2. Run verify block below
3. Hand off IDE details to `work-laptop-ide-clients` if Continue/Cline still empty

## Verify (required before claiming success)

```bash
# Continue — must show models: and a non-placeholder apiKey
grep -E '^(name:|models:)|apiKey:' ~/.continue/config.yaml | head -20

# Cline — OpenAI Compatible → LiteLLM
test -s ~/.cline/data/settings/providers.json && \
  grep -E 'openai-compatible|baseUrl|model' ~/.cline/data/settings/providers.json | head -20

# cx-* roots (Documents/develop, not ~/develop/dotfile-vnext)
grep -E '_CODEX_MT_REPO_' ~/.bashrc.d/codex-multi-terminal.bash
type cx-desktop

# Codex MCP still on user home
test -f ~/.codex/config.toml
```

Do not claim pass without this turn’s command output.

## Common failures

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| Continue/Cline UI empty | LiteLLM key still placeholder / vault missing | `work-laptop-vault` on home → drop ciphertext vault → re-apply; deviation `litellm-key-ide-clients` |
| `continue_ide` / `cline_ide` assert fail | `*_require_api_key: true` and no vault key | Hydrate `vault_k3s_litellm_gateway_master_key` |
| `cd: …/develop/dotfile-vnext: No such file` | Stale `cx-*` bashrc | Re-apply profiles; deviation `documents-develop-paths` |
| hosts_file / become fail | sudo password | `--skip-tags hosts_file`; deviation `hosts-file-skip-day2` |
| `codex` missing after npm | corporate `~/.npmrc` prefix | Codex role prefix repair; deviation `npm-global-prefix` |

Before inventing a new workaround, read `deviations/register.yaml` — the class
of problem may already be accepted and documented.

## Prohibited behavior

- Treating sibling as design authority for packet YAML edits
- Committing `vault/shared.vault.yml`
- Auto-decrypting vault onto network shares
- Skipping verify greps when claiming Continue/Cline/`cx-*` fixed

## Progressive disclosure

- IDE clients: `work-laptop-ide-clients`
- Parent sync: `work-laptop-packet-ops`
- Vault: `work-laptop-vault`
- Inbound laptop feedback / debt: `work-laptop-improvement-review`
- Deviation manifest: `deviations/README.md`
- Packet `README.md` day-2 notes
