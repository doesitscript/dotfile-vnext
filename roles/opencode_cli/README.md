# opencode_cli

Install [OpenCode](https://opencode.ai/install) on macOS and render
`~/.config/opencode/opencode.jsonc` for homelab LiteLLM (`model@host` routes).

## Lifecycle

- `opencode_cli_state: present|absent` (default `absent`)

## Apply / Verify / Undo

| | |
| --- | --- |
| **Apply** | `ansible-playbook playbooks/deploy_opencode_cli.yaml --limit mac-dev` |
| **Verify** | `opencode --version`; `opencode run -m homelab-litellm/ministral-3-8b@desktop "reply ok"` |
| **Undo** | `-e opencode_cli_state=absent` |
| **Change class** | Config idempotent; binary install is bootstrap |

## Secrets

API key via `{env:LITELLM_API_KEY}` — source from
`~/.config/dotfile-vnext/health/env.d/litellm.env` (`homelab_health_secrets` role).

## PATH

Binary installs to `~/.opencode/bin`. Ensure it is on PATH (installer or shell config).
