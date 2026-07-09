---
name: firecrawl-context7-crosscheck
description: Reconcile Firecrawl vendor captures against Context7 query-docs per priority page. Use after Firecrawl scrape or Context7 refresh; records gap notes and capture backlog before marking a library entry complete.
---

# Skill: Firecrawl ↔ Context7 Cross-Check

Reconciliation gate between live vendor captures and Context7 implementation
syntax. Produces `indexes/<entry>/firecrawl-context7-crosscheck.json`.

## When to use this skill

Use when:

- `vendor_docs` and `context7_required` are both true in the entry spec
- Firecrawl pages were added, refreshed, or summarized
- Context7 shards were regenerated
- cross-check JSON is missing, stale, or shows `gaps_detected`

Do not use when:

- no Firecrawl captures exist yet — run `vendor-doc-collection` or entry build first
- the entry has no Context7 block

## Required workflow

1. Read `entry-spec.context7.firecrawl_cross_check` for `library_id` and `index_path`.
2. For each priority page id in the entry spec / build script:
   - load Firecrawl capture from `vendors/<entry>/<page-id>.md`
   - run matching Context7 `query-docs`
   - compare overlap, depth, and `context7_only_terms`
3. Write `firecrawl-context7-crosscheck.json` with per-page `gap_notes`.
4. Update `indexes/<entry>/capture-backlog.yml` for pages needing Firecrawl refresh.
5. Emit a library skill receipt with gap summary.

## Gap interpretation

| `gap_notes` value | Meaning | Typical action |
|-----------------|---------|----------------|
| `low_term_overlap` | Firecrawl capture shares few terms with Context7 | re-scrape with `markdown` not `summary` |
| `context7_has_terms_missing_from_firecrawl` | Context7 knows config/API terms not in capture | thicken capture or full_capture |
| `firecrawl_capture_thinner_than_context7` | Capture much shorter than Context7 answer | re-scrape target page |
| `missing_firecrawl_capture` | No vendor file on disk | run Firecrawl for that page |

## Shared implementation

Use helper (do not reimplement):

- `.cursor/skills/ai-library-entry/references/shared/context7_entry.mjs`
  - `crossCheckFirecrawlPages()`
  - `compareFirecrawlAndContext7()`
  - `summarizeCrossCheck()`

Typically invoked via `library-entry-build` for registered entries.

## Pairing rule

After `vendor-doc-collection` or any Firecrawl scrape in a Context7-enabled
entry, invoke this skill before `library-entry-validate`.

## Library skill receipt

```markdown
## Library skill receipt
- Skill: firecrawl-context7-crosscheck
- Entry: <entry_id>
- Pages checked: N
- gaps_detected: M
- Capture backlog: <page ids with context7_only terms>
- Artifact: indexes/<entry>/firecrawl-context7-crosscheck.json
```

## References

- `.cursor/skills/ai-library-entry/references/context7-capabilities.md`
- `.cursor/rules/framework-firecrawl-context7-crosscheck.mdc`
