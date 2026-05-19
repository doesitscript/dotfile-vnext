# huggingface

Configures the official Hugging Face MCP server for local AI clients.

The upstream server uses streamable HTTP:

```text
https://huggingface.co/mcp
```

Apply:

```bash
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags huggingface
```

What it does:

- verifies the Hugging Face MCP endpoint is reachable
- merges `huggingface` into `.cursor/mcp.json`
- adds `[mcp_servers.huggingface]` to `.codex/config.toml`

Codex may show this server as `Not logged in`. Public documentation search
still works anonymously; Hugging Face login can be added later when account- or
token-scoped tools are needed.

Undo:

```bash
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags huggingface \
  -e huggingface_mcp_state=absent
```

Change class: idempotent MCP client configuration.
