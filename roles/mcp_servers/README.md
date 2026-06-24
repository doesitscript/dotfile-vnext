# MCP Server Roles

Each subdirectory is an Ansible role that installs and configures one MCP
(Model Context Protocol) server for repo-local client integration.

## Roles

| Role | Server | Runtime | Interaction | Targets | Repo |
|---|---|---|---|---|---|
| `redhat-ansible` | Red Hat Ansible Cursor extension MCP | Node.js (extension build) | interactive/editor | Cursor | [redhat.ansible](https://marketplace.visualstudio.com/items?itemName=redhat.ansible) |
| `mcp-sysoperator` | Infrastructure ops (file, shell, Terraform) | Node.js (npm) | launcher | Cursor | [tarnover/mcp-sysoperator](https://github.com/tarnover/mcp-sysoperator) |
| `ansible-mcp` | Ansible playbook/inventory intelligence | Python (pip + venv) | launcher | Cursor | [bsahane/mcp-ansible](https://github.com/bsahane/mcp-ansible) |
| `openai_docs` | OpenAI developer docs (search + read) | HTTP + local Codex | launcher | Cursor, Codex | [Docs MCP](https://developers.openai.com/resources/docs-mcp) |
| `langfuse_docs` | Langfuse developer docs (search + read) | HTTP | launcher | Cursor, Codex | [Docs MCP](https://langfuse.com/docs/docs-mcp) |
| `hf-mcp-server` | Hugging Face Hub, docs, papers, datasets, models, and Spaces tools | HTTP | launcher | Cursor, Codex | [Hugging Face MCP Server](https://huggingface.co/docs/hub/hf-mcp-server) |
| `drawio` | draw.io MCP tool server | Node.js (npm) | interactive/editor | Cursor, Codex, VS Code, OpenAPI stub | [lgazo/drawio-mcp-server](https://github.com/lgazo/drawio-mcp-server) |
| `netbox` | NetBox MCP query server | Python (uv) | launcher | Cursor, Codex | [netboxlabs/netbox-mcp-server](https://github.com/netboxlabs/netbox-mcp-server) |
| `context7` | Technical docs, APIs, SDK references, and library docs | Node.js (npm) | launcher | Cursor, Codex | [upstash/context7](https://github.com/upstash/context7) |
| `firecrawl` | Firecrawl web scraping, crawling, search, and extraction MCP | Node.js (npm) | launcher | Cursor, Codex | [firecrawl/firecrawl-mcp-server](https://github.com/firecrawl/firecrawl-mcp-server) |
| `playwright` | Browser-rendered pages, login flows, screenshots, and browser state | Node.js (npm) | launcher/browser | Cursor, Codex | [microsoft/playwright-mcp](https://github.com/microsoft/playwright-mcp) |
| `fetch` | Lightweight webpage fetching fallback | Node.js (npm) | launcher | Cursor, Codex | [zcaceres/fetch-mcp](https://github.com/zcaceres/fetch-mcp) |

## MCP Research Collection Stack

The controller-local research/fetch capability is named **MCP Research
Collection Stack**. The name describes the job rather than one vendor, so the
stack can grow without renaming the framework surface.

Use the tools in this order:

1. **Context7** for known products, libraries, APIs, SDKs, Terraform providers,
   Kubernetes docs, AWS docs, and vendor docs.
2. **Firecrawl** for documentation ingestion, crawl/search/extraction, and
   collecting pages from multiple sources.
3. **Playwright** when Firecrawl extraction quality is poor, login is required,
   JavaScript rendering is required, screenshots help, or browser state matters.
4. **Fetch** only as the lightweight fallback for simple pages.

Purpose mapping:

| Purpose | Best Choice |
|---|---|
| General webpage fetching | Fetch |
| Documentation extraction | Firecrawl |
| Browser-rendered sites | Playwright |
| Technical docs / APIs | Context7 |

Context7 is a known-documentation lookup/index, not a web scraper. Use it for
current API and implementation syntax. Firecrawl is the live-web and vendor-docs
collector. For example, use Firecrawl first for Zerto installation or account
setup documentation, then use Context7 for any Terraform, Kubernetes, SDK, or
framework syntax needed while implementing from those docs.

Vault-backed API keys must not be rendered into tracked `.cursor/mcp.json` or
`.codex/config.toml`. Roles that need secrets render local `0600` env files
under `~/.config/dotfile-vnext/mcp/env.d/` and point client config at
`bin/mcp-server-env-wrapper`.

## Canonical Pattern

- `roles/mcp_servers/_template/` is the MCP role scaffold.
- `roles/mcp_servers/drawio/` is the first canonical JSON-target example.
- `roles/mcp_servers/openai_docs/` is the first Codex-target example.
- `roles/mcp_servers/langfuse_docs/` is a simple public HTTP docs MCP example.
- `roles/mcp_servers/huggingface/` is the official Hugging Face Hub HTTP MCP example.
- `roles/mcp_servers/context7/` is the technical-docs first choice for known products and libraries.
- `roles/mcp_servers/firecrawl/` is the secret-safe documentation ingestion example.
- `roles/mcp_servers/playwright/` is the browser-rendered fallback example.
- `roles/mcp_servers/fetch/` is the lightweight fetch fallback example.
- `playbooks/mac/mcp_servers.yaml` is the focused controller-side control surface for local MCP convergence on the Mac.

## Hugging Face Auth Note

`roles/mcp_servers/huggingface/` uses the upstream `hf-mcp-server` key and
`https://huggingface.co/mcp?login` endpoint. That default does not require an
API key in repo-managed config; it is intended to trigger client-side OAuth.

For Codex, verify the rendered entry with:

```bash
codex mcp get hf-mcp-server --json
```

Run OAuth only when account-scoped tools are needed:

```bash
codex mcp login hf-mcp-server
```

Bearer-token auth is a fallback, not the default repo implementation. If needed,
use local secret material such as `HF_TOKEN` with the non-login endpoint
`https://huggingface.co/mcp`; do not commit Hugging Face tokens or bearer
headers into repo-managed MCP config.

## Target Model

For v1, new MCP roles should use:

- `<server>_targets`
  Default: `['cursor']`
- repo-local config targets:
  - `.cursor/mcp.json`
  - `.vscode/mcp.json`
- project Codex config target:
  - `.codex/config.toml`
- `openapi` as an explicit stub target that fails fast until implemented

Target tags are available for focused runs:

- `mcp_target_cursor`
- `mcp_target_vscode`
- `mcp_target_codex`
- `mcp_target_openapi`

## Targeting Individual Servers

Install only one server:

```bash
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags drawio
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags context7
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags firecrawl
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags playwright
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags fetch
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags langfuse-docs
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags huggingface
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags ansible-mcp
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags mcp-sysoperator
```

Install one server and target a specific client config:

```bash
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags drawio,mcp_target_cursor
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags drawio,mcp_target_vscode
```

If no target tag is supplied, the role uses its `<server>_targets` default or
explicit variable override.

Supported targets and commissioned targets are not the same thing. A role may
support `cursor`, `vscode`, and `codex`, while a host only commissions a subset
through inventory. For the MCP Research Collection Stack on `mac-dev`, the
commissioned targets are `cursor` and `codex`; `.vscode/mcp.json` is not updated
unless `vscode` is added to the relevant `*_mcp_targets` list or a focused run
uses `mcp_target_vscode`.

After client config changes, reload the MCP client. Cursor Settings and already
running chat sessions can show stale MCP availability until the window/session
restarts or the MCP server list is refreshed.

## Directory Layout

```text
roles/mcp_servers/
  README.md
  _template/
  redhat-ansible/
  mcp-sysoperator/
  ansible-mcp/
  openai_docs/
  langfuse_docs/
  huggingface/
  context7/
  firecrawl/
  playwright/
  fetch/
  drawio/
  netbox/
  _legacy_builder/
```

## Adding A New MCP Server

1. Classify the upstream server from its repo/README.
2. Copy `roles/mcp_servers/_template/`.
3. Fill in the role's `mcp_contract.yml`.
4. Replace the install/uninstall stubs with runtime-appropriate tasks.
5. Keep the public interface state-based and target-list-based.
6. Add validation artifacts under `docs/reports/mcp_server_validations/`.
7. Add the role to `playbooks/mac/mcp_servers.yaml` when it belongs on the controller.
8. See `roles/mcp_servers/ai.mcp_servers.instructions.md` for the full pattern.
