---
id: continue-mcp-oauth-aws-profile
status: accepted
behavior_group: mcp-auth-interactive
title: AWS remote MCP OAuth + AWS IaC profile remain operator interactive
---

## Trigger

- Inbox `2026-09-10-continue-mcp-connection-investigation.md`
- AWS MCP URL reachable; `initialize` returns `401` Bearer (expected)
- AWS IaC `uvx` starts; no profile selected in config
- Morph starts; remaining Morph auth is vault env (not npm)

## Accommodation

- Keep AWS MCP `streamable-http` URL with `oauth=initialize` — Continue must
  complete browser OAuth; not a packet URL bug
- `aws_iac_mcp_aws_profile` host_var (optional); when set, Continue AWS IaC
  env includes `AWS_PROFILE`. Operator still runs `aws sso login`
- Morph: vault `vault_shared_morph_api_key` + env wrapper (no secrets in git)
- Do not treat OAuth/SSO as Ansible-presentable without interactive client

## Re-apply

```bash
# After continue apply: complete AWS OAuth once in Continue UI
# Set aws_iac_mcp_aws_profile in host_vars when a stable profile name exists
aws sso login --profile <name>
```

## Generalize

| Peer | Same risk? | Action |
| --- | --- | --- |
| Other streamable-http OAuth MCPs | yes | document interactive step; do not fake tokens in git |
| Firebase auth | yes | nvm-exec first; then firebase login separately |
