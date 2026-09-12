# cline_ide

Deploys Cline global config under `~/.cline/` so the VS Code extension and
CLI use **LiteLLM OpenAI Compatible** lanes (same gateway as Continue/Zed).

| Artifact | Path |
| --- | --- |
| Providers | `~/.cline/data/settings/providers.json` |
| Model catalog | `~/.cline/data/settings/models.json` |
| MCP (IDE) | `~/.cline/data/settings/cline_mcp_settings.json` |
| MCP (CLI) | `~/.cline/mcp.json` |
| Legacy VS Code keys | `~/Library/Application Support/Code/User/settings.json` (`cline.*`) |

Cline `baseUrl` **includes `/v1`**. Continue `apiBase` intentionally omits it.

`cline_ide_models` populates `models.json` and sets the default model in
`providers.json`. Optional per-model `temperature` / `top_p` (defaults
`0.7` / `0.8` for Qwen3-Coder card alignment) are written into the catalog.
With `cline_ide_providers_merge: true` (default), other provider entries
(e.g. Cline cloud auth) are preserved.

The **Cline extension** (`saoudrizwan.claude-dev`) is installed by
`roles/common/vscode` — not by this role. The **Cline CLI** reads the same
`~/.cline/` tree (including `mcp.json`).

## Apply on mac-dev

```bash
ansible-playbook playbooks/deploy_cline_ide.yaml --limit mac-dev
# or
ansible-playbook playbooks/deploy_development_nodes.yaml --tags cline_ide --limit mac-dev
```

## Lifecycle

- `cline_ide_state: present|absent` (default `absent`)

## Apply / Verify / Undo

| | |
| --- | --- |
| **Apply** | Include role with `cline_ide_state: present` |
| **Verify** | `test -s ~/.cline/data/settings/providers.json` and `models.json`; open Cline → OpenAI Compatible |
| **Undo** | `cline_ide_state: absent` |
| **Change class** | Idempotent config |

## Secrets

Uses `vault_k3s_litellm_gateway_master_key` when `cline_ide_api_key` is empty.
With `cline_ide_require_api_key: true` (default), present runs fail on the
placeholder instead of shipping an empty-looking Cline UI.
