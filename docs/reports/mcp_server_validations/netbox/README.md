# NetBox MCP Server Validation Report

This validation report documents the installation, configuration, and runtime verification of the NetBox MCP Server.

## Validation Date

Placeholder - validation pending first run

## Environment

- **Platform:** macOS (Darwin)
- **Runtime:** Python via uv
- **Install Method:** git clone from GitHub
- **NetBox Instance:** Local (HTTP, no SSL)
- **Targets:** Cursor, Codex

## Validation Checklist

### 1. Installation Surface

- [ ] Check `uv` is available: `which uv`
- [ ] Clone repository: `git clone https://github.com/netboxlabs/netbox-mcp-server.git ~/.local/lib/netbox-mcp-server`
- [ ] Verify clone: `ls ~/.local/lib/netbox-mcp-server/`
- [ ] Run `uv sync` in cloned directory
- [ ] Verify dependencies: `ls ~/.local/lib/netbox-mcp-server/.venv/`
- [ ] Smoke test: `cd ~/.local/lib/netbox-mcp-server && uv run netbox-mcp-server --help`

**Expected Result:** Help output showing available options

### 2. Config Merge Behavior

#### Cursor Target

- [ ] Run role: `ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags netbox`
- [ ] Verify `.cursor/mcp.json` exists
- [ ] Verify `netbox` entry in `mcpServers` section
- [ ] Verify entry contains:
  - `command: "uv"`
  - `args: ["--directory", "/Users/joshc/.local/lib/netbox-mcp-server", "run", "netbox-mcp-server"]`
  - `env.NETBOX_URL`
  - `env.NETBOX_TOKEN`
  - `env.VERIFY_SSL`
  - `env._MCP_ANSIBLE_ROLE_PATH`

#### Codex Target

- [ ] Verify `.codex/config.toml` exists
- [ ] Verify `[mcp_servers.netbox]` block exists
- [ ] Verify block contains command, args, and env subsection
- [ ] Verify Ansible-managed block markers present

### 3. Tool Surface

After Cursor restart with updated config:

- [ ] Open Cursor
- [ ] Check MCP tools are available
- [ ] Verify four NetBox tools appear:
  - `netbox_get_objects`
  - `netbox_get_object_by_id`
  - `netbox_search_objects`
  - `netbox_get_changelogs`

### 4. Runtime Verification

**Prerequisites:**
- NetBox instance must be running: `http://192.168.50.158:8000`
- API token must be valid in vault

**Test Queries:**

- [ ] Query devices: "List all NetBox devices"
- [ ] Query specific object: "Get details for device server-225"
- [ ] Search: "Search NetBox for 'ubuntu'"
- [ ] Changelog: "Show recent NetBox changes"

**Expected Behavior:**
- Queries return real NetBox data
- Responses include device names, IPs, sites, roles
- No authentication errors
- No SSL verification errors (local HTTP instance)

### 5. Notable Side Effects

- **Network dependency:** Requires NetBox instance to be accessible
- **Vault dependency:** Reads API token from project vault
- **No browser launch:** Pure CLI/MCP interaction
- **No editor handoff:** Launcher model, not interactive

### 6. Absent State Verification

- [ ] Run absent: `ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags netbox -e netbox_mcp_state=absent`
- [ ] Verify repository removed: `ls ~/.local/lib/netbox-mcp-server/` should fail
- [ ] Verify Cursor entry removed: `netbox` key absent from `.cursor/mcp.json`
- [ ] Verify Codex block removed: `[mcp_servers.netbox]` absent from `.codex/config.toml`
- [ ] Verify other MCP servers preserved

## Known Issues

None identified at planning stage.

## Next Steps

1. Ensure `uv` is installed on the controller
2. Ensure NetBox instance is running
3. Verify `vault_netbox_api_token` exists in `vault.yml`
4. Run initial installation
5. Execute validation checklist
6. Update this report with actual results

## References

- Upstream docs: https://netboxlabs.com/docs/mcp/
- GitHub repo: https://github.com/netboxlabs/netbox-mcp-server
- Role README: `roles/mcp_servers/netbox/README.md`
- Plan: `.cursor/plans/netbox_mcp_server_integration_*.plan.md`
