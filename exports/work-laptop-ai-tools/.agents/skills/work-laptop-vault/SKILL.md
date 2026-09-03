---
name: work-laptop-vault
description: "Use when preparing or updating the work-laptop-ai-tools packet vault for MCP (and related) API keys: example file, key names, encrypt workflow, optional parent-to-packet transfer prep. Never commit live secrets. Do not enable MCP servers as a side effect."
---

# Skill: Work-laptop vault

Manage the packet’s **vault-ready** surface so secret-bearing MCP roles can be
commissioned later without inventing a new secret pattern.

## When to use / not use

Use when:

- adding vault key placeholders for an adopted MCP
- operator needs encrypt / env.d / wrapper orientation
- preparing a **transfer plan** for keys that exist in parent
  `vault/mac_dev.vault.yml` or `vault/shared.vault.yml` into packet
  `vault/shared.vault.yml`
- running `scripts/hydrate_vault_from_parent.py` when the user asks to copy
  parent values without exposing them in chat

Do not use when:

- committing or pasting live secrets into git-tracked files
- flipping MCP `*_state` to `present` unless the user explicitly commissions

## Inputs

- Packet `vault/README.md` and `vault/shared.vault.yml.example`
- Role `load_vault.yml` / defaults for exact `vault_*` key names
- Optional parent vault file path (read-only; never copy ciphertext blindly into git)

## Reach (allowed)

- Packet `vault/` (example + README tracked; `shared.vault.yml` gitignored)
- Parent vault paths for **operator-guided** transfer (read key *names* and document mapping; do not write parent secrets into the packet repo)
- host_vars overrides for `*_vault_file_path` → `{{ playbook_dir }}/vault/shared.vault.yml`

## Workflow

1. Confirm `.gitignore` ignores `vault/shared.vault.yml` and `vault/*.vault.yml` (keep example + README).
2. For each secret MCP, add the **exact** key name the role asserts (e.g.
   `vault_firecrawl_mcp_api_key`, `vault_shared_morph_api_key`,
   `vault_context7_mcp_api_key`, firebase `vault_firebase_mcp_*`) to
   `shared.vault.yml.example`.
3. Ensure adopt step set `*_vault_file_path` / wrapper / env paths for the packet.
4. Operator local steps (document; do not invent keys):
   - copy example → `shared.vault.yml`
   - fill values (optionally from parent vault on the operator machine)
   - `ansible-vault encrypt vault/shared.vault.yml`
5. **Hydrate from parent (when the user asks):** run
   `scripts/hydrate_vault_from_parent.py`. It writes an encrypted packet vault
   and copies matching parent values. Stdout is key **names** and presence
   only — do not `ansible-vault view` the result in this chat.
6. Remind: commission = vault filled + `*_state: present` + playbook with vault pass.

## Outputs

- Updated example + README if needed
- Transfer mapping table when requested
- No live secrets in git

## Validation

- Example keys match role `load_vault.yml`
- Real vault file remains untracked
- MCP states unchanged unless user commissioned

## Failure boundaries

- If parent vault is encrypted and password unavailable, stop at mapping table
- If key names differ between parent and packet roles, fix role/host_vars before transfer

## Prohibited behavior

- Committing decrypted secrets
- Embedding keys in mcp.json / Codex TOML
- Silently enabling MCP servers

## Progressive disclosure

- Packet `vault/README.md`
- `references/key-name-map.md`
- HRL slice + porting guides via `references/hrl-pointers.md`
- After vault ready + user commission: adopt skill already wired; flip state carefully
