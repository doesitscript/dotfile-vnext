# Firebase MCP validation

## Scope

- role: `roles/mcp_servers/firebase`
- playbook: `playbooks/mac/mcp_servers.yaml`
- controller host: `mac-dev`

## Upstream basis

- Firebase MCP docs: https://firebase.google.com/docs/ai-assistance/mcp-server
- Firebase CLI docs: https://firebase.google.com/docs/cli
- Runtime command: `npx -y firebase-tools@latest mcp`

## Validation plan

1. Lint the new role and controller playbook.
2. Preview target scope and task list on `mac-dev`.
3. Run check mode for `--tags firebase`.
4. Apply live on `mac-dev`.
5. Verify repo-managed targets:
   - `.cursor/mcp.json`
   - `.vscode/mcp.json`
   - `.codex/config.toml`
6. Verify command surface with `npx -y firebase-tools@latest mcp --help`.

## Result

Validated and applied on `mac-dev` on 2026-09-01.

## Evidence

### Repo validation

1. `git diff --check`
   - pass
2. `bin/codex-env ansible-lint roles/mcp_servers/firebase playbooks/mac/mcp_servers.yaml`
   - blocked by pre-existing repo lint debt outside this role:
     - `roles/common/node/tasks/mac.yml`
     - `roles/common/node/tasks/main.yml`
     - `roles/common/node/tasks/ubuntu.yml`
     - `roles/mcp_servers/netbox/meta/main.yml`
3. `bin/codex-env ansible-lint roles/mcp_servers/firebase`
   - pass: `0 failure(s), 0 warning(s)`
4. `bin/codex-env ansible-playbook playbooks/mac/mcp_servers.yaml -i inventory/inventory.yaml --syntax-check`
   - pass

### Preview

1. `bin/codex-env ansible-playbook playbooks/mac/mcp_servers.yaml -i inventory/inventory.yaml --limit mac-dev --list-hosts --tags firebase`
   - host scope: `mac-dev`
2. `bin/codex-env ansible-playbook playbooks/mac/mcp_servers.yaml -i inventory/inventory.yaml --limit mac-dev --list-tasks --tags firebase`
   - preview showed Firebase target wiring for `cursor`, `vscode`, and `codex`
3. Initial check mode found a role bug:
   - `common/node` exposed `node_npm_executable: /npm` during preview
   - Firebase role originally failed looking for `//npx`
4. After patching Firebase command resolution to fall back through `nvm`:
   - `bin/codex-env ansible-playbook playbooks/mac/mcp_servers.yaml -i inventory/inventory.yaml --limit mac-dev --tags firebase --check -v`
   - pass
   - resolved command: `/Users/joshc/.nvm/versions/node/v20.20.0/bin/npx`
5. After patching optional auth handling:
   - current-state preview:
     - pass
     - no local Firebase env file rendered
     - no local Firebase service-account file rendered
     - client entries stayed on direct `npx`
   - wrapper-mode preview with disposable extra env:
     - `bin/codex-env ansible-playbook playbooks/mac/mcp_servers.yaml -i inventory/inventory.yaml --limit mac-dev --tags firebase --check -v -e '{"firebase_mcp_extra_env":{"FIREBASE_MCP_MODE_PREVIEW":"1"}}'`
     - pass
     - Firebase env file path was selected and JSON/TOML targets switched to wrapper mode in preview only

### Apply

`bin/codex-env ansible-playbook playbooks/mac/mcp_servers.yaml -i inventory/inventory.yaml --limit mac-dev --tags firebase -v`

- pass
- original commission recap: `ok=47 changed=3 failed=0`
- auth-capable re-apply recap: `ok=55 changed=0 failed=0`

### Post-apply verification

1. `jq '.mcpServers.firebase' .cursor/mcp.json`
   - command: `/Users/joshc/.nvm/versions/node/v20.20.0/bin/npx`
   - args: `["-y", "firebase-tools@latest", "mcp"]`
2. `jq '.mcpServers.firebase' .vscode/mcp.json`
   - command: `/Users/joshc/.nvm/versions/node/v20.20.0/bin/npx`
   - args: `["-y", "firebase-tools@latest", "mcp"]`
3. `.codex/config.toml`
   - `[mcp_servers.firebase]` present
   - command: `/Users/joshc/.nvm/versions/node/v20.20.0/bin/npx`
   - args: `["-y", "firebase-tools@latest", "mcp"]`
4. `npx -y firebase-tools@latest mcp --help`
   - pass
   - upstream help confirmed `--dir`, `--only`, `--tools`, `--mode`, and `--port`
5. Firebase local auth artifacts for the current `mac-dev` state
   - `~/.config/dotfile-vnext/mcp/env.d/firebase.env`: absent
   - `~/.config/dotfile-vnext/mcp/credentials/firebase-service-account.json`: absent

## Notes

- This role intentionally uses a configure-only pattern through `npx`; it does
  not globally install `firebase-tools`.
- The current upstream auth contract is Firebase CLI user login or
  `GOOGLE_APPLICATION_CREDENTIALS`; `FIREBASE_TOKEN` is still supported by the
  current CLI but is deprecated upstream.
- No documented Firebase MCP-specific paid API-key auth path was found in the
  current Firebase docs or the `firebase-tools@15.28.2` auth surface.
- The role now supports optional auth overrides through vault-backed
  `vault_firebase_mcp_service_account_json`, `vault_firebase_mcp_firebase_token`,
  and `vault_firebase_mcp_extra_env`, while preserving a no-credential default.
