# huggingface

Configures the official Hugging Face MCP server for local AI clients.

The upstream server uses streamable HTTP:

```text
https://huggingface.co/mcp?login
```

Apply:

```bash
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags huggingface
```

What it does:

- verifies the Hugging Face MCP endpoint is reachable
- merges `hf-mcp-server` into `.cursor/mcp.json`
- adds `[mcp_servers.hf-mcp-server]` to `.codex/config.toml`
- removes the older repo-managed `huggingface` MCP entry if present

## Authentication

No API key is required for the default config. The `?login` URL asks the
Hugging Face MCP server to expose an OAuth login flow through the client.

Cursor supports this remote MCP config shape directly:

```json
{
  "mcpServers": {
    "hf-mcp-server": {
      "url": "https://huggingface.co/mcp?login"
    }
  }
}
```

After applying the role, reload Cursor. On first use, Cursor should prompt for
Hugging Face OAuth login. No bearer token belongs in the repo-managed config for
this default path.

Codex stores the same server as:

```toml
[mcp_servers.hf-mcp-server]
url = "https://huggingface.co/mcp?login"
required = false
```

After applying the role, verify the Codex entry with:

```bash
codex mcp get hf-mcp-server --json
```

If account-scoped Hugging Face tools are needed, start the OAuth flow with:

```bash
codex mcp login hf-mcp-server
```

Codex may show this server as `Not logged in` until OAuth completes. Public
documentation search may still work anonymously, while account-scoped tools may
require login.

## Token Fallback Context

Do not implement token auth by default. Keep the role on OAuth-first config
unless the OAuth flow fails or Codex cannot see tools for the HTTP server.

If OAuth fails in Cursor, the manual fallback is a non-login URL plus an
Authorization bearer header in the client config. That token should be treated
as local secret material, not committed to this repo.

If OAuth fails in Codex, the manual fallback is:

```bash
export HF_TOKEN="hf_xxxxxxxxxxxxxxxxxxxxxxxx"
codex mcp add hf-mcp-server --url "https://huggingface.co/mcp" --bearer-token-env-var HF_TOKEN
```

Equivalent direct Codex config shape:

```toml
[mcp_servers.hf-mcp-server]
url = "https://huggingface.co/mcp"
bearer_token_env_var = "HF_TOKEN"
enabled = true
```

This fallback is intentionally documentation-only for now. The role does not
manage `HF_TOKEN`, bearer-token headers, or alternate auth paths.

Known caveat: Codex CLI has active reports where some Streamable HTTP MCP
servers add successfully but expose no tools. If that happens here, verify the
same server in Cursor first, then consider the token fallback or a local
transport bridge.

Undo:

```bash
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags huggingface \
  -e huggingface_mcp_state=absent
```

Change class: idempotent MCP client configuration.
