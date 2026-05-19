# Python Dependency Management Patterns

## Overview

This document captures the established patterns for Python dependency management in this repository, along with the rationale for these decisions.

## Current Tool Landscape

### pip + venv (Standard Pattern)

**Used for:** Project-specific Python dependencies that need isolated environments

**Examples:**
- `ansible-mcp` role
- `netbox-mcp` role (git-cloned MCP servers)

**Pattern:**
```yaml
# Clone repo
ansible.builtin.git:
  repo: <url>
  dest: <install_path>
  version: <tag>

# Create venv
ansible.builtin.command:
  cmd: python3 -m venv <venv_dir>

# Install dependencies
ansible.builtin.command:
  cmd: <venv_dir>/bin/pip install .
  chdir: <install_path>
```

**Why pip/venv:**
- Built into Python (no external tool required)
- Standard, widely understood
- Proven reliable for deterministic installs
- Minimal dependencies
- Works consistently across macOS/Linux

### pipx (Global CLI Tools)

**Used for:** Python CLI applications that should be globally available but isolated

**Examples:**
- `poetry`
- `virtualenv`

**Managed by:** `python` role via `pipx_packages` list

**Why pipx:**
- Automatic isolation for each tool
- No manual venv management
- Designed specifically for CLI tools
- Automatic PATH management

### poetry

**Used for:** Python project packaging and dependency management (when applicable)

**Installed via:** `pipx` (managed by `python` role)

**Status:** Available but not currently required for any MCP servers

### uv

**Status:** Evaluated but NOT adopted for this repository

**Context:** NetBox MCP upstream docs recommended `uv` for faster dependency resolution

**Decision:** Do NOT use `uv` in this repository

**Rationale:**
1. **Redundancy:** `poetry` already installed via `pipx` for similar use cases
2. **Pattern consistency:** `pip/venv` is the established pattern for git-cloned MCP servers
3. **Minimalism:** Avoid introducing new tools when existing ones work
4. **Determinism:** `pip/venv` is proven for this use case
5. **Maintenance:** Fewer tools = simpler mental model

**When to reconsider:**
- If `uv` becomes a hard requirement for a specific upstream project
- If build times become a demonstrable bottleneck (measure first)
- If a new project type (not MCP servers) has a compelling use case

## Decision Framework

When evaluating a new Python tool or dependency manager:

1. **Check existing patterns first**
   - Does `pip/venv` already handle this use case?
   - Is there an established role or pattern?

2. **Evaluate necessity**
   - Is this a hard upstream requirement?
   - Does the existing pattern have a specific limitation?
   - Is there a measurable performance/capability gap?

3. **Consider maintenance cost**
   - How many tools are we maintaining?
   - Is the new tool's benefit worth the added complexity?
   - Will this pattern scale to other use cases?

4. **Document the decision**
   - Update this file with rationale
   - Add pattern examples to relevant role READMEs

## Pattern Selection Guide

| Use Case | Tool | Pattern Location |
|---|---|---|
| Git-cloned Python project (MCP servers) | pip + venv | `roles/mcp_servers/_template` |
| Global Python CLI tool | pipx | `roles/python/defaults/main.yml` |
| Python packaging project (if needed) | poetry (via pipx) | TBD when required |
| Ad-hoc Python scripts | pip + venv or pipx | Case-by-case |

## Historical Context

### NetBox MCP Server (May 2026)

**Initial approach:** Implemented with `uv sync` following upstream docs

**Issue raised:** User questioned `uv` necessity given existing `poetry` and `pip/venv`

**Resolution:** Switched to standard `pip/venv` pattern matching `ansible-mcp`

**Key learning:** Always check project patterns before following upstream tool recommendations, especially when they introduce new dependencies

**Files updated:**
- `roles/mcp_servers/netbox/tasks/mac.yml` - switched to pip/venv
- `roles/mcp_servers/netbox/defaults/main.yml` - removed uv variables
- This documentation - captured the decision

## See Also

- `roles/python/README.md` - Python role documentation (authoritative for Python tooling)
- `roles/mcp_servers/_template/README.md` - MCP server pattern documentation
- `roles/mcp_servers/ansible-mcp/tasks/mac.yml` - Canonical pip/venv pattern example
