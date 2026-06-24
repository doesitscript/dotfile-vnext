# Playwright MCP Server

Browser automation MCP tools for rendered pages, login-required workflows,
screenshots, and extraction fallback when simpler fetch tools are not enough.

## Upstream

- **Docs:** https://playwright.dev/docs/getting-started-mcp
- **Repo:** https://github.com/microsoft/playwright-mcp
- **npm:** `@playwright/mcp`

## Classification

| Attribute | Value |
|---|---|
| Runtime | Node.js (npm) |
| Install Method | npm global |
| Interaction Model | interactive/browser |
| Supported Targets | cursor, vscode, codex |
| Default Targets | cursor, codex on `mac-dev` |
| Verify Mode | manual_browser_validation |

## Defaults

The role preserves upstream's headed, persistent browser default. Set
`playwright_mcp_headless: true`, `playwright_mcp_isolated: true`, or
`playwright_mcp_browser` only when a workflow needs it.

## Apply / Verify / Undo / Change Class

**Apply:**

```bash
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags playwright
```

**Verify:**

1. Check npm install: `which playwright-mcp`
2. Check Cursor config: `.cursor/mcp.json` contains `playwright`
3. Check Codex config: `.codex/config.toml` contains `[mcp_servers.playwright]`
4. Start a fresh MCP client session before browser validation

**Undo:**

```bash
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags playwright -e playwright_mcp_state=absent
```

**Change Class:** Idempotent controller-local configuration management
