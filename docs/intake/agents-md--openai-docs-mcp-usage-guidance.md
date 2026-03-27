# Intake: OpenAI Docs MCP Server — AGENTS.md Guidance

**Source:** https://developers.openai.com/learn/docs-mcp
**Affects:** `AGENTS.md` (Codex CLI), `.cursor/mcp.json` (Cursor)

---

## What the docs recommend

### Add to `AGENTS.md`

```
Always use the OpenAI developer documentation MCP server if you need to work with the OpenAI API, ChatGPT Apps SDK, Codex,… without me having to explicitly ask.
```

> Without this snippet, you must explicitly tell the agent to use the server every time.

### Server configuration

Codex CLI (`~/.codex/config.toml`):
```toml
[mcp_servers.openaiDeveloperDocs]
url = "https://developers.openai.com/mcp"
```

Cursor (`~/.cursor/mcp.json`):
```json
"openaiDeveloperDocs": {
    "url": "https://developers.openai.com/mcp"
}
```

### Tips from the docs

- Keep server names short and descriptive when you have more than one MCP server — the agent uses the name to select the right one.
- The server is read-only. It does not call the OpenAI API on your behalf.
- Covers both `developers.openai.com` and `platform.openai.com`.

### Optional: OpenAI Docs Skill pairing

The docs recommend pairing the MCP server with the OpenAI Docs Skill. It instructs the agent to use Docs MCP tools first for OpenAI questions, then fall back to official OpenAI domains.

1. Install the skill from the OpenAI skills repository
2. Confirm the server is configured at `https://developers.openai.com/mcp`
3. Enable the skill for the project or session

### Optional: `required = true` in `config.toml`

Setting `required = true` on an MCP server causes Codex to fail at startup if the server cannot initialize. Use this to hard-enforce server availability per session.

---

## Current state of this repo

| Item | Status |
|---|---|
| `openaiDeveloperDocs` in `.cursor/mcp.json` | Done |
| Verbatim snippet in `AGENTS.md` | Pending |
| OpenAI Docs Skill installed | Not done |
