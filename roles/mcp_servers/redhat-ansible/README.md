# redhat-ansible

Installs the Red Hat Ansible Cursor extension and configures its MCP server
entry in the project's `.cursor/mcp.json`.

## Source

[VS Code Marketplace: redhat.ansible](https://marketplace.visualstudio.com/items?itemName=redhat.ansible)

The MCP CLI is bundled inside the extension at `out/mcp/cli.js` -- there is no
standalone repo to clone. The role installs the extension via
`cursor --install-extension` and points the MCP entry at the bundled CLI.

## What It Does

1. Installs the `redhat.ansible` extension via `cursor --install-extension`.
2. Writes the `"ansible"` entry into `.cursor/mcp.json` with the extension's
   Node.js CLI path and all required environment variables.

## Extension Path: Local vs Remote

Cursor stores extensions in different locations depending on the connection type:

| Connection          | Extension base path                        |
|---------------------|--------------------------------------------|
| Local (native)      | `~/.cursor/extensions/`                    |
| Remote (SSH / WSL)  | `~/.cursor-server/extensions/`             |

The role auto-detects which path exists and uses it. Override by setting
`redhat_ansible_ext_base` in host/group vars.

## Environment Variables

| Variable | Purpose |
|---|---|
| `WORKSPACE_ROOT` | Project tree the extension analyzes |
| `MCP_ANSIBLE_COLLECTIONS_PATHS` | Colon-separated collections paths |
| `MCP_ANSIBLE_ROLES_PATH` | Colon-separated roles paths |
| `MCP_ANSIBLE_ENV_ANSIBLE_CONFIG` | Path to `ansible.cfg` |
| `_MCP_ANSIBLE_ROLE_PATH` | Relative role path for tracking |

## Updating the Extension Version

Bump `redhat_ansible_extension` in `defaults/main.yml`:

```yaml
redhat_ansible_extension: "redhat.ansible-26.1.3-universal"
```

## Working Config (remote WSL over SSH)

Manually verified config for a WSL host reached via SSH:

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

## Tags

**Ansible tags:** `[mcp, redhat-ansible]`

**Classification:** `["ansible", "workspace"]`
