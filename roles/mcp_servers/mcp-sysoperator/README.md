# mcp-sysoperator

Clones, builds, and installs the [mcp-sysoperator](https://github.com/tarnover/mcp-sysoperator) MCP server natively (no Docker).

## What It Does

1. Clones the repo to `~/.local/lib/mcp-sysoperator` (version-pinned via git ref)
2. Runs `npm install` and `npm run build` using NVM-managed Node.js
3. Prints the MCP JSON snippet to add to your project `.cursor/mcp.json` and
   `.codex/config.toml`

## Dependencies

- `common/node` -- provides NVM + Node.js (pulled in automatically via `meta/main.yml`)

## Supported Platforms

- macOS
- Ubuntu
- Windows

## Variables

| Variable | Default | Description |
|---|---|---|
| `mcp_sysoperator_version` | `"main"` | Git ref (tag, branch, sha) to pin |
| `mcp_sysoperator_repo` | `https://github.com/tarnover/mcp-sysoperator.git` | Upstream repo URL |
| `mcp_sysoperator_install_dir` | `~/.local/lib/mcp-sysoperator` | Clone destination |
| `mcp_sysoperator_entry_point` | `<install_dir>/build/index.js` | Built JS entry point |

## MCP Configuration

After the role runs, it writes the repo-local Cursor entry and the project
Codex entry for `sysoperator`:

```json
{
  "mcpServers": {
    "sysoperator": {
      "command": "node",
      "args": ["/home/joshc/.local/lib/mcp-sysoperator/build/index.js"],
      "env": {}
    }
  }
}
```

The Cursor entry uses the direct `node` launch pattern. The Codex entry uses
the project `.codex/config.toml` managed-block pattern from the shared MCP
helpers.

### Verified Working Config (Ubuntu over SSH)

Installed to the project `.cursor/mcp.json` and `.codex/config.toml` on an
Ubuntu host reached via SSH:

```json
{
  "mcpServers": {
    "sysoperator": {
      "command": "node",
      "args": ["/home/joshc/.local/lib/mcp-sysoperator/build/index.js"],
      "env": {}
    }
  }
}
```

## Source

https://github.com/tarnover/mcp-sysoperator

## Tags

**Ansible tags:** `[mcp, mcp-sysoperator]`

**Classification:** `["infrastructure", "workspace"]`
