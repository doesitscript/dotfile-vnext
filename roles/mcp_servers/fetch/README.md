# Fetch MCP Server

Lightweight webpage and API fetching for simple retrieval fallback.

## Upstream

- **Docs:** https://github.com/zcaceres/fetch-mcp
- **Repo:** https://github.com/zcaceres/fetch-mcp
- **npm:** `mcp-fetch-server`

## Classification

| Attribute | Value |
|---|---|
| Runtime | Node.js (npm) |
| Install Method | npm global |
| Interaction Model | launcher |
| Supported Targets | cursor, vscode, codex |
| Default Targets | cursor, codex on `mac-dev` |
| Verify Mode | tool_listing |

## Apply / Verify / Undo / Change Class

**Apply:**

```bash
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags fetch
```

**Verify:**

1. Check npm install: `which mcp-fetch-server`
2. Check Cursor config: `.cursor/mcp.json` contains `fetch`
3. Check Codex config: `.codex/config.toml` contains `[mcp_servers.fetch]`

**Undo:**

```bash
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags fetch -e fetch_mcp_state=absent
```

**Change Class:** Idempotent controller-local configuration management
