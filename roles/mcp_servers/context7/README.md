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

Store the Context7 API key in `vault/mac_dev.vault.yml` as
`vault_context7_mcp_api_key`.

The role renders the key into a local `0600` env file and points tracked client
config at `bin/mcp-server-env-wrapper`, so the API key is not written into
`.cursor/mcp.json` or `.codex/config.toml`.

## Apply / Verify / Undo / Change Class

**Apply:**

```bash
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags context7
```

**Verify:**

1. Check npm install: `which context7-mcp`
2. Check Cursor config: `.cursor/mcp.json` contains `context7` without the API key
3. Check Codex config: `.codex/config.toml` contains `[mcp_servers.context7]`
4. Check local env file mode: `stat -f '%Lp %N' ~/.config/dotfile-vnext/mcp/env.d/context7.env`

**Undo:**

```bash
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags context7 -e context7_mcp_state=absent
```

**Change Class:** Idempotent controller-local configuration management
