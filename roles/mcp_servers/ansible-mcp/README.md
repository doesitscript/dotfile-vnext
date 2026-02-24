# ansible-mcp

Clones, installs, and configures the [mcp-ansible](https://github.com/bsahane/mcp-ansible)
MCP server -- an advanced Ansible MCP server exposing utilities for inventories,
playbooks, roles, and project workflows.

## Source

https://github.com/bsahane/mcp-ansible

## What It Does

1. Clones the repo to `~/.local/lib/ansible-mcp` (version-pinned via git ref).
2. Creates a Python virtual environment and installs dependencies
   (`pip install -r requirements.txt && pip install -e .`).
3. Writes the `"ansible-mcp"` entry into `.cursor/mcp.json` with all required
   environment variables.

## Dependencies

- `python` -- provides pip/pipx (pulled in automatically via `meta/main.yml`)

## Supported Platforms

- macOS
- Ubuntu / WSL

## Variables

| Variable | Default | Description |
|---|---|---|
| `mcp_ansible_version` | `"main"` | Git ref (tag, branch, SHA) to pin |
| `mcp_ansible_repo` | `https://github.com/bsahane/mcp-ansible.git` | Upstream repo URL |
| `mcp_ansible_install_dir` | `~/.local/lib/ansible-mcp` | Clone destination |
| `mcp_ansible_venv_dir` | `<install_dir>/.venv` | Python venv inside the clone |
| `mcp_ansible_entry_point` | `<venv>/bin/python` | Python binary used in MCP config |
| `mcp_ansible_server_script` | `<install_dir>/src/ansible_mcp/server.py` | Server entry point script |
| `mcp_ansible_project_dir` | `<dotfiles_home>/.cursor` | `.cursor` directory for `mcp.json` |
| `mcp_ansible_role_path` | `roles/mcp_servers/ansible-mcp` | Relative path for tracking |

## Environment Variables

| Env var | Purpose |
|---|---|
| `MCP_ANSIBLE_PROJECT_ROOT` | Absolute project root |
| `MCP_ANSIBLE_INVENTORY` | Inventory path |
| `MCP_ANSIBLE_PROJECT_NAME` | Label for the env project |
| `MCP_ANSIBLE_COLLECTIONS_PATHS` | Colon-separated collections paths |
| `MCP_ANSIBLE_ROLES_PATH` | Colon-separated roles paths |
| `MCP_ANSIBLE_ENV_ANSIBLE_CONFIG` | Path to `ansible.cfg` |
| `_MCP_ANSIBLE_ROLE_PATH` | Relative role path for tracking |

## Tags

**Ansible tags:** `[mcp, ansible-mcp]`

**Classification:** `["ansible", "workspace"]`
