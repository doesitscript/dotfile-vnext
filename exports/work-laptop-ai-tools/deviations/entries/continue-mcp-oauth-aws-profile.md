---
id: continue-mcp-oauth-aws-profile
status: accepted
behavior_group: mcp-auth-interactive
title: AWS remote MCP OAuth + AWS IaC profile remain operator interactive
---

## Trigger

- Inbox `2026-09-10-continue-mcp-connection-investigation.md`
- Inbox `2026-09-10-continue-mcp-working-configuration.md` (validated base URL)

## Accommodation

- Continue/Zed AWS MCP URL is the **base** endpoint
  `https://aws-mcp.us-east-1.api.aws/mcp` (no `?oauth=initialize`). Laptop
  `initialize` against the base URL returned `200` + `Mcp-Session-Id`; the
  `?oauth=initialize` form returned a bearer challenge on direct initialize.
- Browser OAuth / SSO may still be required for some tool calls; that remains
  operator-interactive in the client — not a packet secret.
- `aws_iac_mcp_aws_profile` host_var (optional); when set, Continue AWS IaC
  env includes `AWS_PROFILE`. Operator still runs `aws sso login`. Continue
  AWS IaC defaults omit `AWS_REGION` and pin `awslabs.aws-iac-mcp-server@1.0.26`.
- Morph: vault `vault_shared_morph_api_key` + env wrapper (no secrets in git)
- Firebase: `work-laptop-nvm-exec` + pinned `firebase-tools@15.30.0` via
  `firebase mcp` (not `npx @latest`). Auth is `firebase login` — **not** a
  Firebase Web API key
- Do not treat OAuth/SSO as Ansible-presentable without interactive client

## Re-apply

```bash
# After continue apply: complete any AWS OAuth the client still prompts for
# Set aws_iac_mcp_aws_profile in host_vars when a stable profile name exists
aws sso login --profile <name>
# Firebase after nvm-exec starts: firebase login (interactive)
```

## Generalize

| Peer | Same risk? | Action |
| --- | --- | --- |
| Other streamable-http OAuth MCPs | yes | prefer validated base URL; document interactive step |
| Firebase auth | yes | nvm-exec first; then firebase login separately |
