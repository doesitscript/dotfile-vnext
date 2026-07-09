# AI Library Entry Capability

Orchestrator for durable `ai-resource-library` additions. Delegates execution
to the library skill family — see `references/skill-family-map.md`.

## Child skills

| Skill | Role |
|-------|------|
| `library-entry-validate` | Validator gate |
| `firecrawl-context7-crosscheck` | Gap reconciliation |
| `library-indexes-pack` | `indexes/<entry>/` |
| `library-context7-pack` | Context7 shards |
| `library-entry-build` | Registered build scripts |

`vendor-doc-collection` remains the narrower Firecrawl export helper.

## Build registry

`library-entry-build/references/build-registry.yml` — add a row before new `build_*.mjs`.

## Owned shared references (do not split into separate skills)

- `references/shared/context7_entry.mjs`
- `references/shared/mcp_runtime.mjs`
- `references/validate_entry_spec.rb`
- `references/entry-spec.template.yml`
