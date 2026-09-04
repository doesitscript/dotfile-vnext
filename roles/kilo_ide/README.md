# kilo_ide

Deploys **Kilo Code** config at `~/.config/kilo/kilo.jsonc` (overwrite,
idempotent) with a LiteLLM OpenAI-compatible provider and per-agent model
assignments.

| Artifact | Path |
| --- | --- |
| Config | `~/.config/kilo/kilo.jsonc` |
| Legacy (removed on present) | `~/.config/kilo/config.json` |

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
| **Verify** | `jq '.model,.agent \| keys' ~/.config/kilo/kilo.jsonc` |
| **Undo** | `kilo_ide_state: absent` |
| **Change class** | Idempotent config (full overwrite of kilo.jsonc) |

## Secrets

Uses `vault_k3s_litellm_gateway_master_key` when `kilo_ide_api_key` is empty.
With `kilo_ide_require_api_key: true` (default), present runs fail on the
placeholder.
