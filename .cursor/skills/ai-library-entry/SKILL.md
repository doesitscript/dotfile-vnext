---
name: ai-library-entry
description: "DEPRECATED. Do not use for new work. Former orchestrator for ai-resource-library entries. Prefer library-first-project-handoff, library-first-model-doc-pack, or library-first-troubleshooting-intake; call child library skills directly when the family is already known."
status: deprecated
---

# Skill: AI Library Entry (Orchestrator) — DEPRECATED

> **DEPRECATED — do not use as a front door.**
>
> This skill is retained only as a historical contract/reference surface
> (`entry-spec`, validators, shared scripts). Do not kick off new library
> intakes through it.
>
> **Use instead:**
>
> | Need | Replacement |
> |------|-------------|
> | Durable HRL artifact then project handoff | `library-first-project-handoff` |
> | Model doc pack before runtime wiring | `library-first-model-doc-pack` |
> | Error / troubleshooting → HRL first | `library-first-troubleshooting-intake` |
> | Known single family already classified | call the child skill directly (`vendor-doc-collection`, `library-entry-build`, `library-context7-pack`, `library-indexes-pack`, `firecrawl-context7-crosscheck`, `library-entry-validate`) |

Primary **kickoff and routing** capability for durable `ai-resource-library`
entries. Does not execute collection itself — delegates to the skill family
documented in `references/skill-family-map.md`.

## When to use this skill

**Do not use for new work.** Historical guidance only:

- adding a new library entry or major refresh
- outputs span `vendors/`, `sdk-context/`, `indexes/`, or `prompts/`
- a governed contract must exist before scraping or synthesis

Do not use when:

- inline answer only, no durable outputs
- tiny edit inside an already-governed entry with no contract change

## Orchestration workflow

1. **Classify** content families (see table below).
2. **Create** governed packet `docs/plans/YYYY-MM-DD--slug/README.md`.
3. **Create** packet-local `entry-spec.yml` from `references/entry-spec.template.yml`.
4. **Delegate** by family:

| Phase | Delegate to |
|-------|-------------|
| Vendor Firecrawl tree | `vendor-doc-collection` (narrow helper) |
| Build / regenerate | `library-entry-build` |
| Context7 shards | `library-context7-pack` |
| Cross-check gaps | `firecrawl-context7-crosscheck` |
| Indexes routing pack | `library-indexes-pack` |
| Completion gate | `library-entry-validate` |

5. **Never mark complete** until `library-entry-validate` returns `AI_LIBRARY_ENTRY_VALIDATION_OK`.

## Content-family routing

| Family | Target | Typical outputs |
|--------|--------|-----------------|
| `vendor_docs` | `vendors/` | captures, README, metadata, page indexes |
| `sdk_api_context` | `sdk-context/` | Context7 shards, API notes |
| `library_indexes` | `indexes/` | crosswalk, cross-check, capture backlog, routing README |
| `operator_prompts` | `prompts/` | runbooks, kickoff prompts |

## Defaults (contract-level)

When `vendor_docs` + `context7_required`:

- declare `library_indexes` in `content_families`
- require `indexes/<entry>/` (README, crosswalk, cross-check, capture backlog)
- run Firecrawl ↔ Context7 cross-check on every priority page
- Context7 primary for OpenAPI/Swagger; fetch mirror optional

See `references/context7-capabilities.md` and `references/routing-matrix.md`.

## What stays here (do not split)

- `references/entry-spec.template.yml`
- `references/validate_entry_spec.rb`
- `references/shared/context7_entry.mjs`
- `references/shared/mcp_runtime.mjs`
- per-entry `build_*.mjs` in `ai-resource-library/scripts/`

## Build registry note

`library-entry-build` is **active** (litellm + langfuse scripts registered).
Add a row to `library-entry-build/references/build-registry.yml` before any new
`build_*.mjs`.

## References

- `references/skill-family-map.md` — delegation map and build order
- `references/context7-capabilities.md`
- `references/routing-matrix.md`
- `references/entry-spec.template.yml`
- `.cursor/rules/framework-ai-library-entry.mdc`
