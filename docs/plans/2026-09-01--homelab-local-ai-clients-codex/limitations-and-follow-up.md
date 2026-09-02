<!-- Concurrent editing note: Codex owns this limitations record; Cursor should not rewrite it. -->

# Codex Local Clients Limitations And Follow-Up

**Status date:** 2026-09-02

This is the authoritative record for incomplete, blocked, and deferred work in
the Codex-owned local-client packet. The [plan README](README.md) carries the
desired operating model; the [execution receipt](codex-execution-receipt.md)
carries reproducible evidence. Keep the detailed status here to avoid three
copies that drift apart.

## Current Usable State

- `codex-homelab deep` is the one approved local Codex response/reasoning
  lane. It reaches `qwen2.5-coder-32b@k3s02-vllm` through LiteLLM and passed
  the bounded exact-output Codex CLI check.
- `codex-homelab fast` and `codex-homelab tools` are installed explicit
  profiles, not fallbacks. They remain experimental and should not be used for
  unattended work.
- The RTX 5090 service is healthy with the 32B model resident. The current
  virtual machine disk has about 13 GiB free; that is adequate for the running
  service, not for another large model download or a second large resident
  vLLM model.

## Outcomes Not Yet Achieved

| Requested outcome | Status | What happened | Valid next step |
| --- | --- | --- | --- |
| Three dependable local Codex terminal lanes | Not achieved | Only the 32B deep lane passed its response-completion check. The 7B fast lane returned function-shaped JSON instead of the requested text, and the 8B tools lane did not return in a 90-second full-context check. | Keep these profiles opt-in only; replace or re-qualify each with a bounded Codex CLI proof before relying on it. |
| Autonomous Codex shell-tool execution | Not achieved | The 32B lane emitted a plaintext `exec` tool object for `pwd`; Codex did not execute it. The deployed vLLM service has no working tool-call parser for this model. | Deploy one parser-supported model and prove Codex's complete `exec` loop, including actual command output. |
| A third small local agent lane | Deferred | `qwen3:4b` was downloaded and tested directly through Ollama, but its 4,096-token context and bounded-prompt behavior make it unsuitable for Codex's approximately 41K tool schema/context. | Retain it only for short completion or utility experiments; do not promote it to a Codex profile. |
| Gemini/Google Codex terminal | Blocked externally | No Google API key, Application Default Credentials, or credentialed LiteLLM Gemini Responses route was available. | Add credentials through the existing secret workflow, publish a LiteLLM Responses-compatible route, then run the same `codex exec` smoke test. |
| VS Code or Cursor inline autocomplete | Outside this packet | Codex CLI profiles select an agent model; they do not configure the IDE's fill-in-the-middle completion provider. Concurrent IDE-client work remains separate. | Configure and validate that extension/client independently against its completion endpoint. |

## Why The GPU Appeared Nearly Full

The 32,607 MiB RTX 5090 is not limited to roughly half of its memory. vLLM was
configured to reserve 92 percent of GPU memory for the active server. Its
startup accounting reported approximately 19.75 GiB model and non-Torch
memory, 1.46 GiB peak activations, 0.46 GiB CUDA graph memory, and 8.09 GiB KV
cache. That budget supports a 32,768-token context and around two concurrent
full-context sequences; low free VRAM is therefore expected while the service
is resident.

The separate fault was guest disk pressure, not missing VRAM. The 77 GiB vLLM
guest hit its Kubernetes eviction threshold because stale 14B cache content
and stale partial 32B shards remained after a restart. The stale content was
removed only after confirming live workloads referenced the 32B model. The
guest was expanded to its declared 28 GiB memory allocation, K3s was restarted
to clear the stale DiskPressure condition, and the final state was
`DiskPressure=False`, `Ready=True`, with vLLM and LiteLLM both ready.

## Current Operational Constraints

- Do not download or deploy another large model on the existing vLLM guest
  until its disk is expanded or model cache placement is changed.
- Do not attempt to make multiple large models resident on the single RTX 5090
  at once. The active 32B AWQ service intentionally consumes its configured
  vLLM memory budget.
- The LiteLLM endpoint is `http://litellm.hom.lab/v1`, not HTTPS. The early
  HTTPS probe was corrected before the final tests.
- The currently published 32B alias is
  `qwen2.5-coder-32b@k3s02-vllm`; it was reconciled from an older live mapping
  that still targeted a 14B backend.
- Existing inventory warnings from concurrently maintained IDE-client
  variables are outside the Codex-owned files and were intentionally not
  rewritten.

## Ordered Follow-Up

1. Choose one parser-supported local tool model before downloading it. vLLM's
   Codex integration documents Qwen3.6 with `--reasoning-parser qwen3`,
   `--enable-auto-tool-choice`, and `--tool-call-parser qwen3_coder`; verify
   the exact model and parser against the installed vLLM version first.
2. Expand the vLLM guest disk or move model cache to persistent storage before
   any large model acquisition. Preserve the currently working 32B lane while
   evaluating candidates.
3. Validate a candidate in stages: direct vLLM Responses request, LiteLLM
   Responses request, bounded `codex-homelab ... exec` exact output, then a
   Codex tool request that actually executes `pwd` and returns its output.
4. Revisit the `fast` and `tools` profiles only after those proofs pass. They
   are separate terminal choices, never a fallback chain.
5. Add the Gemini lane only after its credentials and a LiteLLM
   Responses-compatible route exist; do not treat a chat-completions-only
   provider as Codex-ready.

## Evidence Commands

The following commands document the current boundary rather than promising
that every profile succeeds:

```bash
codex-homelab deep exec --ephemeral --skip-git-repo-check -C /tmp \
  'Reply exactly: codex-32b-recovery-ok'
# observed: codex-32b-recovery-ok

codex-homelab deep exec --ephemeral --skip-git-repo-check -C /tmp \
  'Use the available shell tool to run pwd, then report the command output.'
# observed: plaintext {"name":"exec",...}; no command was executed

curl -sS http://litellm.hom.lab/v1/models \
  -H "Authorization: Bearer $LITELLM_API_KEY"
```

## Primary References

- [vLLM Codex integration](https://docs.vllm.ai/en/stable/serving/integrations/codex/)
- [vLLM tool calling](https://docs.vllm.ai/en/stable/features/tool_calling/)
- [vLLM GPU memory profiling](https://docs.vllm.ai/en/stable/api/vllm/v1/worker/gpu_worker/)
- [Ollama Qwen3 tags](https://ollama.com/library/qwen3/tags)
- [Qwen3-Coder-30B-A3B model card](https://huggingface.co/Qwen/Qwen3-Coder-30B-A3B-Instruct)
- [Devstral Small 2 24B model card](https://huggingface.co/mistralai/Devstral-Small-2-24B-Instruct-2512)
