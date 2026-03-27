# AI Instructions: Building MCP Server Roles

This document captures the repo-native pattern for MCP server roles. Use it
when adding a new MCP server or refactoring an existing one.

## Start With Upstream Classification

Before writing tasks, classify the upstream server from its README, package
metadata, and example client config.

Record these decisions in the role's `mcp_contract.yml`:

- `runtime`
  Usually `node`, `python`, `http`, or `other`
- `install_method`
  Examples: `npm`, `pipx`, `uvx`, `clone-build`, `configure-only`
- `interaction_model`
  `launcher` or `interactive/editor`
- `verify_mode`
  Examples: `command_smoke_test`, `tool_listing`, `manual_editor_validation`
- `supported_targets`
  For v1: `cursor`, `vscode`, `codex`, `openapi`

Do not guess these from memory when the upstream repo can answer them.

## Canonical Control Surface

Controller-side MCP installs belong in:

- `playbooks/mac/mcp_servers.yaml`

Do not add a new MCP role to a broad dev-node umbrella play by default.
Only do that when the server is intentionally part of baseline workstation
convergence for many hosts.

## Role Layout

Every MCP role should live under `roles/mcp_servers/<role-name>/` and follow
this layout:

```text
<role-name>/
  README.md
  mcp_contract.yml
  defaults/main.yml
  meta/argument_specs.yml
  meta/main.yml
  tasks/
    main.yml
    present.yml
    absent.yml
    mac.yml
    ubuntu.yml
    configure_target.yml
    remove_target.yml
    openapi_stub.yml
```

Use `roles/mcp_servers/_template/` as the scaffold reference and
`roles/mcp_servers/drawio/` as the first canonical example.

## Required Public Interface

Every MCP role should expose:

- `<server>_state: present|absent`
- `<server>_targets`
  Default: `['cursor']`
- `<server>_project_root`
  Default: current repo root for the playbook run
- `<server>_cursor_config_path`
  Default: `{{ <server>_project_root }}/.cursor/mcp.json`
- `<server>_vscode_config_path`
  Default: `{{ <server>_project_root }}/.vscode/mcp.json`
- `<server>_codex_config_path`
  Default: `{{ <server>_project_root }}/.codex/config.toml`
- `<server>_codex_entry`
  Structured Codex MCP entry with exactly one of `url` or `command`, plus optional `args`, `env`, `cwd`, and `required`
  Some interactive/editor servers may also need `startup_timeout_sec`.

`openapi` is an explicit stub target in v1. If selected, fail fast with a clear
message rather than pretending to support it.

## Target Selection Rules

Variables are the canonical interface:

- `<server>_targets: ['cursor']`

Tags are focused execution helpers:

- `mcp_target_cursor`
- `mcp_target_vscode`
- `mcp_target_codex`
- `mcp_target_openapi`

Behavior:

- if no target tags are requested, use `<server>_targets`
- if one or more target tags are requested, those tags override the variable for
  that run
- target-independent install/uninstall tasks should still be reachable when a
  target tag is used

## Configure / Remove Pattern

Cursor and VS Code share the same JSON merge behavior:

1. Ensure the parent directory exists.
2. Create `mcp.json` with a single `mcpServers` entry when missing.
3. Read and merge when the file already exists.
4. On `absent`, remove only the role's server key and leave other entries alone.

Use `configure_target.yml` and `remove_target.yml` for this pattern.

For Ansible-capable MCP servers on macOS, include the repo's WinRM safety env
vars in the generated MCP entry instead of assuming interactive shell startup
already happened:

- `OBJC_DISABLE_INITIALIZE_FORK_SAFETY=yes`
- `no_proxy=*`
- `NO_PROXY=*`

This prevents the macOS `Python quit unexpectedly` fork/proxy crash path seen
when Python touches `_scproxy` inside a multi-threaded child process launched by
the MCP host.

Codex uses the shared project `.codex/config.toml` block-management pattern:

1. Ensure the parent directory exists.
2. Create the file if it does not exist.
3. Manage one Ansible-owned block per MCP server key.
4. Preserve unrelated config outside that block.
5. On `absent`, remove only the role's block.

Use the shared helper tasks under `roles/mcp_servers/_shared/tasks/` for this
pattern instead of per-role TOML merge logic or `codex mcp` CLI mutation.

Do not hand-edit `.cursor/mcp.json` or `.vscode/mcp.json` as an implementation
shortcut when those files are already owned by an MCP role. Change the owning
role/tasks instead. Only make a one-off manual config edit when the user
explicitly asks for that exception.

## README Requirements

Every MCP role README should include:

- upstream source
- classification summary
- `Apply / Verify / Undo / Change class`
- variables
- target model
- tags
- validation approach

Keep install, config, verify, and remove in the same shape across roles.

## Validation Pattern

Use `docs/reports/mcp_server_validations/_template/` for the reusable validation
shape.

The validation artifact should prove:

- install surface
- config merge behavior
- tool surface or command surface
- notable side effects such as browser launch or editor handoff

## New Role Checklist

1. Read the upstream README/source.
2. Fill in `mcp_contract.yml`.
3. Copy `roles/mcp_servers/_template/`.
4. Replace install/uninstall stubs with runtime-appropriate tasks.
5. Keep the public interface state-based and target-list-based.
6. Add the role to `playbooks/mac/mcp_servers.yaml` if it belongs on the controller.
7. Add or update the validation report under `docs/reports/mcp_server_validations/`.
8. Add a row to `roles/mcp_servers/README.md`.
