---
name: library-context7-pack
description: Collect Context7 SDK/API context for ai-resource-library entries — resolve-library-id, version pin, topic shards, OpenAPI/Swagger interpretation. Use when sdk_api_context is in scope or refreshing implementation syntax for a vendor entry.
---

# Skill: Library Context7 Pack

Owns `ai-resource-library/sdk-context/context7/<entry>/` outputs.

## When to use this skill

Use when:

- `sdk_api_context` or `context7_required` is true in the entry spec
- refreshing implementation syntax after a version contract bump
- adding topic shards for new operator surfaces
- OpenAPI/Swagger interpretation via Context7 (not raw fetch-only)

Do not use when:

- only static vendor help pages are needed with no implementation context — use `vendor-doc-collection`

## Required workflow

1. Read `entry-spec.context7` block: `library_id`, `version_pin`, `topics`, `openapi_swagger`.
2. Resolve library id via Context7 `resolve-library-id` (record resolved id + version).
3. For each topic in `context7.topics`, run `query-docs` and write shard markdown.
4. When `openapi_swagger.enabled`, write overview + usage notes shards.
5. Pair with `firecrawl-context7-crosscheck` when `firecrawl_cross_check.enabled`.
6. Pair with `library-indexes-pack` for crosswalk updates.

## Version pinning

Pin from repo version contracts when declared (e.g. `litellm_tooling_version_contract.cli`).
Record both contract version and Context7 resolved library path in shard README.

## Shared implementation

Do not duplicate — use:

- `.cursor/skills/ai-library-entry/references/shared/context7_entry.mjs`
- `.cursor/skills/ai-library-entry/references/shared/mcp_runtime.mjs`

Typically invoked via `library-entry-build --context7-only` for registered entries.

## Library skill receipt

```markdown
## Library skill receipt
- Skill: library-context7-pack
- Entry: <entry_id>
- Resolved library: <context7 path>
- Topic shards: <list>
- OpenAPI shards: yes | no
```

## References

- `.cursor/skills/ai-library-entry/references/context7-capabilities.md`
- `.cursor/rules/framework-library-context7-pack.mdc`
