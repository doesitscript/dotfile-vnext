---
name: homelab-litellm-model-lane-pytest-draft
description: >-
  Run the project vNext, data-driven LiteLLM model-lane pytest suite for the
  six commissioned evaluation models. Use for scalable chat, FIM, context,
  response-shape, and optional embedding checks after gateway convergence.
  Do not use for deploying runtimes or changing model inventory.
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skill for dotfile-vnext"
modes: "agent, ask, plan, debug"
depends_on_skills: "repo-env-wrapper-contract"
requires_summary: "pytest; LITELLM_API_KEY; LiteLLM gateway"
title: Homelab LiteLLM Model Lane Pytest Draft
technology: litellm
document_type: skill
status: draft
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

This project-owned draft scales the shared LiteLLM lane checks through one
manifest and pytest parametrization. It tests six evaluation models without
requiring simultaneous GPU residency.

## Evaluation set

- `qwen3-coder-30b-a3b` — chat and context-safe response
- `qwen2.5-coder-7b` — chat and context-safe response
- `qwen2.5-coder-1.5b-base-q8_0` — FIM completion, not chat tools
- `qwen2.5-coder-14b` — chat and context-safe response
- `gpt-oss-20b` — chat and non-empty response
- `ministral-3-8b` — chat and non-empty response

`nomic-embed-text` is tested separately as the embedding-owner check; it is
not counted among the six chat/FIM evaluation models.

## Run

```bash
cd /Users/joshc/develop/dotfile-vnext
LITELLM_API_KEY="$LITELLM_API_KEY" \\
  python3 -m pytest -q -s \\
  docs/plans/2026-09-13--get-back-ansible-best-practice/TDD/test_model_lanes_vnext.py
```

The suite skips live tests when `LITELLM_API_KEY` is unset. Never put a key in
the manifest, test source, plan receipt, or command history. Set
`LITELLM_GATEWAY_ROOT` to override the default gateway root.

## Evidence boundary

Passing checks prove the named LiteLLM HTTP contract only: status, response
shape, non-empty output, FIM insertion, embedding vector, and the configured
context-budget guard. They do not prove IDE behavior, grounded editing,
tool execution, or general model quality.

## Outputs

The test prints one `MODEL / CHECK / EXPECTED / ACTUAL / RESULT` receipt for
each live model check. The plan receipt must preserve those outputs and
distinguish skipped tests from passes.

## Documentation Provenance

- Origin: Plan 20 vNext request.
- Root source of truth: global
  `homelab-litellm-model-lane-pytest` skill and the project model SSOT.
- Direct inputs: Plan 20 and `TDD/test_model_lanes.py`.
- Outputs: this draft skill and `TDD/test_model_lanes_vnext.py`.
- Skills used: `skill-creator`, `documentation-provenance-chain`.
