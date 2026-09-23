---
name: homelab-litellm-model-lane-pytest-draft
description: >-
  Run the project vNext LiteLLM model-lane pytest suite via the sibling package
  (catalog pytest_eval + package journeys). Use for scalable chat, FIM, tools,
  and embedding checks after gateway convergence. Do not use for deploying
  runtimes or changing model inventory.
license: MIT
version: "0.3.0b0"
author: "dotfile-vnext"
compatibility: "Project skill for dotfile-vnext"
modes: "agent, ask, plan, debug"
depends_on_skills: "repo-env-wrapper-contract"
requires_summary: "pytest; LITELLM_API_KEY; LiteLLM gateway; DOTFILE_VNEXT"
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
  - /Users/joshc/develop/homelab-model-lane-pytest/README.md
  - inventory/group_vars/model_catalog/LANE-IDENTITY.md
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

Membership SSOT: catalog `pytest_eval.profiles: [eval-core]` in
`inventory/group_vars/model_catalog/manifest.yml` (see `LANE-IDENTITY.md`).

The package is beta-stable to consume (`0.3.0b0`); it owns **full** gateway
harness maturity (functional groups, class-per-group tests, banners, xdist,
HTML/Allure, infrastructure publish gate, rich receipts, `expect_mode` tools).
This skill remains named `-draft` until a later explicit promote decision.

## Package commands (gateway only — no skill-local harness)

All gateway probes run **only** through the package checkout:

```bash
cd /Users/joshc/develop/homelab-model-lane-pytest
DOTFILE_VNEXT=/Users/joshc/develop/dotfile-vnext just sync-env
just unit
just run --profile eval-core
just run --profile smoke --lane-filter qwen3-coder-30b-a3b
just run --profile eval-core -m infrastructure
just run --profile eval-core -m 'smoke or llm_chat or llm_tools or llm_fim or embed'
just run --profile eval-core --probe-parallel
just run --profile eval-core --probe-report html
just run --profile eval-core --probe-report allure
just run --profile eval-core --probe-output machine
```

Use `just run --profile eval-core` for the catalog-opted matrix. Use
`just run --profile smoke --lane-filter <id>` for one model. The legacy alias
`commissioned-six` maps to `eval-core` with a deprecation warning. Profiles are
`smoke`, `pr`, `nightly`, `capability-tools`, and `eval-core`. Set
`LITELLM_LANE_FILTER` for comma-separated IDs.

### Functional groups, banners, and filters

| Marker | Group | Package behavior |
| --- | --- | --- |
| `infrastructure` | Infrastructure | LiteLLM `GET /v1/models` publish gate |
| `smoke` | Smoke | ping→pong liveness |
| `llm_chat` | LLM Chat | coding chat journeys |
| `llm_tools` | LLM Tools | invoke / execute / followup (`expect_mode`, JSON-in-content) |
| `llm_fim` | LLM FIM | autocomplete / FIM |
| `embed` | Embed | embedding vector contracts |

In human output mode, each group prints a **terminal banner** before its class
(`TestInfrastructure`, `TestSmoke`, `TestLlmChat`, …). Session end prints
**USAGE RECEIPT SUMMARY (by functional group)**. Machine mode writes
`.probe-receipts/latest.json`; HTML/Allure paths follow `--probe-report`.

Optional deps: `uv sync --group report` (pytest-html, allure-pytest; xdist in
`dev`).

## Run

```bash
cd /Users/joshc/develop/homelab-model-lane-pytest
DOTFILE_VNEXT=/Users/joshc/develop/dotfile-vnext just sync-env
just unit
just run --profile eval-core -m smoke -k qwen3-coder-30b-a3b
```

The package prints full `JOURNEY / WHY / USER / EXPECTED / ACTUAL` receipts
for every pass and failure, separate `invoke / execute / followup` receipts
for successful tools journeys, and **USAGE RECEIPT SUMMARY (by functional
group)**. Do not replace these receipts with pytest counts alone.

The suite skips live tests when `LITELLM_API_KEY` is unset. Never put a key in
the manifest, test source, plan receipt, or command history. Set
`LITELLM_GATEWAY_ROOT` to override the default gateway root. The package's
`just sync-env` reads the TOML mapping through dotfile-vnext's `bin/codex-env`,
writes ignored `.env` with mode `0600`, and the package loads that `.env` on
direct launch. No skill is required after environment hydration.

`gpt-oss-20b` is intentionally chat-only in the default manifest because its
gateway behavior currently returns empty content rather than a tool call; its
tools scenario is omitted by capability gating until ready.

## Adding a model to eval-core

1. Catalog: `lane` == `client_model_id`, then `pytest_eval: { profiles: [eval-core] }`.
2. Package: add a lane row + journeys in `manifests/default.yml`.
3. `just unit` in the package (SSOT tests fail on drift).

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

- Origin: Plan 20 vNext request; 2026-09-22 lane-identity + eval-core SSOT.
- Root source of truth: package + catalog `pytest_eval` / LANE-IDENTITY.
- Global skill `homelab-litellm-model-lane-pytest` delegates gateway to package.
- Skills used: `documentation-provenance-chain`, package harness.
