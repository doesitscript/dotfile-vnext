# kilo_ide

Deploys **Kilo Code** config at `~/.config/kilo/kilo.jsonc` with a LiteLLM
OpenAI-compatible provider and per-agent model assignments.

| Artifact | Path |
| --- | --- |
| Config | `~/.config/kilo/kilo.jsonc` |
| Legacy (converted then removed) | `~/.config/kilo/config.json` |

## Apply modes

| `kilo_ide_apply_mode` | Behavior |
| --- | --- |
| `merge` (default) | Convert `config.json` → `kilo.jsonc` if needed; merge managed provider/agents/top-level model keys; **preserve** user MCP, custom agents, other providers |
| `overwrite` | Write managed template only (recovery / bootstrap) |

Default agent model map (Continue-aligned):

| Agent | Model |
| --- | --- |
| `code` / `build` / `plan` / `ask` / `general` / `debug` / `orchestrator` | `qwen2.5-coder-32b@k3s02-vllm` |
| `explore` / `title` / `summary` / `compaction` / `small_model` | `qwen2.5-coder-7b@desktop` |

## Lifecycle

- `kilo_ide_state: present|absent` (default `present`)

## Apply / Verify / Undo

| | |
| --- | --- |
| **Apply** | Include role with `kilo_ide_state: present` |
| **Verify** | `jq '.model, (.agent\|keys), (.provider\|keys)' ~/.config/kilo/kilo.jsonc` |
| **Undo** | `kilo_ide_state: absent` |
| **Change class** | Idempotent config (merge by default) |

## Secrets

Uses `vault_k3s_litellm_gateway_master_key` when `kilo_ide_api_key` is empty.
With `kilo_ide_require_api_key: true` (default), present runs fail on the
placeholder.
