<!-- Concurrent editing note: Codex owns this limitations record; Cursor should not rewrite it. -->

# Codex Local Clients Limitations And Follow-Up

**Status date:** 2026-09-02

This is the authoritative record for incomplete, blocked, and deferred work in
the Codex-owned local-client packet. The [plan README](README.md) carries the
desired operating model; the [execution receipt](codex-execution-receipt.md)
carries reproducible evidence. Keep the detailed status here to avoid three
copies that drift apart.

## Verification Correction - 2026-09-02

The former launcher added `--ignore-user-config` to every `codex-homelab ...
exec` run. Codex CLI `0.142.5` then reported `model: gpt-5.5` and
`provider: openai`: the named local profile had been suppressed. Therefore the
earlier `deep` shell-tool fixture is withdrawn as proof of a **local** Codex
tool loop. The launcher now retains the selected profile for `exec`.

The new `desktop` profile is positively verified for a local Responses request,
an exact Codex CLI response, and a code-review prompt while visibly reporting
`qwen2.5-coder-14b@desktop` / `homelab-litellm`. Its file-read test is a useful
negative result: the model emitted an `exec_command` JSON object, but Codex did
not execute it. No autonomous local shell-tool lane is currently approved.

The desktop service now persists `OLLAMA_CONTEXT_LENGTH=12000` through the
Ansible-owned Windows runtime role. The actual launcher loaded the same 12K
context at about 11.17 GB VRAM and returned its exact response from an isolated
desktop `CODEX_HOME`. A richer Codex production-bug review began streaming but
did not complete inside two minutes and was interrupted. This disproves a
claim that the model is already a responsive in-Codex implementation agent;
the route remains suitable only for concise, bounded prompts.

## Current Usable State

- `codex-homelab desktop` is an experimental isolated local coding-chat lane.
  It reaches `qwen2.5-coder-14b@desktop` through LiteLLM from
  `~/.codex-homelab/desktop`, leaving the normal Codex home untouched. The
  isolated home and launcher are managed by the
  `codex_homelab_profiles` Ansible role through
  `playbooks/deploy_codex_homelab_profiles.yaml`; do not hand-edit them. Use it
  for concise pasted snippets and focused questions, not an open-ended review.
- `codex-homelab deep` remains an explicit local profile, but its former local
  shell-tool proof must be re-run without `--ignore-user-config`.
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
| Responsive desktop Codex review | Not achieved | The selected 14B desktop model completed direct code review and exact Codex CLI output, but an isolated-home production-bug review continued streaming past two minutes. | Keep `desktop` to concise coding chat; evaluate a model replacement only after comparing the same prompt and context budget. |
| Autonomous Codex shell-tool execution | Not approved | The historic deep fixture ran through the cloud default because `--ignore-user-config` suppressed its local profile. The new desktop local fixture formed but did not execute an `exec_command` request. | Re-run the deep file-read fixture with the corrected launcher, then retain only a result whose CLI header shows the intended local model and provider. |
| Interactive local shell-tool execution | Not yet validated | Codex CLI exposes `--ignore-user-config` on `exec`, not its interactive command. The shared configuration can still trigger an incompatible unified-exec payload in an interactive local-model session. | Keep local terminal automation on `codex-homelab <profile> exec`; validate an isolated interactive Codex home before promoting interactive tool use. |
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
# observed through the candidate fixture: cli-exit PASS; final-answer PASS
# ready-for-review; no-unexecuted-exec-request PASS

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
