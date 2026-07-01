---
name: vendor-doc-collection
description: Collect vendor/product documentation into a structured, AI-friendly local export tree with localized images and AI image descriptions. Use when asked to scrape, offload, export, or mirror vendor help pages, a documentation subtree, or all pages covering a concept — at any scope from one page to a full nav branch. Not a general webcrawler.
---

# Skill: Vendor Doc Collection

Turn vendor documentation (help portals, product guides, KB trees) into a
structured local datasource: one folder per page mirroring the vendor nav
hierarchy, cleaned markdown with provenance frontmatter, referenced artifacts
extracted as sidecars, images downloaded locally, and AI-generated image
descriptions so screenshot content is text-searchable.

This is the WHAT-collection phase of the composition model in
`docs/codex_framework/mcp-research-collection-stack.md`: Firecrawl collects
what the vendor requires; Context7 supplies library/provider syntax later at
implementation time; internal docs supply environment standards.

## When to use this skill

Use this skill when:

- the user asks to scrape/export/offload vendor doc pages into the repo
- a doc subtree or concept needs to become a local AI-friendly reference
- an existing export tree needs new pages, image localization, or descriptions

Do not use this skill when:

- the question needs one fact from one page — just scrape and answer inline
- the surface is library/SDK/provider syntax — that is Context7's job
- the user wants a full unbounded site crawl — this skill is contract-scoped;
  `firecrawl_crawl` requires explicit limits and user awareness

## Operation modes

Pick the mode from the request's scope shape:

- **Mode 1 — Small scope.** Named page(s). Confirm slugs, add them to the
  export contract, scrape, export, localize images, describe images.
- **Mode 2 — Concept collection.** A concept spread across the vendor docs
  ("everything about CMK configuration"). Discover candidate pages with
  `firecrawl_map` (with `search`) and/or `firecrawl_search` scoped to the
  vendor domain, propose the page list to the user or nav contract, then
  proceed as Mode 1 for each accepted page.
- **Mode 3 — Full tree offload.** A nav subtree ("everything under
  Installation and Deployment"). Resolve the full child list first
  (contract-first), then batch through the pipeline mirroring the hierarchy.

## Output conventions (the export contract)

An export root (e.g. `docs/reference/export/`) contains:

- **One folder per vendor bundle**, named by the bundle ID exactly as it
  appears in the vendor URL (e.g. `ZIC.HTML/`, `AWS.Linux.ZCA.HTML.10.9/`).
  Pages from a different guide/bundle never get shoehorned into an existing
  bundle tree — add the sibling folder and declare it in the contract's
  `bundles:` list. Section folders inside a bundle use `NN-<Section>` prefixes
  mirroring that bundle's left-nav order.
- **`nav-tree.yml`** — the export contract. Header: `bundles:` list (name,
  vendor version, guide title). Every node: slug, title, `status:
  exported | pending | out_of_scope`, `export_path` (export-root-relative,
  including the bundle folder), optional `sidecar_artifacts`. Scope decisions
  live here, not in prose. Update statuses as pages land.
- **`_raw/<Slug>.raw.md`** — unmodified scrape output, kept for re-cleaning.
- **`<Bundle>/<section>/<Page>/page.md`** — cleaned markdown with frontmatter:
  `source_url`, `page_slug`, `page_title`, `exported_at`.
- **`<Page>/meta.yml`** — same identity fields plus `child_exports` for hubs.
- **`<Page>/images/NNN-<vendor-stem>.png`** — every vendor image downloaded
  locally; the markdown link rewritten relative with the vendor URL preserved
  in an HTML comment (`<!-- source: https://... -->`). Filenames keep the
  vendor stem with an order prefix — derivable from the source URL, so re-runs
  are idempotent. Do not hand-write semantic filenames; the semantic layer is
  the `images/README.md` description.
- **`<Page>/images/README.md`** — AI descriptions per image: what is shown,
  visible fields/values transcribed exactly (searchability is the goal),
  purpose in the doc flow.
- **`<Page>/artifacts/`** — referenced resources: inline JSON/policy blocks,
  templates, API summaries. Vendor-portal-only downloads get a note in
  `artifacts/README.md` instead of a broken copy.
- **`scripts/`** — the pipeline scripts (see templates below), including a
  **conformance checker** (`check_export_conformance.py`) that encodes the
  conventions as executable checks with a `CONVENTIONS_VERSION` constant.
- **`README.md`** — conventions + regenerate-one-page runbook, pointing at the
  checker as the machine-checkable conventions authority.

The contract is bidirectional: every `status: exported` node must exist on
disk, and every `page.md` on disk must have a slug entry in `nav-tree.yml`.
Disk cannot outgrow the contract.

Reference implementation:
`oneoffs/issue/ca-3081-zerto/docs/reference/export/` (ZIC.HTML v1.9).

## Pipeline

1. **Discovery (read-only).** `firecrawl_map` for URL space; if the portal is
   JS-rendered with no sitemap (Zoomin and similar), map returns almost
   nothing — scrape the hub page instead and parse the nav tree links from the
   scraped body.
2. **Contract.** Record the resolved page list in `nav-tree.yml` with
   `status: pending` before scraping. Contract-first keeps the offload
   auditable and resumable.
3. **Scrape.** Batch via a fetch script hitting the Firecrawl `/v2/scrape` API
   (markdown format, `onlyMainContent`, `maxAge` for cache-friendliness) into
   `_raw/`. If a page comes back near-empty it did not JS-hydrate: re-scrape
   via the Firecrawl MCP with `waitFor` ~8000ms and `maxAge: 0`, then save the
   result to `_raw/` manually.
4. **Clean + export.** Strip portal chrome (filters, nav trees, feedback
   widgets) with a site-specific clean script; write `page.md` with
   frontmatter and `meta.yml`. Keep a slug-filter argument on the batch script
   so single-page re-exports never clobber manual notes on other pages.
5. **Localize images.** Download every vendor image link to
   `<page>/images/`, rewrite links relative, keep provenance comments.
   Idempotent: existing files are not re-downloaded, localized links skipped.
6. **Describe images.** Generate `images/README.md` per page with a
   multimodal model. Minimum mid-tier vision quality — wrong descriptions
   poison retrieval. Coordinator spot-checks a sample against the actual
   image files.
7. **Sidecars.** Extract inline JSON/policy/template blocks the page carries
   into `artifacts/`.
8. **Verify.** Run the export root's `check_export_conformance.py`; it must
   exit 0. The checker enforces frontmatter, meta.yml, image localization,
   provenance comments, description coverage, filename shape, and the
   bidirectional nav-tree contract. Eyeballing conventions is not
   verification.

## Convention drift detection

Conventions will change over time (image handling did). The mechanism that
keeps old pages honest:

1. The conformance checker is the single machine-checkable authority for the
   conventions, versioned via `CONVENTIONS_VERSION`.
2. When a convention changes: bump the version, add or adjust the check
   first, then run the checker — it lists every already-exported page that
   no longer conforms. That list is the backfill work order.
3. The checker runs at the end of every pipeline pass (step 8) and must exit
   0 before the work is reported complete, so drift cannot accumulate
   silently between convention changes.

Prose conventions in the README describe intent; the checker decides
conformance. If they disagree, fix the checker or the README in the same
change — never leave them split.

## Delegation model

Coordinator (strong model) + cheap-lane workers, per
`docs/codex_framework/agent-workflows/patterns/doc-collection-coordinator.md`:

- Scripts do the scraping/downloading — deterministic work stays out of models.
- Contract decisions, skill/QA work: coordinator.
- Per-page conformance passes: cheap workers, parallel, one page per unit.
- Image descriptions: mid-tier multimodal workers, parallel, files-on-disk
  only. All MCP/network access stays with the coordinator and scripts —
  workers read and write local files.

## Script templates

Generalize from the reference implementation scripts (adapt portal-chrome
patterns per vendor):

- `fetch_raw_pages.py` — Firecrawl API batch scrape to `_raw/`
- `clean_zerto_page.py` — chrome-strip pattern (rename per vendor)
- `batch_export_pages.py` — PAGES registry -> folders, frontmatter, meta,
  slug-filter argument
- `download_page_images.py` — image localization, link rewrite, provenance
- `extract_sidecar_json.py` — inline artifact extraction
- `check_export_conformance.py` — versioned conventions checker / drift
  detector (exit nonzero on any nonconforming page)

The Firecrawl API key comes from the stack's managed env file
(`~/.config/dotfile-vnext/mcp/env.d/firecrawl.env`); source it, never inline it.

## What this skill produces

- an updated or new export tree conforming to the output conventions
- an updated `nav-tree.yml` contract with accurate statuses
- localized images with AI-description READMEs
- a regenerate-one-page runbook in the export README

## Suggested framework roles

- `Planner / Steward` — scope shape, contract decisions
- `Researcher` — discovery, slug resolution
- `Executor` — pipeline runs, worker dispatch, verification
