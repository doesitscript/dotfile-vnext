# MCP Research Collection Stack Validation

Validated: 2026-06-24  
Host: `mac-dev`  
Playbook: `playbooks/mac/mcp_servers.yaml`

## Summary

The stack role and playbook structure validates, and the no-secret lane applied
successfully.

| Server | Status | Evidence |
|---|---|---|
| Context7 | blocked | `vault_context7_mcp_api_key` is currently empty in `vault/mac_dev.vault.yml`; role fails before rendering config. |
| Firecrawl | blocked | `vault_firecrawl_mcp_api_key` is currently empty in `vault/mac_dev.vault.yml`; role fails before rendering config. |
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
| Full four-role apply | blocked at Firecrawl API key assertion |
| Context7 apply probe | blocked at Context7 API key assertion |
| Playwright/Fetch apply | pass; recap `changed=6`, `failed=0` |
| Playwright/Fetch idempotence | pass; recap `changed=0`, `failed=0` |
| Cursor config keys | pass for `playwright`, `fetch`; blocked for `context7`, `firecrawl` |
| Codex config keys | pass for `playwright`, `fetch`; blocked for `context7`, `firecrawl` |
| Secret scan | pass for tracked client config; no `FIRECRAWL_API_KEY`, `CONTEXT7_API_KEY`, or vault key names found |
| Secret env files | blocked; not created because secret-bearing roles stopped before config rendering |

## Runtime Paths

```text
/Users/joshc/.nvm/versions/node/v20.20.0/bin/playwright-mcp
/Users/joshc/.nvm/versions/node/v20.20.0/bin/mcp-fetch-server
```

## Follow-Up

After non-empty values are set for `vault_firecrawl_mcp_api_key` and
`vault_context7_mcp_api_key`, rerun:

```bash
bin/codex-env ansible-playbook -i inventory/inventory.yaml playbooks/mac/mcp_servers.yaml --limit mac-dev --tags context7,firecrawl
bin/codex-env ansible-playbook -i inventory/inventory.yaml playbooks/mac/mcp_servers.yaml --limit mac-dev --tags context7,firecrawl
```

Then verify:

```bash
jq -r '.mcpServers | keys[]' .cursor/mcp.json | sort | rg '^(context7|firecrawl|playwright|fetch)$'
rg -n '^\[mcp_servers\.(context7|firecrawl|playwright|fetch)\]' .codex/config.toml
rg -n 'FIRECRAWL_API_KEY|CONTEXT7_API_KEY|vault_firecrawl_mcp_api_key|vault_context7_mcp_api_key' .cursor/mcp.json .codex/config.toml
stat -f '%Lp %N' ~/.config/dotfile-vnext/mcp/env.d/firecrawl.env ~/.config/dotfile-vnext/mcp/env.d/context7.env
```
