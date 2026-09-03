# MCP client commission gates

**Homelab finding / design contract (2026-09-03).**

Writing a client config file is **access**. Client **commission** is a separate
layer. Treating Ansible `changed/ok` on `mcp.json` / project Codex TOML as
“Agent works” is the leak that delayed Morph enablement — and can hit **any**
MCP server, not Morph alone.

## How the leak happened

| Failure | What we did | What was still missing |
| --- | --- | --- |
| Cursor Agent | Wrote project `.cursor/mcp.json` | Project-MCP allowlist (`approvedProjectMcpServers`) + restart; Agent stayed `disconnected` / no `createClient` |
| Codex list / IDE | Wrote project `.codex/config.toml` only | User `~/.codex/config.toml` — `codex mcp list` / ConfigEditsBuilder path center on user config |
| Continue | Wired Morph | Launch (`npx --prefer-offline`), stub servers, duplicate rules |

Root cause class: **access-layer-complete ≠ client-commissioned**.

## Design principles (sources + lab)

1. **Ansible:** after configure, assert **actual** config state (file/key
   presence), not only module result (integration-test style assert). Check
   mode is preview — not commission proof.
2. **Cursor:** project vs user `mcp.json` are different surfaces; Customize
   enable / allowlist is another gate; UI may omit Project even when Agent has
   `project-*` tools.
3. **Codex:** layered config exists, but operator/`mcp list` surfaces lean on
   **user** `~/.codex/config.toml` — dual-write project + user when `codex` is
   commissioned.
4. **Agents:** habit/routing layer is separate from access (instruction-scope
   registry).

## Required layers (every MCP role)

| Layer | Meaning | Done when |
| --- | --- | --- |
| Install | Binary / package present | Path resolves |
| Access | Client config entry written | File assert / shared report task |
| Client gate | Cursor allowlist, Codex user file, Continue launch hygiene | Per-client checklist below |
| Habit | Routing instructions | Registry + managed blocks |
| Live verify | Tool listing / createClient / `codex mcp get` | Explicit probe this turn |

## Per-client gates

### Cursor

| Target | Access path | Extra gate |
| --- | --- | --- |
| `cursor_user` (preferred default for Agent-critical) | `~/.cursor/mcp.json` | Usually none; often hot-connects |
| `cursor` (project, opt-in) | `<repo>/.cursor/mcp.json` | Allowlist + restart; UI may not show Project |

Ansible cannot fully commission project Cursor inside a live session. Roles
must emit the project allowlist gate (shared task) and must not claim Agent
ready from mcp.json alone.

### Codex

When `codex` is in `*_targets`, write:

1. project `.codex/config.toml`
2. user `~/.codex/config.toml` (`*_configure_codex_user: true` default)

### Continue

Pinned binary (no `npx --prefer-offline` for fragile packages); no stub
`new-mcp-server.yaml`; no duplicate `rules:` + project `.continue/rules/`.

## Shared automation

End of every role `present.yml` (when targets were configured):

```yaml
- name: Report MCP client commission gates
  ansible.builtin.include_tasks: "{{ role_path }}/../_shared/tasks/report_client_commission_gates.yml"
  vars:
    _mcp_commission_server_key: "{{ <server>_mcp_server_key }}"
    _mcp_commission_role_name: "<role>"
    # ... selected flags + paths ...
```

See Morph `tasks/present.yml` as the reference wiring.

## Forbidden

- Declaring MCP enablement complete because Ansible wrote `mcp.json`
- Project-only Codex write when commissioning Codex for CLI/`mcp list`
- Skipping live verify when the user asked for execute-complete Agent tools
