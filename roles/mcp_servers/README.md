# MCP Server Roles

Each subdirectory is an Ansible role that installs and configures one MCP
(Model Context Protocol) server for repo-local client integration.

## Roles

| Role | Server | Runtime | Interaction | Targets | Repo |
|---|---|---|---|---|---|
| `redhat-ansible` | Red Hat Ansible Cursor extension MCP | Node.js (extension build) | interactive/editor | Cursor | [redhat.ansible](https://marketplace.visualstudio.com/items?itemName=redhat.ansible) |
| `mcp-sysoperator` | Infrastructure ops (file, shell, Terraform) | Node.js (npm) | launcher | Cursor | [tarnover/mcp-sysoperator](https://github.com/tarnover/mcp-sysoperator) |
| `ansible-mcp` | Ansible playbook/inventory intelligence | Python (pip + venv) | launcher | Cursor | [bsahane/mcp-ansible](https://github.com/bsahane/mcp-ansible) |
| `openai_docs` | OpenAI developer docs (search + read) | HTTP + local Codex | launcher | Cursor | [Docs MCP](https://developers.openai.com/resources/docs-mcp) |
| `drawio` | draw.io MCP tool server | Node.js (npm) | launcher | Cursor, VS Code, OpenAPI stub | [draw.io AI + MCP](https://www.drawio.com/doc/faq/ai-drawio-generation) |

## Canonical Pattern

- `roles/mcp_servers/_template/` is the MCP role scaffold.
- `roles/mcp_servers/drawio/` is the first canonical example of the target-aware pattern.
- `playbooks/mac/mcp_servers.yaml` is the focused controller-side control surface for local MCP convergence on the Mac.

## Target Model

For v1, new MCP roles should use:

- `<server>_targets`
  Default: `['cursor']`
- repo-local config targets:
  - `.cursor/mcp.json`
  - `.vscode/mcp.json`
- `openapi` as an explicit stub target that fails fast until implemented

Target tags are available for focused runs:

- `mcp_target_cursor`
- `mcp_target_vscode`
- `mcp_target_openapi`

## Targeting Individual Servers

Install only one server:

```bash
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags drawio
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
