# Plan-ready — Langfuse observability + trace metadata

**Status:** awaiting operator review  
**Promote to:** `docs/plans/YYYY-MM-DD--langfuse-agent-observability-incomplete/`  
**Depends on:** [litellm-model-lanes-incomplete.md](./litellm-model-lanes-incomplete.md) (aliases stable)

---

## Scope

From [1.4.0](../1.4.0-langfuse-cookbook-patterns-REFERENCE.md) + 1.1.0 trace example — **Langfuse layer** only.

**Mandatory before design:** Langfuse doc research gate ([wip-intake-principles.md](../wip-intake-principles.md)):

- Langfuse skill → `llms.txt` + [LiteLLM integration](https://langfuse.com/integrations/gateways/litellm)
- Repo: `k3s_langfuse_platform`, existing `success_callback: ["langfuse"]` in LiteLLM

---

## Target trace metadata (align to model lane slugs)

```yaml
# Per completion — propagate via LiteLLM proxy metadata + Langfuse SDK where needed
model_lane: code-deep          # same as LiteLLM model_name
routing_policy: local-5090
context_class: private-code
agent_role: coder
primary_guest: hom-lab-ctl-k3s-02
```

**Do not** add `gpu_lane: lane-5090-primary`.

---

## Apply / Verify / Undo / Change class

| | |
|---|---|
| **Apply** | Extend gateway callback config; document metadata contract in role README; optional Langfuse project/tags via API |
| **Verify** | Test completion → trace in Langfuse UI with `model_lane` visible |
| **Undo** | Revert gateway env / callback config |
| **Class** | Idempotent config |

---

## Evaluation artifact

Full mapping: [langfuse-observability-reconciliation-evaluation.md](../langfuse-observability-reconciliation-evaluation.md)

---

## Obligations (preview)

| ID | Obligation |
|----|------------|
| F-01 | Doc research recorded with URLs |
| F-02 | Metadata keys match LiteLLM alias slugs |
| F-03 | LiteLLM success_callback still works |
| F-04 | Cookbook patterns from 1.4.0 mapped or deferred with reason |
