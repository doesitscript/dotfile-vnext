---
name: litellm-cursor-traffic-analyzer
description: "Use when Cursor Agent traffic through the homelab LiteLLM gateway needs diagnosis or measurement — context overflow, mid-stream Internal Server Error, lost chat context after trim, or questions about what Cursor sends vs what LiteLLM can report. Use for Ornith tool-tax analysis, trim_messages hook evidence, or routing to capture/tune sub-workflows. Do not use for DNS reachability of litellm.hom.lab alone or for generic LiteLLM vendor-doc collection."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: "capture-litellm-tools-payload, analyze-litellm-observable-surfaces, tune-litellm-context-safety-net"
requires_summary: "roles/k3s_litellm_gateway; docs/diagnostics/litellm-context-window--k3s--diagnostics.md; bin/codex-env"
title: LiteLLM Cursor Traffic Analyzer
technology: litellm
document_type: skill
status: reviewed
authority: internal
source_type: internal
last_reviewed_at: "2026-07-23"
applies_to:
  - litellm
  - cursor
  - vllm
  - validation
related:
  - roles/k3s_litellm_gateway/README.md
  - docs/diagnostics/litellm-context-window--k3s--diagnostics.md
  - playbooks/deploy_litellm_gateway.yaml
tags:
  - skill
  - litellm
  - cursor
  - validation
  - tools
---

# Skill: LiteLLM Cursor Traffic Analyzer

Route Cursor → LiteLLM → local vLLM diagnosis to the right evidence workflow.
Do not invent causes from the Cursor UI alone.

## When to use / not use

Use when:

- Agent replies die mid-stream or Cursor shows Internal Server Error on Ornith
- `ContextWindowExceededError` / 32768 overflow appears
- follow-ups claim no context after a crash
- the question is what Cursor is sending (especially `tools[]`) through the gateway

Do not use when:

- only DNS/HTTP reachability of `litellm.hom.lab` is in scope → `homelab-dns-investigator`
- only vendor LiteLLM docs pack work → `ai-library-entry` / library skills
- only k9s navigation → `homelab-k9s`

## Inputs

- Symptom (overflow, mid-stream cut, amnesia, tool-tax question)
- Model alias used (`deepreinforce-ai/Ornith-1.0-35B-GGUF`, `smart-router`, etc.)
- Whether the client was Cursor **Agent** (tools on) or Ask (tools usually off)

## Workflow

1. Classify the failure bucket:
   - overflow / `Fallbacks=None` → context window + missing cloud fallback
   - mid-stream cut with HTTP 200 → completion / trim budget
   - “no context” after crash → message trim under huge `tools_est`
   - “what is Cursor sending?” → tools payload capture
2. Separate **tool schema tax** (`tools_est` / tools dump) from **message/rules tax** (`before=` / `after=`).
3. Hand off:
   - dump / measure tools → `capture-litellm-tools-payload`
   - inventory what LiteLLM can report → `analyze-litellm-observable-surfaces`
   - change trim drivers / vault OpenAI fallback → `tune-litellm-context-safety-net`
4. Prefer gateway evidence (hook logs, pod dumps, Langfuse) over Cursor UI paraphrase.

## Handoffs

- `capture-litellm-tools-payload`
- `analyze-litellm-observable-surfaces`
- `tune-litellm-context-safety-net`

## Outputs

- Failure-bucket classification
- Chosen handoff skill
- Pointers to the evidence surfaces that must be collected next

## Validation

- Classification cites a real log line, dump path, or diagnostics doc section
- Tool tax is not blamed on MCP when `mcp_*_tokens=0` and builtins dominate

## Failure boundaries

- Stop guessing when no LiteLLM log or dump has been collected yet
- Escalate when changing vault keys or raising completion budgets has cost tradeoffs

## Prohibited behavior

- Treating Cursor chat UI history as proof of what the model received
- Blaming `.cursor/rules` for Task/Shell schema size without a tools dump
- Calling repo-only edits a completed diagnosis

## Progressive disclosure

- Operator escalation: `skills/_shared/human-escalation.md`
- Load `references/sources-and-precedence.md` for evidence ranking.
- Load `references/related-artifacts.md` for role paths and known failure modes.
