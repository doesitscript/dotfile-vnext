# vLLM architecture — discussion (what it is and where it goes in *your* lab)

**Type:** discussion + architect recommendation  
**Audience:** Operator building familiarity — not assumed vLLM expertise  
**Repo plans cited:** `docs/plans/2026-05-19--vllm-runtime-and-huggingface-cache/`, `docs/plans/2026-05-28--k3s-vllm-service-publication-incomplete/`

---

## What vLLM is (one paragraph)

**vLLM** is an **open-source inference server** for running downloaded models (from Hugging Face) on **NVIDIA GPUs**. It exposes an **OpenAI-compatible HTTP API** (`/v1/chat/completions`, etc.) so tools like **Cursor**, **OpenClaw**, or **LiteLLM** can call your **local** models as if they were OpenAI — without sending prompts to the cloud.

It is **not** the same as:

| Thing | What it does |
|-------|----------------|
| **LiteLLM** (you already have) | **Gateway** — one address, many backends (local vLLM, Azure, etc.), aliases, keys, routing |
| **Langfuse** (you already have) | **Observability** — traces, evals, cost metadata |
| **Hugging Face Hub** | **Model catalog/download** — where weights come from |
| **Ollama** (in ChatGPT exports only) | **Different** local runtime — you chose **vLLM instead** |

---

## Do you need vLLM on every machine that “has models”?

**No.** Standard homelab pattern (matches your intake + repo direction):

```text
┌─────────────┐     ┌──────────────────┐     ┌─────────────────────────┐
│ Mac / IDE   │────▶│ LiteLLM (k3s-02) │────▶│ vLLM instance(s)        │
│ OpenClaw    │     │  aliases/lanes   │     │  one process per model  │
│ Cursor      │     │  + cloud APIs    │     │  OR per GPU box         │
└─────────────┘     └──────────────────┘     └─────────────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │ Langfuse traces  │
                    └──────────────────┘
```

| Machine | Runs vLLM? | Why |
|---------|------------|-----|
| **mac-dev** | **No** | Client only — talks to LiteLLM / hom.lab |
| **hom-lab-ctl-hvh-02 (5090)** | **Yes — primary** | Powerhouse; deep/coding models need VRAM |
| **hom-lab-ctl-hvh-01 (smaller GPU)** | **Optional second instance** | Smaller models — review, embeddings, parallel lane |
| **dev-workstation-win** | **Not in this slice** | AMD GPU; vLLM is NVIDIA-first; out of scope until reconciled |
| **Every host “just in case”** | **No** | Wastes RAM/disk; complicates HF cache and ops |

**Rule of thumb:** Deploy vLLM **only where you have an NVIDIA GPU and a defined model job**. Count **instances**, not machines: one vLLM server can serve **one model** (or a configured set) per GPU; LiteLLM fans out to multiple vLLM URLs as different **aliases**.

Official pattern: LiteLLM `hosted_vllm` / `vllm` provider points at `api_base: http://<vllm-host>:8000/v1` ([LiteLLM vLLM provider docs](https://docs.litellm.ai/docs/providers/vllm)).

---

## What must be “set up” inside vLLM (checklist)

When the repo implements `k3s_vllm_runtime` / `vllm_runtime`, these are the **real** configuration surfaces (from your vLLM plan + industry practice):

| # | Setting | Purpose |
|---|---------|---------|
| 1 | **Model ID** (Hugging Face repo id) | Which weights load — e.g. `Qwen/Qwen2.5-Coder-7B-Instruct` |
| 2 | **`HF_TOKEN`** (vault) | Gated models + reliable downloads |
| 3 | **GPU memory** (`--gpu-memory-utilization`, tensor parallel size) | Fit model in VRAM (5090 vs small GPU) |
| 4 | **Cache paths** (`HF_HOME`, `VLLM_CACHE_ROOT` on PVC) | Avoid re-download; share cache on K3s |
| 5 | **Port / ingress** | NodePort or Traefik — then hom.lab publication |
| 6 | **LiteLLM model_list entry** | Maps alias `code-deep` → `hosted_vllm/...` + `api_base` |
| 7 | **Langfuse callbacks** (via LiteLLM) | Trace metadata — not inside vLLM itself |

The repo **does not yet encode (6–7)** or final model IDs — that is **reconciliation work**, not missing because vLLM is mysterious.

**Test model in plan:** `Qwen/Qwen3-0.6B` — smoke test only; replace for real coding lanes.

---

## Recommended placement for *your* estate (architect view)

| Workload | Recommended host | Runtime shape |
|----------|------------------|---------------|
| Primary coding / deep private | **5090** — `hom-lab-ctl-k3s-02` worker or GPU-visible guest | **vLLM** (Helm/K3s per existing plan) |
| LiteLLM + Langfuse + Jupyter | **k3s-02** (already) | K8s roles `k3s_*` |
| MinIO + Postgres | **dkr-02 today**; **dkr-01** if you migrate to storage lane | Docker stacks |
| Reviewer / embeddings | **hvh-01** when GPU documented | Second **vLLM** instance, smaller model |
| IDE | **mac-dev** | OpenClaw → LiteLLM only |

This aligns with your **powerhouse vs storage** story while acknowledging **current** Langfuse/LiteLLM on k3s-02.

---

## Relationship to publication plan

Order of operations (do not skip):

1. Deploy vLLM → stable URL on LAN  
2. Register in **LiteLLM** `model_list`  
3. Add **hom.lab** / hosts-file row ([k3s-vllm-service-publication-incomplete](../../../plans/2026-05-28--k3s-vllm-service-publication-incomplete/README.md))  
4. NetBox service slug under code **`vlm`** (`resource-roles.yml`)

**Catalog** (which models you standardize for agents) is a **later** packet — not the same as “one vLLM endpoint exists.”

---

## Further reading

- [placeholder-to-implementation-reconciliation-evaluation.md](./placeholder-to-implementation-reconciliation-evaluation.md) — model/lane replacements  
- [host-role-reconciliation-discussion.md](./host-role-reconciliation-discussion.md) — which physical host  
- [ai-homelab-layer-model.md](../../reference/ai-homelab-layer-model.md) — runtime vs gateway vs observability

Sources checked:
- Repo vLLM plans (2026-05-19, 2026-05-28)
- LiteLLM docs (vLLM provider)
- Web: vLLM serving + LiteLLM proxy patterns (2025–2026 guides)
