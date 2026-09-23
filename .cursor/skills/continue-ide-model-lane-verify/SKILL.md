---
name: continue-ide-model-lane-verify
description: >-
  Verify Continue LiteLLM model lanes with embed dimension and FIM completion
  smokes, and decode evidence shorthand for plan receipts. Use after deploying
  Continue autocomplete/embed/edit/apply routes, when checking nomic 768-dim
  embeddings or FIM HTTP 200, or when a plan says embed smoke / FIM completions
  without explaining the numbers. Do not use as the placement/research step.
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: "homelab-ansible-first-entry, continue-ide-model-lane-recommend"
requires_summary: "LiteLLM /v1/embeddings and /v1/completions probes; vault key; smoke-evidence-decode"
title: Continue IDE Model Lane Verify
technology: continue
document_type: skill
status: reviewed
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-09-12"
applies_to:
  - continue
  - litellm
  - verification
related:
  - docs/plans/2026-09-12-mac_and_model_recommend/smoke-evidence-decode.md
  - model-lane-acceptance/gateway/continue-embed-and-fim-atdd.md
  - roles/continue_ide/
  - roles/k3s_litellm_gateway/
tags:
  - skill
  - continue
  - verification
  - smoke
---

# Skill: Continue IDE Model Lane Verify

Prove Continue-facing LiteLLM lanes after recommend/apply. Decode shorthand
like `embed smoke 768 dims` and `FIM completions 200` using
`references/smoke-evidence-decode.md`.

## When to use / not use

**Use after** gateway + Continue config changes for autocomplete, embed, edit,
apply, or chat — or when a plan receipt needs explained smoke numbers.

**Do not use** to choose models (that is `continue-ide-model-lane-recommend`).

## Run / Evidence

> **AI agent note (future port):** Prefer `/Users/joshc/develop/homelab-model-lane-pytest`
> (`just run --profile eval-core`) for LiteLLM gateway chat/tools/FIM/embed journeys.
> Do not grow a parallel gateway harness in this skill. Port remaining probes here when
> touching this skill. Until ported, this skill may still use `model-lane-acceptance`
> scripts and vault-backed Ansible URI probes for Continue-specific decode tables.

## Workflow

1. Read `references/smoke-evidence-decode.md` and
   `model-lane-acceptance/gateway/continue-embed-and-fim-atdd.md` (user need +
   Given/When/Then).
2. Confirm `GET /v1/models` lists the client ids under test (vault-backed
   Ansible `uri`; never print the master key).
3. **Embed:** `POST /v1/embeddings` with `nomic-embed-text@hvh01` (or the
   commissioned embed id). Pass only if status 200 and
   `len(embedding) == expected_dims` (768 for nomic). Prefer harness when
   `type: embed` exists; until then ops probe + ATDD doc is the contract.
4. **Autocomplete FIM:** Prefer
   `./model-lane-acceptance/scripts/run-gateway-acceptance.sh -m llm_fim -v -s`
   (approved journey). Or `POST /v1/completions` with a FIM prompt — pass only
   if status 200 and non-empty text.
5. Optional: chat/edit smokes via `/v1/chat/completions` when those roles moved.
6. Write pass/fail into the active plan intake table with the plain-language
   decode (not unexplained numbers alone).

## Outputs

- Pass/fail per probe with status + dims/text_len
- Updated plan evidence section when a plan packet is in scope

## Validation

- Probes ran in the **current** turn
- No secrets in chat logs (`no_log: true` on vault tasks)

## Failure boundaries

- Desktop/HVH Ollama down → record blocked with URI error; do not flip model
  picks without evidence
- Wrong dims → treat embed route as fail even if HTTP 200
