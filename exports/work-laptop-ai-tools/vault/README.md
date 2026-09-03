# Vault (work-laptop packet)

This packet is **vault-ready** but does **not** ship live secrets.

## Layout

| Path | Purpose |
| --- | --- |
| `vault/README.md` | This file |
| `vault/shared.vault.yml.example` | Example keys for secret-bearing MCP roles |
| `vault/key-hydrate-map.yml` | Key **names** + parent source files (no values) |
| `vault/shared.vault.yml` | Operator-local Ansible Vault file (gitignored) |

## Hydrate from parent (this controller)

Creates an empty encrypted packet vault, then copies matching parent values
without printing them. Uses parent `.vault_pass` (same password for the
packet ciphertext).

From `dotfile-vnext`:

```bash
bin/codex-env python \
  exports/work-laptop-ai-tools/scripts/hydrate_vault_from_parent.py \
  --also-sibling
```

Stdout is names and status only (`COPIED` / `EMPTY_IN_PARENT` / `ABSENT_IN_PARENT`).

On the work laptop, decrypt with that same vault password:

```bash
ansible-playbook playbook.yaml -i inventory.yaml --ask-vault-pass
```

## Required before Morph / WarpGrep

Morph is **commissioned** (`morph_mcp_state: present`). Prefer hydrate above.
Manual fallback:

1. Copy `shared.vault.yml.example` → `shared.vault.yml`
2. Set `vault_shared_morph_api_key` to a real Morph key (not `REPLACE_ME`)
3. Encrypt: `ansible-vault encrypt vault/shared.vault.yml`
4. Run the packet playbook with `--ask-vault-pass` (or a vault password file)

Context7 and Firebase **install and wire without vault**. Optional Context7
quota key and Firebase service-account/token can be added to the same file
later.

## When enabling other secret-bearing MCP servers

1. Add the exact `vault_*` key names from role `load_vault.yml`
2. Flip matching `*_mcp_state` to `present` (skill `work-laptop-mcp-commission`)
3. Re-run with vault pass

## Env-file pattern (unchanged from dotfile-vnext)

Secret MCP roles render `0600` env files under:

```text
~/.config/work-laptop-ai-tools/mcp/env.d/<server>.env
```

Client config points at `bin/mcp-server-env-wrapper` with that env file as the
first argument. Tracked mcp.json / Codex TOML must not embed API keys.

Continue GUI PATH often lacks nvm. This packet uses `bin/work-laptop-nvm-exec`
in Continue MCP entries so `morph-mcp` / `npx` / `context7-mcp` resolve.

## Related library docs

- HRL: `implementation-guides/mcp/work-laptop-ai-tools-mcp-slice.md`
- HRL: `implementation-guides/mcp/porting-mcp-servers-between-projects.md`
