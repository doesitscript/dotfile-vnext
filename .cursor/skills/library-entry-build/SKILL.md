---
name: library-entry-build
description: Run registered ai-resource-library entry build scripts from build-registry.yml. Use for regenerate pack, run build script, refresh cross-check, or --context7-only refresh. Always follow with library-entry-validate.
---

# Skill: Library Entry Build

Executor wrapper for `ai-resource-library/scripts/ai-library-entry/**/build_*.mjs`.

## Registry gate (mandatory)

Scripts are registered in:

`.cursor/skills/library-entry-build/references/build-registry.yml`

**Before adding a new `build_*.mjs`**, add a registry row. Unregistered scripts must
not be invoked through this skill.

Current registered entries (2+ — this skill is active, not deferred):

| entry_id | script |
|----------|--------|
| `litellm_vendor_reference_pack` | `build_litellm_vendor_pack.mjs` |
| `langfuse_guides_full_capture` | `build_langfuse_guides_pack.mjs` |

## When to use this skill

Use when:

- "regenerate pack", "run build script", "refresh cross-check"
- `--context7-only` Context7 + indexes refresh without full Firecrawl
- targeted `--refresh-pages=<page-id>` for thin captures

Do not use when:

- no registry row exists — add registry row + entry-spec first
- only validating an existing pack — use `library-entry-validate` alone

## Required workflow

1. Resolve `entry_id` → script path from `build-registry.yml`.
2. Confirm `entry-spec.yml` path matches registry row.
3. Run from repo root:

```bash
node ai-resource-library/scripts/ai-library-entry/<entry>/build_<name>.mjs [flags]
```

4. Capture **stderr and stdout** as evidence in the conversation.
5. Invoke downstream skills based on flags:
   - full build → `firecrawl-context7-crosscheck` → `library-indexes-pack` (if not embedded in script)
   - `--context7-only` → `library-context7-pack` outcome + cross-check refresh
6. Always end with `library-entry-validate`.

## Supported flags (entry-dependent)

| Flag | Effect |
|------|--------|
| `--context7-only` | Skip Firecrawl/OpenAPI fetch; refresh Context7 shards, cross-check, indexes |
| `--refresh-pages=id1,id2` | Re-scrape named vendor page ids (litellm only today) |

## Library skill receipt

```markdown
## Library skill receipt
- Skill: library-entry-build
- Entry id: <entry_id>
- Script: <path>
- Flags: <list>
- Exit code: N
- Stderr excerpt: <if any>
- Next: library-entry-validate
```

## What stays in ai-library-entry (do not split)

- `references/shared/context7_entry.mjs`
- `references/shared/mcp_runtime.mjs`
- `references/validate_entry_spec.rb`
- `references/entry-spec.template.yml`
- per-entry `build_*.mjs` scripts under `ai-resource-library/scripts/`

## References

- `.cursor/skills/library-entry-build/references/build-registry.yml`
- `.cursor/skills/ai-library-entry/references/skill-family-map.md`
