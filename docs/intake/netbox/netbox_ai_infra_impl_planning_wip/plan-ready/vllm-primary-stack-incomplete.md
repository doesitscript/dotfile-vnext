# Plan-ready — vLLM primary stack (k3s-02)

**Status:** awaiting operator review  
**Promote to:** extend [docs/plans/2026-05-19--vllm-runtime-and-huggingface-cache/](../../../plans/2026-05-19--vllm-runtime-and-huggingface-cache/README.md) + [2026-05-28--k3s-vllm-service-publication-incomplete/](../../../plans/2026-05-28--k3s-vllm-service-publication-incomplete/README.md)  
**Depends on:** GPU operator on k3s-02; optional [model-catalog-storage-incomplete.md](./model-catalog-storage-incomplete.md)

---

## Intake intent (preserved)

From [1.0.0](../1.0.0-parent-conversation-context-and-constraints-REFERENCE.md): **Primary deep local reasoning** and **vLLM primary** mean the 5090 OpenAI-compatible runtime backend — local, sensitive-capable, and not “a lane” in inventory. **Heavy coding** is how operators/API clients *use* that service via LiteLLM alias `code-deep` (separate plan slice). This stub does not narrow the overall program to `code-deep`; it supplies one backend for the full lane set.

Vocabulary: [intake-semantic-vocabulary.md](../intake-semantic-vocabulary.md)

---

## Scope

Intake jobs from 1.0.0 (5090 path) — **runtime layer only**:

| Intake job | Concrete deliverable |
|------------|---------------------|
| Primary deep local reasoning | vLLM serves `Qwen/Qwen2.5-Coder-32B-Instruct-AWQ` (after smoke `Qwen/Qwen3-0.6B`) |
| vLLM primary | NS `vllm-runtime`, Service URL, operator `vllm.hom.lab`, NetBox `vlm` / slug `vllm-k3s-primary` |

**Not in this slice, but not dropped:** LiteLLM aliases (separate stub), full model-purpose set, agent role defaults, and Langfuse fields (separate stub).

---

## Apply / Verify / Undo / Change class

| | |
|---|---|
| **Apply** | `k3s_vllm_runtime` / `deploy_vllm_runtime.yaml` on hom-lab-ctl-k3s-02 |
| **Verify** | OpenAI `/v1/models` on cluster URL; `nvidia-smi` on GPU node; publication curl from mac-dev |
| **Undo** | Helm uninstall vllm release; `state: absent` |
| **Class** | Idempotent deploy |

---

## Multi-layer note

| Layer | This slice | Next slice |
|-------|------------|------------|
| Catalog | HF weights path (D-4) | model-catalog stub |
| vLLM | **this stub** | — |
| LiteLLM | — | litellm-model-lanes |
| Langfuse | — | langfuse-trace-metadata |

---

## Obligations (preview)

| ID | Obligation |
|----|------------|
| V-01 | vLLM pod healthy on k3s-02 |
| V-02 | Stable cluster `api_base` documented |
| V-03 | Publication row in hosts-file catalog |
| V-04 | NetBox service metadata when URL stable |
| V-05 | Cross-plan check: full lane set remains represented in LiteLLM/catalog plans |

---

## On Deck — user decisions to integrate

| ID | User decision / direction | Target integration | Status |
|----|---------------------------|--------------------|--------|
| OD-AI-002 | Do not let vLLM sequencing narrow the plan to `code-deep` only | V-05 and governed vLLM packet | integrated into stub |
