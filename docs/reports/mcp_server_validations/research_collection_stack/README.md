# MCP Research Collection Stack Validation

Validated: 2026-06-24  
Host: `mac-dev`  
Playbook: `playbooks/mac/mcp_servers.yaml`

## Summary

The MCP Research Collection Stack validates and applies successfully on
`mac-dev`.

| Server | Status | Evidence |
|---|---|---|
| Context7 | pass | Applied to Cursor and Codex with wrapper/env-file mode; idempotence rerun reported `changed=0`. |
| Firecrawl | pass | Applied to Cursor and Codex with wrapper/env-file mode; idempotence rerun reported `changed=0`. |
| Playwright | pass | Applied to Cursor and Codex; idempotence rerun reported `changed=0`. |
| Fetch | pass | Applied to Cursor and Codex; idempotence rerun reported `changed=0`. |

## Commands

```bash
bin/codex-env ansible-playbook -i inventory/inventory.yaml playbooks/mac/mcp_servers.yaml --limit mac-dev --syntax-check
bin/codex-env ansible-lint roles/mcp_servers/firecrawl roles/mcp_servers/context7 roles/mcp_servers/playwright roles/mcp_servers/fetch
bin/codex-env ansible-lint playbooks/mac/mcp_servers.yaml roles/mcp_servers/firecrawl roles/mcp_servers/context7 roles/mcp_servers/playwright roles/mcp_servers/fetch --exclude roles/common/node --exclude roles/mcp_servers/netbox
bin/codex-env ansible-playbook -i inventory/inventory.yaml playbooks/mac/mcp_servers.yaml --limit mac-dev --list-tasks --tags context7,firecrawl,playwright,fetch
bin/codex-env ansible-playbook -i inventory/inventory.yaml playbooks/mac/mcp_servers.yaml --limit mac-dev --tags context7,firecrawl,playwright,fetch
bin/codex-env ansible-playbook -i inventory/inventory.yaml playbooks/mac/mcp_servers.yaml --limit mac-dev --tags context7
bin/codex-env ansible-playbook -i inventory/inventory.yaml playbooks/mac/mcp_servers.yaml --limit mac-dev --tags context7,firecrawl
bin/codex-env ansible-playbook -i inventory/inventory.yaml playbooks/mac/mcp_servers.yaml --limit mac-dev --tags context7,firecrawl
bin/codex-env ansible-playbook -i inventory/inventory.yaml playbooks/mac/mcp_servers.yaml --limit mac-dev --tags playwright,fetch
bin/codex-env ansible-playbook -i inventory/inventory.yaml playbooks/mac/mcp_servers.yaml --limit mac-dev --tags playwright,fetch
```

## Results

| Check | Result |
|---|---|
| Syntax check | pass |
| Lint, changed MCP roles | pass; production profile, 0 failures |
| Lint, changed playbook plus MCP roles | pass with pre-existing dependency exclusions for `roles/common/node` and `roles/mcp_servers/netbox`; production profile, 0 failures |
| Task preview | pass; listed Context7, Firecrawl, Playwright, and Fetch tasks for `mac-dev` |
| Vault key decrypt check | pass; Ansible reports nonzero lengths for `vault_context7_mcp_api_key` and `vault_firecrawl_mcp_api_key` |
| Context7/Firecrawl apply | pass; recap `changed=8`, `failed=0` |
| Context7/Firecrawl idempotence | pass; recap `changed=0`, `failed=0` |
| Playwright/Fetch apply | pass; recap `changed=6`, `failed=0` |
| Playwright/Fetch idempotence | pass; recap `changed=0`, `failed=0` |
| Cursor config keys | pass; `context7`, `firecrawl`, `playwright`, and `fetch` are present |
| Codex config keys | pass; `[mcp_servers.context7]`, `[mcp_servers.firecrawl]`, `[mcp_servers.playwright]`, and `[mcp_servers.fetch]` are present |
| Secret scan | pass for tracked client config; no raw key prefixes, secret env names, or vault key names found |
| Secret env files | pass; Context7 and Firecrawl env files exist with mode `0600` |

## Expected Non-Issues

| Observation | Status |
|---|---|
| `.vscode/mcp.json` only contains `drawio` | Expected. The `mac-dev` commissioned targets for this stack are Cursor and Codex only. Add `vscode` to the four `*_mcp_targets` lists or run with `mcp_target_vscode` to manage VS Code. |
| Cursor Settings or a chat session does not immediately show new MCP tools | Expected after config changes. Reload/restart the client or refresh the MCP server list. Already-running chat sessions may not gain newly configured tools retroactively. |
| Context7 and Firecrawl entries use `bin/mcp-server-env-wrapper` | Expected. The wrapper loads local `0600` env files so tracked Cursor/Codex config does not contain API keys. |

## Runtime Paths

```text
/Users/joshc/.nvm/versions/node/v20.20.0/bin/playwright-mcp
/Users/joshc/.nvm/versions/node/v20.20.0/bin/mcp-fetch-server
/Users/joshc/.nvm/versions/node/v20.20.0/bin/context7-mcp
/Users/joshc/.nvm/versions/node/v20.20.0/bin/firecrawl-mcp
```
