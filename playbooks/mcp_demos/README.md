# MCP Demos — ansible.mcp Collection Examples

Self-contained playbooks that use the `ansible.mcp` collection to interact
with MCP servers as Ansible inventory hosts. Each demo has its own inventory,
manifest, and group_vars — no external dependencies on the main project
inventory.

## Prerequisites

```bash
# Install the ansible.mcp collection
ansible-galaxy collection install ansible.mcp

# Install uv/uvx (for AWS demos)
curl -LsSf https://astral.sh/uv/install.sh | sh

# AWS credentials configured (for AWS demos)
aws configure --profile default
```

## Demos

### aws_core_foundation — AWS Core Server, Foundation Profile

Uses the `AWS_FOUNDATION` role which enables:
- **AWS Knowledge Server**: search/read AWS documentation, list regions
- **AWS API Server**: suggest and execute AWS CLI commands

```bash
cd aws_core_foundation
ansible-playbook -i inventory.yaml demo.yml
```

### aws_core_devtools — AWS Core Server, Multi-Role Activation

Activates `AWS_FOUNDATION` + `dev-tools` + `solutions-architect` simultaneously.
Demonstrates how the Core proxy imports sub-servers from multiple roles without
duplication:
- Foundation tools (knowledge + API)
- Dev-tools: git-repo-research, code-doc-gen
- Solutions-architect: diagram, pricing, cost-explorer

```bash
cd aws_core_devtools
ansible-playbook -i inventory.yaml demo.yml
```

### azure_sql_mock — Azure SQL Database (Self-Contained Mock)

Fully self-contained example with all variables in `group_vars/all.yml`.
Demonstrates a production-ready variable structure (subscription, resource
group, vault-backed passwords) with safe mock defaults.

```bash
cd azure_sql_mock

# Mock run (uses default values)
ansible-playbook -i inventory.yaml playbook.yaml

# Real Azure deployment
ansible-playbook -i inventory.yaml playbook.yaml \
  -e azure_subscription=<sub-id> \
  -e azure_resource_group=<rg-name> \
  -e vault_db_admin_password=<password>
```

Requires: `az login`, Node.js (for npx)

### github_repo — GitHub Repository + Pull Request (HTTP Transport)

Shows HTTP transport with bearer token auth (vs stdio in the AWS demos).
Creates a repository, branch, file, and pull request.

```bash
cd github_repo
ansible-playbook -i inventory.yaml playbook.yaml \
  -e github_token=ghp_...

# In an organization
ansible-playbook -i inventory.yaml playbook.yaml \
  -e github_token=ghp_... \
  -e github_organization=my-org
```

## How Each Demo Is Structured

Every demo follows the same four-file pattern:

```
<demo_name>/
  inventory.yaml       # MCP server as an Ansible host
  manifest.json        # Server connection details (stdio or HTTP)
  <playbook>.yml       # The actual automation
  group_vars/
    <group>.yml        # Shared defaults for all hosts in the group
```

The inventory uses `ansible_connection: ansible.mcp.mcp` to treat the MCP
server as a persistent connection. The manifest tells the connection plugin
how to launch (stdio) or reach (HTTP) the server.

## Adding New Demos

1. Create a new directory under `mcp_demos/`
2. Add `inventory.yaml` with the MCP server as a host
3. Add `manifest.json` with the server's connection details
4. Add a playbook and `group_vars/` with defaults
5. Update this README

No changes to the main project inventory or roles are needed.

## Relationship to roles/mcp_servers

These demos are independent of the `roles/mcp_servers/` role which handles:
- Building MCP server Docker images (Tier 1)
- Deploying `~/.cursor/mcp.json` to client machines (Tier 2)

The demos here are Tier 3: using MCP servers as Ansible automation targets
via the `ansible.mcp` connection plugin.
