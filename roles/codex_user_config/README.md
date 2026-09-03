# codex_user_config

Creates a baseline `~/.codex/config.toml` for a user-scoped Codex CLI setup
without touching project-scoped `.codex/config.toml` files.

Default behavior is conservative:

- create the file when it is missing
- leave an existing file alone unless `codex_user_config_force: true`
- always converge the macOS `shell_environment_policy` locale block when
  `codex_user_config_macos_locale_normalize` is true (Darwin default)
- remove the file only when `codex_user_config_state: absent`

## macOS locale note

Homebrew Bash warns when parent runtimes inject `C.UTF-8` or bare `UTF-8`:

```text
bash: warning: setlocale: LC_ALL: cannot change locale (C.UTF-8): No such file or directory
```

This role writes a managed `[shell_environment_policy.set]` block so Codex
shell launches start with `en_US.UTF-8` before bash initializes.

## Apply / Verify / Undo / Change class

- Apply: include the role with `codex_user_config_state: present`
- Verify: inspect `{{ codex_user_config_path }}` for the baseline model /
  approval settings when newly created, and for the
  `ANSIBLE MANAGED BLOCK: macos_shell_locale` marker on Darwin; then run
  `LC_ALL=C.UTF-8 bin/codex-env /usr/local/bin/bash -c 'true'` and confirm no
  setlocale warning from the wrapped child
- Undo: set `codex_user_config_state: absent`, or set
  `codex_user_config_macos_locale_normalize: false` to remove only the locale block
- Change class: idempotent user-scoped config with explicit force overwrite
  for the baseline file; locale block is independently idempotent

## Variables

See `defaults/main.yml` and `meta/argument_specs.yml`.
