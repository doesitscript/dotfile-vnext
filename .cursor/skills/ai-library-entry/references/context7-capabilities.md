# Context7 Capabilities — AI Library Entry Contract

Context7 exposes **two read-only MCP tools**. The entry contract uses **both**
proactively wherever `sdk_api_context`, `library_indexes`, or validation is in
scope.

## Tools

| Tool | Purpose | When to call |
|------|---------|--------------|
| `resolve-library-id` | Map product/package name → Context7 library ID; list versions, snippet counts, reputation | Before `query-docs` unless the spec already pins `/org/project` or `/org/project/version` |
| `query-docs` | Retrieve indexed docs + code examples for a library ID and natural-language task | Implementation syntax, OpenAPI/Swagger, config patterns, API usage, coverage validation |

## Proactive stance — use Context7 for what it specializes in

Default to Context7 (not inference, not fetch-only summaries) for:

- **SDK / provider / module syntax** — version-pinned when the repo has a contract
- **OpenAPI / Swagger** — endpoint purpose, auth, request/response shapes, curl examples, admin API usage
- **Config accuracy** — `config.yaml`, env vars, Helm values, CLI flags
- **Topic shards** — one durable file per topic cluster
- **Firecrawl cross-check** — compare every priority Firecrawl capture against a matching Context7 query; record gaps and update indexes when new pages land
- **`library_indexes` packs** — crosswalks, coverage maps, Firecrawl↔Context7 reconciliation JSON, and capture backlogs under `indexes/<entry>/`

Context7 is the **primary interpretive layer** for OpenAPI/Swagger. A local
spec mirror (fetch) is optional offline material; Context7 queries are the
authoritative usage surface for agents.

## What Firecrawl still owns

| Job | Owner |
|-----|--------|
| Live vendor page collection | Firecrawl (Playwright fallback) |
| Full-page vendor captures | Firecrawl `full_capture` or declared `structured_summary` |
| Login/JS-rendered pages | Playwright |
| Lightweight static one-off reads | Fetch |

Firecrawl collects **pages**. Context7 validates, enriches, cross-checks, and
interprets **implementation and API semantics**. Neither replaces the other.

## Required `library_indexes` pack

When an entry includes `vendor_docs` and `context7_required: true`, also declare
`library_indexes` and produce an `indexes/<entry>/` pack at minimum:

| File | Purpose |
|------|---------|
| `README.md` | Index of crosswalks, coverage maps, and reconciliation artifacts |
| `doc-api-inventory-crosswalk.json` | doc page ↔ OpenAPI path ↔ inventory key |
| `firecrawl-context7-crosscheck.json` | per-page Firecrawl vs Context7 gap report |
| `capture-backlog.yml` | prioritized Firecrawl follow-up list for thin captures |

**Update rule:** when adding a new priority doc page, OpenAPI path, or inventory
surface, extend the crosswalk and re-run the Firecrawl↔Context7 cross-check in
the same build slice.

## Firecrawl ↔ Context7 cross-check

For every priority page in the entry spec:

1. Firecrawl captures the live page (or reuse existing capture).
2. Context7 runs a page-specific `query-docs` pass.
3. Build compares term/heading overlap and relative depth.
4. Write per-page `gap_notes` to `firecrawl-context7-crosscheck.json` and
   `metadata.json`.

Treat `context7_only_terms` as capture backlog — Firecrawl summary may need
refresh or full capture.

## Recommended `entry-spec.yml` `context7` block

```yaml
context7:
  tools:
    - resolve-library-id
    - query-docs
  resolve_libraries: [...]
  topic_shards: [...]
  page_validation:
    enabled: true
    library_id: /websites/litellm_ai
    metadata_field: context7_page_validation
  firecrawl_cross_check:
    enabled: true
    library_id: /websites/litellm_ai
    index_path: .../indexes/<entry>/firecrawl-context7-crosscheck.json
    backlog_path: .../indexes/<entry>/capture-backlog.yml
    update_on_new_pages: true
  openapi_swagger:
    enabled: true
    primary_tool: context7
    library_id: /websites/litellm_ai
    spec_mirror:
      url: https://example.com/openapi.json
      path: .../vendors/<entry>/openapi/openapi.json
    outputs:
      overview: .../sdk-context/context7/<entry>/openapi-swagger-overview.md
      usage_notes: .../sdk-context/context7/<entry>/openapi-usage-notes.md
    core_paths:
      - /v1/chat/completions
      - /key/generate
  crosswalk_index:
    enabled: true
    path: .../indexes/<entry>/doc-api-inventory-crosswalk.json
```

## Output layout

**`sdk-context/context7/<entry>/`**

- `README.md` — resolved library IDs + shard index
- `<topic>.md` — topic shards
- `openapi-swagger-overview.md` — Context7 OpenAPI/Swagger overview
- `openapi-usage-notes.md` — per-endpoint Context7 usage notes

**`indexes/<entry>/`**

- `README.md` — indexes pack entrypoint
- `doc-api-inventory-crosswalk.json`
- `firecrawl-context7-crosscheck.json`
- `capture-backlog.yml`

Record in `vendors/<entry>/metadata.json`:

- `context7_resolved_libraries`
- `context7_page_validation`
- `context7_firecrawl_crosscheck_summary`

## Build script expectations

1. `resolve-library-id` for each declared library
2. Version pin when `version_pin` is declared
3. One markdown file per `topic_shards[]` row
4. Context7-first `openapi_swagger` outputs (overview + per-path usage notes)
5. Optional `spec_mirror` fetch for offline JSON — does not replace Context7
6. Firecrawl↔Context7 cross-check for every priority page
7. Write/update `capture-backlog.yml` for pages flagged by the cross-check
8. Emit/update `indexes/<entry>/` pack
9. Support `--context7-only` to refresh Context7, cross-check, backlog, and indexes without re-scraping

Shared helper: `references/shared/context7_entry.mjs`
