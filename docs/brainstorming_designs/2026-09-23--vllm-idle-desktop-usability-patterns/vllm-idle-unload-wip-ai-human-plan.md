---
title: vLLM idle unload — WIP AI–human plan
status: brainstorm
execution_status: not_started
created_at: 2026-09-23
filename_note: wip-ai-human-plan suffix — assessment + draft plan shape, not docs/plans/
resource_selection_status: pending_research
---

# vLLM idle unload — WIP AI–human plan

**Status:** brainstorm / WIP. Not an approved `docs/plans/` packet.  
**Pairs with:** [operator-proposal-idle-watcher.md](operator-proposal-idle-watcher.md)

## Intent and provenance

Operator wants Ollama-*like effect* on the LiteLLM → vLLM primary lane
(HVH-02 GPU-P → k3s-02 `vllm-primary`): free VRAM after idle so Windows Task
Manager dedicated memory (~90%+ when resident) drops and desktop use feels
normal. First request after idle may be slow.

Conversation research (2026-09-22/23) established:

| Fact | Implication |
| --- | --- |
| Ollama default `keep_alive` ~5m | Built-in idle unload |
| vLLM has **no** keep_alive equivalent | Policy must live outside the engine |
| vLLM **Sleep Mode** (`--enable-sleep-mode`, HTTP `/sleep` `/wake_up` behind `VLLM_SERVER_DEV_MODE=1`) | Explicit one-shot switches, not a timer |
| KEDA / Knative | Well-supported *generic* scale-to-zero; not “Ollama for vLLM”; not a 15-minute fit for LiteLLM |
| Lab today | `k3s_vllm_runtime` always-on; `--gpu-memory-utilization 0.90`; ComfyUI timeshare is manual `present\|absent` |

## Assessment of the operator sketch

### What is right

- The **policy loop** is small and honest:

  ```text
  every N minutes:
    if last_real_user_traffic older than T:
      free GPU (sleep OR scale replicas to 0)
  ```

- That *effect* matches desktop-after-idle without inventing a fake vLLM flag.
- A **full custom Kubernetes controller / operator is unnecessary** for v1 —
  a CronJob or small in-cluster loop is the same logic with less machinery.
- Lab-side (k3s / HVH-02), not Mac-driven, matches the stated preference.

### Clarifications (spin down vs unload)

| Mechanism | Unloads VRAM? | Pod stays? | Wake cost |
| --- | --- | --- | --- |
| `POST /sleep?level=1` (or 2) | Mostly yes | Yes | Faster than full reload (level 1 needs CPU RAM for weights) |
| `replicas: 0` / scale Deployment | Yes (process gone) | No | Full cold start (minutes possible for 30B AWQ) |

Operator “spin down pods” ≈ **scale-to-zero path**. Sleep endpoints ≈ **keep
pod, free GPU**. Either satisfies *effect*; do not conflate them in design.

### Gaps vs “as simple as the outline”

1. **Last used** — need a durable signal (Prometheus `vllm:*`, LiteLLM access
   logs, or gateway metrics). Health scrapes must not reset the idle clock.
2. **Next request** — LiteLLM will often **fail** until wake/scale-up unless a
   wake-before-forward wrapper exists. Operator already accepts slow first
   load; may also need to accept one error + retry, or add wake later.
3. **Sleep path extras** — `--enable-sleep-mode` + gated `VLLM_SERVER_DEV_MODE`
   (dev admin surface; do not expose broadly). Not required if only scaling.
4. **Timeshare** — idle free must not fight ComfyUI Phase B rules blindly.
5. **Not a product substitute** — this is **homelab automation**, not upstream
   “vLLM acts like Ollama.”

### Verdict

| Question | Answer |
| --- | --- |
| Would the sketched flow do what is needed *in effect*? | **Yes**, if idle detect + free GPU + accept cold/slow next use |
| Is it as trivial as enable-sleep-mode alone? | **No** — flag enables capability; watcher owns the timer |
| Is a custom K8s controller required? | **No** for v1 |
| Effort class | Small intentional capability — larger than a flag, smaller than KEDA+HTTP add-on+LiteLLM rewire |
| Recommend implement now? | **No** unless operator promotes; current always-on is an accepted choice |

## Draft plan shape (WIP — not for execute)

### Capability Packet Boundary (brainstorm)

- **In:** Idle policy for `vllm-primary` on `hom-lab-ctl-k3s-02`; choose sleep
  **or** scale-to-0; lab-side scheduler; document first-request behavior.
- **Out:** Mac controllers; full KEDA/Knative platform; Ollama keep_alive inside
  vLLM; automatic game-aware eviction.

### Apply / Verify / Undo / Change class (if ever promoted)

| | Draft |
| --- | --- |
| **Apply** | Inventory toggle (e.g. idle policy enabled) + CronJob/script or Ansible-managed Job; optionally enable sleep flags if sleep path chosen |
| **Verify** | After idle T, VRAM drops (`nvidia-smi`); after traffic, pod/sleep wakes or scales up; LiteLLM chat recovers |
| **Undo** | Disable policy; restore `replicas: 1` / wake; remove CronJob |
| **Change class** | Idempotent config + optional new runtime knobs; not bootstrap |

### Recommended v1 (if promoted later)

1. Prefer **scale Deployment to 0** after idle (no DEV_MODE, clear VRAM).
2. Idle signal from **request metrics / LiteLLM**, not raw “pod exists.”
3. Document: first chat after idle may error until ready; retry or wait.
4. Defer sleep-mode admin HTTP unless cold-start time becomes painful.
5. Encode as Ansible-managed CronJob/manifests under existing vLLM role family
   — not an ad-hoc Mac script.

### Architecture sketch (optional)

```text
LiteLLM --> Service --> vllm-primary (replicas 1|0)
                ^
                |
         idle watcher (CronJob)
           - read last success timestamp
           - if idle > T: scale 0
           - (optional later) on demand: scale 1
```

Sleep variant replaces “scale 0” with `POST /sleep` and “scale 1” with
`POST /wake_up`.

## Assumptions / defaults

- Primary consumer remains LiteLLM `qwen3-coder-30b-a3b` on vllm-primary.
- Operator OK with cold start; not OK with manual Ansible every evening.
- Desktop and lab share one 5090 via GPU-P on HVH-02.

## Promotion gate

Do **not** treat this file as execute-complete. To implement: promote to
`docs/plans/YYYY-MM-DD--…`, decide sleep vs scale-to-0, define idle metric,
then Ansible-first entry.

## Diagram Inventory

| Diagram | Medium | Included? |
| --- | --- | --- |
| Idle watcher vs LiteLLM / vLLM | ASCII | Yes (sketch above) |
| Architecture SVG via create-diagrams | — | Not yet (brainstorm only) |

## Other available diagram types

Capability routing (sleep vs scale), naming/ownership (who owns idle policy),
sequence (idle → free → next chat).
