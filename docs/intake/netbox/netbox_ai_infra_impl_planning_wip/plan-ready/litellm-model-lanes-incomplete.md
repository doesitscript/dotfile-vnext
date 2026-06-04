# Plan-ready — LiteLLM model lanes + router_settings

**Status:** awaiting operator review  
**Promote to:** `docs/plans/YYYY-MM-DD--litellm-model-lanes-incomplete/`  
**Depends on:** [vllm-primary-stack-incomplete.md](./vllm-primary-stack-incomplete.md) (stable `api_base`)

---

## Intake intent (preserved)

From [1.1.0](../1.1.0-dev-workflow-arch-layers-operating-mode-REFERENCE.md): LiteLLM is the **traffic router** — one OpenAI-compatible front door for agents and IDE. **Model lanes** are intentional aliases (`code-deep`, `ripi-private`, …), not raw provider model strings. Clients “choose model lane” before each call; policies (`local-5090`, `local-only`, …) express where that lane may route.

Vocabulary: [intake-semantic-vocabulary.md](../intake-semantic-vocabulary.md)

---

## Scope

- Extend `roles/k3s_litellm_gateway` `proxy_config`:
  - `model_list` rows for the full planned set: `code-deep`, `code-fast`, `ripi-private`, `code-review`, `code-test`, `embeddings-local`, `public-research`, `experiment`, and migration fallbacks
  - `router_settings` (fallback / strategy per D-2)
- Schema: `model_lane_aliases` pattern in `ansible.yml` + `live-object-registry.yml` rows
- Keep `gpt-4o-mini` during migration

**Source eval:** [gpu-lane-and-model-lane-mapping-evaluation.md](../gpu-lane-and-model-lane-mapping-evaluation.md) § Full proxy_config

---

## Apply / Verify / Undo / Change class

| | |
|---|---|
| **Apply** | Update `defaults/main.yml`, `build_helm_values.yml`; redeploy `deploy_litellm_gateway.yaml` on k3s-02 |
| **Verify** | `curl` to `http://litellm.hom.lab/v1/chat/completions` for every enabled lane; candidate lanes have blocker/research rows; Langfuse trace shows alias metadata |
| **Undo** | Revert model_list to current; helm upgrade |
| **Class** | Idempotent config |

---

## Concrete LiteLLM row (example — not the whole plan)

```yaml
- model_name: code-deep
  litellm_params:
    model: hosted_vllm/Qwen/Qwen2.5-Coder-32B-Instruct-AWQ
    api_base: http://vllm.vllm-runtime.svc.cluster.local:8000/v1
    api_key: none
  model_info:
    routing_policy: local-5090
    primary_guest: hom-lab-ctl-k3s-02
```

---

## Doc research required before promotion

- [LiteLLM proxy config](https://docs.litellm.ai/docs/proxy/configs) — `model_list`, `router_settings`
- [LiteLLM vLLM provider](https://docs.litellm.ai/docs/providers/vllm) — `hosted_vllm/` prefix

---

## Obligations (preview)

| ID | Obligation |
|----|------------|
| L-01 | `code-deep` alias resolves to live vLLM |
| L-02 | `router_settings` present in helm values |
| L-03 | Schema registry rows for each planned alias, including `code-test` and non-local/cloud fallback rows |
| L-04 | No intake `gpu_lane_*` inventory keys |
| L-05 | Agent role defaults represented or routed to named sibling plan |

---

## On Deck — user decisions to integrate

| ID | User decision / direction | Target integration | Status |
|----|---------------------------|--------------------|--------|
| OD-AI-001 | Implement several model lanes now | Full model_list/schematic obligations | integrated into stub; governed plan carries receipts |
