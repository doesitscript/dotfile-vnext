# AI Library addition request

Add a new entry to the AI Library for the `diagrams` Python tool so an AI can
generate diagrams from instructions, Terraform, and product documentation with
less iteration.

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

The diagrams package itself is Python-based. The practical setup is:

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
