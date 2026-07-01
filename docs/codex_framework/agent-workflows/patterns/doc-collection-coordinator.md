---
status: trial
owner: codex-framework
applies_to:
  - vendor-doc-collection
---

# Doc Collection Coordinator + Per-Page Workers

## Purpose

Coordinates vendor documentation offloads executed through the
`vendor-doc-collection` skill (`.cursor/skills/vendor-doc-collection/SKILL.md`):
scraping a page set into a structured export tree, localizing images, and
generating AI image descriptions. Splits deterministic script work, cheap
per-page work, and high-IQ contract/QA work across cost-appropriate lanes.

First real use: ZIC.HTML tree offload
(`docs/plans/2026-07-01--vendor-doc-collection-skill/`).

## Triggers

- A doc collection request resolves to more than ~3 pages, or any page count
  with image-description work attached.
- The user asks to delegate mechanical doc work to cheaper models.
- Backfill passes over an existing export tree (image localization,
  description regeneration, conformance sweeps).

Single-page collections do not need this pattern — run the skill directly.

## Roles

### Coordinator (strong model, main session)

- **Responsibility:** scope shape, nav-tree contract decisions, MCP calls
  (Firecrawl map/scrape), script runs, worker dispatch, spot-check QA,
  receipts.
- **Read/write boundary:** full repo write; only role with MCP and network
  access.
- **Allowed tools:** Firecrawl MCP, shell (pipeline scripts), file edits,
  Task dispatch.
- **Handoff artifact:** on-disk raw scrapes + export folders that workers
  process; worker prompts naming exact folder paths.
- **Completion signal:** verification checks pass and receipt written.

### Per-page workers (cheap/mid lane, parallel subagents)

- **Responsibility:** one page (or small page batch) per unit — conformance
  passes, image descriptions (`images/README.md`), frontmatter checks.
- **Read/write boundary:** files on disk within their assigned page folders
  only. No MCP, no network, no contract files (`nav-tree.yml`, export README).
- **Allowed tools:** Read/Write/Grep on assigned paths.
- **Model floor:** text conformance may use the cheap lane; image descriptions
  require mid-tier multimodal minimum — wrong descriptions poison retrieval.
- **Handoff artifact:** the written per-page files plus a short confirmation
  listing paths written.
- **Completion signal:** confirmation received AND coordinator spot-check.

## Parallel Work

- Per-page workers run in parallel (independent page folders, no shared
  writes).
- Coordinator continues skill/doc/receipt work while workers run.

## Serialized Work

- Discovery -> contract update -> scrape -> export precede worker dispatch.
- `nav-tree.yml` and export README edits are coordinator-only and serialized.
- Verification and receipt writing happen after all workers confirm.

## Gates

### Contract gate (before scraping)

- **Required input:** resolved page list from discovery.
- **Required evidence:** nav-tree entries with `status: pending`.
- **Pass:** every page to be scraped exists in the contract.
- **Fail/send-back:** scraping pages not in the contract is a scope violation;
  stop and update the contract first.
- **Fallback:** if `firecrawl_map` returns nothing (JS portal), parse the nav
  links from a scraped hub page instead.

### Scrape quality gate (before export)

- **Required input:** raw markdown per page.
- **Required evidence:** raw file contains the page's own heading/body, not
  just portal chrome (near-empty file = failed JS hydration).
- **Pass:** body present.
- **Fail/send-back:** re-scrape via MCP with `waitFor` and `maxAge: 0`.

### Worker QA gate (before completion)

- **Required input:** worker confirmations.
- **Required evidence:** coordinator reads a sample of worker output files and
  compares at least one image description against the actual image.
- **Pass:** sample matches the images; format conforms.
- **Fail/send-back:** re-dispatch the page unit with corrections; do not patch
  silently at scale.
- **Fallback:** if subagent lanes are unavailable, the coordinator does the
  per-page work itself sequentially — quality floor over throughput.

## Artifacts

- Updated `nav-tree.yml` statuses (contract truth)
- Export folders per the skill's output conventions
- `images/README.md` per page with images
- Plan verification receipt rows in the owning plan packet

## Completion Rule

All contract nodes in scope are `exported` on disk, the export root's
`check_export_conformance.py` exits 0 (frontmatter, image localization,
description coverage, bidirectional nav-tree contract), worker QA gate passed,
and the receipt is updated. Worker confirmations alone are not completion,
and neither is an eyeball pass over conventions — the checker run is the
verification evidence.

## Failure Rule

If a worker fails, produces nonconforming output, or a lane is unavailable,
the page unit returns to the coordinator queue — it must be re-dispatched or
done by the coordinator before completion may be reported. A failed page unit
never silently drops from scope; it stays `pending` in the contract.
