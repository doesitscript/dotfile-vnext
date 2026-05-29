# Phase 1 synthesis — Group B (infra / Ansible deployment)

**Status:** Phase 1.2 complete  
**Canonical plan input:** [1.2.0-infra-ansible-deployment-map-PLAN-INPUT.md](./1.2.0-infra-ansible-deployment-map-PLAN-INPUT.md)  
**Appendix / full export:** [1.3.0-infra-ansible-deployment-map-full-export.md](./1.3.0-infra-ansible-deployment-map-full-export.md)  
**Prerequisite references (not merged here):** [1.0.0](./1.0.0-parent-conversation-context-and-constraints-REFERENCE.md), [1.1.0](./1.1.0-dev-workflow-arch-layers-operating-mode-REFERENCE.md), [1.4.0](./1.4.0-langfuse-cookbook-patterns-REFERENCE.md)

---

## Purpose

Single merged view of **what to deploy where** in the Ansible/NetBox homelab: multi-GPU lanes, gateways, observability, IDE client, and RIPI V0 — adapted from the parent-thread implementation map.

---

## Core placement decision (from 1.2.0)

| Resource | Role |
|----------|------|
| **5090** | Primary private/deep model lane (vLLM primary) |
| **Second GPU** | Reviewer / tester / embeddings / parallel local |
| **Third medium GPU (desktop)** | Experimental / fallback / dev-agent sandbox |
| **Mac (mac-dev)** | Operator, IDE, Ansible controller |
| **k3s-02** | LiteLLM, Langfuse, Jupyter, shared AI platform |
| **dkr-02** | NetBox, Loki/Grafana, Postgres, MinIO, support services |

**Estate narrative:** mac-dev = execution controller; GPU lane = dkr-02 + k3s-02.

---

## GPU lane policy (from 1.0.0 — reference only)

- Multi-agent **foundations**, not full orchestration platform yet  
- Second GPU **“later is now”** for modeling and NetBox  
- **Do not** treat second GPU as equal peer — assign jobs per lane  
- Simple workflow: capture → privacy class → model lane → bounded agent → trace → verify → promote/reject  

---

## Node classes (inventory concept)

```yaml
node_classes:
  - execution_controller
  - ide_managed
  - ai_gpu_primary
  - ai_gpu_secondary
  - ai_gpu_experimental
  - ai_gateway_host
  - ai_observability_host
  - ai_storage_host
  - ai_agent_surface
```

---

## Proposed Ansible roles (intake names — Phase 0.3 mapped to repo)

**Phase 0 finding:** No `ai_*` directories on disk. Shipped equivalents: `k3s_litellm_gateway`, `k3s_langfuse_platform`, `dev_jupyterlab_workbench`, etc. See [ASSESSMENT.md](./ASSESSMENT.md) §0.3 and [ai-homelab-layer-model.md](../../reference/ai-homelab-layer-model.md).

### Intake role list (historical chat naming)

| Role | Purpose |
|------|---------|
| `ai_huggingface_client` | HF token + cache paths on download-capable nodes |
| `ai_nvidia_runtime` | GPU runtime verification per host |
| `ai_vllm_runtime` | vLLM instances (multi-host profiles) |
| `ai_ollama_runtime` | Lighter local runtime (second/third GPU, optional 5090) |
| `ai_litellm_gateway` | Central LiteLLM on k3s-02 |
| `ai_langfuse_platform` | Langfuse on k3s-02 (may overlap existing deployment) |
| `ai_model_cache` | Shared cache layout / paths |
| `ai_agent_workspace` | Agent workspace surfaces |
| `ai_ide_client` | Mac/Cursor/OpenClaw client config → LiteLLM |
| `ai_privacy_policy` | Routing / privacy classification contract |
| `ai_ripi_dashboard` | RIPI V0 app |
| `ipam_netbox_ai_services` | NetBox service records for AI fleet |

Start as **variable contracts + verify tasks** where full roles are premature.

---

## vLLM placement summary

| Host | vLLM? | Notes |
|------|-------|-------|
| 5090 | yes | Primary, port e.g. 8001 |
| Second GPU | yes (smaller profile) | Reviewer lane, port e.g. 8002 |
| Third GPU desktop | optional | Experimental, port e.g. 8003, publish optional |
| Mac | no | Client only |
| k3s-02 | maybe | Only if GPU attached |
| dkr-02 | no | Stateful support, not inference |

**Boundary:** vLLM runtime ≠ durable model catalog (catalog is a future layer).

---

## LiteLLM

- **One** gateway on k3s-02  
- Model aliases (placeholders): `ripi-private`, `code-deep`, `code-review`, `code-test`, `embeddings-local`, `experiment`, `azure-reasoning`  
- OpenClaw → LiteLLM, not raw endpoints  
- Broad agent permissions deferred until routing/audit gates exist  

---

## Langfuse

- Stay on k3s-02  
- Trace fields: `agent_role`, `work_item_id`, `context_class`, `model_alias`, `backend_host`, `gpu_lane`, `trace_id`, `repo`, `test_status`, `promotion_state`  
- Cookbook absorption patterns → [1.4.0](./1.4.0-langfuse-cookbook-patterns-REFERENCE.md) (separate; not duplicated here)

---

## Mac / IDE (`ai_ide_client`)

- LiteLLM, Langfuse, OpenClaw gateway URLs (hom.lab placeholders)  
- Default model aliases for private / code / review  
- Cursor, SSH, env, privacy defaults  

---

## NetBox services to seed (when endpoints stable)

`vllm-primary-5090`, `vllm-secondary-reviewer`, `vllm-experimental`, `ollama-secondary`, `ollama-experimental`, `litellm-gateway`, `langfuse`, `jupyter`, `ripi-dashboard`, `openclaw-gateway`

**Publication rule:** hom.lab catalog rows only when endpoint is stable — aligns with existing [k3s-vllm-service-publication-incomplete](../../../plans/2026-05-28--k3s-vllm-service-publication-incomplete/README.md) plan.

---

## RIPI dashboard V0

| Piece | Placement |
|-------|-----------|
| Web + API | k3s-02 |
| DB | dkr-02 Postgres |
| Traces | Langfuse |
| Routing | LiteLLM |

Track: WorkItem, AgentRun, ModelLane, ContextClass, PromotionReceipt, Endpoint, TraceLink, RepoBinding.

---

## Implementation order (from 1.2.0)

1. NetBox/dev fleet modeling (second/third GPU)  
2. Hugging Face client/cache role  
3. NVIDIA runtime verification per GPU host  
4. vLLM primary on 5090  
5. vLLM secondary on second GPU  
6. LiteLLM aliases  
7. Langfuse callbacks from LiteLLM  
8. Mac IDE/client → LiteLLM  
9. OpenClaw → LiteLLM  
10. RIPI dashboard V0  

---

## Overlap with active repo plans

| Intake item | Existing plan / surface | Note |
|-------------|-------------------------|------|
| vLLM publication | `docs/plans/2026-05-28--k3s-vllm-service-publication-incomplete/` | Do not duplicate; extend |
| NetBox edge dev hosts | `docs/plans/2026-05-27--edge-dev-host-naming-netbox-incomplete/` | GPU/dev host modeling may depend |
| Langfuse on k3s | Existing runtime (verify in Phase 0) | May extend role vs new `ai_langfuse_platform` |
| LiteLLM on k3s | Existing runtime (verify in Phase 0) | Same |

---

## 1.3.0 appendix

The full ChatGPT export in `1.3.0` largely **duplicates** `1.2.0` with more thread context. For Phase 2 planning, prefer **this synthesis + 1.2.0** as body; attach `1.3.0` only when verbatim thread evidence is needed.

---

## Next step (Phase 1.3)

See [phase-1-TRIAGE.md](./phase-1-TRIAGE.md) for per-item routing (implement now vs incomplete vs future-state).
