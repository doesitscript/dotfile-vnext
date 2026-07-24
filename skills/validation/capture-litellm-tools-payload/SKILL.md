---
name: capture-litellm-tools-payload
description: "Use when LiteLLM pre-call tools[] schemas must be measured or dumped for any OpenAI-compatible client (Cursor, Cline, Codex, etc.) — tool token tax, per-tool desc vs params split, or collecting tools-array-complete.json from the gateway pod. Use after a tools-bearing request through a published LiteLLM alias. Do not use for message/rules-only context analysis without a tools dump, or for changing trim defaults."
license: MIT
version: "0.2.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: "litellm-cursor-traffic-analyzer"
requires_summary: "bin/codex-env; kubectl via hom-lab-ctl-k3s-02; LiteLLM pre-call tools dump"
title: Capture LiteLLM Tools Payload
technology: litellm
document_type: skill
status: reviewed
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-07-23"
applies_to:
  - litellm
  - validation
related:
  - roles/k3s_litellm_gateway/templates/custom_callbacks.py.j2
  - skills/validation/litellm-cursor-traffic-analyzer/SKILL.md
tags:
  - skill
  - litellm
  - tools
  - capture
---

# Skill: Capture LiteLLM Tools Payload

Collect the real request `tools[]` payload as seen by LiteLLM’s pre-call hook
from **any** OpenAI-compatible client (Cursor Agent, Cline, Codex, custom
scripts), including named tool definition files when present.

## Will this work for Cline (and others)?

**Yes**, if all of these are true:

1. The client sends the request to this homelab LiteLLM gateway (published alias).
2. The request includes a non-empty `tools` / functions array.
3. The tools-dump callback is mounted on the LiteLLM pod.

The dump is **client-agnostic**: whatever schemas arrive in `data["tools"]` are
written under `/tmp/litellm-tools-capture/`. There is **no client identity field**
in the dump today (it does not label “Cline” vs “Cursor”).

Caveats:

- **Last write wins** — each tools-bearing request overwrites the pod dump. Collect
  soon after the turn you care about.
- `tool-Task.json` / `tool-Shell.json` exist only when tools named `Task` / `Shell`
  are in that request (common for Cursor; often absent for Cline).
- Group labels such as `cursor_builtin_tokens` are **heuristic buckets** in the
  callback, not proof of which app sent the traffic.

## When to use / not use

Use when measuring or dumping client tool schemas through LiteLLM (token tax,
desc vs params, largest tools).

Do not use when the only need is to change trim drivers →
`tune-litellm-context-safety-net`. Do not use for probes that send empty
`tools` / `tools_est=0` unless confirming the empty case.

## Inputs

- One completed **tools-bearing** request through a published LiteLLM alias
  (e.g. Ornith) after the tools-dump hook is mounted
- Optional output directory (default `logs/litellm-tools-capture/` in the repo)

## Workflow

1. Confirm the LiteLLM pod has the current callback (tools dump writes under
   `/tmp/litellm-tools-capture/`).
2. Ask the operator to send one tools-bearing turn through the gateway if no
   dump exists yet (or to overwrite a stale dump).
3. Run the collect script from the repo root (or follow
   `references/related-artifacts.md` commands):

```bash
bin/codex-env bash skills/validation/capture-litellm-tools-payload/scripts/collect_tools_capture.sh
```

4. Open `summary.json` for `desc_tokens` / `params_tokens` / group totals.
5. Open `tools-array-complete.json` for the full array; open `tool-Task.json` /
   `tool-Shell.json` only when those files exist for this dump.
6. Report the largest tools and whether cost is description prose, parameters,
   or enums — without inventing product knobs that are not evidenced.

## Handoffs

- Back to `litellm-cursor-traffic-analyzer` for interpretation
- `tune-litellm-context-safety-net` only if the next step is changing gateway
  budgets or fallbacks (client tool schemas themselves are client-owned)

## Outputs

- `logs/litellm-tools-capture/` (or `$OUT`) with:
  - `summary.json`
  - `tools-array-complete.json`
  - `tool-Task.json` (when Task is present)
  - `tool-Shell.json` (when Shell is present)
  - `summary-logs.txt`
  - `litellm-tools-structure-dump.json`

## Validation

- `tools-array-complete.json` parses as JSON array (or documented MISSING)
- `summary.json` includes `tool_tokens_total` and per-tool desc/params split
- Log grep shows `tools_breakdown` for the same window when available

## Failure boundaries

- Stop if the pod has no `/tmp/litellm-tools-capture/` after a tools-bearing
  request — redeploy callback or confirm the request hit this gateway
- Stop if Ansible/kubectl cannot reach `hom-lab-ctl-k3s-02` — capture evidence

## Prohibited behavior

- Fabricating per-tool token numbers without the dump or hook log
- Claiming MCP schemas dominate when group totals show `mcp_*=0`
- Skipping the tools-bearing request prerequisite when the dump is missing
- Claiming the dump identifies the client (Cline vs Cursor) when no such field exists

## Progressive disclosure

- Operator escalation: `skills/_shared/human-escalation.md`
- Load `references/sources-and-precedence.md` when ranking dump vs logs.
- Load `references/related-artifacts.md` for paths and collect commands.
