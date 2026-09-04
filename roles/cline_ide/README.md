# cline_ide

Deploys Cline global config under `~/.cline/` so the VS Code extension and
CLI use **LiteLLM OpenAI Compatible** lanes (same gateway as Continue/Zed).

| Artifact | Path |
| --- | --- |
| Providers | `~/.cline/data/settings/providers.json` |
| MCP (IDE) | `~/.cline/data/settings/cline_mcp_settings.json` |
| MCP (CLI) | `~/.cline/mcp.json` |
| Legacy VS Code keys | `~/Library/Application Support/Code/User/settings.json` (`cline.*`) |

Cline `baseUrl` **includes `/v1`**. Continue `apiBase` intentionally omits it.

The **Cline extension** (`saoudrizwan.claude-dev`) is installed by
`roles/common/vscode` — not by this role.

## Lifecycle

- `cline_ide_state: present|absent` (default `absent`)

## Apply / Verify / Undo

| | |
| --- | --- |
| **Apply** | Include role with `cline_ide_state: present` |
| **Verify** | `test -s ~/.cline/data/settings/providers.json` and open Cline → OpenAI Compatible |
| **Undo** | `cline_ide_state: absent` |
| **Change class** | Idempotent config |

## Secrets

Uses `vault_k3s_litellm_gateway_master_key` when `cline_ide_api_key` is empty.
With `cline_ide_require_api_key: true` (default), present runs fail on the
placeholder instead of shipping an empty-looking Cline UI.
