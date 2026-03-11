# openai_docs — OpenAI Developer Docs MCP + Codex app

Adds the [OpenAI Docs MCP](https://developers.openai.com/resources/docs-mcp) to Cursor’s `mcp.json`. Docs = streamable HTTP; Codex = local binary (installed on Mac/Ubuntu).

Two blocks: (1) **openaiDeveloperDocs** — `{ "url": "https://developers.openai.com/mcp" }`; (2) **codex** — `{ "command": "<path>" }` when Codex app is installed (Mac/Ubuntu). Also ensures `~/.codex/config.toml` has the openaiDeveloperDocs URL.

## What this role does

- **macOS:** `community.general.homebrew` installs codex; binary path resolved via `brew --prefix codex`. **Requires nothing external.**
- **Ubuntu:** `community.general.npm` installs `@openai/codex` globally using the nvm-managed npm at `~/.nvm/versions/node/<node_default_version>/bin/npm`. **Requires `roles/common/node` to run first** (provides nvm + Node.js). Binary path resolved via stat on `openai_docs_codex_bin_candidates` (first existing path wins).
- **Windows:** Skipped (Codex not supported).
- Creates or merges `.cursor/mcp.json` with both openaiDeveloperDocs and codex blocks (same merge pattern as ansible-mcp).
- Ensures `~/.codex` and `~/.codex/config.toml` with openaiDeveloperDocs URL block.

## Variables
| Variable | Default | Description |

|----------|---------|-------------|
| `openai_docs_mcp_url` | `https://developers.openai.com/mcp` | Streamable HTTP MCP endpoint. |
| `openai_docs_project_dir` | `{{ dotfiles_home }}/.cursor` | Directory containing `mcp.json`. |
| `openai_docs_server_key` | `openaiDeveloperDocs` | Key under `mcpServers` in `mcp.json`. |
| `openai_docs_codex_command` | `""` | Set by mac.yml/ubuntu.yml after install; path to codex binary. |
| `openai_docs_codex_enabled` | `true` | Set to `false` to omit the codex MCP block. |
| `openai_docs_codex_config_dir` | `{{ dotfiles_user_home }}/.codex` | Directory for `~/.codex/config.toml`. |
| `node_default_version` | `"20"` | Node.js version used by nvm (Ubuntu path resolution). Keep in sync with `roles/common/node`. |
| `openai_docs_codex_bin_candidates` | see defaults | Ordered list of Codex binary paths for Ubuntu stat resolution. First existing path wins. |

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
