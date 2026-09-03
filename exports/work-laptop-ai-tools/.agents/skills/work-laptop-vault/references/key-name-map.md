# Vault key name map (packet)

Exact names must match role `load_vault.yml` (update when roles change).

| Role | Packet vault file | Key(s) |
| --- | --- | --- |
| morph | `vault/shared.vault.yml` | `vault_shared_morph_api_key` |
| firecrawl | same | `vault_firecrawl_mcp_api_key` |
| context7 | same | `vault_context7_mcp_api_key` (optional) |
| firebase | same | `vault_firebase_mcp_service_account_json`, `vault_firebase_mcp_firebase_token`, optional `vault_firebase_mcp_extra_env` |

| continue / zed | same | `vault_k3s_litellm_gateway_master_key` |

Parent `vault/shared.vault.yml` holds Morph + LiteLLM master key.
Parent `vault/mac_dev.vault.yml` holds Firecrawl / Context7 (inline `!vault`).

Hydrate (values never printed):

```bash
bin/codex-env python exports/work-laptop-ai-tools/scripts/hydrate_vault_from_parent.py --also-sibling
```
