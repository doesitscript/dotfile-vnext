# Langfuse observability — reconciliation evaluation

**Type:** evaluation  
**Source:** [1.4.0-langfuse-cookbook-patterns-REFERENCE.md](./1.4.0-langfuse-cookbook-patterns-REFERENCE.md), [1.1.0](./1.1.0-dev-workflow-arch-layers-operating-mode-REFERENCE.md) (trace block ~1119–1128)  
**Plan-ready:** [plan-ready/langfuse-trace-metadata-incomplete.md](./plan-ready/langfuse-trace-metadata-incomplete.md)

---

## Doc research gate (completed for this pass)

| Step | Action | Result |
|------|--------|--------|
| 1 | Repo existing | `k3s_langfuse_platform` deployed; LiteLLM `success_callback: ["langfuse"]` in [build_helm_values.yml](../../../roles/k3s_litellm_gateway/tasks/build_helm_values.yml) |
| 2 | Langfuse skill principle | Documentation-first — no new SDK pattern without fetch |
| 3 | Integration pattern | LiteLLM proxy → Langfuse via env keys + callback list (already wired) |
| 4 | Intake 1.4.0 | Cookbook patterns = **candidates** to map, not copy-paste |

**Sources checked:**
- Langfuse skill (documentation-first)
- [Langfuse LiteLLM gateway integration](https://langfuse.com/integrations/gateways/litellm)
- `roles/k3s_langfuse_platform/`, `roles/k3s_litellm_gateway/defaults/main.yml`

---

## Multi-layer: intake “trace result” workflow step

| Intake step | Layer | Concrete implementation |
|-------------|-------|-------------------------|
| trace result | Langfuse | Traces from LiteLLM callback + optional explicit metadata |
| choose model lane | LiteLLM + Langfuse | `model_name` on request → `model_lane` on trace |
| classify privacy | Langfuse metadata | `context_class: private-code` etc. |

---

## Metadata contract (promote — align to model lanes)

| Field | Type | Example | Set by |
|-------|------|---------|--------|
| `model_lane` | string | `code-deep` | Client / LiteLLM request |
| `routing_policy` | string | `local-5090` | `model_info` or router |
| `context_class` | string | `private-code` | Client metadata (future router) |
| `agent_role` | string | `coder` | Agent profile |
| `primary_guest` | string | `hom-lab-ctl-k3s-02` | Derived from routing |
| `project` | string | `ripi` | Langfuse project config |

**Reject:** `gpu_lane` as intake lane slug.

---

## 1.4.0 cookbook patterns → repo action

| Intake pattern | Repo action | Route |
|----------------|-------------|-------|
| Trace every agent completion | Already via LiteLLM callback | extend metadata |
| Prompt management in Langfuse | **Research** Langfuse prompt API doc before role tasks | future slice |
| Datasets / evals | Defer to product future-state | GROUP-A |
| Scores on promotion | Map to `promotion_state` metadata | plan-ready langfuse stub |

---

## Gap summary

| Gap | Owner |
|-----|-------|
| Rich metadata on traces | `k3s_litellm_gateway` + gateway README |
| Cookbook → Ansible tasks | Not started — needs per-pattern doc check |
| Storage-lane Langfuse duplicate | D-3 placement decision |
