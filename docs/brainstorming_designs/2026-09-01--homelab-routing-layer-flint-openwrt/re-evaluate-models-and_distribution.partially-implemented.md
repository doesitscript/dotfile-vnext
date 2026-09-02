---
title: "Kilo coding — GPU model placement (v1 implemented)"
status: partially-implemented
created: 2026-09-01
implemented_at: 2026-09-01
execution_status: v1-implemented
scope: kilo-code-coding-only
supersedes_misplacement:
  - devstral-24b@desktop~kilo-main
  - ornith-35b@k3s02-vllm~* (invented model-slug; real weights are Qwen2.5-Coder-32B AWQ)
remaining_scope: v2-kilo-aligned-5090-upgrade
deferred_scope: v3-qwen3-coder-next-hardware-change
note: >-
  v1 (5090-primary Kilo routing) is live. v2 = Kilo-aligned model upgrade research.
  v3 = Qwen3-Coder-Next only when hardware provides 48 GB+ VRAM path.
---

## Execution status

| Version | Scope | Status |
| --- | --- | --- |
| **v1** | 5090-primary Kilo routing via LiteLLM; 1060 autocomplete; desktop fallback | **Implemented** (2026-09-01) |
| **v2** | Kilo-aligned 5090 upgrade — **Qwen 3.6 27B** research + vLLM probe | **Remaining / incomplete** |
| **v3** | **Qwen3-Coder-Next** (48 GB+ VRAM) | **Deferred** — revisit only when hardware changes |

---
# Kilo coding — GPU model placement (v1 implemented)

## Summary (read this first)

**Problem:** Kilo was aimed at **desktop Ollama** (slow AMD path). The **5090** already
runs a **32B coder on vLLM** but was not the Kilo default.

**Fix:** Route Kilo **main coding** to **5090 vLLM**. Use **1060** for autocomplete.
Use **desktop** only as **fallback**. No new 5090 model download required for v1.

**Client ID rule (dropdown string):**

```text
<real-model>@<host>~<purpose-suffix>
```

Only the part after `~` is an invented homelab label. The model-slug must be the
real weight name (e.g. `qwen2.5-coder-32b`, not `ornith-35b` or `kilo-coder`).

---

## Kilo model alignment (5090)

Kilo Code is **model-agnostic** (BYOK / OpenAI-compatible). It does not mandate one
local weight — but Kilo publishes **hardware-tier picks** ([best local coding models](https://blog.kilo.ai/p/the-best-local-coding-models-for), Jul 2026).

### What is on the 5090 today?

| Field | Value |
| --- | --- |
| Weights | `Qwen/Qwen2.5-Coder-32B-Instruct-AWQ` |
| Stack | vLLM CUDA on `hom-lab-ctl-k3s-02` |
| Client id | `qwen2.5-coder-32b@k3s02-vllm~kilo-main` |

**Verdict:** Uses the 5090 well (32B AWQ, ~0.5 s warm). **Solid v1 choice** — fixes
misplacement. **Not** Kilo's current #1 pick for a single 5090.

### Kilo's 5090-class recommendations (32 GB VRAM)

| Kilo pick | Fits single 5090? | Notes |
| --- | --- | --- |
| **[Qwen 3.6 27B](https://kilo.ai/models/by/qwen)** | **Yes** — Kilo's **best overall local coding model 2026** for 24–32 GB | Explicitly lists RTX 5090 (32 GB) at up to 262K context. **Top upgrade candidate.** |
| **[Devstral Small 2](https://kilo.ai/models/by/mistralai)** | Yes (~32K–64K) | Strong SWE-bench; good for tool/agent workflows. You already have older `devstral:24b` on desktop — different generation. |
| **[Qwen3-Coder-Next](https://kilo.ai/models/qwen-qwen3-coder-next)** | **No** on one card | Trained for Kilo/agent scaffolds; Kilo cites **48 GB+** (two GPUs). Not v1 without research. |
| **qwen3-coder:30b** (Ollama docs example) | Yes on 5090 via **vLLM**, not desktop Ollama | Already on desktop Ollama — wrong stack for speed. Candidate to **move to 5090 vLLM** in Phase 4. |

**Qwen2.5-Coder-32B** is absent from Kilo's 2026 "best nine" list — it is the **prior-gen**
dedicated coder the homelab already serves. Keeping it is reasonable until an upgrade
probe proves a newer model on vLLM.

### Recommended strategy

| Phase | 5090 model | Rationale |
| --- | --- | --- |
| **v1 (now)** | Keep **Qwen2.5-Coder-32B AWQ** | Already on vLLM, fast, no download. Route Kilo here. |
| **v2 (upgrade)** | Evaluate **Qwen 3.6 27B** on vLLM | Kilo's single-5090 best pick; research matrix + probe before pin. |
| **v3 (optional)** | **Qwen3-Coder-Next** | Only if 48 GB path appears (second GPU or aggressive quant). |

Do **not** use desktop `devstral:24b` or `qwen3-coder:30b` as Kilo main — wrong GPU/stack.

---

**Goal:** Kilo Code as the primary coding IDE, with **each GPU doing what it does
best**:

| GPU | Job |
| --- | --- |
| **RTX 5090** | Main agent / code / debug / architect (quality + speed) |
| **GTX 1060** | Tab autocomplete / tiny completions (latency) |
| **RX 9060 XT** | Fallback when 5090 path is down — **not** default coding |

**What went wrong:**

1. **Misplacement (root cause of ~66 s desktop probe):** Kilo main used
   `devstral-24b@desktop~kilo-main` → desktop **Ollama** (24B, AMD/Vulkan).
2. **Not a bad model:** Devstral is real Mistral `devstral:24b`; wrong **lane** and **stack**.
3. **Cold load likely contributed:** first trivial reply ~**66 s** vs **~0.5 s** on
   5090 (same LiteLLM gateway, 2026-09-01). Warm-repeat desktop probe still pending.
4. **5090 was idle for Kilo:** weights already served —
   `Qwen/Qwen2.5-Coder-32B-Instruct-AWQ` on vLLM.

**Out of scope:** ComfyUI, image models, future 5090 experiments. This plan is
**Kilo coding only**.

---

## Recommended Kilo setup (v1 — execute this)

### LiteLLM provider (Kilo → OpenAI Compatible)

| Field | Value |
| --- | --- |
| Base URL | `http://litellm.hom.lab/v1` |
| API key | `sk-Pass@w0rd1` |

### Model dropdown (use exact strings)

| Kilo role | Client `model_name` (dropdown) | GPU | Stack |
| --- | --- | --- | --- |
| **Default / Main / Code / Debug / Architect** | `qwen2.5-coder-32b@k3s02-vllm~kilo-main` | RTX 5090 | vLLM CUDA |
| **Testing (14B AWQ swap)** | `qwen2.5-coder-14b@k3s02-vllm~kilo-lite` | RTX 5090 | vLLM CUDA — **active while `k3s_vllm_runtime_kilo_testing_active` on k3s-02** |
| **Autocomplete** (if exposed) | `qwen2.5-coder-1.5b@hvh01~kilo-autocomplete` | GTX 1060 | Ollama |
| **Fallback** (5090 down) | `ministral-3-8b@desktop~kilo-fast` | RX 9060 XT | Ollama |

**Remove from Kilo defaults:**

- `devstral-24b@desktop~kilo-main` (deprecated; was misplacement)
- Any `ornith-35b@...` id (invented slug; replaced by `qwen2.5-coder-32b@...`)

**Cursor / Continue** may keep `qwen2.5-coder-32b@k3s02-vllm~coder-primary` —
same 5090 backend, different `~suffix`.

### Disk / cache (kilo-lite testing)

While serving **14B AWQ**, the **32B AWQ HF cache** may be removed from the
vLLM PVC to free ~19GB (`models--Qwen--Qwen2.5-Coder-32B-Instruct-AWQ`). Repo
defaults still reference 32B for later revert; re-download when restoring
`kilo-main`.

LiteLLM routes like `~experiment`, `~coder-no-trim`, `~default` are **friendly-name
duplicates** over the same vLLM weights — they do not add disk use. Use
`kilo-lite` during 14B testing; ignore `kilo-main` until 32B vLLM is restored.

---

While troubleshooting 32B `kilo-main`, vLLM primary on k3s-02 serves
`Qwen/Qwen2.5-Coder-14B-Instruct-AWQ` at **32k** context (`hom-lab-ctl-k3s-02.yaml`).

| Kilo setting | Value |
| --- | --- |
| Default model (interim agent) | `ministral-3-8b@desktop~kilo-fast` |
| 5090 smoke / chat only | `qwen2.5-coder-14b@k3s02-vllm~kilo-lite` (`tool_call: false` in kilo.jsonc) |
| Weights | `Qwen/Qwen2.5-Coder-14B-Instruct-AWQ` (official HF) |
| Revert | Remove `k3s_vllm_runtime_kilo_testing_active` block; redeploy vLLM + gateway |

`kilo-main` / 32B gateway rows stay in repo — they fail until 32B vLLM is restored.

### Tool calling (2026-09-01 — do not fix 14B)

| Route | Kilo code agent tools | Notes |
| --- | --- | --- |
| `kilo-lite` (14B vLLM) | **Broken** | Tool JSON in `content`; `tool_calls: null` |
| `kilo-fast` (Ministral Ollama) | **API OK** | Interim operator default; raw JSON in UI may be Kilo subagent display |
| `kilo-main` (32B vLLM) | **Restore target** | Primary 5090 lane when HF cache re-downloaded |

**Recommendation:** Stop debugging 14B parser mismatch. Next 5090 agent path:
restore **32B `kilo-main`**, or v2 **Qwen 3.6 27B**, or v3 **Qwen3-Coder** with
`qwen3_coder` parser.

HRL: `homelab-reference-library/notes/investigations/2026-09-01--kilo-code-litellm-vllm-context-limits.md`.

---

If agent mode hits 32k context limits:

1. Lower Kilo max context (16k–24k).
2. Fewer files per turn; fresh chat per task.
3. **Do not** move main lane back to desktop Devstral for “speed.”

---

## Target architecture

```text
                 Kilo Code (VS Code)
                        │
                        ▼
           LiteLLM  http://litellm.hom.lab/v1
                        │
      ┌─────────────────┼─────────────────┐
      ▼                 ▼                 ▼
 5090 PRIMARY       1060 FAST         desktop FALLBACK
 qwen2.5-coder-32b   qwen2.5-coder     ministral-3-8b
 @k3s02-vllm        -1.5b@hvh01       @desktop
 ~kilo-main          ~kilo-autocomplete ~kilo-fast
 vLLM AWQ            Ollama Pascal      Ollama Vulkan
```

---

## “Devstral” clarified

| Name | What it is | Kilo role |
| --- | --- | --- |
| **Devstral** | Real Mistral coding model (`devstral:24b`) | **None** — keep as `devstral-24b@desktop~open-webui-coder` |
| **Ministral** | Smaller Mistral (`ministral-3:8b`) | **Fallback only** on desktop |
| **Qwen2.5-Coder-32B** | Live 5090 vLLM weights (AWQ) | **Kilo primary** |

---

## Evidence

| Route | GPU | Warm trivial reply |
| --- | --- | --- |
| `qwen2.5-coder-32b@k3s02-vllm~kilo-main` | 5090 | **~0.39 s** |
| `qwen2.5-coder-1.5b@hvh01~kilo-autocomplete` | 1060 | **~3.8 s** |
| `ministral-3-8b@desktop~kilo-fast` | Desktop | **~8.3 s** |
| `devstral-24b@desktop~kilo-main` (old) | Desktop | **~66 s** |

---

## Repo / gateway changes

### v1 — Implemented (2026-09-01)

- [x] `model_client_ids.yml` — real model slugs; `kilo-main` on 5090; demote desktop Devstral
- [x] `defaults/main.yml` — `kilo-main` vLLM route
- [x] `build_helm_values.yml` — `kilo-autocomplete`, `open-webui-coder`, `kilo-fast` routes
- [x] `kilo_code_ollama_hosts`, `dev-workstation-win`, `hom-lab-hvh-01` — lane contract
- [x] `validate_ai_inference_stack_contracts.yaml` — Kilo main → vLLM assertion
- [x] LiteLLM gateway redeploy — `changed=1`, exit 0
- [x] `/v1/models` exposes all three Kilo client ids
- [x] `kilo-main` warm probe — **~0.39 s** (5090 vLLM)
- [x] `kilo-autocomplete` probe — **~3.8 s** (HVH-01 Ollama / 1060)
- [x] Disk cleanup — removed 32B HF cache from vLLM PVC (~19GB freed; 32B repo config kept)
- [x] `kilo-lite` warm probe — **READY** after vLLM bring-up
- [x] Context limits — 32k `max-model-len` + kilo.jsonc `limit` (Kilo code agent overhead)
- [x] Tool-calling probe — **14B broken** (do not fix); **Ministral API OK**; operator interim default `kilo-fast`

### v1 — Operator Kilo UI (manual)

In Kilo Code → Settings → Providers → OpenAI Compatible:

| Setting | Value |
| --- | --- |
| Base URL | `http://litellm.hom.lab/v1` |
| API key | `sk-Pass@w0rd1` |
| Default model (interim) | `ministral-3-8b@desktop~kilo-fast` |
| 5090 when 32B restored | `qwen2.5-coder-32b@k3s02-vllm~kilo-main` |
| Autocomplete model | `qwen2.5-coder-1.5b@hvh01~kilo-autocomplete` |

- [ ] Operator confirms Kilo UI picks (cannot be automated from Ansible)

### v2 — Remaining (incomplete)

- [ ] Research matrix: **Qwen 3.6 27B** vs current Qwen2.5-Coder-32B AWQ on vLLM/5090
- [ ] Probe vLLM serve + Kilo agent turn before changing `k3s_vllm_runtime_model`
- [ ] Warm-repeat desktop Devstral probe (characterize cold vs steady-state)

### v3 — Deferred (hardware change)

- [ ] **Qwen3-Coder-Next** — `pending_research` until 48 GB+ VRAM path exists (second GPU or new hardware)

---

## Apply / Verify / Undo / Change class

| | |
| --- | --- |
| **Apply** | Kilo UI model IDs + LiteLLM redeploy (Phase 2) |
| **Verify** | `/v1/models` + Kilo agent turn + latency probe |
| **Undo** | Revert Kilo picks; redeploy prior gateway config from git |
| **Change class** | Gateway routes = idempotent; client id rename = **breaking** for old Kilo picks |

---

## Operator review checklist

- [x] Gateway routes — Kilo main on 5090 vLLM (repo + live `/v1/models`)
- [x] Autocomplete route — `qwen2.5-coder-1.5b@hvh01~kilo-autocomplete`
- [x] Desktop — fallback only (`ministral-3-8b@desktop~kilo-fast`)
- [x] Devstral — Open WebUI only (`devstral-24b@desktop~open-webui-coder`)
- [ ] Kilo VS Code UI picks confirmed by operator

---

## On deck

| Item | Status |
| --- | --- |
| v1 gateway + Ollama prefetch + validation | implemented 2026-09-01 |
| Operator Kilo UI confirmation | pending operator |
| v2 Qwen 3.6 27B research matrix | incomplete |
| v3 Qwen3-Coder-Next | deferred — hardware change |
