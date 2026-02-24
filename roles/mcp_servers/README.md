# MCP Server Roles

Each subdirectory is an Ansible role that installs and configures one MCP
(Model Context Protocol) server for IDE integration (Cursor / VS Code).

## Roles

| Role | Server | Runtime | Tags | Repo |
|---|---|---|---|---|
| `redhat-ansible` | Red Hat Ansible Cursor extension MCP | Node.js (Cursor extension) | `["ansible", "workspace"]` | [redhat.ansible](https://marketplace.visualstudio.com/items?itemName=redhat.ansible) |
| `mcp-sysoperator` | Infrastructure ops (file, shell, Terraform) | Node.js (npm) | `["infrastructure", "workspace"]` | [tarnover/mcp-sysoperator](https://github.com/tarnover/mcp-sysoperator) |
| `ansible-mcp` | Ansible playbook/inventory intelligence | Python (pip + venv) | `["ansible", "workspace"]` | [bsahane/mcp-ansible](https://github.com/bsahane/mcp-ansible) |

## Targeting Individual Servers

Every role is tagged so you can install just the one you need:

```bash
# Install only redhat-ansible (Cursor extension MCP)
ansible-playbook playbooks/local.yaml --limit mac-dev --tags redhat-ansible

# Install only mcp-sysoperator
ansible-playbook playbooks/local.yaml --limit mac-dev --tags mcp-sysoperator

# Install only ansible-mcp
ansible-playbook playbooks/local.yaml --limit mac-dev --tags ansible-mcp

# Install all MCP servers
ansible-playbook playbooks/local.yaml --limit mac-dev --tags mcp
```

## Directory Layout

```
roles/mcp_servers/
  README.md               # this file
  redhat-ansible/         # Cursor extension MCP (install ext + configure)
  mcp-sysoperator/        # Node.js MCP server (clone + npm install + npm run build)
  ansible-mcp/            # Python MCP server  (clone + venv + pip install)
  _legacy_builder/        # archived Docker-based builder approach (not active)
```

## Tagging Taxonomy

Every MCP server carries a two-part tag set: **domain** + **execution context**.

**Primary tag -- domain:**
The functional area the server covers (e.g. `ansible`, `infrastructure`).

**Secondary tag -- execution context:**

| Context     | Meaning                                                    |
|-------------|------------------------------------------------------------|
| `workspace` | Runs in a local dev environment (Cursor, terminal, laptop) |
| `pipeline`  | Runs inside Langfuse, RAG, or an orchestrated workflow     |
| `runtime`   | Runs inside deployed infrastructure (containers, CI/CD)    |

All roles in this repo currently target `workspace`. Future deployments into
orchestration layers or CI/CD would use the same domain tag with `pipeline` or
`runtime`:

```jsonc
// Local Ansible MCP (Cursor, laptop)
["ansible", "workspace"]

// Langfuse / RAG / orchestrated automation
["ansible", "pipeline"]

// CI/CD or cloud-hosted Ansible MCP
["ansible", "runtime"]
```

## Adding a New MCP Server

1. Create a new subdirectory under `roles/mcp_servers/` with `defaults/`, `meta/`, and `tasks/`.
2. Follow the pattern from `mcp-sysoperator` (Node.js) or `ansible-mcp` (Python).
3. Tag all tasks with `[mcp, <your-server-name>]`.
4. Assign a domain + execution-context tag set and document it in the role README.
5. Add the role to `playbooks/local.yaml`.
6. See `ai.mcp_servers.instructions.md` for the full pattern reference.
