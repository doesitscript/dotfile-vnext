# Local LLM context vs always-on framework rules

**Date:** 2026-07-23  
**Evidence:** `logs/litellm-tools-capture/summary.json` (~26k tool tokens) +
measured `.cursor/rules` always-on (~45k tokens before demotion).

## Problem

Local Ornith via LiteLLM is ~32k context. Cursor Agent was injecting:

1. ~26k Cursor builtin tool schemas (Task, Shell, …) — product client tax
2. ~45k `alwaysApply: true` framework rules — repo-controlled tax

That combination cannot fit; LiteLLM trim then drops chat → amnesia / errors.

## Constraint

Cursor has **no** model-conditional rule field. You cannot say “only if
Anthropic/OpenAI.” LiteLLM cannot strip rules Cursor already sent.

## Fix applied

1. Added `.cursor/rules/framework-context-budget.mdc` (`alwaysApply: true`).
2. Demoted heavy framework / Ansible / NetBox / MCP / troubleshooting rules to
   `alwaysApply: false` (with `globs` where file-scoped).
3. Kept thin always-on: context-budget, user-interaction-style, model-lanes,
   slim `.cursorrules`.

## Intent vs reality

**Desired:** framework tokens only on Cursor provider models.  
**Achievable in one workspace:** framework mostly on-demand for **all** models;
large Cursor models still auto-attach rules via description/globs; local models
stop paying ~45k always-on.

Hard split (optional later): open Ornith sessions in a boot-only workspace copy.

## Related

- `docs/diagnostics/litellm-context-window--k3s--diagnostics.md`
- `.cursor/rules/framework-context-budget.mdc`
- Skills: `litellm-cursor-traffic-analyzer`, `tune-litellm-context-safety-net`
