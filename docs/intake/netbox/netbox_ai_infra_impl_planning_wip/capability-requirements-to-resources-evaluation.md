# Capability requirements → tangible resources — evaluation

**Type:** evaluation (primary reconciliation artifact)  
**Source:** [`1.1.0-dev-workflow-arch-layers-operating-mode-REFERENCE.md`](./1.1.0-dev-workflow-arch-layers-operating-mode-REFERENCE.md) and related intake  
**Audience:** Operator with minimal prior knowledge — each row explains *what the generic name meant* and *what we actually deploy*

**This is not executable.** It feeds Phase 2 plan packets after you confirm rows marked **decision needed**.

---

## How to use this file

ChatGPT exports describe **capabilities** (`code-deep`, `planner agent`, `trace links`) because you did not have live inventory when those chats ran. This evaluation:

1. States the **requirement** in plain language  
2. Recommends a **concrete resource** (model, service, path, tool)  
3. Names **where it runs** on your estate  
4. Lists **repo gap** (what Ansible/Langfuse/Cursor does not do yet)  
5. Points to a **plan slice** to implement  

**Naming:** New resources use repo schema (`vlm`, `llm`, `hfc`, `hom-lab-ctl-*`) — see [placeholder-to-implementation-reconciliation-evaluation.md](./placeholder-to-implementation-reconciliation-evaluation.md).

---

## A. Model lanes (`model_aliases` from 1.1.0)

Intake was **lane policy only**. Below: recommended **backing model + runtime + host**.

| Alias | Generic lane (intake) | What you actually need | Recommended backing | Runtime | Host | LiteLLM `model_name` | Repo gap |
|-------|----------------------|------------------------|---------------------|---------|------|----------------------|----------|
| **`code-deep`** | `local-5090` — architecture, refactors, test generation | Strong **local** coding model on powerhouse GPU | **Qwen/Qwen2.5-Coder-32B-Instruct** (AWQ-INT4 quant for VRAM headroom) | **vLLM** | `hom-lab-ctl-k3s-02` or 5090-visible worker | `code-deep` → `hosted_vllm/Qwen2.5-Coder-32B-Instruct-AWQ` | vLLM role missing; alias not in `k3s_litellm_gateway_model_list` (today: `gpt-4o-mini` only) |
| **`code-fast`** | `local-preferred` — autocomplete, small edits, repo Q&A | **Fast** responses; local preferred, cloud OK | **Primary:** `Qwen/Qwen2.5-Coder-7B-Instruct` on vLLM (hvh-01). **Cloud fallback:** `gemini-2.5-flash` or `gemini-3.5-flash` via LiteLLM when local saturated | vLLM + Google API | Second GPU / cloud | `code-fast` | Second vLLM instance; Google API key in vault; LiteLLM route |
| **`code-review`** | `local-or-azure` — critique, security, verify steps | Cheaper/faster than deep; may use cloud for “second opinion” | **Local:** same 7B as `code-fast` on hvh-01. **Cloud (scrubbed):** `gemini-2.5-flash` | vLLM + cloud | hvh-01 + LiteLLM | `code-review` | Privacy routing policy (future) |
| **`ripi-private`** | `local-only` — planning, thinking out loud, Notion-adjacent work | **Private** reasoning; no cloud leakage; good at planning prose | **Local:** `Qwen/Qwen2.5-7B-Instruct` or `microsoft/Phi-4-mini-instruct` on **second GPU** (lower VRAM). **Notion:** not a model — future **MCP/integration** slice | vLLM | `hom-lab-ctl-hvh-01` | `ripi-private` | **Clarify with you:** Notion sync = separate app/MCP plan; model is only the LLM part |
| **`public-research`** | `azure-allowed` — docs, comparisons, web research | **Cloud** with scrubbed/public context only | **Gemini 2.5/3.5 Flash** (cost/latency) or **Azure OpenAI** `gpt-4o-mini` / reasoning tier when scrubbed | LiteLLM cloud routes | LiteLLM on k3s-02 | `public-research` | Vault keys; **privacy classifier** before route (Phase 3) |
| *(intake table)* **`private-reasoning`** | Same family as ripi-private | Merge into **`ripi-private`** alias | Same as ripi-private | — | hvh-01 | — | Dedupe in plan |
| **`dashboard-helper`** | Hybrid trace/prompt analysis | Langfuse UI + optional small model | **Langfuse web** + optional `code-fast` for in-UI assist | Langfuse / LiteLLM | k3s-02 | — | Langfuse dashboards / evals not configured |
| **`research-heavy`** | Azure + web tools | Cloud + tools (browser MCP later) | Gemini Pro class or Azure **o3-mini** / reasoning SKU when context scrubbed | Cloud | LiteLLM | `research-heavy` | Out of scope until Phase 3 |
| **`coding-fast`** | (earlier table in 1.1.0) | Same as **code-fast** | Same | — | — | — | Alias dedupe |
| **`coding-deep`** | (earlier table) | Same as **code-deep** | Same | — | — | — | Alias dedupe |
| **`reviewer`** | reviewer lane | Same as **code-review** | Same | — | — | — | Alias dedupe |
| **`embeddings-local`** | RAG / similarity | Embedding model | **BAAI/bge-small-en-v1.5** or **Qwen/Qwen3-Embedding-0.6B** | vLLM embeddings API or dedicated small vLLM | **hvh-01** | `embeddings-local` | Not in repo; HF cache path on storage share |
| **`experiment`** | Try new weights | Scratch alias | Points to smoke model `Qwen/Qwen3-0.6B` or manual HF id | vLLM | Either GPU | `experiment` | Catalog entry only |

### Research notes (models)

- **5090 / ~32GB class:** Industry consensus for local coding is **Qwen2.5-Coder-32B** (AWQ) on **vLLM**, not Ollama — matches your vLLM decision and existing plan smoke test family (Qwen3-0.6B).  
- **code-fast cloud example you gave:** **Gemini Flash** is a valid LiteLLM route (`gemini/gemini-2.5-flash`) for speed when local 7B is busy — requires Google AI API key in vault, not on GPU.  
- **ripi-private:** Treat as *planning/conversation* lane — smaller dense model on **storage/second GPU**, strict `local-only` in LiteLLM router — **ask you** to confirm Notion is MCP later vs just “private chat model.”

---

## B. Langfuse “black box recorder” (1.1.0 §4)

### What the generic requirement meant

Record per call: **agent role**, **model alias**, **prompt template**, **failure**, **promotion state**, **repo**, **work item** — not “open Langfuse sometimes.”

### What we have today

| Piece | Status |
|-------|--------|
| Langfuse platform on K3s | **Deployed** — `k3s_langfuse_platform` |
| LiteLLM → Langfuse callback | **Partial** — `success_callback: ['langfuse']` in role defaults |
| Rich **metadata** on each completion | **Missing** — no `session_id`, `agent_role`, `trace_tags` in proxy config |
| Prompts / datasets in Langfuse | **Not wired** |
| Eval scores / promotion | **Not wired** |

### What to add (architect plan — not implemented)

| Work item | Implementation | Owner surface |
|-----------|----------------|---------------|
| B-LF-1 | LiteLLM proxy: pass `metadata` from clients (Cursor/OpenClaw) with `session_id`, `tags`, `trace_user_id` | [LiteLLM Langfuse integration](https://docs.litellm.ai/docs/observability/langfuse_integration) |
| B-LF-2 | Standard metadata schema (YAML contract in repo) | `group_vars` or `docs/reference/langfuse-trace-metadata-contract.yml` *(proposed)* |
| B-LF-3 | Helm values: ensure Langfuse OTEL/callback env matches self-hosted URL `http://langfuse.hom.lab` | `k3s_litellm_gateway` |
| B-LF-4 | Jupyter/cookbook patterns from [1.4.0](./1.4.0-langfuse-cookbook-patterns-REFERENCE.md) | `dev_jupyterlab_workbench` docs |
| B-LF-5 | Datasets + evals for golden tests | future-state after V0 traces work |

**Plan slice:** `docs/plans/…--langfuse-agent-observability-incomplete/` (to be created in Phase 2).

**Apply / Verify:** Deploy extended LiteLLM config → send test completion with metadata → see trace in Langfuse UI with tags.

---

## C. Trace links (dashboard “jumps into Langfuse”)

### What the generic requirement meant

RIPI/work-control UI shows a link: click → open the **exact trace** for that agent run.

### Tangible implementation

| Layer | Resource |
|-------|----------|
| **Trace ID** | Returned by LiteLLM/Langfuse SDK in response metadata (`trace_id` / `existing_trace_id`) |
| **URL pattern (self-hosted)** | `{langfuse_base_url}/project/{projectId}/traces/{traceId}` — confirm path in your Langfuse version at `http://langfuse.hom.lab` |
| **Storage** | Langfuse Postgres (dkr-02) — traces are not files on disk |
| **RIPI dashboard** | future-state — stores `trace_id` on `AgentRun` entity; template URL in app config |

**Repo gap:** No RIPI app; no URL template in inventory. **Near-term:** document URL template in observability plan; test manually from Langfuse UI after B-LF-1.

---

## D. Agent roles (1.1.0 §5, §1152–1155) — not “install an agent binary”

### What the generic requirement meant

A **team-shaped workflow**: planner → coder → tester → reviewer → steward — each with **limited access**, not one god-mode AI.

### What this is in practice (research conclusion)

There is **no single Ansible role** called `planner agent`. You implement **three surfaces**:

| Surface | What defines “planner” vs “coder” |
|---------|----------------------------------|
| **Cursor** | Custom **Agent modes** / rules / allowed tools (repo `.cursor/rules`, future `AGENTS.md` per role) |
| **LiteLLM** | Virtual keys or aliases per workflow; optional rate limits |
| **Langfuse** | `metadata.agent_role`, `session_id` = work item id, **tags** = `agent:planner` |

| Agent (intake) | Job | Cursor/config | Model alias (LiteLLM) | Access boundary |
|----------------|-----|---------------|----------------------|-----------------|
| **planner** | Safe slices, docs | Planner mode — read-only tools, no write | `ripi-private` or `code-fast` | No repo write |
| **coder** | Write code | Default Agent — write | `code-deep` | Branch write |
| **tester** | Run tests | Agent with terminal + test tag | `code-fast` | Test dirs + commands |
| **reviewer** | Diff review | Ask/review mode | `code-review` | Read diff, no write |
| **documenter** | Docs only | Narrow rule scope | `code-fast` | `docs/` only |
| **steward** | Promotable? | Human or constrained local | `ripi-private` | Read summaries + evidence |

**Repo gap:** No Cursor role pack in repo; no Langfuse session convention; no virtual keys in LiteLLM.

**Plan slice:** `cursor-agent-workflow-future-state` + part of `langfuse-agent-observability-incomplete`.

---

## E. Phase 2 coding team (1.1.0 lines 1212–1224) — first five items

Intake said **implement** — architect translation for **planning** (your request: plan first five):

| # | Intake line | Tangible implementation | Depends on |
|---|-------------|-------------------------|------------|
| 1 | **planner agent** | Cursor custom agent + Langfuse `session_id` + rule file `framework-planner-agent.mdc` *(proposed)* | LiteLLM aliases, Langfuse metadata |
| 2 | **coder agent** | Cursor default agent + `code-deep` alias + git branch policy in rules | vLLM primary |
| 3 | **tester agent** | Cursor agent profile + pytest/ansible test commands allowlist | Local runtime |
| 4 | **reviewer agent** | Cursor review profile + `code-review` alias | 7B or cloud |
| 5 | **test command capture** | Langfuse trace + optional artifact dir `artifacts/agent-runs/<work_item>/test.log` | Langfuse callback working |

Items 6–8 (Git diff capture, Langfuse trace IDs, RIPI run records) → **next plan slice** after 1–5.

See [agent-workflow-phase2-planning-discussion.md](./agent-workflow-phase2-planning-discussion.md).

---

## F. Phase 3 Azure booster (1.1.0 §1227–1230)

### Generic requirement

“Heavy reasoning” in **cloud** only after local works; **scrubbed** context for architecture; block private-core.

### Tangible replacements

| Generic | Recommended cloud resource | LiteLLM route | When |
|---------|---------------------------|---------------|------|
| `azure-reasoning` / heavy reasoning | **Azure OpenAI** `o3-mini` or **`gpt-4o`** / **Gemini 2.5 Pro** for long architecture | `azure/heavy-reasoning` or `gemini/gemini-2.5-pro` | Phase 3 only |
| `public-research` | **Gemini Flash** | `gemini/gemini-2.5-flash` | After privacy router |
| Private-core block | LiteLLM **guardrail** / router rule: `context_class: private-core` → local aliases only | Config in `k3s_litellm_gateway` | `ai_privacy_policy` future-state |

**Repo gap:** No Azure/Gemini routes in `k3s_litellm_gateway_model_list`; no scrubbing pipeline.

---

## G. GPU lanes from 1.0.0 (lines 82–84)

Full mapping (hosts + model aliases only — **no** new `gpu_lane_*` inventory): **[gpu-lane-and-model-lane-mapping-evaluation.md](./gpu-lane-and-model-lane-mapping-evaluation.md)**.

| Intake phrase *(provenance only)* | Inventory host | Repo group |
|-----------------------------------|----------------|------------|
| “5090 lane” | `hom-lab-ctl-hvh-02` | `hyperv_lane_gpu` |
| “second GPU lane” | `hom-lab-ctl-hvh-01` | `hyperv_lane_storage` |

## G2. GPU node capabilities (1.1.0 §1243–1260)

Document **capabilities as metadata** on hosts; deploy **runtimes** separately.

| Node (operator) | Intake capability phrases | Tangible resources to deploy |
|-----------------|---------------------------|------------------------------|
| **5090 / hvh-02** | deep coding, vLLM primary, heavier reasoning | vLLM + **Qwen2.5-Coder-32B-AWQ**; LiteLLM alias `code-deep`; HF cache PVC or storage share read |
| **Second GPU / hvh-01** | parallel agents, reviewer, embeddings, smaller models | vLLM **7B** + **embedding model**; Langfuse/MinIO **workloads** (see host-role doc for drift); weights on **public share** |
| **Third / dev-workstation** | experimental | **Document only** — AMD 9060 XT not vLLM-primary; optional future ROCm experiment |

---

## H. Model catalog + download storage (1.1.0 §1265, your vote)

### Generic requirement

Later **catalog** of downloaded models, roles, lanes — not the same as vLLM endpoint publication.

### Architect recommendation (with your vote: **storage node + public share**)

| Layer | Where | What |
|-------|-------|------|
| **Physical weights (HF cache)** | `\\hom-lab-ctl-hvh-01\public\models\huggingface\` (SMB) mirrored on Linux guest as `/mnt/homelab-models` or bind mount | Large binaries; backup-friendly |
| **Catalog manifest (SSOT)** | Git: `inventory/group_vars/model_catalog/manifest.yml` *(proposed)* + NetBox config context `homelab-model-catalog` | model_id, lane, host, path, quant, vram_gb, hf_repo_id |
| **Operational registry** | NetBox: tags/fields for **installed models** on device/VM — not intake “lane” names | Phase 2 NetBox slice |
| **Runtime pointer** | LiteLLM `model_list` + vLLM `--model` arg | Points at manifest rows |

**Not** primary on 5090 disk — avoids filling OS drive on powerhouse.

**Plan slice:** `model-catalog-storage-lane-incomplete` — depends on [windows-public-share plan](../../plans/windows-public-share-netbox-naming/README.md) on **hvh-01**.

---

## I. OpenClaw + Cursor (IDE integration)

| Generic | Tangible |
|---------|----------|
| OpenClaw in coding setup | **OpenClaw** app on Mac → OpenAI-compatible base URL = `http://litellm.hom.lab/v1` → model = `code-deep` / `code-fast` |
| Cursor | Cursor → LiteLLM or direct; repo `deploy_development_nodes` + homelab hosts file |
| Env vars | `OPENAI_API_BASE`, `OPENAI_API_KEY` = LiteLLM master key |

**Repo gap:** No `ai_ide_client` tasks; no documented env template on mac-dev.

---

## J. Master gap → plan map

| Plan packet (proposed slug) | Covers |
|----------------------------|--------|
| `…--ai-homelab-gpu-vllm-hf-incomplete` | vLLM primary, HF cache, GPU verify, storage share paths |
| `…--litellm-model-lanes-incomplete` | All aliases in §A, router policies |
| `…--langfuse-agent-observability-incomplete` | §B, §C, metadata contract |
| `…--model-catalog-storage-lane-incomplete` | §H |
| `…--cursor-agent-workflow-future-state` | §D, §E |
| `…--azure-cloud-lanes-future-state` | §F |
| Extend `2026-05-28--k3s-vllm-service-publication-incomplete` | One stable vLLM URL |

---

## Decisions needed from you

| ID | Question |
|----|----------|
| D-1 | **ripi-private + Notion:** Model-only for now, or prioritize Notion MCP integration in a separate packet? |
| D-2 | **code-fast:** Prefer **local 7B always** or **Gemini Flash default** with local fallback? |
| D-3 | **Langfuse/MinIO on k3s-02 today:** Keep while adding hvh-01 second vLLM, or plan migration to storage lane? |
| D-4 | **Public share path:** Confirm `F:\shares\public\models` on **hvh-01** as canonical HF root |

---

Sources checked:
- Intake `1.1.0`, `1.4.0`, [ASSESSMENT.md](./ASSESSMENT.md), [host-role-reconciliation-discussion.md](./host-role-reconciliation-discussion.md)
- `roles/k3s_litellm_gateway/defaults/main.yml`
- [LiteLLM Langfuse integration](https://docs.litellm.ai/docs/observability/langfuse_integration), [Langfuse LiteLLM gateway](https://langfuse.com/integrations/gateways/litellm)
- Model research: Qwen2.5-Coder, Gemini Flash (web summaries May 2026)
