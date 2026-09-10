# Saved — LM Studio + Continue + Zed (2026-09-06 inbox)

**Status:** interim laptop experiment. Prefer DMR OpenAI-compatible API for new
Continue local wiring. Keep as proof that Continue accepts local `openai`
provider + `apiBase` without LiteLLM.

## LM Studio

- GGUF: `qwen2.5-3b-instruct-q4_k_m.gguf`
- Model id: `qwen2.5-3b-instruct`
- API: `http://127.0.0.1:1234/v1`
- Context observed: 8192 (Zed wanted load at 32768 for tool headroom)

```bash
~/.lmstudio/bin/lms ls
curl http://127.0.0.1:1234/v1/models
```

## Continue (local chat)

```yaml
name: "Chat Qwen2.5 3B Instruct (local LM Studio)"
provider: "openai"
apiBase: "http://127.0.0.1:1234/v1"
model: "qwen2.5-3b-instruct"
apiKey: "local"
defaultCompletionOptions:
  contextLength: 8192
  maxTokens: 1024
  temperature: 0.2
```

Remote LiteLLM `contextLength` / `maxTokens` numbers in that laptop session
were an operator experiment only. **Do not treat Continue headroom tweaks as
the root fix for weak remote 32B coding.** The durable infra fix was untuned
14B → tuned 32B AWQ + fp8 KV
(`docs/plans/2026-09-01--homelab-local-ai-clients-cursor-kilo/diagrams/5090-vram-tuning-before-after.md`).
LiteLLM does not live-trim prompts (Request Inspector observe-only).

## Zed

Native `lmstudio` provider; model `qwen2.5-3b-instruct`; auto-compaction ~75%.

## Mapping to DMR

Same Continue shape with:

- `apiBase: http://127.0.0.1:12434/engines/v1`
- `model:` from `docker model list` / `/engines/v1/models`
