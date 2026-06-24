# Firecrawl MCP Server

Web scraping and crawling MCP tools for Cursor and other repo-local MCP clients.

## Upstream

- **Docs:** https://github.com/firecrawl/firecrawl-mcp-server
- **Repo:** https://github.com/firecrawl/firecrawl-mcp-server
- **API keys:** https://www.firecrawl.dev/app/api-keys

## Classification

| Attribute | Value |
|---|---|
| Runtime | Node.js (npm) |
| Install Method | npm global |
| Interaction Model | launcher |
| Supported Targets | cursor, vscode, codex |
| Default Targets | cursor |
| Verify Mode | tool_listing |

## Vault

Store the Firecrawl API key in `vault/mac_dev.vault.yml` as `vault_firecrawl_mcp_api_key`.

This role loads that file through `include_vars` with `name: vault_vars` and maps the
secret into `FIRECRAWL_API_KEY` for generated MCP client config.

## Variables

| Variable | Default | Description |
|---|---|---|
| `firecrawl_mcp_state` | `present` | Lifecycle state: `present` or `absent` |
| `firecrawl_mcp_targets` | `['cursor']` | Target client configs to manage |
| `firecrawl_mcp_package_name` | `firecrawl-mcp` | npm package to install |
| `firecrawl_mcp_api_key` | from vault | Firecrawl API key |
| `firecrawl_mcp_api_url` | `""` | Optional self-hosted API URL |

## Apply / Verify / Undo / Change Class

**Apply:**

```bash
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags firecrawl
```

**Verify:**

1. Check npm install: `which firecrawl-mcp`
2. Check Cursor config: `.cursor/mcp.json` contains a `firecrawl` entry with `FIRECRAWL_API_KEY`
3. Restart Cursor and confirm Firecrawl tools appear in the MCP tool list

**Undo:**

```bash
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags firecrawl -e firecrawl_mcp_state=absent
```

**Change Class:** Idempotent configuration management

## Ingest API Key

See role README section above and the vault header in `vault/mac_dev.vault.yml`.

Tracked in repo structure only until first live apply on mac-dev.
