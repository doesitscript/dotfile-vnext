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
| Chat | Qwen3.6-35B-A3B | `qwen3.6-35b-a3b` | 5090 vLLM |
| Edit | qwen2.5-coder:14b | `qwen2.5-coder-14b` | RX 9060 XT Ollama |
| Apply | qwen2.5-coder:7b | `qwen2.5-coder-7b` | RX 9060 XT Ollama |
| Autocomplete | qwen2.5-coder:1.5b-base-q8_0 | `qwen2.5-coder-1.5b-base-q8_0` → Ollama GGUF `:1.5b-base-q8_0` | GTX 1060 |
| Embed | nomic-embed-text | `nomic-embed-text` | GTX 1060 |

### Autocomplete role — FIM (fill-in-the-middle)

For the **autocomplete** role we care about **FIM**, not chat. Tab / ghost-text
must fill the *middle* of the current edit (code above the cursor + code below).
That is why this lane uses the **base** Ollama GGUF tag
`qwen2.5-coder:1.5b-base-q8_0` (not Instruct) and Continue’s **legacy
completions** path (`useLegacyCompletionsEndpoint: true` → LiteLLM
`POST /v1/completions`).

Continue renders this template (see `~/.continue/config.yaml` /
`templates/config.yaml.j2`):

```text
<|fim_prefix|>{{{prefix}}}<|fim_suffix|>{{{suffix}}}<|fim_middle|>
```

That matches the **Modelfile TEMPLATE** on the live Ollama model
(`ollama show qwen2.5-coder:1.5b-base-q8_0`):

```text
{{- if .Suffix }}<|fim_prefix|>{{ .Prompt }}<|fim_suffix|>{{ .Suffix }}<|fim_middle|>{{ else }}{{ .Prompt }}{{ end }}
```

When a suffix is present, Ollama wraps prefix/suffix with the same
`<|fim_*|>` tokens Continue emits. Chat-only success on this id does **not**
prove autocomplete. Acceptance: `FIM completions 200` in
`model-lane-acceptance/gateway/continue-embed-and-fim-atdd.md` and
`docs/plans/2026-09-12-mac_and_model_recommend/smoke-evidence-decode.md`.

#### Other FIM candidates (not commissioned)

Documented for later trials only. Prefer Ollama **GGUF** on HVH-01. Do **not**
flip Continue/LiteLLM to these until FIM is verified:

| Candidate | Why interesting | Notes |
| --- | --- | --- |
| `granite-code:8b` / `granite-code:8b-base` | IBM Granite Code; FIM is part of the training story | Prefer **base** over chat-style tags when available; 8B is tight on 6 GB — use a Q4/Q5 GGUF and confirm VRAM |
| `starcoder2:3b` or `starcoder2:7b` | StarCoder2 is a well-rated FIM / fill-in-the-middle family | Prefer non-`instruct` tags for Tab-complete; `15b` is usually too large for GTX 1060 |

**Verify-if-tried gate (required):**

1. `ollama show <tag>` — TEMPLATE (or docs) must support suffix / FIM tokens
2. LiteLLM `POST /v1/completions` with a FIM-shaped prompt → HTTP **200** + non-empty text
3. Align Continue `promptTemplates.autocomplete` if the model’s FIM tokens are not `<|fim_prefix|>` / `<|fim_suffix|>` / `<|fim_middle|>`

Chat `/v1/chat/completions` alone is **not** proof of autocomplete FIM.

Autocomplete policy:

- `continue_ide_autocomplete_enabled: false` by default → FIM model entry
  `enabled: false` (same generic flag as any other model)
- mac-dev sets `true` so that entry is included in the full-file template
- Template has **no** role-specific omit logic — every `enabled` entry converges
- Local edits/comments in `~/.continue/config.yaml` are overwritten on each
  `present` run (no force flag required)
- keep Mac-local `provider: ollama` out of the gateway path unless a work-laptop
  deviation explicitly documents a local OpenAI-compatible server

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
