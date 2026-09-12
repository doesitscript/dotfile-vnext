# Recommended models ↔ role fit (this plan)

For each model in the recommendation table, what **technology property** matched
the **role requirement**.

## Autocomplete → `qwen2.5-coder:1.5b-base` (HVH-01 Ollama)

| Role need | Matching property |
| --- | --- |
| Sub-second FIM | ~1.5B params; ~1.5GB class footprint on GTX 1060 |
| FIM token behavior | **Base** checkpoint (HF `Qwen/Qwen2.5-Coder-1.5B`), not Instruct — next-token FIM, not chat |
| Continue ecosystem | Same family Continue documents for autocomplete (Qwen2.5-Coder 1.5B) |
| OpenAI-compatible serve | Ollama exposes `/v1` completions; LiteLLM route `qwen2.5-coder-1.5b@hvh01` |
| Proven | FIM `/v1/completions` HTTP 200 |

Instruct `qwen2.5-coder:1.5b` remains on disk for chat-style smokes (Codex HVH
alias stability) but the **autocomplete LiteLLM backend** points at **base**.

---

## Embed → `nomic-embed-text` (HVH-01 Ollama)

| Role need | Matching property |
| --- | --- |
| Vector search, not generation | Dedicated embedding model (~137M), not a chat LLM |
| Tiny compute | Coexists with 1.5B FIM under ~2GB combined |
| Standard Continue pick | Continue “best open embed” lists Nomic Embed Text |
| Known width for verify | Output dimension **768** (smoke asserted) |
| Gateway path | LiteLLM `ollama/nomic-embed-text` → `nomic-embed-text@hvh01` |

---

## Edit → `qwen2.5-coder:14b` (desktop Ollama, instruct default)

| Role need | Matching property |
| --- | --- |
| Better transformation quality than 7B | Larger instruct coder (~9GB Q4-class) on 16GB RX 9060 XT |
| Instruct / edit prompts | Ollama `14b` tag is the instruct line (plan’s “14b-instruct”) |
| Shared host with Apply | 14B + 7B still fit 16GB if both loaded |
| Already in lab pipeline | Tag already in `windows_ollama_runtime_models_present`; LiteLLM `qwen2.5-coder-14b@desktop` |

---

## Apply → `qwen2.5-coder:7b` (desktop Ollama)

| Role need | Matching property |
| --- | --- |
| Narrow merge job | Smaller instruct coder; less “creative rewrite” than Edit |
| Keep as-is | Already commissioned; low change risk |
| Latency vs Edit | Faster / lighter than 14B for mechanical apply |
| Same runtime family as Edit | Same Ollama host simplifies ops |

---

## Chat (unchanged this plan) → `qwen3.6-35b-a3b` (+ Gemini / gpt-oss)

| Role need | Matching property |
| --- | --- |
| Primary Agent/chat quality | Large MoE on 5090 vLLM with tools/reasoning parsers |
| Do not steal VRAM for aux roles | Autocomplete/embed/edit/apply stay off HVH-02 / k3s-02 GPU |
| Cloud / long-context options | Existing Gemini lanes; gpt-oss on desktop Ollama when up |

This plan **did not** re-pick chat; it protected the 5090 lane from auxiliary
workloads.

---

## Roles not commissioned in this plan

| Role | Recommendation stance |
| --- | --- |
| `rerank` | Leave OFF until retrieval A/B shows value; then research Continue-supported rerank provider (not assumed Ollama-native) |
| `summarize` | No inventory — unused by Continue today |

---

## Sources

- Continue roles intro + best-models-by-role tables
- Continue autocomplete FIM guidance (base vs chat)
- Ollama library tags for `qwen2.5-coder:*` and `nomic-embed-text`
- Live lab smokes (see `smoke-evidence-decode.md`)
