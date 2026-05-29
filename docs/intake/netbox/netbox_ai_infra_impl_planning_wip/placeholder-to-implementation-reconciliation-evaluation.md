# Placeholder → implementation reconciliation — evaluation

**Type:** evaluation  
**Purpose:** Replace ChatGPT **samples** with **repo decisions**, **research-backed candidates**, and **naming-schema targets**.  
**Rule:** Intake described *capabilities*; this file assigns *what we actually use*.

---

## How to read intake exports

| Pattern in chat | Meaning | Action |
|-----------------|---------|--------|
| `ai_*` role names | Capability labels | Map to `k3s_*` / `llm_compute_windows` / extend `ipam_netbox` |
| `ollama-*` services | “Light local runtime” placeholder | **Reject for your lab** — use **second vLLM** (smaller model) on hvh-01 |
| Model alias `code-deep`, `ripi-private` | **Lane intent** | Keep alias names in LiteLLM; fill with real HF model + vLLM URL |
| `OpenClaw` | **Your IDE/agent choice** | Document as Mac client path → LiteLLM |
| `RIPI dashboard` | Product app V0 | future-state — not infra Phase 2 |
| Exact model names in chat | Often generic | Replace with researched candidates below |

---

## Runtime reconciliation table

| Intake / chat | Need described | **Chosen direction** | Repo surface | Naming |
|---------------|----------------|----------------------|--------------|--------|
| **Ollama** (`ai_ollama_runtime`, `ollama-secondary`) | Lighter local LLM on 2nd/3rd GPU | **vLLM** second instance on **hvh-01** (when GPU known) | New: small-model vLLM profile; **no** `ai_ollama_runtime` role | Service code candidate: extend `vlm` with suffix in registry, e.g. `vlm-reviewer-hvh-01` |
| **vLLM primary** | Deep/private coding on 5090 | **vLLM on K3s GPU path** (existing plan) | `k3s_vllm_runtime` / `vllm_runtime` + publication plan | `vlm` + L1 slug `vllm-k3s-primary` (repo pattern, not chat `vllm-primary-5090` until reconciled) |
| **vLLM secondary** | Reviewer / tester / embeddings | **vLLM on hvh-01** (smaller GPU) | Phase 2 incomplete plan slice | `vlm-secondary-hvh-01` candidate |
| **LiteLLM** | Single gateway, aliases | **Already shipped** `k3s_litellm_gateway` | extend config | `llm` / `litellm-k3s-gateway` |
| **Langfuse** | Traces, eval substrate | **Already shipped** `k3s_langfuse_platform` | extend trace metadata vars | `lfs` / `langfuse-k3s-web` |
| **Hugging Face client** | Token + cache | **Net-new** HF cache role/tasks | vault `vault_*` pattern + PVC on K3s | `hfc` code exists |
| **OpenClaw** | Coding agent IDE | **Operator decision: use OpenClaw** | `ai_ide_client` → extend `deploy_development_nodes` + LiteLLM base URL | Document only until role tasks exist; alias `openclaw-default` |
| **RIPI dashboard** | Work items / agent UX | **Defer** | future-state app on k3s | `ripi-dashboard` candidate slug — not seeded yet |
| **Cursor** | IDE | Already in dev node playbook | `deploy_development_nodes` | N/A |
| **Azure reasoning** (`azure-reasoning` alias) | Cloud fallback | LiteLLM cloud provider entry | vault API keys | provider name in LiteLLM, not hostname code |

---

## Model lane reconciliation (research candidates)

**Not final deploy** — validate VRAM with `nvidia-smi` and a smoke `vllm serve` before pinning in Ansible.

| LiteLLM alias (intake) | Intent | Suggested backing (5090 primary) | Suggested backing (hvh-01 smaller GPU) | Notes |
|------------------------|--------|----------------------------------|----------------------------------------|-------|
| `code-deep` / deep private coding | Long context, strong codegen | **Qwen2.5-Coder-32B-Instruct** or **DeepSeek-Coder-V2-Lite-Instruct** | N/A on small GPU | 32B needs ~24GB+ quantized; 5090 class fits with AWQ/GPTQ |
| `code-review` | Faster review pass | **Qwen2.5-Coder-7B-Instruct** | Same model acceptable on small GPU | Lower latency |
| `code-test` | Test generation / smaller tasks | **Qwen2.5-Coder-7B-Instruct** | **Qwen2.5-7B-Instruct** | |
| `embeddings-local` | RAG / similarity | **BAAI/bge-small-en-v1.5** via vLLM embeddings API or dedicated embedding server | Same on hvh-01 | Embeddings can be separate lightweight vLLM |
| `ripi-private` | Sensitive product work | Same stack as `code-deep` with **routing policy** (future `ai_privacy_policy`) | — | Privacy = LiteLLM routing + tags, not a different engine |
| `experiment` | Try new weights | Pointer to test model or `-0.6B` smoke | — | |
| `azure-reasoning` | Cloud escape hatch | Azure OpenAI / Anthropic via LiteLLM | — | Already standard LiteLLM |

**Smoke test (repo plan):** `Qwen/Qwen3-0.6B` — keep for CI/smoke only.

**OpenClaw:** Configure base URL = `http://litellm.hom.lab` (or Mac hosts file name), model = `code-deep` alias — not raw vLLM port.

---

## Service slug reconciliation (NetBox L1)

| Intake slug | Repo L1 today | Target |
|-------------|---------------|--------|
| `litellm-gateway` | `litellm-k3s-gateway` | **Keep repo slug**; document alias in source-reconciliation |
| `langfuse` | `langfuse-k3s-web` | **Keep repo slug** |
| `jupyter` | `jupyterlab-workbench` | **Keep repo slug** |
| `vllm-primary-5090` | — | Add when URL stable → prefer **`vllm-k3s-primary`** pattern |
| `ollama-secondary` | — | **Do not add** — use `vlm-*` instead |
| `openclaw-gateway` | — | **Defer** — OpenClaw is client; optional `operator-tooling` doc tag only |
| `ripi-dashboard` | — | future-state seed |

---

## Product labels (intake-only)

| Label | Treatment |
|-------|-----------|
| **HD-01** Harmonic Work Domain | Product taxonomy — not NetBox hostname |
| **HWC-01** Harmonic Execution Cell | Product taxonomy — not NetBox hostname |
| **RIPI** entities (WorkItem, AgentRun) | Application schema — future-state |

---

## What Phase 2 plan should contain vs these docs

| Belongs in **discussion/evaluation** (here) | Belongs in **Phase 2 plan packet** (later) |
|---------------------------------------------|--------------------------------------------|
| Why Ollama → vLLM | Ansible tasks for `k3s_vllm_runtime` |
| Model research candidates | Pinned `vllm_runtime_model_id` in defaults + version contract |
| Host role drift hvh-01 vs dkr-02 | Explicit migration decision + checklist rows |
| OpenClaw as client choice | `deploy_development_nodes` tasks + LiteLLM config PR |
| GPU inventory gaps | `nvidia-smi` probe task output in verification receipt |

---

## Sources checked

- Intake `1.2.0`, Group B synthesis, `1.4.0` Langfuse patterns
- `docs/reference/naming-standards/resource-roles.yml` (`vlm`, `llm`, `lfs`, `hfc`)
- Hugging Face model cards (Qwen2.5-Coder, DeepSeek-Coder-V2-Lite, bge-small) — candidate sizing from public VRAM guidance
- Operator messages (vLLM not Ollama; OpenClaw; host mapping)
