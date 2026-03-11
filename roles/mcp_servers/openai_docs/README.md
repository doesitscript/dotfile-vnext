# openai_docs — OpenAI Developer Docs MCP

Adds the [OpenAI Docs MCP](https://developers.openai.com/resources/docs-mcp) to Cursor’s `mcp.json`. Read-only, streamable HTTP server — no local install.

**Server URL:** `https://developers.openai.com/mcp`  
**Cursor entry:** `mcpServers.openaiDeveloperDocs` with `{ "url": "..." }`.

## What this role does

- Ensures `.cursor` exists in the project root.
- Creates `.cursor/mcp.json` with only this server if missing.
- If `mcp.json` exists, **merges** the `openaiDeveloperDocs` entry into `mcpServers` (same pattern as ansible-mcp, redhat-ansible, mcp-sysoperator).

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `openai_docs_mcp_url` | `https://developers.openai.com/mcp` | Streamable HTTP MCP endpoint. |
| `openai_docs_project_dir` | `{{ dotfiles_home }}/.cursor` | Directory containing `mcp.json`. |
| `openai_docs_server_key` | `openaiDeveloperDocs` | Key under `mcpServers` in `mcp.json`. |

## Tags

| Tag | Description |
|-----|-------------|
| `mcp` | All MCP configure tasks. |
| `openai-docs` | This role’s tasks. |
| `codex` | Codex / OpenAI tooling. |
| `openai` | OpenAI ecosystem. |
| `development` | Development tooling. |
| `research` | Research / docs lookup. |

## Usage

The role is included in both `playbooks/local.yaml` (controller + WSL) and
`playbooks/deploy_development_nodes.yaml` (nodes with `node_purpose: development`),
so development nodes get the Docs MCP when you run either playbook.

```yaml
roles:
  - role: mcp_servers/openai_docs
```

Run only this server:

```bash
ansible-playbook playbooks/local.yaml --limit mac-dev --tags codex
ansible-playbook playbooks/local.yaml --limit mac-dev --tags openai-docs
ansible-playbook playbooks/local.yaml --limit mac-dev --tags openai
ansible-playbook playbooks/local.yaml --limit mac-dev --tags research
ansible-playbook playbooks/deploy_development_nodes.yaml --tags openai-docs
```

## Reference

- [Docs MCP — OpenAI Developers](https://developers.openai.com/resources/docs-mcp)
