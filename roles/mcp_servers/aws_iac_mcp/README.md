# aws_iac_mcp

Install and configure the AWS Labs AWS IaC MCP server for local MCP clients.

This role is the AWS-side IaC companion for Terraform workflows. It does not
reintroduce the deprecated AWS Labs Terraform MCP server; that upstream now
recommends HashiCorp's official `terraform-mcp-server` for Terraform-specific
work and `awslabs.aws-iac-mcp-server` for AWS infrastructure guidance.

## Apply / Verify / Undo / Change Class

- Apply: include the role with `aws_iac_mcp_state: present`
- Verify: confirm `{{ aws_iac_mcp_command }}` exists and inspect target MCP
  config entries
- Undo: set `aws_iac_mcp_state: absent`
- Change class: idempotent user-scoped configuration management
