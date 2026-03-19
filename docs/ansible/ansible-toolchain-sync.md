# Ansible toolchain sync on macOS

This note captures a specific failure mode we hit while testing Windows-targeted
playbooks from the Mac controller.

## Problem

The machine had two usable Ansible entrypoints:

- a global one on `PATH` under `~/.local/bin`
- a project-local one under `.venv/bin`

They were not equivalent. The project `.venv` had the required WinRM Python
dependencies (`pywinrm`, `requests`, related packages), while the global
toolchain did not.

Result:

- `ansible-playbook` from `PATH` failed before connecting to Windows
- `.venv/bin/ansible-playbook` succeeded against the same target

This is toolchain drift, not playbook drift.

## Short fix

On macOS, treat the project `.venv` as the source of truth for Ansible and
publish that same toolchain into `~/.local/bin`.

That gives us:

- one effective Ansible install
- global command discoverability for shells, editors, MCP servers, and agents
- repo runs that use the same Python dependencies every time

## Role direction

`roles/ansible_dev_tools` should handle this by:

- installing Ansible dev tools into the project `.venv`
- removing duplicate `pipx` installs of `ansible`, `ansible-lint`, and
  `ansible-builder` on macOS
- symlinking key Ansible CLI binaries from `.venv/bin/` into `~/.local/bin`

This is narrower and safer than globally prepending `.venv/bin` in shell
startup files.
