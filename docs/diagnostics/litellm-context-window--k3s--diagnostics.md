# LiteLLM Context Window Diagnostic Sources

Component: LiteLLM proxy on K3s (`k3s_litellm_gateway`) when forwarding to
local `hosted_vllm` / `vllm-primary` (32k Qwen AWQ).

OS / runtime: Linux (K3s on `hom-lab-ctl-k3s-02`).

## Error that drove homelab custom trim values

Seen from Cursor Agent via the gateway (Ornith lane):

```text
litellm.ContextWindowExceededError: litellm.BadRequestError:
ContextWindowExceededError: Hosted_vllmException - {
  "error": {
    "message": "This model's maximum context length is 32768 tokens. However,
                you requested 0 output tokens and your prompt contains at
                least 32769 input tokens, for a total of at least 32769
                tokens. (parameter=input_tokens, value=32769)",
    "type": "BadRequestError",
    "param": "input_tokens",
    "code": 400
  }
}
Received Model Group=deepreinforce-ai/Ornith-1.0-35B-GGUF
Available Model Group Fallbacks=None
```

### Failure sequence (evidence-backed)

1. Client used a published alias (`deepreinforce-ai/Ornith-1.0-35B-GGUF`) —
   not the invalid bare provider name `hosted_vllm`.
2. Prompt exceeded the **32768** vLLM context (often by 1+ tokens on fat
   Cursor Agent payloads with rules + tools).
3. Without OpenAI/Anthropic keys, LiteLLM had **no** larger-context fallback.
4. An early trim budget of **30000** still failed: hook logs showed
   `after≈29993` while vLLM still returned **32769** — tokenizer disagreement
   plus Agent `tools` schemas after message trim; Cursor also sent
   `max_tokens: 0` (“0 output tokens” in the error text).

Repo response: pre-call `trim_messages` hook with server-tuned drivers
(budget **24000**, safety **2048**, preferred completion **4096** adaptive,
min messages **2048**, tools estimate, multimodal hard-cut). Contract:
`roles/k3s_litellm_gateway/README.md` § Message trim pre-call hook.

## Second failure mode — mid-stream Internal Server Error

Symptom: Cursor Agent reply stops halfway; UI shows Internal Server Error.

Evidence from LiteLLM logs (HTTP 200 path):

- `tools_est≈26360`, message budget ≈`4104`, **`requested_out=256`**
- Completion capped at 256 after rewriting Cursor `max_tokens: 0`
- Truncation (`finish_reason=length`) can surface in Cursor as Internal Server Error
  even when the gateway returned 200

Fix direction: raise preferred completion to **4096** and allocate
completion vs messages adaptively under the 32k window.

## Logging Locations

- LiteLLM pod stdout/stderr (K3s): look for
  `litellm trim_messages hook:` and `ContextWindowExceededError`
- kubectl: `kubectl -n litellm logs -l app.kubernetes.io/name=litellm --tail=200`
- ngrok / client tunnel logs (operator Mac) may show `POST /v1/chat/completions 400`

## Diagnostic Commands

- List published aliases: `GET http://litellm.hom.lab/v1/models` (Bearer master key)
- Small completion probe to Ornith / `smart-router` (expect HTTP 200)
- Oversized completion probe (expect HTTP 200 + `trim_messages hook` log line)
- Inspect mounted callback:
  `kubectl -n litellm exec deploy/litellm -- cat /etc/litellm/custom_callbacks.py`

## Event / Channel Sources

- Kubernetes events on Deployment/Pod in namespace `litellm` (rollout / CrashLoop
  if callback import fails)
- No Windows Event Log for this path

## Vendor / Tooling Diagnostics

- LiteLLM: [context window fallbacks](https://docs.litellm.ai/docs/proxy/reliability),
  [trim_messages](https://docs.litellm.ai/docs/completion/message_trimming),
  [call hooks](https://docs.litellm.ai/docs/proxy/call_hooks)
- vLLM OpenAI-compatible error body surfaced through LiteLLM as
  `Hosted_vllmException`

## Notes

- Do not use `hosted_vllm` as a Cursor model name; use published LiteLLM aliases.
- Mount callback beside config at `/etc/litellm/custom_callbacks.py` (not `/app/`
  alone) so `custom_callbacks.proxy_handler_instance` imports.
- ConfigMap `subPath` mounts require Deployment restart after callback edits.
- **Two separate taxes:** (1) Cursor builtin `tools[]` (~26k in
  `logs/litellm-tools-capture/`) — not removable by repo rules; (2) always-on
  framework rules — demoted 2026-07-23; see
  `docs/lessons-learned/codex/local-llm-context-vs-always-on-framework-rules.md`
  and `.cursor/rules/framework-context-budget.mdc`. LiteLLM trim cannot remove
  either upstream injection.
