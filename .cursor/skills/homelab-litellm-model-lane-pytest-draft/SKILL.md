---
name: homelab-litellm-model-lane-pytest-draft
description: >-
  Run the project vNext, data-driven LiteLLM model-lane pytest suite for the
  six commissioned evaluation models. Use for scalable chat, FIM, context,
  response-shape, and optional embedding checks after gateway convergence.
  Do not use for deploying runtimes or changing model inventory.
license: MIT
version: "0.2.0b0"
author: "dotfile-vnext"
compatibility: "Project skill for dotfile-vnext"
modes: "agent, ask, plan, debug"
depends_on_skills: "repo-env-wrapper-contract"
requires_summary: "pytest; LITELLM_API_KEY; LiteLLM gateway"
title: Homelab LiteLLM Model Lane Pytest Draft
technology: litellm
document_type: skill
status: beta
authority: internal
source_type: derived
skill_scope: project
applies_to:
  - python
  - pytest
  - litellm
  - model-evaluation
related:
  - /Users/joshc/develop/global-skills/skills/validation/homelab-litellm-model-lane-pytest/SKILL.md
  - docs/plans/2026-09-13--get-back-ansible-best-practice/TDD/test_model_lanes_vnext.py
tags:
  - draft
  - pytest
  - litellm
  - model-lanes
---

# Skill: Homelab LiteLLM Model Lane Pytest Draft

This project-owned draft is a thin SHIM over the beta-stable package
`/Users/joshc/develop/homelab-model-lane-pytest`. The package owns the client,
YAML manifest, capability gating, journeys, tools, targeting, and receipts;
this skill owns discovery, vault launch context, and evidence rules.

The package is beta-stable to consume (`0.2.0b0`); this skill remains named
`-draft` until a later explicit promote decision.

## Package commands

```bash
cd /Users/joshc/develop/homelab-model-lane-pytest
just unit
just run --profile commissioned-six
just run --profile smoke --lane-filter qwen3-coder-30b-a3b
just live -m 'llm_chat or llm_tools' -k qwen3-coder-30b-a3b
```

Use `just run --profile commissioned-six` for the full six-model commissioned
matrix. Use `just run --profile smoke --lane-filter <id>` for one model. The
legacy forwarding form `just run -- --profile commissioned-six` is supported.
Profiles are `smoke`, `pr`, `nightly`, `capability-tools`, and
`commissioned-six`. Set `LITELLM_LANE_FILTER` for comma-separated IDs. The
manifest is package-owned and aligned to exported commissioned IDs; disabled
or pending lanes are omitted from default live cases.

## Run

```bash
cd /Users/joshc/develop/homelab-model-lane-pytest
DOTFILE_VNEXT=/Users/joshc/develop/dotfile-vnext just sync-env
just unit
just live -m smoke -k qwen3-coder-30b-a3b
```

The package prints full `JOURNEY / WHY / USER / EXPECTED / ACTUAL` receipts
for every pass and failure, separate `invoke / execute / followup` receipts
for successful tools journeys, and a grouped end-of-run PASS/FAIL/SKIP
summary. Do not replace these receipts with pytest counts alone.

The suite skips live tests when `LITELLM_API_KEY` is unset. Never put a key in
the manifest, test source, plan receipt, or command history. Set
`LITELLM_GATEWAY_ROOT` to override the default gateway root. The package's
`just sync-env` reads the TOML mapping through dotfile-vnext's `bin/codex-env`,
writes ignored `.env` with mode `0600`, and the package loads that `.env` on
direct launch. No skill is required after environment hydration.

`gpt-oss-20b` is intentionally chat-only in the default manifest because its
gateway behavior currently returns empty content rather than a tool call; its
tools scenario is omitted by capability gating until commissioned.

## Evidence boundary

Passing checks prove the named LiteLLM HTTP contract only: status, response
shape, non-empty output, FIM insertion, embedding vector, and the configured
context-budget guard. They do not prove IDE behavior, grounded editing,
tool execution, or general model quality.

## Outputs

Human mode prints `JOURNEY / WHY / USER / EXPECTED / ACTUAL` for every pass and
failure, including separate tools invoke/execute/followup receipts. Preserve
those blocks in plan receipts and distinguish skipped from passed. Machine,
JSON, or CI output is opt-in only.

## Measurement boundary

Passing proves only the named LiteLLM HTTP, capability, tool-harness, FIM, or
embedding contract. It does not prove IDE round trips, grounded repo editing,
tool execution when only content was returned, general model quality, or
production readiness.

## Documentation Provenance

- Origin: Plan 20 vNext request.
- Root source of truth: global
  `homelab-litellm-model-lane-pytest` skill and the project model SSOT.
- Direct inputs: Plan 20 and `TDD/test_model_lanes.py`.
- Outputs: this draft skill and `TDD/test_model_lanes_vnext.py`.
- Skills used: `skill-creator`, `documentation-provenance-chain`.
