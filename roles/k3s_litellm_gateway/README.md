# k3s_litellm_gateway

Deploys the LiteLLM proxy on K3s using the official `litellm-helm` chart. Secrets are sourced from Ansible vault at apply time and written to Kubernetes Secrets; the chart references them with `os.environ/<VAR>` in `proxy_config`.

## Vault sources

| Vault file | Variables |
|------------|-----------|
| `vault/shared.vault.yml` | `vault_shared_openai_api_key`, `vault_k3s_litellm_gateway_master_key`, Langfuse and Minio shared keys |
| `vault/network.vault.yml` | `vault_network_postgres_*` (same credentials as `/srv/stacks/network/.env`) |

Set a real OpenAI key before using the migration/provider routes:

```bash
ansible-vault edit vault/shared.vault.yml
# vault_shared_openai_api_key: "sk-..."
```

## Kubernetes secrets

| Secret | Keys |
|--------|------|
| `litellm-env-secret` | `PROXY_MASTER_KEY`, `OPENAI_API_KEY` (when set), `LANGFUSE_*` |
| `litellm-external-postgres` | `username`, `password` |

Helm `environmentSecrets` mounts `litellm-env-secret` into the pod; `proxy_config` uses `os.environ/OPENAI_API_KEY` and `os.environ/PROXY_MASTER_KEY`.

External PostgreSQL uses `k3s_litellm_gateway_db_endpoint` plus
`k3s_litellm_gateway_db_port` when rendering the database URL and status output.

## Model routes vs model catalog

`k3s_litellm_gateway_model_list` is the LiteLLM gateway route list. It defines
client-facing aliases such as `code-deep`, `experiment`, and the preserved
migration rows.

For the current slice:

- `code-deep` is the first real local coding lane.
- `experiment` remains visible as a smoke alias, but it currently shares the
  same `vllm-primary` backend as `code-deep` until a second runtime exists.
- `gpt-4o-mini` and `default` stay present as migration rows while local-lane
  verification is still maturing.

The durable Hugging Face/storage catalog is separate:
`inventory/group_vars/model_catalog/manifest.yml`. That manifest tracks
candidate/downloaded/served model weights and their storage path on the
`hom-lab-hvh-01` public SMB share.

Do not duplicate the full catalog into this role. When a catalog row becomes a
served runtime, add or update the corresponding LiteLLM route here and keep the
route's `model_info.model_lane` aligned with its `model_name`.

## Langfuse trace metadata

The gateway supplies route-level metadata through LiteLLM `model_info`, including
`model_lane`, `routing_policy`, and `project`.

Per-request metadata such as `agent_role` and `context_class` is owned by the
IDE/agent client profile. Those values must be sent with the completion request
metadata, not hardcoded globally in the gateway, because planner, coder, tester,
reviewer, documenter, and steward traffic can share the same gateway.

## Playbook

```bash
ansible-playbook playbooks/deploy_litellm_gateway.yaml
```

Requires the shared fuzlang external data-plane declared in
`inventory/group_vars/all/fuzlang_external_services.yml` so external
PostgreSQL and the vault-aligned `.env` exist.

## Lifecycle

- `k3s_litellm_gateway_state: present` — deploy
- `k3s_litellm_gateway_state: absent` — remove Helm release and namespace
