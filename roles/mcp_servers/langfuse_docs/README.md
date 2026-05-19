# langfuse_docs

Configures the public Langfuse Docs MCP server for local AI clients.

The upstream docs server is unauthenticated and uses streamable HTTP:

```text
https://langfuse.com/api/mcp
```

Apply:

```bash
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags langfuse-docs
```

What it does:

- verifies the Langfuse Docs MCP endpoint is reachable
- merges `langfuse-docs` into `.cursor/mcp.json`
- adds `[mcp_servers.langfuse-docs]` to `.codex/config.toml`

Undo:

```bash
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags langfuse-docs \
  -e langfuse_docs_mcp_state=absent
```

Change class: idempotent MCP client configuration.
