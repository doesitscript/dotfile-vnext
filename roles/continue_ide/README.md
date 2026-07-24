# continue_ide

Deploys Continue IDE `~/.continue/config.yaml` from
`templates/config.yaml.j2` so Chat, Autocomplete, and Edit use **only LiteLLM
aliases that are live** via Continue `apiBase` `http://litellm.hom.lab`
(no `/v1` — Continue probes `GET {apiBase}`; `/v1` alone 404s on this gateway).

The **Continue editor extension** (`Continue.continue`) is installed by
`roles/cursor` / `roles/common/vscode` via their extension lists — not by this
role. This role owns config only.

Do not hand-edit `~/.continue/config.yaml`. Change role defaults / host_vars
and re-run the playbook.

## Lifecycle

- `continue_ide_state: present|absent` (default `absent`)

## Apply / Verify / Undo

| | |
| --- | --- |
| **Apply** | `ansible-playbook playbooks/deploy_continue_ide.yaml --limit mac-dev` (or `deploy_development_nodes.yaml --tags continue_ide`) |
| **Verify** | `GET http://litellm.hom.lab/` → 200; each `model:` in `continue_ide_models` returns 200 from `/chat/completions` (or `/v1/chat/completions`) |
| **Undo** | `-e continue_ide_state=absent` |
| **Change class** | Idempotent config |

## Inventory knobs

Desired Continue shape for mac-dev is in `inventory/host_vars/mac-dev.yaml`.
Role defaults are the fallback when a host does not override.

| Variable | Purpose |
| --- | --- |
| `continue_ide_state` | `present` / `absent` |
| `continue_ide_gateway_api_base` | Shared `apiBase` (default host root, no `/v1`) |
| `continue_ide_config_name` / `_version` / `_schema` | Top-level Continue config fields |
| `continue_ide_provider` | Default provider (`openai`) |
| `continue_ide_models` | List of `{name, model, roles[, provider, api_base]}` |
| `continue_ide_blocked_lanes` | Comment-only notes for not-yet-commissioned lanes |
| `continue_ide_api_key` | Optional override; else vault `vault_k3s_litellm_gateway_master_key` |

## Functional lanes (commissioned)

| Continue UI role | Display name | LiteLLM `model` | Backend |
| --- | --- | --- | --- |
| Chat | Chat Ornith (local vLLM) | `deepreinforce-ai/Ornith-1.0-35B-GGUF` | vLLM on k3s-02 |
| Autocomplete | Autocomplete Qwen2.5-Coder 1.5B | `code-autocomplete-1.5b` | Ollama on HVH-01 GTX 1060 |
| Edit / Apply | Edit Ornith (local vLLM) | `deepreinforce-ai/Ornith-1.0-35B-GGUF` | vLLM on k3s-02 |

## Not in Continue config until commissioned

| Alias | Why blocked |
| --- | --- |
| `code-autocomplete-7b` | Too large for GTX 1060 autocomplete sidecar |
| `qwen3-coder-30b` | No local serve + LiteLLM route yet |
| `diffucoder` / DiffuCoder `continue-edit` | Apple `diffusion_generate` is not OpenAI chat-native; needs a wrapper before LiteLLM |
| `diffusiongemma-nextedit` | Weights cataloged; vLLM serve not commissioned |

## Secrets

Uses `vault_k3s_litellm_gateway_master_key` when `continue_ide_api_key` is empty.
Do not paste upstream provider keys into Continue — keep them on the gateway.
