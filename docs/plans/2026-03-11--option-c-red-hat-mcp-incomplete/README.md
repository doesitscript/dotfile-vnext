---
name: Option C Build Red Hat MCP
overview: Build Red Hat Ansible MCP from source via a new role following the mcp-sysoperator pattern, with explicit version pinning so the package only upgrades when you change the version variable and re-run.
todos: []
isProject: false
---

# Option C: Build Red Hat Ansible MCP from Source

## Version pinning (upgrade only when you want)

- **Default:** Pin to a **release tag** (e.g. `v24.6` or the latest from [vscode-ansible releases](https://github.com/ansible/vscode-ansible/releases)), **not** `main`. The role variable (e.g. `vscode_ansible_mcp_version`) is the single place that controls which ref is checked out.
- **No automatic upgrades:** The role uses `ansible.builtin.git` with `version: "{{ vscode_ansible_mcp_version }}"` and `update: true`. So:
  - As long as you don’t change the variable, the same tag/sha is used every run; idempotent.
  - To upgrade: set `vscode_ansible_mcp_version` to a new tag or commit SHA (e.g. in group_vars, host_vars, or extra vars) and re-run the role. The repo will update and the MCP will rebuild (because the built `cli.js` will be recreated).
- **Recommendation:** Set the default in the role’s `defaults/main.yml` to a specific tag (e.g. `v24.6` or the current latest release). Document in the role README: “To upgrade the MCP, set `vscode_ansible_mcp_version` to the desired tag or SHA and re-run the role.”

---

## Existing pattern in this repo (stable)

**[roles/mcp_servers/mcp-sysoperator](roles/mcp_servers/mcp-sysoperator)** is the established MCP build pattern:

- **Defaults** ([defaults/main.yml](roles/mcp_servers/mcp-sysoperator/defaults/main.yml)): repo URL, version (tag/branch/sha), install dir (`~/.local/lib/mcp-sysoperator`), entry point (`{{ install_dir }}/build/index.js`), role path for `_MCP_ANSIBLE_ROLE_PATH`.
- **Flow**: Clone → `npm install` (in install dir) → `npm run build` → idempotence via `creates: {{ entry_point }}`.
- **Platform tasks**: mac.yml, ubuntu.yml, windows.yml — same steps; nvm used on Mac/Ubuntu for Node.
- **Config** (configure.yml): Ensure `.cursor` exists; create or merge `.cursor/mcp.json` with the server entry. Merge preserves other servers.

This is a stable, repeatable pattern: one role per “build from source” MCP, install under `~/.local/lib/<name>`, point Cursor at the built entry point.

---

## Upstream build steps (support resources)

- **MCP package:** `packages/ansible-mcp-server`; after build run with `node out/server/src/cli.js --stdio`.
- **Build:** Clone vscode-ansible → from root `yarn install` → in `packages/ansible-mcp-server` run `npm run build`. Entry point: `{{ install_dir }}/packages/ansible-mcp-server/out/server/src/cli.js`.
- **Node:** MCP package requires Node >= 24.

---

## Recommended approach: new role mirroring mcp-sysoperator

**Role name (suggestion):** `redhat_ansible_mcp` or `vscode_ansible_mcp` under `roles/mcp_servers/`.

**Defaults (concept):**

- `vscode_ansible_mcp_repo`: `https://github.com/ansible/vscode-ansible`
- **`vscode_ansible_mcp_version`**: **pinned to a release tag** (e.g. `v24.6`). Only change this when you want to upgrade.
- `vscode_ansible_mcp_install_dir`: `{{ dotfiles_user_home }}/.local/lib/vscode-ansible`
- `vscode_ansible_mcp_entry_point`: `{{ vscode_ansible_mcp_install_dir }}/packages/ansible-mcp-server/out/server/src/cli.js`
- Role path and env for Cursor as in current “ansible” entry in .cursor/mcp.json.

**Tasks:** Clone (with `version: "{{ vscode_ansible_mcp_version }}"`, `update: true`) → yarn install at root → build in `packages/ansible-mcp-server` → configure .cursor/mcp.json. Idempotence via `creates` on the entry point.

**README:** State that upgrades are intentional: set `vscode_ansible_mcp_version` to the new tag or SHA and re-run the role.

---

## Summary

- **Pattern:** Same as mcp-sysoperator: clone → install → build → configure mcp.json.
- **Pinning:** Default to a release tag; the package only upgrades when you change `vscode_ansible_mcp_version` and re-run the role.
- **Stability:** Reproducible, version-controlled upgrade path.
