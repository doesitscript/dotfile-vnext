# Related Artifacts

## Driver variables (`roles/k3s_litellm_gateway/defaults/main.yml`)

- `k3s_litellm_gateway_trim_messages_enabled`
- `k3s_litellm_gateway_trim_messages_max_input_tokens`
- `k3s_litellm_gateway_trim_messages_safety_tokens`
- `k3s_litellm_gateway_trim_messages_min_completion_tokens`
- `k3s_litellm_gateway_trim_messages_min_message_tokens`
- `k3s_litellm_gateway_trim_messages_chars_per_token`
- `k3s_litellm_gateway_context_window_fallbacks_with_openai`
- `k3s_litellm_gateway_context_window_fallbacks_without_openai`

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

## Verify callback constants on pod

```bash
bin/codex-env ansible hom-lab-ctl-k3s-02 -m shell -a \
  'kubectl -n litellm exec deploy/litellm -- grep -E "_MIN_COMPLETION|_MIN_MESSAGE|_SAFETY|_HARD" /etc/litellm/custom_callbacks.py'
```
