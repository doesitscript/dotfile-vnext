# Sources And Precedence

1. Live Request Inspector logs (`litellm request_inspector` JSON) after the change
2. Role defaults / inventory overrides actually deployed
3. `roles/k3s_litellm_gateway/README.md` § AI Request Inspector
4. `docs/diagnostics/litellm-context-window--k3s--diagnostics.md` (current stub;
   trim narrative outdated 2026-09-09)
5. For weak local coding quality: 5090 untuned→tuned model docs before any
   trim/safety-net theory
6. Upstream LiteLLM call_hooks docs when extending **observe** behavior

**Do not** prefer archived `trim_messages` mutate docs as live remediation.
Archive only: `roles/k3s_litellm_gateway/archive/trim-messages-callback-2026-07/`.

Prefer measured Agent payloads over theoretical 32k arithmetic alone.
