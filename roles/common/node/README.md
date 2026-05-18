node
====

Installs nvm and a pinned Node.js version on macOS and Ubuntu. Sets
`node_npm_executable` as a play-scoped fact that all downstream roles must use.

## What this role does

1. Installs nvm from the upstream installer script (idempotent via `creates:`).
2. Installs the Node.js version declared by `node_default_version` via `nvm install`.
3. Sets the nvm default alias.
4. Installs any packages listed in `npm_global_packages`.
5. **Resolves `node_default_version` to the real installed path** via `nvm which` and
   sets `node_npm_executable` as a play-scoped fact.

## Canonical fact: `node_npm_executable`

After this role runs, `node_npm_executable` contains the absolute path to the
nvm-managed npm binary — e.g. `/Users/joshc/.nvm/versions/node/v20.20.0/bin/npm`.

**Every role in this project that needs npm must use this fact.**

```yaml
- name: Install my-tool globally
  community.general.npm:
    name: my-tool
    global: true
    state: present
    executable: "{{ node_npm_executable }}"
```

The npm-managed binary for any globally-installed package lives in the same bin
directory: `{{ node_npm_executable | dirname }}/my-tool`.

### Why not construct the path manually?

`node_default_version: "20"` is a nvm alias — it is the value you pass to
`nvm install`. It is **not** a directory name. nvm creates
`~/.nvm/versions/node/v20.20.0/`, not `~/.nvm/versions/node/20/`. Any role that
assembles a path from `node_default_version` directly will produce a path that does
not exist. `nvm which {{ node_default_version }}` resolves the alias to the real
installed version and returns the authoritative path.

## NPM CLI Tool Installation Patterns

This project has two patterns for installing npm-based CLI tools that should be available system-wide (not project-local).

### Pattern A: npm_global_packages List

**When to use**: Pure convenience utilities that don't require version pinning or custom configuration.

**Characteristics**:
- Listed in `npm_global_packages` in this role's `defaults/main.yml`
- Installed via shell commands during node setup
- No version control - gets whatever `npm install -g` provides
- No lifecycle management (always present)
- Examples: `tldr`, convenience scripts

**Add a tool here when ALL of these are true**:
- It's a convenience utility, not infrastructure
- Breaking changes won't affect project work
- You don't care what version runs
- No custom post-install configuration needed

### Pattern B: Dedicated Role

**When to use**: Infrastructure tooling, AI/LLM tools, or anything requiring version control.

**Characteristics**:
- Own role under `roles/` with defaults, tasks, meta, README
- Version pinning via `*_tooling_version_contract` in inventory
- Installed via `community.general.npm` module
- Full lifecycle control (`present`/`absent`)
- Custom configuration possible (quarantine removal, etc.)
- Examples: `codex`, `langfuse-cli`, `supergateway`, `drawio-mcp-server`

**Use this pattern when ANY of these are true**:
- Tool is part of AI/LLM infrastructure
- Tool is an MCP server or infrastructure component
- Version stability is important
- Tool requires custom configuration
- User explicitly requests version pinning

### Canonical Installation Pattern (Pattern B)

Most Pattern B roles use this pattern:

```yaml
- name: Install <tool> at pinned version
  community.general.npm:
    name: "{{ tool_package_name }}"
    global: true
    state: "{{ tool_state }}"
    executable: "{{ node_npm_executable }}"
  when: tool_version | default('') | length > 0
```

**Optional environment.PATH fix**: If a tool installs to the wrong location (e.g., Cursor's node_modules instead of nvm's), add:

```yaml
  environment:
    PATH: "{{ (node_npm_executable | dirname) ~ ':' ~ ansible_facts['env']['PATH'] }}"
```

Only add this when you observe the failure - most packages work fine without it.

**Troubleshooting**: If a tool installs but isn't available in shell, or you see it in `/Applications/Cursor.app/.../node_modules/` instead of `~/.nvm/versions/node/v20.20.0/lib/node_modules/`, add the environment.PATH block.

## Variables

| Variable | Default | Description |
|---|---|---|
| `nvm_version` | `v0.40.4` | nvm git tag to install |
| `node_default_version` | `20` | nvm alias / major version to install |
| `npm_global_packages` | `[tldr]` | Packages installed globally after node |

## Output fact

| Fact | Example value | Description |
|---|---|---|
| `node_npm_executable` | `/Users/joshc/.nvm/versions/node/v20.20.0/bin/npm` | Canonical npm path for downstream roles |

## Platform support

| Platform | File | Notes |
|---|---|---|
| macOS | `tasks/mac.yml` | Full support |
| Ubuntu | `tasks/ubuntu.yml` | Full support |
| Windows | `tasks/windows.yml` | Skipped — use nvm-windows separately |
