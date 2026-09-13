# 02 — Assessment and proposal

Date: 2026-09-12  
Lane: `qwen3-coder-30b-a3b` (Qwen3-Coder-30B-A3B AWQ on 5090)  
Related: `01-actors-retro-capture.yml`, `diagrams/before.md`, `diagrams/after.md`

## 1. What broke (plain language)

The model’s “cup” holds **32,768** tokens total (vLLM `max-model-len`).

Continue reserved **8,192** tokens for the answer (`maxTokens`). A real chat
prompt used about **24,577** tokens. LiteLLM added those and got **32,769** —
one over the cup — and raised `ContextWindowExceededError`.

Separately, two embeddings wanted the `embed` job (gateway `nomic-embed-text`
and local LM Studio `continue-nomic-embed`). That made evaluation messy; the
operator commented the local one out by hand.

## 2. Assessment

| Actor | Finding |
| --- | --- |
| **vLLM** | Weight + tools + 32k context were already correct. Not the bug. |
| **LiteLLM** | Sampling fine; lacked clear input/output budgets; rep penalty was 1.0 vs HF 1.05. |
| **Continue** | Chat `maxTokens: 8192` too greedy for a full 32k cup; dual embed inventory. |
| **Model swap?** | **No.** Failures were budgeting and inventory, not poor coding quality. |

## 3. Proposal (adopted)

1. Cut default chat **max_output / maxTokens from 8192 → 4096** (Continue, Cline, `ai_cli_apps`).
2. Set LM Studio local embed to **`enabled: false`** so only gateway `nomic-embed-text` owns `embed`.
3. Set LiteLLM **`repetition_penalty: 1.05`** and **`model_info`** caps (`max_input_tokens: 28672`, `max_output_tokens: 4096`).
4. Keep **`qwen3-coder-30b-a3b`**; leave Qwen3.6 as sequential generalist only.
5. Later (optional): raise vLLM context only after a VRAM/kv-cache probe.

## 4. Why this fixes it

Smaller reserved answer room means a large prompt still fits under 32,768.
One embed owner removes hand-edits and dual-role confusion. Diagrams in
`diagrams/` show the before overflow vs after fit.
