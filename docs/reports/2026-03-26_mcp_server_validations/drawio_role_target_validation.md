# draw.io role target validation

Generated: 2026-03-26

This report captures the Ansible-role side of the draw.io validation after the
target-aware MCP pattern was implemented.

## Scope

- role: `roles/mcp_servers/drawio`
- control surface: `playbooks/mac/mcp_servers.yaml`
- command override used: `/Users/joshc/.nvm/versions/node/v20.20.0/bin/drawio-mcp`
- Ansible temp paths were redirected to `/tmp` for sandbox-safe validation

## Static checks

- `ansible-playbook --syntax-check playbooks/mac/mcp_servers.yaml -i inventory/inventory.yaml`
  Result: passed
- `ansible-lint roles/mcp_servers/drawio roles/mcp_servers/_template`
  Result: passed

## Live role runs

### Default Cursor target

Command shape:

```bash
ANSIBLE_LOCAL_TEMP=/tmp/ansible-local ANSIBLE_REMOTE_TEMP=/tmp/ansible-remote \
ansible-playbook playbooks/mac/mcp_servers.yaml -i inventory/inventory.yaml \
  --limit mac-dev --tags drawio \
  -e drawio_mcp_command=/Users/joshc/.nvm/versions/node/v20.20.0/bin/drawio-mcp
```

Result:

- success
- `changed=0`
- repo-local Cursor config remained idempotent

### Explicit VS Code target

Command shape:

```bash
ANSIBLE_LOCAL_TEMP=/tmp/ansible-local ANSIBLE_REMOTE_TEMP=/tmp/ansible-remote \
ansible-playbook playbooks/mac/mcp_servers.yaml -i inventory/inventory.yaml \
  --limit mac-dev --tags drawio,mcp_target_vscode \
  -e drawio_mcp_command=/Users/joshc/.nvm/versions/node/v20.20.0/bin/drawio-mcp
```

Result:

- success
- `changed=1`
- created repo-local `.vscode/mcp.json`
- wrote the `drawio` server entry with the expected command and role-path env

### OpenAPI stub

Command shape:

```bash
ANSIBLE_LOCAL_TEMP=/tmp/ansible-local ANSIBLE_REMOTE_TEMP=/tmp/ansible-remote \
ansible-playbook playbooks/mac/mcp_servers.yaml -i inventory/inventory.yaml \
  --limit mac-dev --tags drawio,mcp_target_openapi \
  -e drawio_mcp_command=/Users/joshc/.nvm/versions/node/v20.20.0/bin/drawio-mcp
```

Result:

- expected failure
- message: `The openapi target is a deliberate stub for draw.io in v1. Use cursor or vscode targets for now.`

## Artifacts

- `.vscode/mcp.json`
- `.cursor/mcp.json`
- `docs/reports/2026-03-26_mcp_server_validations/README.md`
- `docs/reports/2026-03-26_mcp_server_validations/drawio_mcp_validation_results.json`

## Conclusion

The draw.io role now proves the v1 MCP pattern in three ways:

- repo-local Cursor targeting is the default and is idempotent
- repo-local VS Code targeting is selectable and creates the expected config file
- the unimplemented `openapi` target fails fast instead of silently misbehaving
