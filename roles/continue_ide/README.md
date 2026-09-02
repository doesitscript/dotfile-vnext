# continue_ide

Deploys Continue IDE `~/.continue/config.yaml` from
`templates/config.yaml.j2` so Chat and Edit use **only LiteLLM
`model@host` routes** via Continue `apiBase` `http://litellm.hom.lab`
(no `/v1` — Continue probes `GET {apiBase}`; `/v1` alone 404s on this gateway).

Remote autocomplete is intentionally disabled by default as of `2026-09-02`
because remote autocomplete lanes have been observed to destabilize editors and
remote inference backends. Only re-enable autocomplete with a deliberately
local-only model on the client machine after explicit validation.

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

## Functional lanes (2026-09-02)

| Continue role | Display name | LiteLLM `model` | GPU |
| --- | --- | --- | --- |
| Chat | Chat Qwen2.5 Coder 32B | `qwen2.5-coder-32b@k3s02-vllm` | 5090 vLLM AWQ |
| Edit / Apply | Edit Qwen2.5 Coder 7B | `qwen2.5-coder-7b@desktop` | RX 9060 XT Ollama |

Autocomplete policy:

- `continue_ide_autocomplete_enabled: false` by default
- keep remote autocomplete lanes out of the rendered config
- if a future local-only autocomplete lane is proven stable on the client Mac,
  enable it explicitly and document the exact local model/runtime

Set `defaultCompletionOptions.contextLength: 32768` and `maxTokens: 4096` on
chat/edit lanes (Continue docs; aligns with vLLM `--max-model-len`).

## Secrets

Uses `vault_k3s_litellm_gateway_master_key` when `continue_ide_api_key` is empty.
