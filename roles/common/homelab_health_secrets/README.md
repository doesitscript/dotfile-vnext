# homelab_health_secrets

Render local `0600` env files used by homelab health probe scripts on the
controller (`mac-dev`). Mirrors the MCP `env.d` pattern under
`~/.config/dotfile-vnext/health/env.d/`.

## Contract

```yaml
homelab_health_secrets_state: present | absent
```

## Rendered files

| File | Contents |
| --- | --- |
| `~/.config/dotfile-vnext/health/env.d/litellm.env` | `LITELLM_API_KEY` from `vault_k3s_litellm_gateway_master_key` |

Health scripts also accept process env and fallback
`~/.config/dotfile-vnext/mcp/env.d/litellm.env` if present.

## Apply

```bash
ansible-playbook playbooks/mac/homelab_health_secrets.yaml -i inventory/inventory.yaml --limit mac-dev
```

## Verify

```bash
stat -f '%Lp %N' ~/.config/dotfile-vnext/health/env.d/litellm.env
bin/codex-env python3 ~/.codex/skills/homelab-health-matrix/scripts/run_health_matrix.py --repo-root "$PWD"
```
