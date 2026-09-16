---
title: Codex IDE "Permission mode is unavailable" from duplicate config.toml key
document_type: diagnostics
status: reviewed
created_at: "2026-09-15"
identifier: codex-permission-mode-unavailable-2026-09-15
tags:
  - codex
  - diagnostics
  - config.toml
  - permission-mode
---

# Codex IDE: Permission mode is unavailable (2026-09-15)

**Identifier:** `codex-permission-mode-unavailable-2026-09-15`

## Symptom

OpenAI Codex IDE extension (Cursor / VS Code `openai.chatgpt`) shows:

```text
Permission mode is unavailable
```

Composer submit is blocked. This is a UI disable reason, not a model chat reply.

Extension message id: `composer.submit.permissionModeUnavailable`  
Meaning: permissions failed to load or still require a selection.

## Root cause (this incident)

`~/.codex/config.toml` failed to reload:

```text
failed to reload config: /Users/joshc/.codex/config.toml:166:2: duplicate key
```

Evidence (Cursor extension host):

```text
…/exthost/openai.chatgpt/Codex.log
error={"code":-32603,"message":"failed to reload config: …/config.toml:166:2: duplicate key"}
```

Duplicate Ansible-managed block:

```text
# BEGIN ANSIBLE MANAGED BLOCK: macos_shell_locale
[shell_environment_policy]
…
```

First copy lost its `# END ANSIBLE MANAGED BLOCK: macos_shell_locale` marker; a second full copy was appended. TOML forbids redeclaring the same table, so config reload fails and the IDE treats permission mode as unavailable.

Owner role: `roles/codex_user_config` (`macos_shell_locale` via `blockinfile`).

## Fix applied (live home file)

1. Keep a single balanced `macos_shell_locale` managed block.
2. Confirm parse: `python3 -c 'import pathlib,tomllib; tomllib.loads(pathlib.Path.home().joinpath(".codex/config.toml").read_text())'`
3. Reload the Codex panel / Cursor window.

## Do not confuse with

- ChatGPT desktop Settings → Permissions (Full access / Auto-review not enabled)
- Sol Ultra vs Full access coupling (historical IDE issue, different message)
- Auth / subscription problems (different log signatures)

## Prevention in repo

- Role `codex_user_config` validates that `config.toml` parses after managed-block updates and that `macos_shell_locale` BEGIN/END markers are balanced and unique via `scripts/managed_config_integrity.py`.
- README troubleshooting points here.
- Global skill: `client-ui-symptom-local-evidence` (local logs/config before product docs).

## Related

- Role: `roles/codex_user_config/`
- Prior similar thrash: `model-lane-acceptance/.../backup_context_conversation_gemni.md` (duplicate `shell_environment_policy`)
