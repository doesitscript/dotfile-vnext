# Firebase MCP Server

Configures the official Firebase MCP server for repo-local MCP clients on the
controller.

## Upstream

- **Docs:** https://firebase.google.com/docs/ai-assistance/mcp-server
- **CLI docs:** https://firebase.google.com/docs/cli
- **Runtime command:** `npx -y firebase-tools@latest mcp`

## Classification

| Attribute | Value |
|---|---|
| Runtime | Node.js / npm |
| Install Method | configure-only via `npx` |
| Interaction Model | launcher |
| Supported Targets | cursor, vscode, codex |
| Default Targets | cursor generically; mac-dev commissions cursor, codex, vscode |
| Verify Mode | command_smoke_test |

## Authentication

The Firebase MCP server uses the credentials available to the Firebase CLI in
its environment. Upstream currently documents Firebase CLI user login and
Google Application Default Credentials as the supported auth paths for MCP tool
calls. No Firebase MCP-specific paid API-key mode is documented at this time.

This role supports three runtime modes:

1. No auth overrides configured:
   - launch `npx -y firebase-tools@latest mcp` directly
   - rely on the existing free/keyless Firebase CLI environment on the Mac
2. Service-account auth configured:
   - render a local `0600` JSON credentials file
   - launch through `bin/mcp-server-env-wrapper` with `GOOGLE_APPLICATION_CREDENTIALS`
3. Legacy headless token configured:
   - render a local `0600` env file
   - launch through `bin/mcp-server-env-wrapper` with `FIREBASE_TOKEN`

If you prefer interactive login on the controller, complete one of these
outside the role before first use:

- `firebase login`
- `gcloud auth application-default login`

If you want the role to manage the MCP auth artifacts instead, store one of the
following in `vault/mac_dev.vault.yml`:

```yaml
vault_firebase_mcp_service_account_json: ""
vault_firebase_mcp_firebase_token: ""
vault_firebase_mcp_extra_env: {}
```

Precedence is:

1. `vault_firebase_mcp_service_account_json`
2. `vault_firebase_mcp_firebase_token`
3. no auth override

`vault_firebase_mcp_extra_env` is an escape hatch for additional upstream env
variables, but it should not be treated as proof that Firebase MCP supports a
paid API-key auth path.

## Variables

| Variable | Default | Description |
|---|---|---|
| `firebase_mcp_state` | `present` | Ensure the Firebase MCP config is present or absent |
| `firebase_mcp_targets` | `['cursor']` | Client config targets to manage |
| `firebase_mcp_dir` | empty | Optional `--dir` project root for Firebase MCP |
| `firebase_mcp_only` | empty | Optional `--only` feature filter |
| `firebase_mcp_tools` | empty | Optional `--tools` explicit tool list |
| `firebase_mcp_mode` | `stdio` | MCP transport mode; stdio is the default for IDE clients |
| `firebase_mcp_port` | `3000` | SSE port when `firebase_mcp_mode: sse` |
| `firebase_mcp_service_account_json` | empty | Optional service-account JSON rendered locally and used via `GOOGLE_APPLICATION_CREDENTIALS` |
| `firebase_mcp_firebase_token` | empty | Optional legacy CLI token used via `FIREBASE_TOKEN` |
| `firebase_mcp_extra_env` | `{}` | Optional extra runtime env vars passed to the Firebase MCP process |

## Apply / Verify / Undo / Change Class

**Apply:**

```bash
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags firebase
```

**Verify:**

1. Check Cursor config: `.cursor/mcp.json` contains `firebase`
2. Check VS Code config: `.vscode/mcp.json` contains `firebase`
3. Check Codex config: `.codex/config.toml` contains `[mcp_servers.firebase]`
4. If auth overrides are configured, check local artifacts:
   - `~/.config/dotfile-vnext/mcp/env.d/firebase.env`
   - `~/.config/dotfile-vnext/mcp/credentials/firebase-service-account.json`
5. Check command surface: `npx -y firebase-tools@latest mcp --help`
6. Start a fresh IDE/MCP client session before testing tools

**Undo:**

```bash
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags firebase -e firebase_mcp_state=absent
```

**Change Class:** Idempotent controller-local MCP configuration
