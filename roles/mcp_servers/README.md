# MCP Server Roles

Each subdirectory is an Ansible role that installs and configures one MCP
(Model Context Protocol) server for repo-local client integration.

## Roles

| Role | Server | Runtime | Interaction | Targets | Repo |
|---|---|---|---|---|---|
| `redhat-ansible` | Red Hat Ansible Cursor extension MCP | Node.js (extension build) | interactive/editor | Cursor | [redhat.ansible](https://marketplace.visualstudio.com/items?itemName=redhat.ansible) |
| `mcp-sysoperator` | Infrastructure ops (file, shell, Terraform) | Node.js (npm) | launcher | Cursor | [tarnover/mcp-sysoperator](https://github.com/tarnover/mcp-sysoperator) |
| `ansible-mcp` | Ansible playbook/inventory intelligence | Python (pip + venv) | launcher | Cursor | [bsahane/mcp-ansible](https://github.com/bsahane/mcp-ansible) |
| `openai_docs` | OpenAI developer docs (search + read) | HTTP + local Codex | launcher | Cursor, Codex | [Docs MCP](https://developers.openai.com/resources/docs-mcp) |
| `langfuse_docs` | Langfuse developer docs (search + read) | HTTP | launcher | Cursor, Codex | [Docs MCP](https://langfuse.com/docs/docs-mcp) |
| `hf-mcp-server` | Hugging Face Hub, docs, papers, datasets, models, and Spaces tools | HTTP | launcher | Cursor, Codex | [Hugging Face MCP Server](https://huggingface.co/docs/hub/hf-mcp-server) |
| `drawio` | draw.io MCP tool server | Node.js (npm) | interactive/editor | Cursor, Codex, VS Code, OpenAPI stub | [lgazo/drawio-mcp-server](https://github.com/lgazo/drawio-mcp-server) |
| `netbox` | NetBox MCP query server | Python (uv) | launcher | Cursor, Codex | [netboxlabs/netbox-mcp-server](https://github.com/netboxlabs/netbox-mcp-server) |

## Canonical Pattern

- `roles/mcp_servers/_template/` is the MCP role scaffold.
- `roles/mcp_servers/drawio/` is the first canonical JSON-target example.
- `roles/mcp_servers/openai_docs/` is the first Codex-target example.
- `roles/mcp_servers/langfuse_docs/` is a simple public HTTP docs MCP example.
- `roles/mcp_servers/huggingface/` is the official Hugging Face Hub HTTP MCP example.
- `playbooks/mac/mcp_servers.yaml` is the focused controller-side control surface for local MCP convergence on the Mac.

## Hugging Face Auth Note

`roles/mcp_servers/huggingface/` uses the upstream `hf-mcp-server` key and
`https://huggingface.co/mcp?login` endpoint. That default does not require an
API key in repo-managed config; it is intended to trigger client-side OAuth.

For Codex, verify the rendered entry with:

```bash
codex mcp get hf-mcp-server --json
```

Run OAuth only when account-scoped tools are needed:

```bash
codex mcp login hf-mcp-server
```

Bearer-token auth is a fallback, not the default repo implementation. If needed,
use local secret material such as `HF_TOKEN` with the non-login endpoint
`https://huggingface.co/mcp`; do not commit Hugging Face tokens or bearer
headers into repo-managed MCP config.

## Target Model

For v1, new MCP roles should use:

- `<server>_targets`
  Default: `['cursor']`
- repo-local config targets:
  - `.cursor/mcp.json`
  - `.vscode/mcp.json`
- project Codex config target:
  - `.codex/config.toml`
- `openapi` as an explicit stub target that fails fast until implemented

Target tags are available for focused runs:

- `mcp_target_cursor`
- `mcp_target_vscode`
- `mcp_target_codex`
- `mcp_target_openapi`

## Targeting Individual Servers

Install only one server:

```bash
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags drawio
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags langfuse-docs
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags huggingface
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags ansible-mcp
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags mcp-sysoperator
```

Install one server and target a specific client config:

```bash
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags drawio,mcp_target_cursor
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags drawio,mcp_target_vscode
```

If no target tag is supplied, the role uses its `<server>_targets` default or
explicit variable override.

## Directory Layout

```text
roles/mcp_servers/
  README.md
  _template/
  redhat-ansible/
  mcp-sysoperator/
  ansible-mcp/
  openai_docs/
  huggingface/
  drawio/
  _legacy_builder/
```

## Adding A New MCP Server

1. Classify the upstream server from its repo/README.
2. Copy `roles/mcp_servers/_template/`.
3. Fill in the role's `mcp_contract.yml`.
4. Replace the install/uninstall stubs with runtime-appropriate tasks.
5. Keep the public interface state-based and target-list-based.
6. Add validation artifacts under `docs/reports/mcp_server_validations/`.
7. Add the role to `playbooks/mac/mcp_servers.yaml` when it belongs on the controller.
8. See `roles/mcp_servers/ai.mcp_servers.instructions.md` for the full pattern.
