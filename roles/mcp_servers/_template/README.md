# template-mcp — MCP role scaffold

Copy this directory when creating a new MCP role.

Rename the directory, variable prefix, server key, and role tags before using
it for real automation.

## What this scaffold standardizes

- one lifecycle variable: `<server>_state: present|absent`
- repo-local target model via `<server>_targets`
- shared Cursor / VS Code `mcp.json` merge pattern
- shared Codex `config.toml` block-management pattern
- explicit `openapi` stub target
- small machine-readable contract in `mcp_contract.yml`
- required README sections and validation shape
- reusable `template_mcp_env` surface for role-owned MCP runtime env vars

For Ansible-capable MCP servers on macOS, the generated MCP env should carry
the repo's WinRM safety vars instead of depending on interactive shell startup:

- `OBJC_DISABLE_INITIALIZE_FORK_SAFETY=yes`
- `no_proxy=*`
- `NO_PROXY=*`

## Apply / Verify / Undo / Change Class

- Apply: replace the install/uninstall stubs, fill in the contract, then run the focused MCP play with the new role.
- Verify: syntax-check the play, run the role against the intended targets, and capture a validation report under `docs/reports/mcp_server_validations/`.
- Undo: run with `<server>_state=absent`, then remove the role from the playbook if it is no longer wanted.
- Change class: idempotent config once the runtime install/uninstall tasks are implemented.

## Required Follow-Up After Copying

1. Replace `template_mcp_*` with the real prefix.
2. Update `mcp_contract.yml`.
3. Replace `mac.yml`, `ubuntu.yml`, and `uninstall.yml` stubs.
4. Update README source links, tags, and validation notes.
5. Add the role to `playbooks/mac/mcp_servers.yaml` only if it belongs on the controller.
