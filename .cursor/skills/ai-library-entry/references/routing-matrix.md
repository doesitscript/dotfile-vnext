# AI Library Entry Routing Matrix

Use this matrix before collecting or writing files.

## Content family to target root

| Family | Primary root | Typical output types |
|---|---|---|
| `vendor_docs` | `ai-resource-library/vendors/` | full pages, normalized exports, metadata, page indexes, localized assets |
| `sdk_api_context` | `ai-resource-library/sdk-context/` | Context7-backed implementation notes, OpenAPI/Swagger notes, SDK call patterns |
| `library_indexes` | `ai-resource-library/indexes/` | crosswalks, Firecrawl↔Context7 cross-checks, coverage maps, pack README |
| `operator_prompts` | `ai-resource-library/prompts/` | request templates, kickoff prompts, reusable operator runbooks |

**Default:** `vendor_docs` + `context7_required` ⇒ also `library_indexes` and
`indexes/<entry>/` outputs.

## Tool routing

| Question | Primary tool | Fallback | Notes |
|---|---|---|---|
| Live vendor/help docs | Firecrawl | Playwright, then Fetch | Declare scope before crawl |
| JS-rendered or login-dependent docs | Playwright | Firecrawl retry with stronger settings | Do not accept weak scrape output |
| Lightweight static page read | Fetch | Firecrawl scrape | Use only when structured extraction is unnecessary |
| SDK/API/provider syntax, version-pinned implementation notes | Context7 (`resolve-library-id`, `query-docs`) | official docs fallback | Record library IDs, topic shards, validation gaps |
| OpenAPI / Swagger interpretation (overview, auth, curl, request shape) | Context7 `query-docs` | vendor doc fallback | **Primary** interpretive layer for agents |
| OpenAPI spec JSON mirror (offline) | Fetch or scripted HTTP GET | — | Optional `spec_mirror`; does not replace Context7 |
| Machine path inventory from mirrored spec | local parser → `library_indexes` | — | Complements Context7; index of paths/operations |
| Firecrawl capture vs Context7 depth/overlap | Context7 cross-check pass | — | Required when both tools run; write `firecrawl-context7-crosscheck.json` |
| Doc page ↔ API ↔ inventory crosswalk | `library_indexes` JSON + Context7 hints | manual curation | Update when pages/paths/inventory change |

## Output rules by family

| Family | Required durable anchors |
|---|---|
| `vendor_docs` | pack `README.md`, provenance, metadata/index file, declared page outputs, localized assets when required |
| `sdk_api_context` | resolved library IDs, topic shard paths, OpenAPI/Swagger Context7 notes, README index |
| `library_indexes` | `indexes/<entry>/README.md`, crosswalk JSON, Firecrawl↔Context7 cross-check JSON when Context7 is in scope |
| `operator_prompts` | reusable prompt file, clear start/stop conditions, reference to the kickoff capability when appropriate |

## Summary policy

- Default: forbidden
- Allowed only when the packet-local `entry-spec.yml` declares the exact output
  in `allowed_summary_outputs`
- Full captures must not be disguised as summaries

## Cross-check update rule

When adding or refreshing vendor doc pages:

1. Re-run Firecrawl capture for changed URLs.
2. Re-run matching Context7 `query-docs` queries.
3. Update `firecrawl-context7-crosscheck.json` and crosswalk mappings in the
   same build slice.
