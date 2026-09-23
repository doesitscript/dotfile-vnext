---
title: Library research receipt — context budget client + lab config
captured_at: "2026-09-17"
---

# Library research receipt (HRL + Context7)

## Library topic check — context budget / Continue chat hard error

### Exists (already in HRL before this turn)

- `generated/context7/litellm/kilo-client-context-errors/` — thin ContextWindowExceeded note (Kilo-oriented)
- `notes/investigations/2026-09-01--kilo-code-litellm-vllm-context-limits.md` — same arithmetic class for Kilo
- `generated/context7/continue/configuration-customization-and-reference/` — config surfaces, MCP links (not maxTokens budget deep-dive)
- LiteLLM proxy / routing packs; vLLM openai-compatible / gpu-memory packs

### Missing → Written this turn

| Topic | Landing |
| --- | --- |
| Continue `contextLength` / `maxTokens` / tools / MCP agent-only | `homelab-reference-library/generated/context7/continue/contextlength-maxtokens-tools-mcp/` |
| LiteLLM `ContextWindowExceededError` + `context_window_fallbacks` | `…/generated/context7/litellm/context-window-fallbacks-and-errors/` |
| vLLM `max_model_len` = prompt + output validation | `…/generated/context7/vllm/max-model-len-prompt-plus-output/` |
| This incident investigation | `…/notes/investigations/2026-09-16--continue-work-laptop-qwen3-context-tool-budget.md` |
| Operator Q&A | `…/q-and-a/continue/chat-context-window-tools-and-maxtokens.md` |

### Research Needed (deferred)

- Exact Continue version tool name catalog for `toolOverrides` on work-laptop build
- Whether work-laptop export packet should lower default `maxTokens` in Ansible SSOT (design decision — not done)
- Optional LiteLLM `context_window_fallbacks` only if a larger-context sibling lane is commissioned

### Context7

- ran resolve+query: `/continuedev/continue`, `/websites/litellm_ai`, `/websites/vllm_ai_en_stable`
- Indexes rebuilt: yes (`bin/hrl-env scripts/build_indexes.py`)

## Practical config guidance (from packs + lab evidence)

**Not a GPU crash** — vLLM/LiteLLM rejected `input + max_tokens > 32768`.

### Client (Mac work laptop Continue) — do these first

1. Keep disabling unused MCP/tools (you started this; evidence showed ~28.7k tool schemas / 84 tools).
2. Prefer **Chat** mode for pure chatting — Continue: MCP is **Agent-only**.
3. Consider lowering `defaultCompletionOptions.maxTokens` from 4096 → 1024–2048 for more input headroom.
4. In Agent mode, use `chatOptions.toolOverrides.<tool>.disabled: true` for heavy built-ins.

### Lab (shared gateway / vLLM) — understand, change only deliberately

1. Request Inspector already explains budgets (tools/system/conversation/reserved_output).
2. No silent trim in lab anymore (observe-only).
3. `context_window_fallbacks` is optional and only useful if a larger-context model group exists.
4. Do not raise `--max-model-len` as the first fix for tool-schema tax.
