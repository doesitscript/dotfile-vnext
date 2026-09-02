# codex_user_config

Creates a baseline `~/.codex/config.toml` for a user-scoped Codex CLI setup
without touching project-scoped `.codex/config.toml` files.

Default behavior is conservative:

- create the file when it is missing
- leave an existing file alone unless `codex_user_config_force: true`
- remove the file only when `codex_user_config_state: absent`

## Apply / Verify / Undo / Change class

- Apply: include the role with `codex_user_config_state: present`
- Verify: inspect `{{ codex_user_config_path }}` and confirm the baseline model,
  approval, features, and desktop settings are present
- Undo: set `codex_user_config_state: absent`
- Change class: idempotent user-scoped config with explicit force overwrite

## Variables

See `defaults/main.yml` and `meta/argument_specs.yml`.
