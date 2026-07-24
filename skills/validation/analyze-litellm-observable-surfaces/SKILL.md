---
name: analyze-litellm-observable-surfaces
description: "Use when the question is what LiteLLM can report or observe from Cursor traffic on this homelab gateway — pre-call hooks, kubectl logs, pod dumps, Langfuse, models/health endpoints, or Postgres spend metadata. Use to inventory evidence surfaces before deeper capture or tuning. Do not use to dump tools[] (use capture-litellm-tools-payload) or to change trim defaults (use tune-litellm-context-safety-net)."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: "litellm-cursor-traffic-analyzer, capture-litellm-tools-payload"
requires_summary: "roles/k3s_litellm_gateway; Langfuse callback settings; bin/codex-env"
title: Analyze LiteLLM Observable Surfaces
technology: litellm
document_type: skill
status: reviewed
authority: internal
source_type: internal
last_reviewed_at: "2026-07-23"
applies_to:
  - litellm
  - observability
  - validation
related:
  - roles/k3s_litellm_gateway/defaults/main.yml
  - roles/k3s_litellm_gateway/templates/custom_callbacks.py.j2
  - docs/diagnostics/litellm-context-window--k3s--diagnostics.md
tags:
  - skill
  - litellm
  - observability
  - validation
---

# Skill: Analyze LiteLLM Observable Surfaces

Inventory what this lab’s LiteLLM gateway can actually report about Cursor
requests — without claiming Cursor-internal UI state.

## When to use / not use

Use when asking what LiteLLM can report, where Cursor request evidence lives,
or which surface to wire next.

Do not use when the operator only needs a tools dump →
`capture-litellm-tools-payload`. Do not use for DNS-only checks.

## Inputs

- Active gateway role defaults (callbacks, Langfuse, trim hook enabled)
- Optional live pod/log access on `hom-lab-ctl-k3s-02`

## Workflow

1. Load `references/related-artifacts.md` and walk the surface table.
2. For each surface, mark: **wired**, **available-but-unqueried**, or **not in this lab**.
3. Prefer pre-call hook + pod dumps for tools/schema questions; Langfuse for
   post-call traces; `/v1/models` for alias inventory only.
4. If the next action is a dump, hand off to `capture-litellm-tools-payload`.
5. If the next action is changing drivers/fallbacks, hand off to
   `tune-litellm-context-safety-net`.

## Handoffs

- `capture-litellm-tools-payload`
- `tune-litellm-context-safety-net`
- `litellm-cursor-traffic-analyzer` (parent routing)

## Outputs

- Surface inventory table with status per row
- Recommended next evidence action

## Validation

- Every claimed surface cites a repo path or live probe command
- Cursor UI is never listed as a LiteLLM reporting surface

## Failure boundaries

- Stop short of declaring Langfuse “working” without a trace lookup when that
  is the claim under test

## Prohibited behavior

- Inventing LiteLLM admin APIs this role does not deploy
- Equating model alias lists with tools[] observability

## Progressive disclosure

- Operator escalation: `skills/_shared/human-escalation.md`
- Load `references/sources-and-precedence.md` for ranking.
- Load `references/related-artifacts.md` for the surface table and probes.
