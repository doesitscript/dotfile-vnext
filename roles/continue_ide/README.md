# continue_ide

Deploys Continue IDE `~/.continue/config.yaml` from
`templates/config.yaml.j2` so Chat and Edit use **only LiteLLM
`model@host` routes** via Continue `apiBase` `http://litellm.hom.lab`
(no `/v1` — Continue probes `GET {apiBase}`; `/v1` alone 404s on this gateway).

Remote autocomplete is intentionally disabled by default as of `2026-09-02`
because remote autocomplete lanes have been observed to destabilize editors and
remote inference backends. Only re-enable autocomplete with a deliberately
local OpenAI-compatible server on the client Mac (e.g. Jan) after explicit
validation — never `provider: ollama` against a Jan GGUF model id.

**Morph WarpGrep (evaluation):** When `continue_ide_mcp_servers` includes
`morph-mcp` (see `inventory/host_vars/mac-dev.yaml`), Continue Agent mode can
call `codebase_search`. Steering rule:
`.continue/rules/morph-warpgrep-evaluation.md` (deployed by `roles/mcp_servers/morph`).

**stdio MCP gotcha:** Continue requires `command` on every `type: stdio`
entry. If `command`/`cwd` use `{{ dotfiles_home }}` and that var is undefined
(common when `group_vars/all/` shadows `all.yaml` and a standalone playbook
omits the var), Continue fails to load the **entire** `config.yaml`. Prefer
HOME-anchored absolute paths for MCP command/cwd, keep
`inventory/group_vars/all/dotfiles_home.yml`, and set `dotfiles_home` on
`playbooks/deploy_continue_ide.yaml`.

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

## Functional lanes (2026-09-12)

| Continue role | Display name | LiteLLM `model` | GPU |
| --- | --- | --- | --- |
| Chat | Chat Qwen3.6-35B-A3B | `qwen3.6-35b-a3b` | 5090 vLLM |
| Edit | Edit Qwen2.5 Coder 14B | `qwen2.5-coder-14b@desktop` | RX 9060 XT Ollama |
| Apply | Apply Qwen2.5 Coder 7B | `qwen2.5-coder-7b@desktop` | RX 9060 XT Ollama |
| Autocomplete | Autocomplete 1.5B-base | `qwen2.5-coder-1.5b@hvh01` → Ollama `:1.5b-base` | GTX 1060 |
| Embed | nomic-embed-text | `nomic-embed-text@hvh01` | GTX 1060 |

Autocomplete policy:

- `continue_ide_autocomplete_enabled: false` by default
- mac-dev may set `true` for HVH-01 FIM via LiteLLM (plan 2026-09-12)
- keep Mac-local `provider: ollama` out of this path; gateway `model@host` only

## Work-laptop local Ollama section

First iteration of
`docs/brainstorming_designs/2026-09-09--continue-mac-local-model-patterns`.
This role does not download weights. The human runs the helper scripts, then
this role writes only the marked block `continue-ollama-local` for the plan
roles (autocomplete, embed, edit, apply). Other models, MCP, and rules stay
as they were.

**Direction (2026-09-09):** prefer Docker Model Runner
(`exports/work-laptop-ai-tools/DOCKER-MODEL-RUNNER.md`). DMR Ansible
automation is **disabled** until commissioned — do not add a DMR managed
block here yet. Legacy share/rsync helpers remain under
`exports/work-laptop-ai-tools/helpers/work-mac-local-models/`.

Set `defaultCompletionOptions.contextLength: 32768` and `maxTokens: 4096` on
chat/edit lanes (Continue docs; aligns with vLLM `--max-model-len`).

## Secrets

Uses `vault_k3s_litellm_gateway_master_key` when `continue_ide_api_key` is empty.
