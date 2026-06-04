# Intake semantic vocabulary — design language → repo artifacts

**Purpose:** Keep the **clear meaning** from numbered archives when we implement. Technical SSOT stays compact (`hom-lab-ctl-hvh-02`, `code-deep`); this file holds **why** and **what job** each name serves.

**Update when:** You reconcile a new section of `1.x.0` / `2.x.0`, promote a plan, or add a role README.

**Playbook:** [wip-intake-principles.md](./wip-intake-principles.md) §9

---

## How to use this file

| Column | Meaning |
|--------|---------|
| **Intake term** | Phrase or name from ChatGPT export (may be imprecise) |
| **Design meaning** | What the modular design intended — preserve in READMEs/descriptions |
| **Repo artifact** | What we actually implement (host, role, var, alias) |
| **Carry into** | Where the wording should appear (not duplicate SSOT YAML in plans) |

---

## Workflow and lanes (from 1.0.0, 1.1.0)

| Intake term | Design meaning | Repo artifact | Carry into |
|-------------|----------------|---------------|------------|
| choose model lane | Pick policy class for this request before calling LLM | LiteLLM `model_name` + trace `model_lane` | Gateway README; Langfuse metadata doc |
| model lane | Friendly API alias (`code-deep`, not GPU hardware) | `k3s_litellm_gateway_model_list[].model_name` | Role defaults comments; operator docs |
| code-deep | Heavy private coding on primary GPU | `hosted_vllm/Qwen/...` @ k3s-02 vLLM | README “Heavy coding lane”; task names |
| ripi-private | Planning/thinking without cloud leak | `ripi-private` alias → local vLLM | Privacy router docs |
| code-fast | Quick edits, autocomplete | 7B local and/or Gemini fallback | D-2 decision |
| classify privacy | Tag work before routing | `context_class` metadata | Langfuse + future router |
| bounded agent role | One hat per run (coder vs reviewer) | Cursor mode + `agent_role` trace field | Agent workflow discussion |
| capture work → … → promote/reject | Full RIPI-style loop | Future product; today manual | Plan future-state; layer-model doc |
| 5090 lane *(provenance)* | Jobs for powerhouse GPU host | `hom-lab-ctl-hvh-02`, k3s-02 vLLM | README job list — **not** inventory key |
| second GPU lane *(provenance)* | Reviewer, embeddings, smaller models | `hom-lab-ctl-hvh-01` | Same |
| Primary deep local reasoning | Largest local model for hard problems | vLLM 32B AWQ deployment | vLLM plan “Intake intent” section |
| Heavy coding | Same stack, coding-focused use | `code-deep` alias | LiteLLM README |
| vLLM primary | One main OpenAI-compatible inference service | `vllm-runtime` + `vllm.hom.lab` | Publication plan |
| Sensitive/private work | No cloud for private classes | Router + guardrails | litellm plan-ready |
| LiteLLM as traffic router | Single gateway; not the brain | `k3s_litellm_gateway` | [ai-homelab-layer-model.md](../../reference/ai-homelab-layer-model.md) |
| Langfuse black box recorder | Traces, prompts, evals over time | `k3s_langfuse_platform` | langfuse eval + role README |
| local-only / local-5090 / … | Routing policy labels | `model_info.routing_policy` | Helm values comments |

---

## Capability / role names (from 1.2.0 — evaluate, don’t blindly rename)

| Intake term | Design meaning | Repo artifact | Carry into |
|-------------|----------------|---------------|------------|
| ai_litellm_gateway | Multi-model control plane for agents/IDE | `k3s_litellm_gateway` | README title “K3s LiteLLM gateway (model lanes)” |
| ai_vllm_runtime | GPU inference server | `k3s_vllm_runtime` (plan) | README “vLLM runtime (OpenAI-compatible)” |
| ai_langfuse_platform | Observability substrate | `k3s_langfuse_platform` | README trace/eval purpose |
| ai_huggingface_client | Token + download hygiene | HF vault + vLLM role | Var descriptions |
| ai_ide_client | Mac/Cursor/OpenClaw → gateway | `deploy_development_nodes` | Playbook name/description |
| ai_privacy_policy | Enforce class before cloud | LiteLLM router (future) | Future-state plan prose |

---

## Product vocabulary (Group A — future-state; keep meaning)

| Intake term | Design meaning | Repo artifact | Carry into |
|-------------|----------------|---------------|------------|
| HD-01 | Governed product domain label | **Not** a hostname | GROUP-A synthesis only |
| RIPI | Work items + agent runs | Future dashboard | future-state plan |
| Product engineering lab | Build software with agents, not train foundation models | [ai-homelab-layer-model.md](../../reference/ai-homelab-layer-model.md) | Project README |

---

## Gaps discovered from rich intake (candidates to define)

| Intake concept | Suggested repo action | Governed plan (incomplete-wip) |
|--------------|----------------------|--------------------------------|
| Model catalog (durable inventory of chosen HF models) | `manifest.yml` + registry rows | [2026-05-29--ai-model-catalog-hf-storage-incomplete-wip](../../../plans/2026-05-29--ai-model-catalog-hf-storage-incomplete-wip/README.md) |
| `node_classes` | Map to inventory groups in reference doc | [2026-05-29--ai-ansible-modularity-and-gaps-incomplete-wip](../../../plans/2026-05-29--ai-ansible-modularity-and-gaps-incomplete-wip/README.md) |
| Notion / ripi-private | Model-only vs MCP integration | D-1 in modularity plan + [litellm model lanes](../../../plans/2026-05-29--ai-litellm-model-lanes-incomplete-wip/README.md) |
| Privacy router (`ai_privacy_policy`) | Future guardrails before cloud routing | modularity plan + litellm plan |
| Cookbook eval patterns (1.4.0) | Per-pattern Langfuse doc check → task | [2026-05-29--ai-langfuse-observability-incomplete-wip](../../../plans/2026-05-29--ai-langfuse-observability-incomplete-wip/README.md) |

**Program umbrella:** [2026-05-29--ai-homelab-intake-execution-incomplete-wip](../../../plans/2026-05-29--ai-homelab-intake-execution-incomplete-wip/README.md)

---

## Template row (copy for new terms)

```markdown
| <intake term> | <what designer meant> | <role/host/var/alias> | README / plan / comment target |
```
