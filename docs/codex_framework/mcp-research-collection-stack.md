# MCP Research Collection Stack

The **MCP Research Collection Stack** is the controller-local capability for
external documentation, web, and rendered-browser context collection.

The durable capability identifier is `mcp_research_collection_stack`. The name
describes the job, not a vendor, and the role surfaces remain independently
removable:

- `roles/mcp_servers/context7`
- `roles/mcp_servers/firecrawl`
- `roles/mcp_servers/playwright`
- `roles/mcp_servers/fetch`

Machine-readable ownership lives in:

```text
docs/codex_framework/capabilities/mcp-research-collection-stack.yml
```

Treat that manifest as the install/update/remove inventory for this capability.
Do not add new stack-specific rules as scattered global instructions unless the
manifest and this document are updated in the same slice.

## Modularity Boundary

Owned capability files:

- `docs/codex_framework/capabilities/mcp-research-collection-stack.yml`
- `docs/codex_framework/mcp-research-collection-stack.md`
- `docs/plans/2026-06-24--mcp-research-collection-stack/README.md`
- `docs/reports/mcp_server_validations/research_collection_stack/README.md`
- `roles/mcp_servers/context7`
- `roles/mcp_servers/firecrawl`
- `roles/mcp_servers/playwright`
- `roles/mcp_servers/fetch`
- `roles/mcp_servers/_shared/tasks/render_env_file.yml`
- `bin/mcp-server-env-wrapper`

Integration anchors:

- `.cursor/rules/framework-mcp-and-tool-usage.mdc`
- `docs/codex_framework/README.md`
- `roles/mcp_servers/README.md`
- `roles/mcp_servers/ai.mcp_servers.instructions.md`
- `playbooks/mac/mcp_servers.yaml`
- `inventory/host_vars/mac-dev.yaml`
- `.cursor/mcp.json`
- `.codex/config.toml`

The rule file should stay a router, not the owner of the capability details.
The role docs own MCP-server implementation details. This document owns the
framework routing model. The manifest owns cleanup boundaries.

## Commissioned Client Scope

On `mac-dev`, the MCP Research Collection Stack is commissioned for Cursor and
Codex:

```yaml
context7_mcp_targets:
  - cursor
  - codex
firecrawl_mcp_targets:
  - cursor
  - codex
playwright_mcp_targets:
  - cursor
  - codex
fetch_mcp_targets:
  - cursor
  - codex
```

The roles support VS Code, but `.vscode/mcp.json` is not part of the
commissioned target set unless `vscode` is added to the relevant target lists or
a focused run includes `mcp_target_vscode`.

After MCP client config changes, reload the client. Cursor Settings and
already-running chat sessions can reflect stale MCP availability until the
window/session restarts or the MCP server list is refreshed. Configured servers
also do not become tools inside a chat session that was started before the MCP
configuration was applied.

## Removal Path

1. Run the commissioned roles absent before deleting files:

   ```bash
   ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags context7,firecrawl,playwright,fetch \
     -e context7_mcp_state=absent \
     -e firecrawl_mcp_state=absent \
     -e playwright_mcp_state=absent \
     -e fetch_mcp_state=absent
   ```

2. Remove owned files listed in the manifest.
3. Remove integration anchors from the playbook, host vars, global MCP rule,
   MCP role docs, Cursor config, and Codex config.
4. Rerun syntax/lint and verify the removed server keys are absent.

## Routing Model

Use the stack in this order:

1. **Context7** for known products, libraries, APIs, SDKs, Terraform providers,
   Kubernetes docs, AWS docs, and vendor docs.
2. **Firecrawl** for documentation ingestion, crawl/search/extraction, or
   collecting pages from multiple sources.
3. **Playwright** when extraction quality is poor, login is required,
   JavaScript rendering is required, screenshots help, or browser state matters.
4. **Fetch** only as a lightweight fallback for simple pages.

| Purpose | Best Choice |
|---|---|
| General webpage fetching | Fetch |
| Documentation extraction | Firecrawl |
| Browser-rendered sites | Playwright |
| Technical docs / APIs | Context7 |

## General Usage Model

This stack is not limited to `dotfile-vnext` implementation work. It is the
general research and fetching path for coding agents when they need external
technical context.

Think of the tools by source type:

| Source type | First tool | Why |
|---|---|---|
| Known library, SDK, framework, API, Terraform provider, Kubernetes resource, Helm chart, Python package | Context7 | It resolves known documentation sources and injects current/version-specific docs and code examples into the agent context. |
| Vendor/product docs, arbitrary URLs, product KBs, blog posts, unknown docs sites, multi-page doc collection | Firecrawl | It is built for live web content collection through search, scrape, map, crawl, batch scrape, and extraction workflows. |
| Login-required, JavaScript-rendered, click/navigation-dependent, screenshot-needed pages | Playwright | It acts as the browser-backed fallback when page state or rendering matters. |
| Simple static HTML or one-off lightweight page reads | Fetch | It is the low-cost fallback when full extraction/crawling is unnecessary. |

Bottom line:

- **Context7 helps agents write correct code from known docs.**
- **Firecrawl helps agents collect messy web/vendor docs.**
- **Playwright helps agents inspect pages like a user/browser.**
- **Fetch helps agents cheaply read simple static pages.**

## Agent Prompt Patterns

Use explicit tool-routing language when the task benefits from it:

```text
Use Context7. Show me the current Terraform AWS provider syntax for aws_kms_key.
```

```text
Use Context7 for the Kubernetes API syntax, then use Firecrawl for the vendor
installation docs that are not in Context7.
```

```text
Use Firecrawl to collect the product docs under this vendor documentation
section. If extraction is incomplete or navigation depends on JavaScript, use
Playwright.
```

```text
Use Fetch only if this is a simple static page and we do not need crawl,
structured extraction, screenshots, or browser state.
```

For known Context7 libraries, include the exact product/library and version when
you know them. For Firecrawl, include the URL scope and whether you need a
single page, multiple known URLs, URL discovery, site-section coverage, or
structured fields.

## Vendor Documentation Example

For product documentation such as:

```text
Zerto installation docs
Zerto member account setup docs
```

do not expect Context7 to be the primary tool. Zerto-style docs are vendor help
pages, not common package/library/API docs. Use Firecrawl first for discovery
and collection:

1. Use Firecrawl `search` when the right URLs are not known.
2. Use Firecrawl `map` when the docs site or section is known but the page list
   is not.
3. Use Firecrawl `scrape` for one known page.
4. Use Firecrawl `batch_scrape` for multiple known pages.
5. Use Firecrawl `crawl` only when broad section coverage is needed and limits
   are explicit.
6. Escalate to Playwright when the site needs login, JavaScript rendering,
   clicking, or screenshots.

Then use Context7 separately for implementation syntax that comes from known
engineering docs, such as Terraform provider resources, Kubernetes manifests,
SDK calls, or language/framework APIs.

## Firecrawl Collection Shape

When using Firecrawl, choose the smallest collection mode that fits:

| Need | Firecrawl mode |
|---|---|
| One known URL | `scrape` |
| Multiple known URLs | `batch_scrape` |
| Discover URLs in a known docs site/section | `map`, then `scrape` or `batch_scrape` |
| Search across the web for unknown sources | `search` |
| Broad multi-page section coverage | `crawl` with explicit limits |
| Structured fields from pages | `extract` or JSON scrape format |

Prefer structured/JSON extraction when you only need specific fields. Use full
markdown when the task genuinely needs page-level reading, summarization, or
doc-structure analysis.

## Multi-Agent Use

This stack supports the repo's single-agent-first workflow and future
multi-agent split:

| Role | Default use |
|---|---|
| Planner / Steward | Select the routing path, preserve the user target, and require source-backed evidence. |
| Researcher | Use Context7, Firecrawl, Playwright, then Fetch according to the routing model. |
| Executor | Install/update the MCP server roles and render Cursor/Codex config through Ansible. |
| Independent Validator | Check that docs, roles, inventory, config, secrets, and receipts agree before completion. |

For parallel research, assign different sources or domains to workers, but keep
tool order stable inside each worker. Do not let one worker's Fetch result
override a better Context7 or Firecrawl source without a reason recorded in the
receipt.

## Secret Model

Tracked config must not contain vault-backed API keys. Secret-backed servers
render local env files:

```text
~/.config/dotfile-vnext/mcp/env.d/context7.env
~/.config/dotfile-vnext/mcp/env.d/firecrawl.env
```

Those files are mode `0600`. `.cursor/mcp.json` and `.codex/config.toml` point
at `bin/mcp-server-env-wrapper`, which sources the env file at runtime and then
execs the upstream MCP server command.

## Apply / Verify / Undo / Change Class

| Item | Contract |
|---|---|
| Apply | `ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags context7,firecrawl,playwright,fetch` |
| Verify | Syntax/lint, task preview, apply, idempotence rerun, npm binaries, Cursor/Codex server keys, no plaintext secrets, env file mode `0600` |
| Undo | Run the same playbook with `-e '<role>_mcp_state=absent'` for the role being removed |
| Change class | Idempotent controller-local configuration management |

## Architecture/Structure Diagram

```mermaid
flowchart TD
  plan["docs/plans/2026-06-24--mcp-research-collection-stack/README.md"] --> playbook["playbooks/mac/mcp_servers.yaml"]
  framework["docs/codex_framework/mcp-research-collection-stack.md"] --> rules["Framework routing guidance"]
  inventory["inventory/host_vars/mac-dev.yaml"] --> playbook
  vault["vault/mac_dev.vault.yml"] --> envfiles["local 0600 MCP env files"]

  playbook --> context7["roles/mcp_servers/context7"]
  playbook --> firecrawl["roles/mcp_servers/firecrawl"]
  playbook --> playwright["roles/mcp_servers/playwright"]
  playbook --> fetch["roles/mcp_servers/fetch"]

  context7 --> cursor[".cursor/mcp.json"]
  firecrawl --> cursor
  playwright --> cursor
  fetch --> cursor

  context7 --> codex[".codex/config.toml"]
  firecrawl --> codex
  playwright --> codex
  fetch --> codex
```

## Capability Routing Diagram

```mermaid
flowchart LR
  need["Need external docs or web context"] --> known{"Known product/library?"}
  known -- yes --> context7["Context7"]
  known -- no --> docs{"Need crawl/search/extraction?"}
  docs -- yes --> firecrawl["Firecrawl"]
  docs -- no --> browser{"Needs rendered browser?"}
  browser -- yes --> playwright["Playwright"]
  browser -- no --> fetch["Fetch"]
  firecrawl -- poor extraction --> playwright
  fetch -- insufficient --> firecrawl
```

## Naming/Modeling Diagram

```mermaid
flowchart TD
  capability["mcp_research_collection_stack"] --> roles["Capability-focused MCP roles"]
  roles --> context7["context7_mcp_*"]
  roles --> firecrawl["firecrawl_mcp_*"]
  roles --> playwright["playwright_mcp_*"]
  roles --> fetch["fetch_mcp_*"]

  context7 --> ckey["server key: context7"]
  firecrawl --> fkey["server key: firecrawl"]
  playwright --> pkey["server key: playwright"]
  fetch --> fekey["server key: fetch"]
```
