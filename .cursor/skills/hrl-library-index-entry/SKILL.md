---
name: hrl-library-index-entry
description: >-
  Use when Cursor/Codex work in dotfile-vnext should load or cite
  homelab-reference-library indexes, LangGraph/Langfuse packs, or learning-path
  guides. Use for where is the HRL index, open library indexes, LangGraph
  recipes, or agent learning path. Do not use for live Ansible deploy.
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: ""
requires_summary: "HRL repo path; indexes rebuilt"
title: HRL Library Index Entry
technology: documentation
document_type: skill
status: reviewed
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-07-24"
applies_to:
  - documentation
  - langgraph
  - langfuse
tags:
  - skill
  - hrl
  - indexes
  - context7
---

# Skill: HRL Library Index Entry

Force Cursor sessions to **open HRL indexes** instead of relying on ambient
memory. HRL indexes are not auto-injected into every turn.

## When to use / not use

Use when the task needs library truth (LangGraph recipes, Langfuse integrations,
learn-later frameworks, SOURCE decisions).

Do not use for mutating hosts — use `homelab-ansible-first-entry`.

## Workflow

1. Treat HRL root as:
   `/Users/joshc/develop/homelab-reference-library`
2. Open entry doors (Read tool):
   - `indexes/technologies.md`
   - `indexes/tasks.md`
   - `indexes/relationships.md`
   - `indexes/q-and-a.md`
3. For LangGraph coding:
   - `implementation-guides/langgraph/recipes.md`
   - `implementation-guides/langgraph/learning-path.md`
   - `implementation-guides/agent-learning-path/README.md`
4. Prefer `generated/context7/<tech>/<topic>/result.md` over web guesswork.
5. Optional Context7 MCP: resolve library ids from each `vendor/*/SOURCE.md`.
6. If Context7 private/public repo indexing is needed for HRL or dotfile-vnext,
   use dashboard https://context7.com/add-library (API add currently 500 — see
   `docs/diagnostics/context7-add-repo-api--2026-07-24.md`).
7. For multi-topic library ingest / “is this in good shape?” completion gates,
   hand off to HRL skill `library-intake-good-shape` (do not stop after opening
   indexes alone).
8. When coverage is thin or zero, emit the HRL thin/zero Exists/Missing/
   Research Needed receipt (`homelab-reference-library/AGENTS.md`) before
   inventing answers.
9. When chat/plan research must land in HRL before build: hand off to global
   skill `conversation-research-to-library`. Plan habit:
   `docs/codex_framework/plan-research-intermission.md`.
10. When the next step is vendor scrape before planning a product build:
   hand off to `vendor-doc-collection` with **task-scoped** pages by default
   (only what the goal needs). Full/complete vendor clone only when the user
   explicitly asks. Then plan — do not invent Ansible placement first.
   Product orchestration: `homelab-product-capability-flow`.

## Prompt

```text
Use skill hrl-library-index-entry and open HRL indexes/technologies.md before answering.
```

```text
Use skill hrl-library-index-entry then vendor-doc-collection for <product>
(task-scoped unless I say full clone), then plan before build.
```
