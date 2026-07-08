---
name: ai-library-entry
description: Govern new or refreshed ai-resource-library entries across vendors, sdk-context, indexes, and prompts. Use when the task adds durable library content, restructures library placement, or remediates an existing pack so it follows the repo-managed collection and validation workflow.
---

# Skill: AI Library Entry

Use this as the primary kickoff for any new or materially refreshed
`ai-resource-library` entry.

This capability decides:

- which content families are in scope
- which library roots own the outputs
- which MCP tools collect or validate each phase
- when the narrower `vendor-doc-collection` helper should be used
- how the entry is validated before it can be called complete

## When to use this skill

Use this skill when:

- the task adds a new library entry or major refresh
- outputs may belong in more than one library subtree
- the collection contract needs to be explicit before scraping or synthesis
- assets, indexes, metadata, or Context7 notes must land in durable paths

Do not use this skill when:

- the user only wants an inline answer with no durable library output
- the task is a tiny edit inside an already-governed entry and no new routing,
  collection, or validation contract is needed

## Primary rule

Do not start collection as an unnamed blob.

Before scraping, summarizing, or writing files, create:

1. a governed plan packet under `docs/plans/YYYY-MM-DD--slug/README.md`
2. a packet-local `entry-spec.yml`

That packet and spec together are the contract for the entry.

## Content-family routing

Classify the request into one or more content families:

| Content family | Primary target | Typical outputs |
|---|---|---|
| `vendor_docs` | `ai-resource-library/vendors/` | full captures, normalized vendor pages, pack README, metadata, page indexes, localized assets |
| `sdk_api_context` | `ai-resource-library/sdk-context/` | Context7-backed implementation notes, API/provider/module references, version-sensitive syntax notes |
| `library_indexes` | `ai-resource-library/indexes/` | lookup tables, inventories, cross-pack maps, machine-friendly indexes |
| `operator_prompts` | `ai-resource-library/prompts/` | entrypoint prompts, request templates, plan kickoffs, operator-facing collection runbooks |

Route outputs by family. Do not force everything into `vendors/` when the work
also creates SDK notes, indexes, or reusable prompts.

## Collection modes

Preserve the scoped collection model from `vendor-doc-collection`:

- **Known page(s)**: named URLs or files already known
- **Concept discovery collection**: discover the right page set first, then
  collect only the accepted scope
- **Full tree offload**: offload a bounded documentation subtree with explicit
  limits and hierarchy ownership

## Tool routing

Use the MCP Research Collection Stack by phase:

- **Firecrawl first** for live vendor/product/help docs
- **Playwright fallback** when the page needs JS, login, clicks, browser state,
  or Firecrawl output is weak
- **Fetch fallback** only for lightweight static reads
- **Context7** for implementation syntax, SDK/provider/API context, and
  validation of indexed technical-doc coverage

Context7 is not the live-collection tool for vendor docs.
Firecrawl is not the substitute for provider/module syntax.

## `entry-spec.yml` minimum contract

Every library-entry packet needs a packet-local `entry-spec.yml` with at least:

- `entry_id`
- `content_families`
- `library_targets`
- `source_urls`
- `required_outputs`
- `output_modes`
- `collection_strategy`
- `context7_required`
- `context7_topics`
- `asset_requirements`
- `allowed_summary_outputs`
- `validation_rules`

Use the template at:

- `references/entry-spec.template.yml`

Minimum contract rules:

- summary outputs are forbidden unless explicitly declared
- every source URL must map to one or more declared outputs
- Context7 topics are required when the entry needs SDK/API/provider/library
  implementation context
- required outputs must declare their path, family, source mapping, and whether
  provenance is mandatory

## Output quality rules

- No unbounded crawl without declared limits.
- No summary-only output unless the contract explicitly allows it.
- Do not accept weak or unhydrated scrape output as done.
- Preserve commands, identifiers, URLs, and technical sequencing.
- Localize required assets when the entry contract calls for local graphics.
- Record provenance on durable outputs.
- Keep sidecar extraction and image localization when the routed helper needs
  them.

## Relationship to `vendor-doc-collection`

`ai-library-entry` is the kickoff capability.

`vendor-doc-collection` remains the narrower helper for structured vendor-doc
export trees with nav contracts, localized images, sidecars, and conformance
checks. Use it when `ai-library-entry` routes the work into a Firecrawl-style
vendor tree.

## Completion gate

Before reporting a library entry complete:

1. run the validator against the packet-local `entry-spec.yml`
2. record the pass token in the packet receipt when required
3. verify the declared outputs exist in the declared target roots

Validator:

```bash
ruby .cursor/skills/ai-library-entry/references/validate_entry_spec.rb \
  docs/plans/YYYY-MM-DD--slug/entry-spec.yml
```

Expected pass token:

```text
AI_LIBRARY_ENTRY_VALIDATION_OK
```

If the validator fails, the entry is not complete.

## References

- `references/routing-matrix.md`
- `references/entry-spec.template.yml`
- `references/validate_entry_spec.rb`
- `.cursor/rules/framework-ai-library-entry.mdc`
- `docs/codex_framework/mcp-research-collection-stack.md`
