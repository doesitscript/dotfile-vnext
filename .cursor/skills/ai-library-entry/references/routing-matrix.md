# AI Library Entry Routing Matrix

Use this matrix before collecting or writing files.

## Content family to target root

| Family | Primary root | Typical output types |
|---|---|---|
| `vendor_docs` | `ai-resource-library/vendors/` | full pages, normalized exports, metadata, page indexes, localized assets |
| `sdk_api_context` | `ai-resource-library/sdk-context/` | Context7-backed implementation notes, SDK call patterns, provider/module notes |
| `library_indexes` | `ai-resource-library/indexes/` | inventories, source maps, lookup tables, coverage maps |
| `operator_prompts` | `ai-resource-library/prompts/` | request templates, kickoff prompts, reusable operator runbooks |

## Tool routing

| Question | Primary tool | Fallback | Notes |
|---|---|---|---|
| Live vendor/help docs | Firecrawl | Playwright, then Fetch | Declare scope before crawl |
| JS-rendered or login-dependent docs | Playwright | Firecrawl retry with stronger settings | Do not accept weak scrape output |
| Lightweight static page read | Fetch | Firecrawl scrape | Use only when structured extraction is unnecessary |
| SDK/API/provider syntax | Context7 | official docs fallback | Record library id and topics |

## Output rules by family

| Family | Required durable anchors |
|---|---|
| `vendor_docs` | pack `README.md`, provenance, metadata/index file, declared page outputs, localized assets when required |
| `sdk_api_context` | explicit Context7 topics and source notes, durable README or note index when the subtree is new |
| `library_indexes` | machine-friendly structure, references to owned outputs, no orphan indexes |
| `operator_prompts` | reusable prompt file, clear start/stop conditions, reference to the kickoff capability when appropriate |

## Summary policy

- Default: forbidden
- Allowed only when the packet-local `entry-spec.yml` declares the exact output
  in `allowed_summary_outputs`
- Full captures must not be disguised as summaries
