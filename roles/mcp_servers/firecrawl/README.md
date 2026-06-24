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

On macOS, generate the inline vault block and copy it to the clipboard:

```bash
bin/codex-env ansible-vault encrypt_string --stdin-name vault_firecrawl_mcp_api_key | pbcopy
```

Paste the raw API key in the terminal, press `Ctrl-D`, then replace this line in
`vault/mac_dev.vault.yml`:

```yaml
vault_firecrawl_mcp_api_key: ""
```

with the encrypted block from the clipboard:

```yaml
vault_firecrawl_mcp_api_key: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          ...
```

This role loads that file through `include_vars` with `name: vault_vars` and maps the
secret into a local runtime env file:

```text
~/.config/dotfile-vnext/mcp/env.d/firecrawl.env
```

The env file is rendered with mode `0600`. Tracked client config uses
`bin/mcp-server-env-wrapper` and does not store the API key in `.cursor/mcp.json`
or `.codex/config.toml`.

## Variables

| Variable | Default | Description |
|---|---|---|
| `firecrawl_mcp_state` | `present` | Lifecycle state: `present` or `absent` |
| `firecrawl_mcp_targets` | `['cursor']` | Target client configs to manage |
| `firecrawl_mcp_package_name` | `firecrawl-mcp` | npm package to install |
| `firecrawl_mcp_api_key` | from vault | Firecrawl API key |
| `firecrawl_mcp_api_url` | `""` | Optional self-hosted API URL |
| `firecrawl_mcp_env_file_path` | `~/.config/dotfile-vnext/mcp/env.d/firecrawl.env` | Local secret env file |

## Apply / Verify / Undo / Change Class

**Apply:**

```bash
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags firecrawl
```

**Verify:**

1. Check npm install: `which firecrawl-mcp`
2. Check Cursor config: `.cursor/mcp.json` contains a `firecrawl` entry that points at `bin/mcp-server-env-wrapper`
3. Check Codex config: `.codex/config.toml` contains `[mcp_servers.firecrawl]`
4. Check secret hygiene: neither tracked config file contains `FIRECRAWL_API_KEY`
5. Check env file mode: `stat -f '%Lp %N' ~/.config/dotfile-vnext/mcp/env.d/firecrawl.env`
6. Restart Cursor/Codex and confirm Firecrawl tools appear in the MCP tool list

**Undo:**

```bash
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags firecrawl -e firecrawl_mcp_state=absent
```

**Change Class:** Idempotent configuration management
