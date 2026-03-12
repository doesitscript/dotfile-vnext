# vscode-ansible MCP Server — Build Broken on v26.x+ (moduleResolution: bundler + path aliases)

**Environment:** macOS (mac-dev), Node 24 via NVM, vscode-ansible built from source at
`~/.local/lib/vscode-ansible`, MCP server launched by Cursor via `mcp.json`.

**Date confirmed:** March 2026

**Status: UNRESOLVED for v26.x+** — current workaround is pinning to `v25.12.2`.

---

## The Problem

After bumping `redhat_ansible_version` from `v24.6` to `v26.3.0` (commit `565032d`),
the Red Hat Ansible MCP server crashes immediately on startup with:

```
Error [ERR_MODULE_NOT_FOUND]: Cannot find package '@src/server.js' imported from
/Users/joshc/.local/lib/vscode-ansible/packages/ansible-mcp-server/out/server/src/cli.js
```

Node.js restarts it repeatedly, always failing with the same error. The MCP server
never reaches the point of responding to any request.

---

## Root Cause: TypeScript Path Aliases Not Rewritten by Plain tsc

### What changed between v25.12.2 and v26.3.0

Commit `565032d` ("fixes ansible redhat mcp server. pins to version that still has
the mcp server") bumped the pinned version and changed the build command. The version
bump is what introduced the breakage.

`packages/ansible-mcp-server/tsconfig.json` changed between these two versions:

| Setting | v25.12.2 | v26.3.0 |
|---|---|---|
| `moduleResolution` | `"node"` | `"bundler"` |
| `baseUrl` | absent | `"."` |
| `paths` (aliases) | absent | `{"@src/*": ["./src/*"], "@test/*": ["./test/*"]}` |

### Why `moduleResolution: "bundler"` breaks plain tsc

`moduleResolution: "bundler"` is a TypeScript 5.0 mode designed for projects that use
a bundler (webpack, esbuild, Vite, Rollup) as the final module resolver. When this mode
is used, TypeScript validates imports but **emits path aliases verbatim into the compiled
JavaScript** — it assumes the bundler will resolve them at bundle time.

The build script in `packages/ansible-mcp-server/package.json` is:

```json
"compile": "tsc -p . && npm run copy-resources"
```

This is plain `tsc` — no bundler, no post-processing. With `moduleResolution: "bundler"`,
`tsc` produces `cli.js` containing:

```javascript
import { runStdio } from "@src/server.js";
```

Node.js interprets `@src/server.js` as a scoped npm package named `@src`. No such
package exists. The server crashes before executing a single line of business logic.

### Pervasive — not just cli.js

All compiled files in `out/server/src/` contain unresolved `@src/` aliases:

```
cli.js                → @src/server.js
handlers.js           → @src/constants.js, @src/tools/*, @src/resources/*
server.js             → @src/handlers.js, @src/dependencyChecker.js, @src/tools/*, @src/resources/*
resources/agents.js   → @src/utils/resourcePath.js
resources/eeSchema.js → @src/utils/resourcePath.js
tools/executionEnv.js → @src/resources/eeSchema.js
```

The server would fail at the first import chain regardless of entry point.

### The changed build command was a red herring

`565032d` also changed the build command from:

```yaml
nvm exec default npm run build
# chdir: packages/ansible-mcp-server  (correct scope)
```

to:

```yaml
nvm exec 24 bash -c 'corepack enable && yarn run build'
# chdir: redhat_ansible_install_dir   (repo root)
```

The root `build` script is `yarn workspaces foreach --all -tvv run compile`, which
iterates workspaces and calls each package's own `compile` script. For
`ansible-mcp-server`, that is still `tsc -p .` — the same plain tsc. Running from
root vs subpackage produces identical broken output. The build command change did not
fix the path alias issue.

---

## The Actual Evidence

Inspected `out/server/src/cli.js` after the build ran (commit `565032d` in effect):

```javascript
#!/usr/bin/env node
import process from "node:process";
import { runStdio } from "@src/server.js";   // ← alias not rewritten
```

`server.js` physically exists at `out/server/src/server.js`. The file is present.
Node.js cannot find it because the import path is wrong.

---

## Current Workaround: Pin to v25.12.2

`v25.12.2` uses `moduleResolution: "node"` with no path aliases. Plain `tsc`
produces clean output. All imports are standard relative paths. Node.js resolves them
correctly.

Changes made:
- `defaults/main.yml`: `redhat_ansible_version: "v25.12.2"`
- `install_mac.yml` and `install_ubuntu.yml`: reverted build command to
  `npm run build` from the `packages/ansible-mcp-server` subpackage directory
- Removed the `nvm install 24` task — v25.12.2 requires `node >=20.0`, not `>=24.0`

---

## How to Fix for v26.x+ (when ready to upgrade)

The correct fix for v26.x+ is to add `tsc-alias` as a post-compile step in the
Ansible role. `tsc-alias` reads `tsconfig.json` `paths`, walks the compiled output,
and rewrites all path aliases to correct relative paths.

Required change to `install_mac.yml` and `install_ubuntu.yml` (build task only):

```yaml
- name: Build Red Hat Ansible MCP package (macOS)
  ansible.builtin.shell: |
    export NVM_DIR="{{ dotfiles_user_home }}/.nvm"
    . "$NVM_DIR/nvm.sh"
    nvm exec default bash -c '
      npm run build &&
      npx --yes tsc-alias -p packages/ansible-mcp-server/tsconfig.json
    '
  args:
    chdir: "{{ redhat_ansible_install_dir }}"
    creates: "{{ redhat_ansible_entry_point }}"
    executable: /bin/bash
```

`npx --yes tsc-alias` downloads and runs `tsc-alias` without requiring it to be a
committed devDependency. It rewrites `@src/foo.js` → relative paths in all compiled
`.js` files.

**Before applying this fix:** confirm the upstream `packages/ansible-mcp-server/tsconfig.json`
still uses `moduleResolution: "bundler"` at the target version. If the upstream project
fixes this on their side (adds `tsc-alias` to their own build, or switches to a bundler,
or reverts `moduleResolution`), this post-build step is no longer needed.

---

## Key References

| Item | Value |
|---|---|
| Evidence commit | `565032d` — "fixes ansible redhat mcp server. pins to version that still has the mcp server" |
| Broken version | `v26.3.0` (and likely all v26.x) |
| Working version | `v25.12.2` |
| Broken tsconfig setting | `"moduleResolution": "bundler"` + `"paths": {"@src/*": ...}` |
| Tool to fix for v26.x+ | `tsc-alias` (npx invocation, no install required) |
| Role files affected | `roles/mcp_servers/redhat-ansible/tasks/install_mac.yml`, `install_ubuntu.yml`, `defaults/main.yml` |
