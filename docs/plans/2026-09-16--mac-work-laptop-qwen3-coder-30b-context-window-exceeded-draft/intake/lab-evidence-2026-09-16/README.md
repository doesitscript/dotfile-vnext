---
title: Lab evidence gather — LiteLLM Request Inspector + vLLM
captured_at: "2026-09-17T04:15:00Z"
captured_from: hom-lab-ctl-k3s-02
method: read-only kubectl via bin/codex-env ansible
incident_model: qwen3-coder-30b-a3b
fix_attempted: false
---

# Lab evidence — most helpful surfaces

Read-only gather for draft plan
`2026-09-16--mac-work-laptop-qwen3-coder-30b-context-window-exceeded-draft`.
No config changes. Host of client incident remains **Mac work laptop**; this
folder is **gateway/runtime** evidence from the shared lab.

## What was queried

| Surface | Result |
| --- | --- |
| LiteLLM pod logs (`request_inspector`, ContextWindow, qwen3) | **Hit** — full overflow timeline + exact operator error text |
| LiteLLM `/tmp/litellm-request-inspector/*.json` | **Hit** — 13 dump files for this alias |
| LiteLLM `/tmp/litellm-tools-capture/` | **Missing** on pod (not present this gather) |
| vLLM-primary running pod logs | **Hit** — `max_model_len=32768`; HTTP **400** from LiteLLM pod IP |
| Ollama | **Not queried** — wrong path for this model |

## Smoking-gun timeline (LiteLLM, ~03:33–03:37 UTC in pod log clock)

Request Inspector repeatedly reported for `qwen3-coder-30b-a3b`:

| Slice | Tokens |
| --- | ---: |
| tools (schemas) | **28743** |
| system | 900 |
| conversation | started **0**, grew to **7992** across tool-loop turns |
| reserved_output (`max_tokens`) | **4096** |
| safety (inspector field) | 2048 |
| estimated_input | 29643 → **37635** |
| max_window | 32768 |
| tool_count_total | **84** |

Warnings on those calls included:

- `tool budget exceeds 75% of context (28743/32768)`
- `estimated input + reserved_output + safety exceeds max_window (...)`
- final failure: `finish_reason: error` + `proxy_call_failed`

LiteLLM then logged the same text the work-laptop UI showed:

`ContextWindowExceededError` … max 32768 … requested 4096 output … prompt at
least **28673** input … total at least **32769** … Model Group=`qwen3-coder-30b-a3b`

## Interpretation (evidence-backed, still draft)

1. **Primary budget consumer was tool schemas (~28.7k / 32k)**, not an empty
   chat. Top named tools in dumps: `context7_resolve-library-id`, several
   `aws_mcp_*`, `terraform_mcp_search_providers`, `edit_existing_file`, etc.
2. **`reserved_output: 4096`** matches Continue SSOT `maxTokens: 4096` and the
   error’s requested output tokens.
3. Conversation/tool-result growth (folder search / tool loop) pushed estimated
   input further over the edge until vLLM rejected.
4. This does **not** prove Mac work-laptop drift; the live gateway saw a
   correctly routed `qwen3-coder-30b-a3b` → hosted vLLM request. Drift remains
   possible for *how* the client assembled tools/maxTokens, but the failure is
   confirmed on the lab path.

## Artifact index

| File | Contents |
| --- | --- |
| [01-litellm-pods-and-filtered-logs.txt](01-litellm-pods-and-filtered-logs.txt) | Pod status + filtered LiteLLM logs |
| [02-litellm-pod-dump-listing.txt](02-litellm-pod-dump-listing.txt) | `/tmp` dump dir listing (inspector present; tools-capture absent) |
| [03-vllm-pods-and-filtered-logs.txt](03-vllm-pods-and-filtered-logs.txt) | All vLLM pods; initial grep (noisy dead pods) |
| [04-request-inspector-dumps-raw.txt](04-request-inspector-dumps-raw.txt) | Raw ansible capture of all inspector JSON dumps |
| [request-inspector-dumps/](request-inspector-dumps/) | Cleaned per-dump JSON (13 files) |
| [05-vllm-running-pod-filtered-logs.txt](05-vllm-running-pod-filtered-logs.txt) | Running pod `vllm-primary-86495b66c8-8mhs8` startup (`max_model_len: 32768`) |
| [05b-vllm-400-and-context-grep.txt](05b-vllm-400-and-context-grep.txt) | Running pod HTTP **400 Bad Request** line |
| [05c-vllm-400-context.txt](05c-vllm-400-context.txt) | Surrounding lines for the 400 |
| [06-qwen3-overflow-excerpt.txt](06-qwen3-overflow-excerpt.txt) | Extracted overflow / dump / error lines for qwen3 |
| [07-inspector-dump-timeline.json](07-inspector-dump-timeline.json) | Parsed timeline of dump budgets |

## Gaps / not collected

- Exact wall-clock mapping to Mac work-laptop local time (pod log showed `03:37:18`)
- Full tools-array dump (`/tmp/litellm-tools-capture` absent)
- Langfuse (success-callback only; likely silent on this 400)
- Work-laptop `~/.continue/config.yaml` (client host; not this gather)
