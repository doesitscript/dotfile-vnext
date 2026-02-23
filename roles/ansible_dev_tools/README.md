# ansible_dev_tools

Installs Ansible development tooling and configures the Red Hat Ansible MCP server for Cursor.

## Tools Installed

| Tool               | macOS       | Ubuntu (pipx) | Windows (pip) |
|--------------------|-------------|---------------|---------------|
| ansible-dev-tools  | pip         | pipx          | pip           |
| ansible-navigator  | pip         | pipx          | pip           |
| ansible-builder    | pipx        | pipx          | pip           |
| ansible-lint       | Homebrew    | pipx          | -             |

Each tool is gated by a boolean toggle in `defaults/main.yml` (e.g. `ansible_navigator_install`).

## Dependencies

- `common/shell_config` — ensures `~/.bashrc.d` sourcing pattern exists
- `python` — provides pip/pipx

## Ansible MCP Server Setup

The `project` tag tasks write the Ansible MCP server entry into the project's `.cursor/mcp.json`.

### Extension Path: Local vs Remote

Cursor stores extensions in different locations depending on the connection type:

| Connection          | Extension base path                        |
|---------------------|--------------------------------------------|
| Local (native)      | `~/.cursor/extensions/`                    |
| Remote (SSH / WSL)  | `~/.cursor-server/extensions/`             |

The role auto-detects which path exists and uses it. You can override by setting
`ansible_mcp_cursor_ext_base` in host/group vars.

### Prerequisite

The Red Hat Ansible extension (`redhat.ansible`) must be installed **in the Cursor
instance that connects to the target machine**. For remote SSH/WSL connections, this
means installing the extension while connected to the remote — Cursor installs it under
`~/.cursor-server/extensions/` on the remote host.

### Working Config (remote WSL over SSH)

This is the config that was manually verified working when installed to the project
`.cursor/mcp.json` on a WSL host reached via SSH:

```json
{
  "mcpServers": {
    "ansible": {
      "command": "node",
      "args": [
        "/home/joshc/.cursor-server/extensions/redhat.ansible-26.1.3-universal/out/mcp/cli.js",
        "--stdio"
      ],
      "env": {
        "WORKSPACE_ROOT": "/mnt/d/develop/dotfile-vnext"
      }
    }
  }
}
```

Key points:
- `.cursor-server` (not `.cursor`) because the extension was installed via a remote SSH session
- `--stdio` argument is required
- `WORKSPACE_ROOT` points to the dotfiles repo on the remote filesystem

### Updating the Extension Version

When the extension updates, bump `ansible_mcp_extension` in `defaults/main.yml`:

```yaml
ansible_mcp_extension: "redhat.ansible-26.1.3-universal"
```
