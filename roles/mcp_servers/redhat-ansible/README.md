# redhat-ansible

Builds the Red Hat Ansible MCP server from source (vscode-ansible) and configures the `"ansible"` entry in the project's `.cursor/mcp.json`. The package only upgrades when you change the version variable and re-run the role.

## Background

The Red Hat Ansible VS Code/Cursor extension used to ship an MCP entry point at `out/mcp/cli.js` inside the extension directory. In newer packaged builds (e.g. 26.3.0), that file is no longer present—the extension only ships data under `out/mcp/`, and the MCP server is intended to be started via the extension’s provider rather than a static path.

**This role does not recover or restore the old extension.** It builds the MCP server from the [ansible/vscode-ansible](https://github.com/ansible/vscode-ansible) source repo, pinned to a release tag (e.g. `v26.3.0`). The result is a standalone `cli.js` under `~/.local/lib/vscode-ansible/` that Cursor invokes directly. The MCP server you get is built from current upstream source and is independent of the Cursor extension install; upgrades are controlled only by `redhat_ansible_version`.

## What It Does

1. Clones [ansible/vscode-ansible](https://github.com/ansible/vscode-ansible) to `~/.local/lib/vscode-ansible` (version-pinned via git ref).
2. Runs `yarn install` and `yarn run build` at repo root (using NVM-managed Node 24 where available).
3. Resolves the Node binary via `nvm which 24` (fallback `nvm which default`) — project pattern: resolve with nvm, never construct nvm paths.
4. Merges the `"ansible"` server entry into `.cursor/mcp.json` with the **full path to node** as the command, the built `cli.js` path in args, and required environment variables.

**Why the full path to node?** Cursor often runs without nvm on PATH (e.g. when launched from the GUI). Using `command: "node"` then causes spawn ENOENT. We intentionally write the resolved full path (e.g. `~/.nvm/versions/node/v24.14.0/bin/node`) into `mcp.json` so the MCP server starts reliably. This is intentional and acceptable.

## Dependencies

- **common/node** (or NVM + Node 24+ elsewhere) for yarn/npm. The MCP package requires Node >= 24.
- **yarn** (enabled via corepack or installed globally).

## Supported Platforms

- macOS
- Ubuntu / WSL
- Windows

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `redhat_ansible_version` | `"v26.3.0"` | Git ref to pin (tag, branch, or sha). **Change only when you want to upgrade.** |
| `redhat_ansible_repo` | `https://github.com/ansible/vscode-ansible.git` | Upstream repo URL |
| `redhat_ansible_install_dir` | `~/.local/lib/vscode-ansible` | Clone destination |
| `redhat_ansible_entry_point` | `<install_dir>/packages/ansible-mcp-server/out/server/src/cli.js` | Built MCP CLI path |
| `redhat_ansible_project_dir` | `{{ dotfiles_home }}/.cursor` | Directory containing `mcp.json` |
| `redhat_ansible_workspace_root` | `{{ dotfiles_home }}` | WORKSPACE_ROOT for the MCP server |
| `redhat_ansible_collections_paths` | `{{ dotfiles_home }}/collections` | MCP env: collections paths |
| `redhat_ansible_roles_path` | `{{ dotfiles_home }}/roles:...` | MCP env: roles path |
| `redhat_ansible_config` | `{{ dotfiles_home }}/ansible.cfg` | MCP env: ansible.cfg path |

## Upgrading

To upgrade the MCP to a newer release, set `redhat_ansible_version` to the desired tag or commit SHA (e.g. in group_vars, host_vars, or extra vars) and re-run the role. The repo will update and the MCP package will rebuild.

Example (pin to a newer tag):

```yaml
redhat_ansible_version: "v26.4.0"
```

## #FIXME

Re-run the playbook (with this role) when you use a different Node 24.x or a different machine. The role rewrites `.cursor/mcp.json` with the **resolved** Node path (via `nvm which 24` or `nvm which default`). If you upgrade Node 24 or move to another host, run the playbook once so the role writes the correct node path into the ansible MCP entry; otherwise Cursor may still point at an old or missing node binary and the MCP will fail with spawn ENOENT.

## Tags

**Ansible tags:** `[mcp, redhat-ansible]`

**Classification:** `["ansible", "workspace"]`
