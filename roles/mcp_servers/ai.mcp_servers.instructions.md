# AI Instructions: Building MCP Server Roles

This document captures the repo-native pattern for MCP server roles. Use it
when adding a new MCP server or refactoring an existing one.

## MCP Research Collection Stack Routing

For research and fetching work, prefer the **MCP Research Collection Stack**
before ad hoc browser/search behavior. Use this order:

1. Context7 first for known products, libraries, APIs, SDKs, Terraform
   providers, Kubernetes docs, AWS docs, and vendor docs.
2. Firecrawl for documentation ingestion, crawl/search/extraction, or collecting
   pages from multiple sources.
3. Playwright when Firecrawl extraction is poor, login is required, JavaScript
   rendering is required, screenshots are useful, or browser state matters.
4. Fetch only as a lightweight fallback for simple page fetching.

Purpose mapping:

| Purpose | Best Choice |
|---|---|
| General webpage fetching | Fetch |
| Documentation extraction | Firecrawl |
| Browser-rendered sites | Playwright |
| Technical docs / APIs | Context7 |

Context7 is not a general web scraper. Use it as a known-documentation lookup
and prompt-context tool for code/library/framework/API syntax. Firecrawl is the
general live-web/vendor documentation collection tool.

Practical examples:

- Terraform AWS provider syntax for `aws_kms_key`: Context7 first.
- Kubernetes resource syntax or Helm chart values: Context7 first.
- Vendor product docs, Zerto docs, arbitrary URLs, product KBs, or blogs:
  Firecrawl first.
- Pages that require login, clicking, JavaScript rendering, or screenshots:
  Playwright after Firecrawl fails or when the need is obvious.
- Plain static pages with no extraction/crawl need: Fetch.

For Firecrawl collection:

- one known URL: scrape
- multiple known URLs: batch scrape
- discover URLs in a docs section: map, then scrape or batch scrape
- unknown sources: search
- broad docs-section coverage: crawl with explicit limits
- structured fields: extract or JSON scrape format

Use the smallest tool that can answer the research question. Do not crawl a
whole site when a mapped URL list plus focused scrape is enough.

## Morph WarpGrep — Local Codebase Search

Morph MCP (`roles/mcp_servers/morph`) is separate from the research collection
stack. It answers "where in *this repo* does X live?" via WarpGrep
`codebase_search`, not vendor documentation.

- Install via `playbooks/mac/mcp_servers.yaml --tags morph`
- Secret: `vault_shared_morph_api_key` in `vault/shared.vault.yml`
- Launcher: global `morph-mcp` binary from `@morphllm/morphmcp` (not `npx --prefer-offline`)
- Reflex tools stay enabled by default; they only run when explicitly called

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

This prevents the macOS `Python quit unexpectedly` fork/proxy crash path seen
when Python touches `_scproxy` inside a multi-threaded child process launched by
the MCP host.

Codex uses the shared project `.codex/config.toml` block-management pattern:

1. Ensure the parent directory exists.
2. Create the file if it does not exist.
3. Manage one Ansible-owned block per MCP server key.
4. Preserve unrelated config outside that block.
5. On `absent`, remove only the role's block.

**Required dual-write:** when `codex` is commissioned, also write
`~/.codex/config.toml` (`*_configure_codex_user: true` by default).
`codex mcp list` / IDE surfaces lean on user config; project-only write is an
incomplete Codex commission (see `CLIENT_COMMISSION_GATES.md`).

Use the shared helper tasks under `roles/mcp_servers/_shared/tasks/` for this
pattern instead of per-role TOML merge logic or `codex mcp` CLI mutation.

## Access ≠ commission (mandatory)

**Do not** treat “Ansible wrote mcp.json / project Codex TOML” as Agent/Codex
ready. That incomplete commission delayed Morph and can hit **any** project MCP.

Authority: `roles/mcp_servers/CLIENT_COMMISSION_GATES.md`

Every role `present.yml` must end with
`_shared/tasks/report_client_commission_gates.yml` (file asserts + Cursor
project allowlist warning + receipt). Prefer Cursor target `cursor_user` for
Agent-critical servers; project `cursor` needs allowlist + restart.

Do not hand-edit `.cursor/mcp.json` or `.vscode/mcp.json` as an implementation
shortcut when those files are already owned by an MCP role. Change the owning
role/tasks instead. Only make a one-off manual config edit when the user
explicitly asks for that exception.

## Secret Hygiene

Tracked client config must not contain vault-backed API keys or bearer tokens.
When an MCP server needs a secret:

1. Load the secret from vault in the role.
2. Render a local env file under `~/.config/dotfile-vnext/mcp/env.d/` with mode
   `0600`.
3. Point `.cursor/mcp.json`, `.vscode/mcp.json`, and `.codex/config.toml` at
   `bin/mcp-server-env-wrapper`.
4. Put only non-secret metadata in the rendered client `env` block.
5. Verify tracked config does not contain the secret variable name or value.

This is required for Firecrawl and Context7. It is also the default for future
research/fetch MCP servers with API keys.

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
