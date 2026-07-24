# Sources And Precedence

1. Live hook logs after the change (`requested_out`, `budget`, `tools_est`)
2. Role defaults / inventory overrides actually deployed
3. `roles/k3s_litellm_gateway/README.md` server-tuned driver table
4. `docs/diagnostics/litellm-context-window--k3s--diagnostics.md`
5. Upstream LiteLLM trim_messages / call_hooks docs when extending behavior

Prefer measured Agent payloads over theoretical 32k arithmetic alone.
