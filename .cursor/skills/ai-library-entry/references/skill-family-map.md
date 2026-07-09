# AI Library Entry — Skill Family Map

`ai-library-entry` is the **orchestrator only**. Delegate execution to the
skills below in build order.

## Build order (recommended)

| Step | Skill | When |
|------|-------|------|
| 1 | `ai-library-entry` | Plan packet + `entry-spec.yml` + family routing |
| 2 | `vendor-doc-collection` | Structured Firecrawl vendor tree (optional) |
| 3 | `library-entry-build` | Run registered `build_*.mjs` |
| 4 | `library-context7-pack` | Context7 shards / OpenAPI interpretation (often via build `--context7-only`) |
| 5 | `firecrawl-context7-crosscheck` | Gap JSON + capture backlog |
| 6 | `library-indexes-pack` | `indexes/<entry>/` crosswalk + README |
| 7 | `library-entry-validate` | `AI_LIBRARY_ENTRY_VALIDATION_OK` gate |

**Effectiveness first:** steps 7 and 5 block incomplete packs early once outputs exist.

## Skill responsibilities

| Skill | Owns | Does not own |
|-------|------|--------------|
| `ai-library-entry` | Packet contract, routing, orchestration | Per-phase collection scripts |
| `library-entry-validate` | Validator gate + receipt | `validate_entry_spec.rb` implementation |
| `firecrawl-context7-crosscheck` | Gap interpretation, backlog | `context7_entry.mjs` |
| `library-indexes-pack` | `indexes/<entry>/` defaults | Cross-check logic |
| `library-context7-pack` | Context7 workflow | MCP runtime |
| `library-entry-build` | Registry + script invocation | Build script bodies |

## What NOT to split (avoid skill sprawl)

Keep these under `ai-library-entry/references/`:

- `shared/context7_entry.mjs`
- `shared/mcp_runtime.mjs`
- `validate_entry_spec.rb`
- `entry-spec.template.yml`
- per-entry `build_*.mjs` under `ai-resource-library/scripts/ai-library-entry/`

## Build registry

New `build_*.mjs` scripts require a row in:

`.cursor/skills/library-entry-build/references/build-registry.yml`

**Active now (2+ scripts):** `library-entry-build` is not deferred.

## Library skill receipt (all child skills)

Each executor/validator skill emits:

```markdown
## Library skill receipt
- Skill: <name>
- Entry: <entry_id>
- Evidence: <paths or validator token>
```
