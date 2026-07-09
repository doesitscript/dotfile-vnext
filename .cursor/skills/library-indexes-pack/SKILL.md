---
name: library-indexes-pack
description: Build and maintain ai-resource-library indexes/<entry>/ routing packs — crosswalk, cross-check index, README, capture backlog. Use when vendor_docs and context7_required are both true or when adding library routing for an entry.
---

# Skill: Library Indexes Pack

Owns durable routing artifacts under `ai-resource-library/indexes/<entry>/`.

## Default outputs

When `vendor_docs` + `context7_required`:

| File | Purpose |
|------|---------|
| `README.md` | Human routing guide for agents |
| `doc-api-inventory-crosswalk.json` | Maps vendor pages ↔ Context7 topics ↔ repo surfaces |
| `firecrawl-context7-crosscheck.json` | Per-page gap evidence (via cross-check skill) |
| `capture-backlog.yml` | Pages needing thicker Firecrawl capture |

## When to use this skill

Use when:

- creating a new library entry with both vendor docs and Context7
- crosswalk or indexes README is missing
- remediating an entry to current contract defaults

Do not use when:

- entry is `prompts` or `sdk_api_context` only with no indexes block

## Required workflow

1. Read declared `library_indexes` outputs plus `context7.crosswalk_index` and
   `context7.firecrawl_cross_check` paths from `entry-spec.yml`.
2. Build crosswalk from entry-spec page ids, Context7 topic shards, and repo anchors.
3. Ensure `indexes/<entry>/README.md` lists:
   - vendor pack path
   - sdk-context path
   - when to use Firecrawl vs Context7 vs repo roles
4. Delegate cross-check JSON to `firecrawl-context7-crosscheck`.
5. Run `library-entry-validate`.

## Shared implementation

- `.cursor/skills/ai-library-entry/references/shared/context7_entry.mjs`
  - `buildDocApiInventoryCrosswalk()`
  - `writeIndexesReadme()`

## Library skill receipt

```markdown
## Library skill receipt
- Skill: library-indexes-pack
- Index path: indexes/<entry>/
- Outputs written: <list>
- Crosswalk pages: N
```

## References

- `.cursor/skills/ai-library-entry/references/routing-matrix.md`
- `.cursor/rules/framework-library-indexes-pack.mdc`
