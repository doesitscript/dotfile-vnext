# mcp_inspector Role

Ensures the [MCP Inspector](https://modelcontextprotocol.io/docs/tools/inspector) is usable on macOS and deploys usage documentation. **Macs only.**

The Inspector does **not** require installation: it runs via `npx @modelcontextprotocol/inspector`. This role ensures Node/npx is available, optionally installs the package globally for convenience, and deploys a short usage doc with examples for inspecting npm, PyPI, and local MCP servers.

## What This Role Does

- **Checks npx** — Verifies `npx` is available (e.g. after `common/node`); fails with a clear message if not.
- **Optional install** — If `mcp_inspector_install_package` is true, installs `@modelcontextprotocol/inspector` globally so npx runs without downloading each time.
- **Usage doc** — Deploys a markdown file (default `~/docs/mcp_inspector_usage.md`) with:
  - No-install usage: `npx @modelcontextprotocol/inspector <command>`
  - Inspecting npm packages: `npx -y @modelcontextprotocol/inspector npx <package> <args>`
  - Inspecting PyPI packages: `npx @modelcontextprotocol/inspector uvx <package> <args>`
  - Inspecting local TypeScript/Python servers

Reference: [MCP Inspector docs](https://modelcontextprotocol.io/docs/tools/inspector).

## Requirements

- **macOS** — Role runs only when `ansible_facts['system'] == 'Darwin'`; skipped on other OSes.
- **Node.js / npx** — npx must be on the PATH (e.g. install `common/node` before this role in the play).

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `mcp_inspector_install_package` | `false` | If true, install inspector globally via npm (no install required otherwise). |
| `mcp_inspector_deploy_doc` | `true` | If true, deploy the usage document. |
| `mcp_inspector_doc_path` | `""` | Full path for the usage doc. Defaults to `~/docs/mcp_inspector_usage.md` (using `dotfiles_user_home` or `ansible_user_dir`). |

## Tags

| Tag | Description |
|-----|-------------|
| `mcp_inspector` | All role tasks. |
| `mcp_inspector_install` | Optional global npm install only. |
| `mcp_inspector_doc` | Deploy usage document only. |

## Usage

Run after `common/node` so npx is available:

```yaml
- name: Set up dev environment on controller (Mac)
  hosts: execution_nodes
  connection: local
  gather_facts: true
  roles:
    - role: common/node
    - role: common/shell_config
    - role: mcp_inspector
```

Target only Macs (e.g. `mac_dev`):

```yaml
- name: MCP Inspector on Mac
  hosts: mac_dev
  connection: local
  gather_facts: true
  roles:
    - role: common/node
    - role: mcp_inspector
```

Optional global install (faster npx):

```yaml
- name: MCP Inspector on Mac
  hosts: mac_dev
  roles:
    - role: common/node
    - role: mcp_inspector
  vars:
    mcp_inspector_install_package: true
```

## Files Deployed

| Path | Purpose |
|------|---------|
| `~/docs/mcp_inspector_usage.md` (default) | Usage and examples (no install, npm, PyPI, local servers). |

If `mcp_inspector_install_package` is true, the npm package `@modelcontextprotocol/inspector` is installed globally in the default Node (e.g. nvm default).
