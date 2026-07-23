# continue_ide

Deploys Continue IDE `~/.continue/config.yaml` so Chat, Autocomplete, and Edit
use **only LiteLLM aliases that are live** at `http://litellm.hom.lab/v1`.

## Lifecycle

- `continue_ide_state: present|absent` (default `absent`)

## Apply / Verify / Undo

| | |
| --- | --- |
| **Apply** | `ansible-playbook playbooks/deploy_development_nodes.yaml --tags continue_ide --limit mac-dev` |
| **Verify** | Each `model:` in config returns 200 from LiteLLM `/v1/chat/completions` |
| **Undo** | `-e continue_ide_state=absent` |
| **Change class** | Idempotent config |

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
