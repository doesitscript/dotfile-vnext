# Qwen3-Coder-30B deployed config + improvement evaluation

Date: 2026-09-12

## Deployed configuration (as implemented)

### vLLM (`hom-lab-ctl-k3s-02` / `vllm-primary`)

| Flag | Value |
| --- | --- |
| model / served | `cyankiwi/Qwen3-Coder-30B-A3B-Instruct-AWQ-4bit` |
| auto tools | `--enable-auto-tool-choice` |
| tool parser | `--tool-call-parser qwen3_coder` |
| gpu util | `0.90` |
| max-model-len | `32768` |
| max-num-seqs | `6` |
| plugin | **disabled** (legacy qwen2_5 plugin breaks on vLLM 0.29) |

Live `/v1/models` reports `max_model_len=32768`.

### LiteLLM gateway

| Item | Value |
| --- | --- |
| client id | `qwen3-coder-30b-a3b` |
| backend | `hosted_vllm/` + cyankiwi AWQ id |
| sampling | temp **0.7**, top_p **0.8**, top_k **20**, rep **1.05** |
| model_info | max_tokens 32768; max_input 28672; max_output 4096 |

### Continue / clients

| Role | Model |
| --- | --- |
| chat | `qwen3-coder-30b-a3b` (maxTokens **4096**, context 32768, tool_use) |
| embed | `nomic-embed-text` (gateway); LM Studio local **enabled: false** |
| autocomplete | `qwen2.5-coder-1.5b-base-q8_0` only |

## Research sources

- HF card `Qwen/Qwen3-Coder-30B-A3B-Instruct` (Firecrawl)
- Context7 `/websites/vllm_ai_en_stable` (tool calling / qwen3_coder)
- Context7 LiteLLM (ContextWindowExceededError / max_input_tokens)
- HRL pack: `homelab-reference-library/models/qwen-qwen3-coder-30b-a3b-instruct/`

## Evaluation — what to change

| Change | Priority | Decision |
| --- | --- | --- |
| Client max_output 8192→4096 | **do now** | Adopted (inbox ContextWindowExceededError) |
| Disable LM Studio embed candidate | **do now** | Adopted (`enabled: false`) |
| repetition_penalty 1.0→1.05 | **do now** | Adopted (HF Best Practices) |
| LiteLLM model_info input/output caps | **do now** | Adopted in Helm values |
| Raise vLLM max-model-len (64k+) | later | Only after VRAM/kv probe; card is 256K native |
| Switch parser to `qwen3_xml` | **no** | Docs alias noise; `qwen3_coder` tool smoke passed |
| Swap to Qwen3.6 or another coder | **no** | Failures were budgeting/embed inventory, not model fit |

## Model-swap verdict

**Stay on Qwen3-Coder-30B-A3B AWQ.** No evidence that a different weight is
required. Keep Qwen3.6 as sequential generalist alternate only.
