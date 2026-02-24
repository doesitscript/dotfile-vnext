# AI Instructions: Building MCP Server Roles

This document describes the repeatable patterns used to create Ansible roles
that install and configure MCP (Model Context Protocol) servers. Follow these
guidelines when adding a new server or modifying an existing one.

## Extracting Patterns from a GitHub Repo

Every MCP server starts as an upstream project on GitHub. The repo README
contains the three things you need:

1. **Runtime** -- look at the repo's language stats and dependency files.
   - `package.json` / `tsconfig.json` --> Node.js runtime, use `common/node` dependency.
   - `requirements.txt` / `pyproject.toml` --> Python runtime, use `python` dependency.
   - Cursor/VS Code extension --> no clone needed; install via `cursor --install-extension`.

2. **Install steps** -- find the "Quick start", "Setup", or "Installation"
   section. These steps map directly to the platform task files (`mac.yml`,
   `ubuntu.yml`). Typical patterns:
   - **Node.js**: `git clone` -> `npm install` -> `npm run build`
   - **Python**: `git clone` -> `python3 -m venv .venv` -> `pip install -U pip`
     -> `pip install -r requirements.txt` -> `pip install -e .`
   - **Extension**: `cursor --install-extension <publisher>.<name>`

3. **MCP client config** -- find the JSON block under "Cursor config",
   "Claude Desktop config", or similar. This block tells you:
   - `command` + `args` -- the entry point (becomes the `*_entry_point` /
     `*_server_script` / `*_cli_path` variable).
   - `env` -- runtime environment variables (each becomes a default variable
     with the role prefix).

## Role Directory Structure

Every MCP server role lives under `roles/mcp_servers/<role-name>/` and follows
this layout:

```
<role-name>/
  defaults/main.yml      # all variables (repo, version, paths, env vars)
  meta/main.yml           # role dependencies (python, common/node, or [])
  tasks/
    main.yml              # OS dispatch + import configure.yml
    mac.yml               # macOS install steps
    ubuntu.yml            # Ubuntu/WSL install steps
    configure.yml         # create/merge entry in .cursor/mcp.json
  README.md               # human docs (source, variables, env vars, tags)
```

## Variable Naming Convention

All defaults use the role name (snake_case) as a prefix:

| Role directory      | Variable prefix         |
|---------------------|-------------------------|
| `mcp-sysoperator`   | `mcp_sysoperator_*`     |
| `ansible-mcp`       | `mcp_ansible_*`         |
| `redhat-ansible`    | `redhat_ansible_*`      |

Standard variables every role declares:

| Variable suffix       | Purpose                                         |
|-----------------------|-------------------------------------------------|
| `_repo`               | Upstream git URL (clone-based roles only)        |
| `_version`            | Git ref to pin (tag, branch, SHA)                |
| `_install_dir`        | Clone destination (`~/.local/lib/<name>`)        |
| `_entry_point`        | Binary or script the MCP client invokes          |
| `_project_dir`        | Path to the `.cursor` directory for `mcp.json`   |
| `_role_path`          | Relative path from project root for tracking     |

## Standard Ansible Environment Variables

Every Ansible-related MCP server should include these env vars in its
`configure.yml` entry so the server can locate project resources:

| Env var                            | Purpose                            |
|------------------------------------|------------------------------------|
| `MCP_ANSIBLE_COLLECTIONS_PATHS`    | Colon-separated collections paths  |
| `MCP_ANSIBLE_ROLES_PATH`          | Colon-separated roles paths        |
| `MCP_ANSIBLE_ENV_ANSIBLE_CONFIG`  | Path to `ansible.cfg`              |
| `_MCP_ANSIBLE_ROLE_PATH`          | Relative role path for tracking    |

Non-Ansible servers (e.g. `mcp-sysoperator`) only need `_MCP_ANSIBLE_ROLE_PATH`.

## The `configure.yml` Pattern

All roles share the same create-or-merge pattern for `.cursor/mcp.json`:

1. `ansible.builtin.file` -- ensure the `.cursor` directory exists.
2. `ansible.builtin.stat` -- check whether `mcp.json` already exists.
3. **If missing**: `ansible.builtin.copy` -- create `mcp.json` with the single
   server entry rendered via `to_nice_json`.
4. **If present**: `ansible.builtin.slurp` + `from_json` to read the existing
   file, then `combine()` to merge the new entry under `mcpServers`, and
   `ansible.builtin.copy` to write the result back.

The entry key in `mcpServers` is the server's short name (e.g. `ansible`,
`sysoperator`, `ansible-mcp`).

## Tagging

### Ansible tags

All tasks in a role are tagged with two Ansible tags:

- `mcp` -- selects all MCP server roles at once.
- `<role-name>` -- selects a single server (e.g. `ansible-mcp`, `redhat-ansible`).

### MCP server classification tags

Each MCP server is classified with a two-axis tag set: **domain** +
**execution context**.

**Primary tag -- domain:**
The functional domain the server operates in (e.g. `ansible`, `infrastructure`).

**Secondary tag -- execution context:**

| Context     | Meaning                                                    |
|-------------|------------------------------------------------------------|
| `workspace` | Runs in a local dev environment (Cursor, terminal, laptop) |
| `pipeline`  | Runs inside Langfuse, RAG, or an orchestrated workflow     |
| `runtime`   | Runs inside deployed infrastructure (containers, CI/CD)    |

**Current tag assignments:**

| Role               | Tag set                          |
|--------------------|----------------------------------|
| `redhat-ansible`   | `["ansible", "workspace"]`       |
| `ansible-mcp`      | `["ansible", "workspace"]`       |
| `mcp-sysoperator`  | `["infrastructure", "workspace"]`|

**Future context examples (for documentation):**

| Scenario                                 | Tag set                  |
|------------------------------------------|--------------------------|
| Langfuse / RAG / orchestrated automation | `["ansible", "pipeline"]`|
| CI/CD or cloud-hosted Ansible MCP        | `["ansible", "runtime"]` |

## Adding a New MCP Server Role

1. Find the upstream repo and read its README.
2. Identify the runtime, install steps, and MCP config JSON (see above).
3. Copy the closest existing role as a starting point:
   - Node.js server --> copy `mcp-sysoperator`
   - Python server --> copy `ansible-mcp`
   - Cursor extension --> copy `redhat-ansible`
4. Rename the directory and update the variable prefix.
5. Adapt `mac.yml` / `ubuntu.yml` from the upstream install steps.
6. Adapt `configure.yml` with the correct entry key and env vars.
7. Tag all tasks with `[mcp, <role-name>]`.
8. Assign domain + execution-context tags and document them in the README.
9. Add the role to `playbooks/local.yaml`.
10. Add a row to the parent `roles/mcp_servers/README.md` table.
