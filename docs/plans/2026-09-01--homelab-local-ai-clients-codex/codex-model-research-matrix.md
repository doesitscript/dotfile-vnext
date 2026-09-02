<!-- Concurrent editing note: Codex owns this model-selection matrix; Cursor should not rewrite it. -->

# Codex Local Model Research Matrix

This is a Codex CLI client decision record, not a Cursor extension or other
IDE-client configuration. Each terminal explicitly chooses one profile; there
is no automatic fallback or model group.

## Evidence-Based Roles

| Terminal | Intended model class | Realistic homelab work | Current status |
| --- | --- | --- | --- |
| `fast` | small local code responder | Explain a failed Ansible task after its output is pasted; draft a small YAML or shell correction; review one skill's metadata. | Gateway transport works, but current exact-output test emitted fake tool-shaped JSON. Do not use for dependable work. |
| `deep` | one large local code/repository responder | Investigate the LiteLLM/vLLM role, trace a deployment failure, or prepare a scoped implementation in `dotfile-vnext`. | Current 32B Responses/CLI completion passed. It is not an autonomous tool agent: `pwd` was emitted as text and not executed. |
| `desktop` | local 14B code-review/chat responder | Review one function, explain a contained test failure, propose a small patch, or produce concise code from a pasted requirement. | Dedicated `CODEX_HOME` and LiteLLM route proved exact CLI output at 12K context. Direct code review passed; a richer Codex review prompt streamed past two minutes, so keep prompts short and do not delegate tools. |
| `tools` | independent utility/tool agent | Classify test logs, synthesize a change receipt, or run a bounded file inspection after parser proof. | Not approved: full-context test exceeded 90 seconds and tool loop is unproven. |
| future Gemini window | cloud large-context research | Compare broad evidence across repositories or reason over a user-selected large corpus. | Not installed: a LiteLLM Gemini Responses route and real Google credential are required. |

The first three are separate terminal selections. They may be open at the same
time, but the 5090 can host one large vLLM model at a time; this is not a claim
that three large GPU models can coexist in 32 GiB of VRAM.

## Candidate Decision

| Candidate | Why it is relevant | Do not select until | Decision |
| --- | --- | --- | --- |
| Qwen3 4B via Ollama on HVH-01 | Current Ollama docs list a small tool/thinking artifact, and the model now runs as 3.18 GiB Q4_K_M on the GTX 1060. | A context window large enough for Codex's tool schema and a real Codex `exec` tool-loop test both pass. | Downloaded and direct-tested. Retain only as a short utility/autocomplete candidate; reject as a Codex terminal at 4K context. |
| Qwen3-Coder 30B A3B | Official model card presents agentic coding and function-call formatting; a quantized desktop artifact already exists. | GPU/host-RAM residency and vLLM parser preflight show it is fast enough for interactive use. | Research candidate only; current desktop runtime is CPU/memory-heavy. |
| Devstral Small 2 24B | Official vLLM guidance documents Mistral parser-based tool calling and the model is agent-focused. | Exact quantization, VRAM budget, and a single-GPU vLLM launch are measured. | Strong future 5090 replacement candidate, not a parallel model. |
| Qwen3 14B | Official card identifies tool-calling support and vLLM integration. | A quantized 32 GiB deployment leaves enough KV cache for the required context and passes Codex tool execution. | Candidate only; full precision is not right-sized with usable cache headroom. |
| Qwen2.5-Coder 14B Q4_K_M on desktop Ollama | Official Ollama documentation positions it for code generation, code reasoning, and code fixing. The pulled artifact is about 9.0 GB on disk and loaded at about 11.17 GB VRAM with 12K context. | A full Codex tool loop and prompt-latency qualification. | Selected only for the explicit `desktop` short coding-chat lane. It answered the direct production-bug review in 15.64 seconds and the isolated-home exact CLI request. Reject as an autonomous agent for now: the richer Codex review was interrupted after two minutes. |
| Devstral 24B on desktop Ollama | Existing agent-oriented artifact and a plausible future coding candidate. | Responsive first-token latency and adequate VRAM for useful context. | Rejected for this desktop role: correct direct code response, but about 78.9 seconds and 15.53 GB VRAM fully loaded. |
| GPT-OSS 20B on desktop Ollama | Existing local agentic artifact. | Responsive coding behavior with reasoning controlled. | Rejected for this desktop role: direct coding response was correct but took about 90 seconds and `think: false` did not materially reduce the latency. |
| Current Qwen2.5-Coder 32B AWQ | It is the live vLLM deployment as of 2026-09-02 and can use the 5090 fully. | A compatible tool parser/model combination passes real Codex execution. | LiteLLM reconciliation and Responses completion now pass; not a Codex autonomous agent. |

## vLLM Memory Interpretation

`nvidia-smi` reporting approximately 29 GiB used out of 32,607 MiB while vLLM
is idle is expected with `--gpu-memory-utilization 0.92`. vLLM reserves that
budget after profiling model weights, peak activations, non-framework memory,
CUDA graph memory, and the KV cache. It is not evidence that half of the 5090
is inaccessible.

The correct tuning choice depends on the goal:

- Keep 0.92 and 32K context for a single large, high-throughput model.
- Lower utilization or context only to trade request concurrency/context for
  operational headroom; this will not make a second 14B/24B/30B model fit
  alongside a resident large model.
- Use separate endpoints for a small utility model, desktop code responder,
  and one 5090 deep model. This is the practical three-terminal topology.

## Required Next Proof

1. Keep the selected desktop lane limited to concise code tasks until a
   representative Codex code-review prompt completes within its 120-second
   ceiling.
2. Use Context7-verified vLLM flags for the chosen model's parser, then run a
   Codex filesystem tool fixture and prove the command was actually executed,
   not merely emitted as text.
3. Re-qualify `deep` with the corrected launcher before calling any 5090 CLI
   outcome local; its historic proof was cloud fallback.
4. Do not download another desktop coding model until the measured failure is
   attributable to model behavior rather than the Codex orchestration prompt.

## Sources Checked

- [Codex with vLLM](https://docs.vllm.ai/en/stable/serving/integrations/codex)
- [vLLM GPU worker memory profiling](https://docs.vllm.ai/en/stable/api/vllm/v1/worker/gpu_worker)
- [vLLM tool calling](https://docs.vllm.ai/en/stable/features/tool_calling/)
- [Qwen3 tool use via Ollama](https://ollama.com/library/qwen3/tags)
- [Qwen3-Coder 30B A3B model card](https://huggingface.co/Qwen/Qwen3-Coder-30B-A3B-Instruct)
- [Devstral Small 2 model card](https://huggingface.co/mistralai/Devstral-Small-2-24B-Instruct-2512)
- [Ollama Qwen2.5-Coder](https://ollama.com/library/qwen2.5-coder)
- [Ollama context length](https://docs.ollama.com/context-length)
