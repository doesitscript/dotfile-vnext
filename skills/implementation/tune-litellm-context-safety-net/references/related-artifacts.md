# Related Artifacts

## Live Request Inspector vars (`roles/k3s_litellm_gateway/defaults/main.yml`)

- `k3s_litellm_gateway_request_inspector_enabled`
- `k3s_litellm_gateway_request_inspector_max_window`
- `k3s_litellm_gateway_request_inspector_safety_tokens`
- `k3s_litellm_gateway_request_inspector_chars_per_token`
- `k3s_litellm_gateway_request_inspector_warn_tools_pct`
- `k3s_litellm_gateway_request_inspector_warn_conversation_pct`
- `k3s_litellm_gateway_request_inspector_dump_tools_on_warn`
- `k3s_litellm_gateway_context_window_fallbacks_with_openai`
- `k3s_litellm_gateway_context_window_fallbacks_without_openai`

## Archived trim mutate path

- `roles/k3s_litellm_gateway/archive/trim-messages-callback-2026-07/`

## Vault (cloud fallback)

```bash
bin/codex-env ansible-vault edit vault/shared.vault.yml
# vault_shared_openai_api_key: "sk-..."
# vault_shared_anthropic_api_key: "sk-ant-..."   # optional
```

## Deploy

```bash
bin/codex-env ansible-playbook playbooks/deploy_litellm_gateway.yaml -l hom-lab-ctl-k3s-02
```

## Verify callback on pod

```bash
kubectl -n litellm logs deploy/litellm --tail=200 | grep request_inspector
```
