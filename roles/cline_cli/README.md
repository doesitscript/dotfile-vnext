# cline_cli

Install the [Cline](https://cline.bot/cli) terminal CLI (`npm i -g cline`) on
macOS via nvm Node **22+** (default Node **24**).

Homelab LiteLLM **models**, **provider**, and **MCP** are owned by
[`cline_ide`](../cline_ide/README.md) under `~/.cline` (same surfaces the CLI
reads):

| Surface | Path |
| --- | --- |
| Providers | `~/.cline/data/settings/providers.json` |
| Models | `~/.cline/data/settings/models.json` |
| MCP (CLI) | `~/.cline/mcp.json` |

## Lifecycle

- `cline_cli_state: present|absent` (default `absent`)

Commission with `cline_ide_state: present` and mirror MCP:

```yaml
cline_ide_mcp_servers: "{{ continue_ide_mcp_servers }}"
cline_cli_state: present
```

## Apply / Verify / Undo

| | |
| --- | --- |
| **Apply** | `ansible-playbook playbooks/deploy_development_nodes.yaml --limit mac-dev --tags cline_cli,cline_ide` |
| **Verify** | `cline --version`; `cline config`; `cline "Reply with exactly: OK" -m qwen3.6-35b-a3b -P openai-compatible --auto-approve true --json` |
| **Undo** | `-e cline_cli_state=absent` (does not delete `~/.cline` config) |
| **Change class** | Binary bootstrap (npm); config idempotent via `cline_ide` |

## PATH

Global install lands in
`~/.nvm/versions/node/v<ver>/bin/cline`. When
`cline_cli_link_to_local_bin: true` (default), a symlink is created at
`~/.local/bin/cline`.

## Work-laptop transform

Packet host_vars may pin `cline_cli_node_version` to the laptop's nvm Node
major. MCP command paths stay in `continue_ide_mcp_servers` /
`work_laptop_nvm_exec` as today.
