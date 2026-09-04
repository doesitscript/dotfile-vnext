---
name: work-laptop-vault
description: "Use when the work-laptop-ai-tools packet needs Ansible vault work: init, hydrate from parent, or names-only status. Always run packet scripts (never ansible-vault view in chat). Do not commit live secrets or enable MCP as a side effect."
---

# Skill: Work-laptop vault

Default vault skill for this slice. Routes to packet scripts under `scripts/`
and the focused skills `work-laptop-vault-hydrate` / `work-laptop-vault-status`.

## When to use / not use

Use when the user mentions packet vault, API keys, Morph vault gate, LiteLLM
key for Continue/Cline/Zed, empty Continue/Cline UI after apply, or parent→packet
secret copy.

Do not use to `ansible-vault view` / `decrypt` to the terminal in this chat.
Do not commit `vault/shared.vault.yml`.

## LiteLLM key (Continue / Cline / Zed)

`vault_k3s_litellm_gateway_master_key` must be nonempty in the packet vault
before `continue_ide` / `cline_ide` present runs succeed
(`*_require_api_key: true`). Symptom of missing key: Continue/Cline UI looks
empty. After hydrate on the home Mac, get ciphertext onto the laptop (share
drop or similar — never auto-decrypt onto shares), then
`work-laptop-day2-apply`. IDE details: `work-laptop-ide-clients`.

## Scripts (required)

From **dotfile-vnext**:

```bash
bin/codex-env python \
  exports/work-laptop-ai-tools/scripts/work_laptop_vault.py hydrate --also-sibling
bin/codex-env python \
  exports/work-laptop-ai-tools/scripts/work_laptop_vault.py status
bin/codex-env python \
  exports/work-laptop-ai-tools/scripts/work_laptop_vault.py init-empty
```

`hydrate` always calls `scripts/hydrate_vault_from_parent.py`.
`status` always calls `scripts/vault_status.py`.

## Workflow

1. Map keys live in `vault/key-hydrate-map.yml` (names only). Keep
   `vault/shared.vault.yml.example` in sync.
2. If the user wants parent values copied: skill `work-laptop-vault-hydrate`.
3. If they want to know what is filled: skill `work-laptop-vault-status`.
4. If they want a blank encrypted schema: `work_laptop_vault.py init-empty`.
5. Sync sibling with `work-laptop-packet-ops` after tracked vault files change
   (README, map, example, scripts). Encrypted dest stays gitignored.

## Prohibited behavior

- Printing or pasting secret values
- `ansible-vault view` / `decrypt` as a chat-visible command
- Force-adding gitignored `vault/shared.vault.yml`

## Progressive disclosure

- `work-laptop-vault-hydrate`
- `work-laptop-vault-status`
- `work-laptop-ide-clients` (Continue/Cline empty UI)
- `work-laptop-day2-apply` (laptop converge after vault drop)
- `vault/README.md`
- `references/key-name-map.md`
