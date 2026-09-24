---
name: work-laptop-day2-apply
description: "Use when applying or verifying the work-laptop-ai-tools sibling on the corporate Mac after a git pull: open scripts/recent_and_next.md for full or grouped capability updates (default ai_tools), or recent_10/recent_15 windows. Do not invent ad-hoc SSH/scp applies. Do not use for parent packet design edits (edit packet then work-laptop-packet-ops)."
---

# Skill: Work-laptop day-2 apply

Canonical **on-laptop** loop after parent/sibling changes land on GitHub.
Design authority stays the parent packet; this skill runs against the sibling
checkout on the work Mac (`a805120` / `MLLXLJJ2XVFJ`).

## Default command card

After `git pull`, open **`scripts/recent_and_next.md`**. That file is refreshed
on every upstream → sibling sync and is the default place for:

- full day-2 update (`--skip-tags hosts_file`)
- grouped capability updates (`ai_tools`, `ai_clients`, `model_runtime`, `mcp`)
- recent-change windows (`recent_10`, `recent_15`)

Do not invent alternate apply command lists when that card is present.

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
| Default apply commands | sibling `scripts/recent_and_next.md` |
| Vault on laptop | sibling `vault/shared.vault.yml` + `vault_pass.sh` → `.vault_pass` |

## Workflow (on the work laptop)

```bash
cd ~/Documents/develop/work-laptop-ai-tools
git pull --ff-only
# Then run the matching block from scripts/recent_and_next.md
# (full, grouped capability tag, or recent_10 / recent_15).
```

Default AI refresh when unsure which group changed:

```bash
.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml \
  --skip-tags hosts_file --tags ai_tools --check --diff
.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml \
  --skip-tags hosts_file --tags ai_tools
```

Hosts refresh only when catalog names change:

```bash
# .venv/bin/ansible-playbook playbook.yaml -i inventory.yaml --tags hosts_file --ask-become-pass
```

Vault: `ansible.cfg` → `vault_pass.sh` → `.vault_pass` (same password as parent).
Do **not** pass `--ask-vault-pass` unless that chain is broken.

After apply:

1. New shell (or `source ~/.bashrc.d/codex-multi-terminal.bash`)
2. Run verify block below
3. Hand off IDE details to `work-laptop-ide-clients` if Continue/Cline still empty

Upstream sync keeps `scripts/recent_and_next.md` current; do not replace it
with a one-off note unless the user asks for a temporary operator card. After
upstream sync/push, this skill does not claim the laptop is updated until the
work Mac pulls and applies.

## Verify (required before claiming success)

```bash
# Continue — must show models: and a non-placeholder apiKey
grep -E '^(name:|models:)|apiKey:' ~/.continue/config.yaml | head -20

# Cline — OpenAI Compatible → LiteLLM (+ model catalog)
test -s ~/.cline/data/settings/providers.json && \
  test -s ~/.cline/data/settings/models.json && \
  grep -E 'openai-compatible|baseUrl|model' ~/.cline/data/settings/providers.json | head -20

# Kilo — agent→model map in kilo.jsonc
test -s ~/.config/kilo/kilo.jsonc && \
  grep -E '"model"|"code"|"explore"|"plan"' ~/.config/kilo/kilo.jsonc | head -30

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
- Recent-window check: `scripts/check_playbook_recent_window.py`
