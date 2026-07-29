---
lifecycle: implemented
scope: doc-only
implemented_date: 2026-07-08
archive_candidate: true
superseded_by: docs/codex_framework/architecture-diagram-routing.md
procedure_status: retired
---

# Diagrams tool — AI library and skill setup (RETIRED PROCEDURE)

> **Do not follow Step 3 brew/pip Graphviz install, YAML-as-intermediate, or
> project-local skill authoring from this packet.** Diagramming procedure for
> this repo is
> [architecture-diagram-routing.md](../../codex_framework/architecture-diagram-routing.md)
> and the global **`create-diagrams`** pack (SVG default here; Mermaid fences
> when Mermaid is preferred). Vendor Firecrawl under `ai-resource-library` may
> remain as **reference docs only**, not as the how-to-diagram path.

Add a new entry to the AI Library for the `diagrams` Python tool so an AI can
generate diagrams from instructions, Terraform, and product documentation with
less iteration.

## Status: implemented (2026-07-08) — procedure superseded (2026-07-28)

| Deliverable | Location |
|-------------|----------|
| Vendor documentation pack | `/Users/joshc/develop/ai-resource-library/vendors/diagrams/firecrawl/` (reference only) |
| Diagramming skill (current) | global-skills `create-diagrams` (+ exporters); runtime via home/bridge |
| Project routing | `docs/codex_framework/architecture-diagram-routing.md` |
| Original intake note | Promoted from `docs/ai-library/diagrams_tool_install_plan.md` |

## AI-library-entry backfill (2026-07-08)

- Backfill packet: `docs/plans/2026-07-08--ai-library-entry-recent-pack-backfill-incomplete/README.md`
- Packet-local spec: `docs/plans/2026-07-08--ai-library-entry-recent-pack-backfill-incomplete/diagrams-entry-spec.yml`
- Validator result: `AI_LIBRARY_ENTRY_VALIDATION_OK`
- Result: this pack passed the new `ai-library-entry` contract without content rebuild; the remediation added durable `metadata.json`, `page-index.json`, and packet/README validation evidence only.

## Goal

The library should make it easy for an AI to:

- understand the `diagrams` tool
- generate AWS diagrams and other architecture diagrams
- decide when to use source docs, Terraform, or provided instructions
- output both source-first structured data and rendered diagram images

## Step 1. Review the existing AI Library

If the current library structure is not ideal, move things around now so the
next additions can follow the same pattern cleanly.

## Step 2. Use the library as the source of truth

Use the material in:

- `/Users/joshc/develop/ai-resource-library/vendors/diagrams/firecrawl`

That folder already contains the documentation pack. The install instruction file
is there, but this plan is the higher-level setup instruction for how the AI
should use the tool.

## Step 3. Best-practice setup

> **RETIRED.** Do not `brew install graphviz` / `pip install diagrams` as the
> project procedure. Use global `create-diagrams` (Docker / project venv per that
> skill). See `docs/codex_framework/architecture-diagram-routing.md`.

Historical text (do not execute as guidance):

1. Install Graphviz with Homebrew on macOS:
   - `brew install graphviz`
2. Install `diagrams` with your Python tool of choice:
   - `pip install diagrams`
   - or `uv tool install diagrams`
   - or `poetry add diagrams`

## Step 4. Choose a skill structure

The AI should decide whether to build:

- one skill
- or a small skill bundle

Use a bundle when installation, source ingestion, icon policy, and diagram
generation are separable concerns. That is the preferred shape here.

## Step 5. Source-first design requirement

Design the skill bundle so it is source-first:

- read the docs first
- derive the diagram behavior from the docs
- prefer structured input over memory
- keep the output reproducible

The bundle should also output generated images, not only structured source data.

## Source control

- https://github.com/mingrammer/diagrams

## Documentation to ingest

- https://diagrams.mingrammer.com/docs/getting-started/installation
- https://diagrams.mingrammer.com/docs/getting-started/examples
- https://diagrams.mingrammer.com/docs/guides/diagram
- https://diagrams.mingrammer.com/docs/guides/cluster
- https://diagrams.mingrammer.com/docs/guides/edge
- https://diagrams.mingrammer.com/docs/nodes/aws
- https://diagrams.mingrammer.com/docs/nodes/generic
- https://diagrams.mingrammer.com/docs/nodes/programming

## Authoring options

Use the following options as the source-first design decision.

| Option | Human readability | Machine readability | Best for AWS metadata | Best for automation | Best for multi-output |
|---|---|---|---|---|---|
| A: Mermaid | ⭐⭐⭐ | ⭐ | ⭐ | ⭐ | ⭐⭐ |
| B: YAML/JSON | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| C: Python graph | ⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |

Decision: **Option B, YAML/JSON**.

## How the AI should behave

- Use the documentation pack as the first source.
- Prefer YAML/JSON as the intermediate source format.
- Generate rendered diagrams from that source.
- Use the docs pack to decide whether a single skill is enough or a bundle is better.
- For this project, default to a bundle with separate responsibilities:
  - install/setup
  - source ingestion
  - diagram generation
  - icon policy

## AWS icon policy

`diagrams` includes AWS icons by default, but they are look-alikes rather than
official AWS architecture icons.

If official icons are needed:

- use custom nodes with `icon_path`
- or define custom classes
- or monkey-patch provider classes

Prefer default AWS nodes when speed matters more than exact icon fidelity.
