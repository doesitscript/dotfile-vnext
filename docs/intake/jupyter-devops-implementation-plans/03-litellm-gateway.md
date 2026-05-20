# 03 - LiteLLM Gateway

## Goal

Deploy LiteLLM as the unified OpenAI-compatible gateway for notebook and app
model calls.

## Preliminary Project Structure And Resources

Expected project areas:

- `roles/k3s_litellm_gateway/`: new Helm or Kubernetes-manifest role for the
  LiteLLM gateway.
- `playbooks/`: add or extend a k3s AI platform playbook with
  `k3s_litellm_gateway` tags.
- `inventory/group_vars/`: define namespace, release name, gateway service
  host, model routes, upstream provider endpoints, and Langfuse integration.
- Vault or ignored secret files: store provider keys, LiteLLM master key, and
  any Langfuse callback credentials.
- `roles/ipam_netbox/`: later model the gateway endpoint and service ownership.
- `docs/reference/naming-standards/`: add route/model naming schema if missing.

Expected Kubernetes resources:

- namespace
- LiteLLM deployment
- model routing config
- provider secret(s)
- service
- optional ingress
- optional config link to Langfuse LLM API/playground/eval settings

## Implementation Intent

- Role name candidate: `k3s_litellm_gateway`.
- Deploy LiteLLM on k3s.
- Route friendly model names to provider APIs and local vLLM services.
- Keep provider secrets out of committed plaintext.
- Configure Langfuse optional LLM API/playground/eval settings to use LiteLLM,
  not direct provider endpoints.

## Acceptance Criteria

- LiteLLM exposes a stable internal service endpoint.
- At least one provider or placeholder route is configured.
- Later vLLM services can be added without changing notebook/app client code.
- Langfuse can use LiteLLM for optional LLM-backed features.
