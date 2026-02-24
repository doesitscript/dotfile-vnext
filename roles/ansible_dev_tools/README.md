# ansible_dev_tools

Installs Ansible development CLI tooling via pipx.

## Tools Installed

| Tool               | macOS (pipx) | Ubuntu (pipx) | Windows (pip) |
|--------------------|--------------|---------------|---------------|
| ansible            | pipx         | pipx          | pip           |
| ansible-builder    | pipx         | pipx          | pip           |
| ansible-lint       | pipx         | pipx          | -             |

On macOS, tools that cannot compile natively (e.g. `ansible-navigator`) are
provided as Docker wrapper functions deployed to `~/.bashrc.d/`.

## Dependencies

- `common/shell_config` — ensures `~/.bashrc.d` sourcing pattern exists
- `python` — provides pip/pipx

## MCP Server

The Red Hat Ansible Cursor extension MCP server configuration has moved to
`roles/mcp_servers/redhat-ansible`. See that role's README for extension path
detection, environment variables, and version management.
