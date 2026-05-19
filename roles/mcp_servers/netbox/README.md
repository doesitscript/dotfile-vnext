# NetBox MCP Server

Read-only natural language query interface to NetBox infrastructure data.

## Upstream

- **Docs:** https://netboxlabs.com/docs/mcp/
- **Repo:** https://github.com/netboxlabs/netbox-mcp-server

## Classification

| Attribute | Value |
|---|---|
| Runtime | Python (uv) |
| Install Method | git-clone |
| Interaction Model | launcher |
| Supported Targets | cursor, codex |
| Default Targets | cursor, codex |
| Verify Mode | tool_listing |

## What It Does

The NetBox MCP Server enables AI agents and LLMs to interact with NetBox infrastructure data using natural language queries. It exposes four read-only MCP tools:

- `netbox_get_objects` - Retrieve NetBox objects by type with filtering and pagination
- `netbox_get_object_by_id` - Get detailed information about a specific object
- `netbox_search_objects` - Search across multiple object types
- `netbox_get_changelogs` - Retrieve change history and audit trail

## Requirements

- **uv** must be installed on the controller: `curl -LsSf https://astral.sh/uv/install.sh | sh`
- **NetBox instance** must be running and accessible from the controller
- **Read-only API token** must exist in the project vault as `vault_netbox_api_token`

## Variables

| Variable | Default | Description |
|---|---|---|
| `netbox_mcp_state` | `present` | Lifecycle state: `present` or `absent` |
| `netbox_mcp_targets` | `['cursor', 'codex']` | Target client configs to manage |
| `netbox_mcp_install_path` | `~/.local/lib/netbox-mcp-server` | Clone destination |
| `netbox_mcp_url` | `{{ ipam_netbox_api_url }}` | NetBox API URL |
| `netbox_mcp_token` | `{{ vault_vars.vault_netbox_api_token }}` | NetBox API token (from vault) |
| `netbox_mcp_verify_ssl` | `false` | SSL verification (false for local HTTP) |

## Target Model

**Cursor/Codex** (default): Manages both `.cursor/mcp.json` and `.codex/config.toml`

**Tags:**
- `netbox` - Apply the entire role
- `mcp_target_cursor` - Configure only Cursor
- `mcp_target_codex` - Configure only Codex
- `mcp_target_openapi` - Fail-fast stub (not yet implemented)

## Apply / Verify / Undo / Change Class

**Apply:**
```bash
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags netbox
```

**Verify:**
1. Check clone: `ls ~/.local/lib/netbox-mcp-server/`
2. Check Cursor config: `cat .cursor/mcp.json` - should have `netbox` entry
3. Check Codex config: `cat .codex/config.toml` - should have `[mcp_servers.netbox]` block
4. Test in Cursor: Verify netbox MCP tools appear in tool listing
5. Test query: Ask Cursor to list NetBox devices

**Undo:**
```bash
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags netbox -e netbox_mcp_state=absent
```

**Change Class:** Idempotent configuration management

## Integration Notes

- Reuses `ipam_netbox_api_url` from the `ipam_netbox` role
- Complements `netbox.netbox` Ansible collection (write/seed) with MCP read queries
- Enables knowledge gate pattern: query NetBox via MCP before Ansible changes
- Read-only by design - never modifies NetBox data
