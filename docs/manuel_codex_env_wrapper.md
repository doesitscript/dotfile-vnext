# Manual Codex Env Wrapper

This note documents the repo-local wrapper used to make Codex and other
non-interactive shell runtimes enter the correct project environment.

## Purpose

Some automation runtimes start `bash` as a non-login, non-interactive shell.
When that happens, they do not automatically load:

- `~/.bash_profile`
- `~/.bashrc`
- the `direnv` hook from `~/.bashrc.d/direnv.bash`
- the repo's `.envrc`

That can leave the runtime without:

- WinRM-required environment variables from `.envrc`
- the project Python virtual environment from `.venv`

The result is intermittent "works in my terminal, fails in the agent" behavior.
It can also leak a macOS-only temp path into `ANSIBLE_REMOTE_TEMP`, which
breaks remote Linux hosts with `/private/tmp/...` temp-dir failures.

## Standard Entry Point

Use:

```bash
bin/codex-env <command> [args...]
```

Examples:

```bash
bin/codex-env python3 -c 'import sys; print(sys.executable)'
bin/codex-env ansible-playbook --version
bin/codex-env ansible-playbook playbooks/access_windows.yaml -i inventory/inventory.yaml --limit HOM-LAB-HVH-02
```

## What The Wrapper Does

`bin/codex-env`:

1. is interpreted by macOS system `/bin/bash` (not Homebrew Bash), so the
   wrapper itself does not emit setlocale warnings when parents inject
   `C.UTF-8` / bare `UTF-8`
2. changes to the repo root
3. on macOS, normalizes invalid inherited `C.UTF-8` / `UTF-8` locale values to
   `en_US.UTF-8`
4. sources `.envrc` when present
5. sources `bin/load-netbox-controller-env.sh` when present
6. activates `.venv/bin/activate` when present
7. for `ansible*` commands on macOS, defaults controller temp paths under
   `/private/tmp`
8. for `ansible*` commands on macOS, drops inherited controller-only
   `ANSIBLE_REMOTE_TEMP` values such as `/private/tmp/...` or `/var/folders/...`
9. `exec`s the requested command

This makes the environment explicit instead of depending on shell startup mode.

## When To Use It

Use `bin/codex-env` for repo-local commands that depend on:

- Python interpreter selection
- Ansible from the project `.venv`
- WinRM/macOS environment variables from `.envrc`
- predictable behavior in agent, editor, MCP, or other non-interactive shells

Typical examples:

- `python`
- `python3`
- `pip`
- `ansible`
- `ansible-playbook`
- `ansible-lint`

## Relationship To Existing Tools

- `bin/fz` already sources `.envrc` as part of its own startup path.
- `bin/run-playbook.sh` already hard-pins `.venv/bin/ansible-playbook`.
- `bin/codex-env` is the generic wrapper for cases where a command would
  otherwise rely on ambient shell state.

## Why Not Rely On Interactive Shells

Forcing login or interactive shell startup can help, but it is not the main
solution because it can introduce prompt, alias, completion, and shell-hook
side effects. The wrapper is narrower and more predictable.

## Locale Note

Some agent or editor runtimes inherit:

```bash
LANG=C.UTF-8
LC_CTYPE=C.UTF-8
LC_ALL=C.UTF-8
```

On this macOS machine, `C.UTF-8` is not an available locale, which causes:

```text
bash: warning: setlocale: LC_ALL: cannot change locale (C.UTF-8): No such file or directory
```

`bin/codex-env` normalizes those inherited values to `en_US.UTF-8` on macOS so
repo commands run without that warning. It also normalizes bare `UTF-8` /
`utf-8` values (Apple Terminal style) that Homebrew Bash rejects when set as
`LC_ALL`.

Complementary owner surfaces:

- project `.codex/config.toml` and user `~/.codex/config.toml`
  `shell_environment_policy.set` (role `codex_user_config`)
- Cursor `terminal.integrated.env.osx` locale keys (role `cursor`)
- interactive `~/.bashrc.d/00-macos-locale.bash` (role `common/shell_config`)

## Ansible Temp Path Note

For `ansible`, `ansible-playbook`, and similar commands on macOS, the wrapper
also protects the controller/remote temp split:

- controller temp files belong under macOS paths such as `/private/tmp`
- remote temp files must use a path valid on the remote host OS

So `bin/codex-env` now:

- defaults `TMPDIR` to `/private/tmp` when unset
- defaults `ANSIBLE_LOCAL_TEMP` to `/private/tmp/ansible-local` when unset
- unsets inherited `ANSIBLE_REMOTE_TEMP` values that point at macOS-only
  controller paths

This is intentionally narrow. It hardens the controller-side environment
without forcing one remote temp path onto Linux and Windows targets alike.

For Codex specifically, the repo also sets these values in
[.codex/config.toml](/Users/joshc/develop/dotfile-vnext/.codex/config.toml) via
`shell_environment_policy.set` so new Codex subprocesses start with a valid
locale before `bash` launches.

## Maintenance Contract

If the repo changes where it stores project environment state, update
`bin/codex-env` and this document together.
