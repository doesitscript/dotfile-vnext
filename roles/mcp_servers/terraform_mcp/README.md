# terraform_mcp

Installs the official HashiCorp Terraform MCP server locally and configures
client entries for Codex and IDE consumers.

This role uses `go install` against the official HashiCorp release tag and
publishes the binary to `~/.local/bin/terraform-mcp-server`.

## Apply / Verify / Undo / Change class

- Apply: include the role with `terraform_mcp_state: present`
- Verify: confirm `{{ terraform_mcp_command }}` exists and inspect target MCP
  config for the `terraform` entry
- Undo: set `terraform_mcp_state: absent`
- Change class: idempotent local tool install plus idempotent config
