---
name: continue-ide-model-lane-recommend
description: >-
  Recommend Continue IDE model@host lanes from required roles plus free
  homelab infrastructure. Use when the user lists Continue roles or features
  (chat, edit, apply, autocomplete, embed, rerank) and available GPUs/hosts,
  asks which models to run where, or wants a mac-dev Continue placement plan
  after research. Do not use for ad-hoc Ollama pulls without Ansible or for
  non-Continue clients unless mapped through the same LiteLLM model@host
  contract.
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan"
depends_on_skills: "homelab-ansible-first-entry, ansible-knowledge-gate, hf-model-weight-lifecycle, continue-ide-model-lane-verify"
requires_summary: "Continue roles; LiteLLM model@host; windows_ollama_runtime; plan packet pattern"
title: Continue IDE Model Lane Recommend
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
  - ollama
  - model-catalog
related:
  - docs/plans/2026-09-12-mac_and_model_recommend/
  - inventory/group_vars/all/ai_cli_apps.yml
  - inventory/group_vars/all/ai_cli_apps-INTAKE.md
  - inventory/group_vars/all/ai_cli_apps-INFRA-COGS.md
  - roles/continue_ide/
  - roles/k3s_litellm_gateway/
  - roles/windows_ollama_runtime/
tags:
  - skill
  - continue
  - model-lanes
  - placement
---

# Skill: Continue IDE Model Lane Recommend

Turn **required Continue roles** + **free infrastructure** into a researched
recommendation matrix (model, host, runtime, LiteLLM id, smokes) before any
mutate. Apply stays behind `homelab-ansible-first-entry`.

## When to use / not use

**Use when** the user names Continue roles/features and what hardware is free,
or asks to place autocomplete/embed/edit/apply/chat without putting models on
a weak client Mac.

**Do not use** to invent SSH `ollama pull` as the primary path, or to park aux
roles on a GPU already committed to primary vLLM chat without an explicit trade.

## Inputs (require before deciding)

1. **Roles in scope** — subset of: `chat`, `edit`, `apply`, `autocomplete`,
   `embed`, `rerank` (`summarize` = skip; unused)
2. **Free infra** — inventory hostnames, GPU, VRAM, existing runtime
   (Ollama / vLLM), what must stay untouched
3. **Client** — usually mac-dev Continue via `http://litellm.hom.lab/v1`
4. **Constraints** — e.g. do not remove existing Continue entries; protect 5090

## Workflow

1. Load role cards: `references/continue-role-requirements.md` (or plan copy).
2. Research candidates (Context7 / Firecrawl / Continue best-models tables /
   Ollama library tags). Record run params (temp, FIM vs chat, embed dims).
3. Place with rules in `references/placement-rules.md`:
   - match role latency/size to VRAM
   - protect primary GPU
   - prefer existing `windows_ollama_runtime` / vLLM / LiteLLM pipelines
   - client Mac config-only when no discrete GPU
4. Emit a recommendation table + model↔role fit notes + placement rationale.
5. Map LiteLLM `model@host` ids; note Ollama vs `openai/` vs `ollama/` provider.
6. **Stop for apply** unless user asked to execute — then hand off
   `homelab-ansible-first-entry` → ollama/HF/LiteLLM/continue_ide.
7. After apply, hand off `continue-ide-model-lane-verify`.

## Outputs

- Role × model × host × runtime × client id matrix
- Fit + placement prose (or links into a plan packet under `docs/plans/`)
- Explicit deferred roles (`rerank`, `summarize`)
- Apply / Verify / Undo / Change class when moving to execute

## Validation

- Every in-scope role has a candidate or an explicit deferral
- Placement cites free-infra facts (not invented hosts)
- Research sources listed
- No claim of live apply without Ansible evidence

## Failure boundaries

- Missing free-infra list → ask once, do not guess VRAM
- Continue provider cannot serve a role (e.g. unsupported rerank) → defer with research note
- Pascal GPU → Ollama/llama.cpp, not modern vLLM

## Handoffs

- `homelab-ansible-first-entry` (mutate)
- `hf-model-weight-lifecycle` (HF trees only)
- `continue-ide-model-lane-verify` (smokes)
- Plan packet pattern: `docs/plans/YYYY-MM-DD--*/`
