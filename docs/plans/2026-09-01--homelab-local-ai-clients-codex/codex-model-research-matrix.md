<!-- Concurrent editing note: Codex owns this model-selection matrix; Cursor should not rewrite it. -->

# Codex Local Model Research Matrix

This is a Codex CLI client decision record, not a Cursor extension or other
IDE-client configuration. Each terminal explicitly chooses one profile; there
is no automatic fallback or model group.

## Evidence-Based Roles

| Terminal | Intended model class | Realistic homelab work | Current status |
| --- | --- | --- | --- |
| `fast` | small local code responder | Explain a failed Ansible task after its output is pasted; draft a small YAML or shell correction; review one skill's metadata. | Response completion passed. Not proven to execute tools autonomously. |
| `deep` | one large local code/repository responder | Investigate the LiteLLM/vLLM role, trace a deployment failure, or prepare a scoped implementation in `dotfile-vnext`. | Current 32B Responses/CLI completion passed. It is not an autonomous tool agent: `pwd` was emitted as text and not executed. |
| `tools` | independent utility/tool agent | Classify test logs, synthesize a change receipt, or run a bounded file inspection after parser proof. | Not approved: full-context test exceeded 90 seconds and tool loop is unproven. |
| future Gemini window | cloud large-context research | Compare broad evidence across repositories or reason over a user-selected large corpus. | Not installed: a LiteLLM Gemini Responses route and real Google credential are required. |

The first three are separate terminal selections. They may be open at the same
time, but the 5090 can host one large vLLM model at a time; this is not a claim
that three large GPU models can coexist in 32 GiB of VRAM.

## Candidate Decision

| Candidate | Why it is relevant | Do not select until | Decision |
| --- | --- | --- | --- |
| Qwen3 4B via Ollama on HVH-01 | Current Ollama docs list a 2.5 GB artifact with tools/thinking support. It is a plausible small utility lane. | Ansible-owned pull, LiteLLM publication, Responses probe, and a real Codex `exec` tool-loop test all pass. | Best next new-model experiment, not downloaded yet. |
| Qwen3-Coder 30B A3B | Official model card presents agentic coding and function-call formatting; a quantized desktop artifact already exists. | GPU/host-RAM residency and vLLM parser preflight show it is fast enough for interactive use. | Research candidate only; current desktop runtime is CPU/memory-heavy. |
| Devstral Small 2 24B | Official vLLM guidance documents Mistral parser-based tool calling and the model is agent-focused. | Exact quantization, VRAM budget, and a single-GPU vLLM launch are measured. | Strong future 5090 replacement candidate, not a parallel model. |
| Qwen3 14B | Official card identifies tool-calling support and vLLM integration. | A quantized 32 GiB deployment leaves enough KV cache for the required context and passes Codex tool execution. | Candidate only; full precision is not right-sized with usable cache headroom. |
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

1. Wait for `DiskPressure=False` and `deployment/vllm-primary Available=1`.
2. Reconcile the LiteLLM published alias to the actual served 32B model, or
   intentionally redeploy the desired 14B model. Do not allow an alias/model
   identity mismatch.
3. Use Context7-verified vLLM flags for the chosen model's parser, then run a
   Codex filesystem tool fixture and prove the command was actually executed,
   not merely emitted as text.
4. Only then use the Ansible-owned Ollama role to download Qwen3 4B, publish a
   distinct route, and repeat the same Responses plus Codex tool-loop proof.

## Sources Checked

- [Codex with vLLM](https://docs.vllm.ai/en/stable/serving/integrations/codex)
- [vLLM GPU worker memory profiling](https://docs.vllm.ai/en/stable/api/vllm/v1/worker/gpu_worker)
- [vLLM tool calling](https://docs.vllm.ai/en/stable/features/tool_calling/)
- [Qwen3 tool use via Ollama](https://ollama.com/library/qwen3/tags)
- [Qwen3-Coder 30B A3B model card](https://huggingface.co/Qwen/Qwen3-Coder-30B-A3B-Instruct)
- [Devstral Small 2 model card](https://huggingface.co/mistralai/Devstral-Small-2-24B-Instruct-2512)
