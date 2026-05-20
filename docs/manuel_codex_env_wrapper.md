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

## Standard Entry Point

Use:

```bash
bin/codex-env <command> [args...]
```

Examples:

```bash
bin/codex-env python3 -c 'import sys; print(sys.executable)'
bin/codex-env ansible-playbook --version
bin/codex-env ansible-playbook playbooks/access_windows.yaml -i inventory/inventory.yaml --limit hom-lab-ctl-hvh-02
```

## What The Wrapper Does

`bin/codex-env`:

1. changes to the repo root
2. on macOS, normalizes invalid inherited `C.UTF-8` locale values to `en_US.UTF-8`
3. sources `.envrc` when present
4. activates `.venv/bin/activate` when present
5. `exec`s the requested command

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
repo commands run without that warning.

For Codex specifically, the repo also sets these values in
[.codex/config.toml](/Users/joshc/develop/dotfile-vnext/.codex/config.toml) via
`shell_environment_policy.set` so new Codex subprocesses start with a valid
locale before `bash` launches.

## Maintenance Contract

If the repo changes where it stores project environment state, update
`bin/codex-env` and this document together.
