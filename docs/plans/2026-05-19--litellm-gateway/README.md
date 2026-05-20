# LiteLLM Gateway

## Summary

Deploy LiteLLM as the OpenAI-compatible gateway for notebook and application
model calls. LiteLLM becomes the stable client endpoint while provider routes
and local vLLM backends can change behind it.

Proposed schema/resource code:

- `llm`: LiteLLM gateway

## Architecture/Structure Diagram

```mermaid
graph TB
    schema[docs/reference/naming-standards<br/>service code llm]
    inv[inventory/group_vars<br/>routes, upstreams, service host]
    vault[vault vars<br/>provider keys + LiteLLM master key]
    role[roles/k3s_litellm_gateway]
    pb[playbooks/k3s_ai_platform.yaml<br/>tag: k3s_litellm_gateway]
    svc[LiteLLM service]
    langfuse[Langfuse optional LLM features]
    vllm[vLLM runtime service]
    providers[External provider APIs]

    schema --> inv
    inv --> role
    vault --> role
    pb --> role
    role --> svc
    svc --> providers
    svc --> vllm
    langfuse --> svc
```

## Worklist

1. Add `roles/k3s_litellm_gateway`.
2. Define model route config, provider secret handling, service, and optional
   ingress.
3. Route Langfuse optional LLM API/playground/eval settings through LiteLLM.
4. Leave vLLM routes additive so app/notebook clients do not change later.

## Apply / Verify / Undo / Change Class

- Apply: run the K3s AI platform playbook with `k3s_litellm_gateway`.
- Verify: gateway service responds to an OpenAI-compatible request.
- Undo: remove Helm release/manifests and provider secrets by state.
- Change class: idempotent config with secret-managed inputs.

## Diagram Inventory

Included:

- Architecture/Structure Diagram

Other available diagram types:

- Model Route Diagram
- Secret Boundary Diagram
- Langfuse Integration Diagram
- Provider Failover Diagram
