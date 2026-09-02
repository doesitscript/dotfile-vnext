<!-- Concurrent editing note: Codex owns this live evidence receipt; Cursor should not rewrite it. -->

# Codex Local Clients Execution Receipt

Executed on 2026-09-01/02 against the live homelab. This receipt supplements the
shared plan README, which is concurrently being edited by Cursor.

## Current Status And Ownership

**Codex-owned scope only:** Codex CLI profiles, the `codex-homelab` launcher,
and this evidence packet. No Cursor extension or other IDE-client route is
required or changed by this packet. Cursor should leave this receipt and the
`templates/` subtree intact while its separate client work continues.

The prior local-model proofs were genuine Responses-API and Codex CLI proofs,
but they are not a claim that three autonomous local Codex agents are ready.
Current qualification approves only the deep response-completion lane. The
other two profiles remain experimental, and vLLM tool execution still needs a
model/parser combination that has been proven with Codex's real `exec` tool
loop.

## Limits And Follow-Up

The [limitations and follow-up](limitations-and-follow-up.md) record is the
canonical status of incomplete, blocked, and deferred outcomes. This receipt
keeps the successful and failed command evidence needed to reproduce that
status without duplicating the operational decision log.

## Delivered Local Codex Profiles

The following separate profiles are installed under `~/.codex` with mode `0600`.
They are explicit selections, not an automatic fallback or model group.

| Terminal command | Codex profile | Live LiteLLM model | Intended lane | Result |
| --- | --- | --- | --- | --- |
| `codex-homelab fast` | `local-fast` | `qwen2.5-coder-7b@desktop` | short coding and focused questions | transport reaches the gateway, but current exact-output check emitted fake tool-shaped JSON; not approved as a dependable Codex lane |
| `codex-homelab deep` | `local-deep` | `qwen2.5-coder-32b@k3s02-vllm` | codebase reasoning and implementation | current Responses/CLI smoke test passed; autonomous tool loop failed honestly |
| `codex-homelab tools` | `local-tools` | `ministral-3-8b@desktop` | experimental alternate local model | did not return within 90 seconds in full repository context |

The launcher is installed as `~/bin/codex-homelab` with mode `0700`. It reads
the current `PROXY_MASTER_KEY` from the live Kubernetes secret into process
memory and starts the selected profile. It does not write a gateway credential
to any configuration file.

Scope boundary: these Codex profiles select the agent model for Codex CLI (and
the Codex client configuration layer). They do not configure Cursor or VS Code
inline FIM autocomplete. Keep that separate in the IDE extension that owns
completion requests, using the already validated LiteLLM completion route.

Example non-interactive checks:

```bash
codex-homelab fast exec --ephemeral 'Reply with exactly: check-ok'
codex-homelab deep exec --ephemeral 'Reply with exactly: check-ok'
```

`local-tools` remains installed as a deliberately separate selection, not a
fallback or model group, but it is not approved as a practical autonomous
tool-use lane. Its earlier filesystem-tool test stalled, and the 90-second
real-profile smoke test also did not complete. Do not rely on it for unattended
edits until the desktop runtime is accelerated or a tool-call parser is
verified for that model.

## Codex Compatibility Findings

Codex custom providers use the Responses wire API, so the profiles correctly
set `wire_api = "responses"`. A LiteLLM standard `/v1/models` response cannot
supply the Codex-specific catalog schema. Without catalog metadata Codex treated
the local routes as unknown models and attempted a 32,769-token request, one
token above the active Qwen2.5-Coder-14B vLLM limit of 32,768.

`scripts/render_local_model_catalog.sh` derives a minimal three-model catalog
from the installed Codex cache, preserves the current required schema, removes
cloud-model instruction bloat, and sets honest 24K/28K working windows. The
renderer generated `~/.codex/local-model-catalog.json`; all three profiles point
to it. Re-run the renderer after a significant Codex CLI update.

Validated with Codex CLI `0.142.5` in the actual `dotfile-vnext` worktree:

| Profile | Expected response | Observed result |
| --- | --- | --- |
| `local-deep` | `local-deep-catalog-ok` | passed, 15,965 tokens |
| `local-fast` | `local-fast-catalog-ok` | passed, 2,056 tokens |
| `local-tools` | `local-tools-catalog-ok` | timed out at the 90-second ceiling |
| `codex-homelab deep` | `codex-homelab-wrapper-ok` | passed, 8,419 tokens |

The `@` characters in existing LiteLLM model aliases cause harmless Codex
telemetry tag warnings. The catalog prevents the functional unknown-model
context fallback; it cannot change the alias spelling without changing the
published gateway contract.

## Homelab Reconciliation And Storage

The k3s VM was changed from static 10 GiB to the declared 28 GiB through the
repository Hyper-V lifecycle playbook. After restart the guest reported 27 GiB.

The live deployment changed again during this work. At 2026-09-02T01:53Z it
declared and began serving `Qwen/Qwen2.5-Coder-32B-Instruct-AWQ` with
`--gpu-memory-utilization 0.92`, `--max-model-len 32768`, FP8 KV cache, and
`--max-num-seqs 4`. This supersedes the earlier 14B runtime observation. The
published LiteLLM alias and the currently loaded vLLM model must be reconciled
by the inference owner before `local-deep` is called current again.

The apparent 5090 memory anomaly was not half of the GPU being missing. vLLM
reserves its configured GPU budget at startup for model weights, activations,
CUDA graphs, and KV cache; low free VRAM while idle is normal at 0.92
utilization. The actual service interruption was node ephemeral-storage
pressure: the 77 GiB guest disk hit Kubernetes' eviction threshold and the
32B pod was evicted. A preflight found only the 32B model referenced by active
workloads, while the 14 GiB `Qwen2.5-Coder-14B-Instruct-AWQ` cache was stale,
unshared, and included abandoned partial downloads. That exact cache directory
was removed through Ansible. Root free space increased from 12 GiB to 26 GiB;
Kubernetes initially retained `DiskPressure` despite the newly available space,
so the single-node `k3s` service was restarted in a controlled recovery. The
node then reported `DiskPressure=False` and the taint was removed.

The first restarted 32B load also left 9.56 GiB of timestamped partial shards
from its evicted predecessor. A second guarded cleanup removed only files older
than the current pod's 2026-09-02T02:04:16Z start time, preserving the five
current download shards. Root free space is now 24 GiB. The vLLM container and
LiteLLM pod are both `1/1 Running`; vLLM is still in its 32B cold-load phase and
has not yet opened port 8000, so the current route and Codex CLI re-test remain
pending rather than being falsely marked passed. That re-test subsequently
passed after the LiteLLM source deployment reconciled the stale live backend
mapping from 14B to 32B.

After the current 18 GiB 32B checkpoint completed and vLLM created its runtime
cache, the closeout check reported 13 GiB free on the 77 GiB guest disk with
`DiskPressure=False`. This is stable for the current single-model service, but
there is not enough headroom for another large vLLM artifact on that VM.

The desktop already had eight candidate artifacts, including Qwen2.5-Coder 7B,
Ministral 3 8B, Qwen3-Coder 30B, Devstral 24B, and GPT-OSS 20B. The researched
Qwen3 4B artifact was then installed through the Ansible-owned
`windows_ollama_runtime` role on HVH-01. Ollama reports a 3.18 GiB Q4_K_M
resident model with 4,096-token context and 370.5 GiB host storage remaining.
It fits the GTX 1060, but it does not fit Codex's approximately 41K-token tool
schema. Its first direct tool probe did not complete in the allowed window, and
a bounded non-thinking exact-output probe stopped at length after producing
reasoning text. It is retained as a local short utility/autocomplete candidate,
not installed as a third Codex agent profile.

The current model recommendation and realistic terminal roles are in
[`codex-model-research-matrix.md`](codex-model-research-matrix.md).

## Gemini Fourth Window

`templates/gemini-via-litellm.config.toml.example` remains an intentionally
uninstalled template. Direct Gemini OpenAI compatibility documents Chat
Completions, whereas Codex custom providers require Responses. A fourth Codex
window therefore needs a separately published Gemini route in LiteLLM (for
example using a real Google or Vertex credential) before it can be configured
and tested.

No `GEMINI_API_KEY`, `GOOGLE_API_KEY`, Google application credential, `gcloud`,
or repository-owned Google credential route was present on this machine during
execution. No credential was guessed, no cloud route was fabricated, and no
Gemini profile was installed as working.

## Research Sources

- [Codex advanced configuration](https://learn.chatgpt.com/es-419/docs/config-file/config-advanced)
- [Codex configuration reference](https://learn.chatgpt.com/es-419/docs/config-file/config-reference)
- [LiteLLM documentation](https://docs.litellm.ai/)
- [Qwen2.5-Coder-14B-Instruct-AWQ model card](https://huggingface.co/Qwen/Qwen2.5-Coder-14B-Instruct-AWQ)
- [Google Gemini OpenAI compatibility](https://ai.google.dev/gemini-api/docs/openai)
- [vLLM tool calling](https://docs.vllm.ai/en/stable/features/tool_calling/)

## Current Verification Commands And Output

These commands simulate the CLI behavior rather than merely probing an HTTP
endpoint.

```bash
codex-homelab fast exec --ephemeral --skip-git-repo-check -C /tmp \
  'Reply exactly: codex-fast-recovery-ok'
# Result: emitted {"name":"codex-fast-recovery-ok","arguments":{}} instead
# of the requested text. Transport passed; behavioral contract did not.

codex-homelab deep exec --ephemeral --skip-git-repo-check -C /tmp \
  'Reply exactly: codex-32b-recovery-ok'
# Output: codex-32b-recovery-ok

codex --profile local-tools exec --ephemeral --skip-git-repo-check -C /tmp \
  'Reply exactly: local-tools-catalog-ok'
# Result: exceeded the 90-second test ceiling; not approved.

bin/codex-env ansible hom-lab-ctl-k3s-02 -i inventory/inventory.yaml -b \
  -m ansible.builtin.shell -a 'df -h /; kubectl get node; kubectl get pod -n vllm-runtime'
# Current evidence: 13 GiB free; DiskPressure=False; vLLM is ready and serves
# Qwen/Qwen2.5-Coder-32B-Instruct-AWQ through the published 32B LiteLLM alias.
```

The current 32B tool-loop result is deliberately not labeled a pass:

```bash
codex-homelab deep exec --ephemeral --skip-git-repo-check -C /tmp \
  'Use an available shell tool to run pwd. After the tool result, reply exactly: codex-32b-tool-loop-ok'
# Output: {"name": "exec", "arguments": {"command": "pwd", "shell": "bash"}}
# Codex did not execute pwd. The model emitted a textual tool-shaped response.
```

vLLM's startup log attributes this to the currently unconfigured parser path:
the service accepts Responses API calls, but Qwen2.5-Coder-32B-AWQ has not
been proven to produce the parser format Codex/vLLM needs for executable tool
calls. Keep this lane interactive and response-oriented until a parser-supported
model passes the same fixture.

The direct Qwen3 4B validation was likewise intentionally not promoted:

```text
Ollama /api/ps: qwen3:4b, Q4_K_M, 3.18 GiB VRAM, context_length=4096
Ollama tool probe: did not complete inside the first-load validation window
Ollama exact-output probe: done_reason=length; returned reasoning text rather
than qwen3-4b-ok within a 24-token cap
```
