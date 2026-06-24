# Context7 MCP Server

Up-to-date library, API, SDK, and product documentation for MCP clients.

## Upstream

- **Docs:** https://context7.com/docs/resources/all-clients
- **Repo:** https://github.com/upstash/context7
- **npm:** `@upstash/context7-mcp`

## Classification

| Attribute | Value |
|---|---|
| Runtime | Node.js (npm) |
| Install Method | npm global |
| Interaction Model | launcher |
| Supported Targets | cursor, vscode, codex |
| Default Targets | cursor, codex on `mac-dev` |
| Verify Mode | tool_listing |

## Vault

Context7 works without an API key for basic usage. Store an optional Context7
API key in `vault/mac_dev.vault.yml` as `vault_context7_mcp_api_key` when higher
rate limits are needed.

On macOS, generate the inline vault block and copy it to the clipboard:

```bash
bin/codex-env ansible-vault encrypt_string --stdin-name vault_context7_mcp_api_key | pbcopy
```

Paste the raw API key in the terminal, press `Ctrl-D`, then replace this line in
`vault/mac_dev.vault.yml`:

```yaml
vault_context7_mcp_api_key: ""
```

with the encrypted block from the clipboard:

```yaml
vault_context7_mcp_api_key: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          ...
```

When the vault value is non-empty, the role renders the key into a local `0600`
env file and points tracked client config at `bin/mcp-server-env-wrapper`, so
the API key is not written into `.cursor/mcp.json` or `.codex/config.toml`.
When the vault value is empty, the role configures the local `context7-mcp`
binary directly.

## Apply / Verify / Undo / Change Class

**Apply:**

```bash
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags context7
```

**Verify:**

1. Check npm install: `which context7-mcp`
2. Check Cursor config: `.cursor/mcp.json` contains `context7` without the API key
3. Check Codex config: `.codex/config.toml` contains `[mcp_servers.context7]`
4. If an API key is configured, check local env file mode:
   `stat -f '%Lp %N' ~/.config/dotfile-vnext/mcp/env.d/context7.env`

**Undo:**

```bash
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags context7 -e context7_mcp_state=absent
```

**Change Class:** Idempotent controller-local configuration management
