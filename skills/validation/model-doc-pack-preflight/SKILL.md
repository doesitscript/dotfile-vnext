---
name: model-doc-pack-preflight
description: "Use when dotfile-vnext is about to implement or change LiteLLM, vLLM, Ollama, or Continue wiring for a model and must consult the HRL model-doc-pack first, then sync inventory source_routing pointers. Use for model doc pack preflight, check HRL before model implement, or sync model_catalog source routing. Do not use to author the HRL pack itself (use global library-first-model-doc-pack / HRL create) or for unrelated Ansible work."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: ""
requires_summary: "HRL models/ catalog reachable; inventory/group_vars/model_catalog/"
title: Model Doc Pack Preflight
technology: framework
document_type: skill
status: draft
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-07-23"
applies_to:
  - models
  - litellm
  - vllm
  - ollama
related:
  - inventory/group_vars/model_catalog/manifest.yml
  - inventory/group_vars/model_catalog/SOURCE-ROUTING.md
  - /Users/joshc/develop/global-skills/skills/documentation/library-first-model-doc-pack/SKILL.md
tags:
  - skill
  - model-doc-pack
  - preflight
---

# Skill: Model Doc Pack Preflight

Gate model-backed implementation in `dotfile-vnext` on an HRL model-doc-pack
lookup, then keep inventory `source_routing` pointers aligned.

## When to use / not use

Use before implementing or changing model lanes, pulls, or serving wiring.

Do not use to scrape model cards into this repo — durable docs live in HRL.

## Inputs

- Model lane and/or HF repo id and/or Ollama tag
- Intended change class (inventory only vs Ansible apply)

## Workflow

1. Call global `library-first-model-doc-pack` in `lookup` mode (or HRL
   `model-doc-pack-lookup` directly if already in an HRL session).
2. If pack missing or critically incomplete for the change, stop and request
   `create` / `refresh` mode first.
3. Read `inventory/group_vars/model_catalog/SOURCE-ROUTING.md` and the matching
   `manifest.yml` row.
4. Sync or add `source_routing` fields on the row when they drift from the pack
   (`primary_doc_source`, URLs, `hrl_pack_slug`, optional Context7/`llms.txt`).
5. Only then proceed to the owning implementation skill/playbook.
6. Receipt: pack path, gaps that do not block, inventory paths touched.

## Handoffs

- Global: `library-first-model-doc-pack`
- After preflight: existing LiteLLM / vLLM / Ollama roles and playbooks
- Docs-only inventory edits stay in `model_catalog`

## Outputs

- Preflight pass/fail with pack path
- Updated `source_routing` on the catalog row when needed
- Explicit blockers from HRL coverage gaps

## Validation

- Lookup evidence cited from HRL `models/<slug>/`
- No model-card markdown duplicated into `dotfile-vnext` as a second SSOT

## Failure boundaries

- Stop when HRL pack is missing and create was not run
- Stop when required serving/license facts are absent and apply would depend on them

## Prohibited behavior

- Inventing HF/Ollama URLs
- Treating LiteLLM lane names as HF repo ids without a catalog mapping
- Skipping library-first lookup because inventory already has a row

## Progressive disclosure

- Operator escalation: `skills/_shared/human-escalation.md`
- Load `references/sources-and-precedence.md` and `references/related-artifacts.md`.
