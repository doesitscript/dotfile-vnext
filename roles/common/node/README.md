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
