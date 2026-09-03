# zed_ide

Optionally installs Zed on macOS (Homebrew cask) and manages a Zed AI
configuration that points agent features at the homelab LiteLLM gateway.

Set `zed_ide_install_cask: false` when Zed is already installed and should not
be installed or upgraded by this role (config + launcher only). The work-laptop
export packet uses that mode.

Remote autocomplete-style behavior is intentionally disabled by default as of
`2026-09-02`. In this role, that means `zed_ide_edit_predictions_enabled:
false` unless a deliberately local-only model on the client Mac is chosen and
validated first.

This role owns:

- `~/.config/zed/settings.json`
- `~/.config/zed/openai.env`
- `~/.local/bin/zed-homelab`

The managed launcher is the non-interactive path for supplying
`OPENAI_API_KEY` from Ansible-managed local state. If you later save the key in
Zed's provider UI, Zed stores it in the system keychain and the normal app
launch path also works.

## Lifecycle

- `zed_ide_state: present|absent` (default `absent`)

## Apply / Verify / Undo

| | |
| --- | --- |
| **Apply** | Include the role with `zed_ide_state: present`, or run the work-laptop export packet |
| **Verify** | Inspect `~/.config/zed/settings.json`, `~/.config/zed/openai.env`, and `~/.local/bin/zed-homelab` |
| **Undo** | Set `zed_ide_state: absent` |
| **Change class** | Idempotent config |

## Notes

- Zed settings live at `~/.config/zed/settings.json` per upstream docs.
- Zed AI provider keys must not be stored in `settings.json`.
- The work-laptop export packet intentionally ships
  `REPLACE_WITH_LITELLM_KEY` instead of a real gateway secret.
- Keep `edit_predictions` local-only if they are ever re-enabled. Do not point
  them at remote Ollama, LiteLLM, or vLLM infrastructure.
