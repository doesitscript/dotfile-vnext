# aws_mcp

Configures the official AWS managed MCP Server in local client config files.

This role uses the current AWS remote MCP endpoint with OAuth initialization for
desktop and IDE clients. It does not install a local proxy by default.

## Apply / Verify / Undo / Change class

- Apply: include the role with `aws_mcp_state: present`
- Verify: inspect the target `mcp.json` and Codex config for the `aws-mcp`
  entry and complete OAuth login on first use
- Undo: set `aws_mcp_state: absent`
- Change class: idempotent config
