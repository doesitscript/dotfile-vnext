# continue_ide

Deploys Continue IDE `~/.continue/config.yaml` from
`templates/config.yaml.j2` so Chat, Autocomplete, and Edit use **only LiteLLM
`model@host` routes** via Continue `apiBase` `http://litellm.hom.lab`
(no `/v1` — Continue probes `GET {apiBase}`; `/v1` alone 404s on this gateway).

The **Continue editor extension** (`Continue.continue`) is installed by
`roles/cursor` / `roles/common/vscode` — not by this role.

## Lifecycle

- `continue_ide_state: present|absent` (default `absent`)

## Apply / Verify / Undo

| | |
| --- | --- |
| **Apply** | `ansible-playbook playbooks/deploy_continue_ide.yaml --limit mac-dev` |
| **Verify** | `ansible-playbook playbooks/validate_homelab_local_clients_probes.yaml` |
| **Undo** | `-e continue_ide_state=absent` |
| **Change class** | Idempotent config |

## Functional lanes (2026-09-01)

| Continue role | Display name | LiteLLM `model` | GPU |
| --- | --- | --- | --- |
| Chat | Chat Qwen2.5 Coder 14B | `qwen2.5-coder-14b@k3s02-vllm` | 5090 vLLM AWQ |
| Edit / Apply | Edit Ministral 3 8B | `ministral-3-8b@desktop` | RX 9060 XT Ollama |
| Autocomplete | Autocomplete 1.5B | `qwen2.5-coder-1.5b@hvh01` | GTX 1060 Ollama |

Set `defaultCompletionOptions.contextLength: 32768` and `maxTokens: 4096` on
chat/edit lanes (Continue docs; aligns with vLLM `--max-model-len`).

## Secrets

Uses `vault_k3s_litellm_gateway_master_key` when `continue_ide_api_key` is empty.
