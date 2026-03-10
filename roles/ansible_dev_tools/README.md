# ansible_dev_tools

Installs Ansible development CLI tooling via pipx.

## Tools Installed

| Tool               | macOS (pipx) | Ubuntu (pipx) | Windows (pip) |
|--------------------|--------------|---------------|---------------|
| ansible            | pipx         | pipx          | pip           |
| ansible-builder    | pipx         | pipx          | pip           |
| ansible-lint       | pipx         | pipx          | -             |

On macOS, tools that cannot compile natively (e.g. `ansible-navigator`) are
provided as Docker wrapper functions deployed to `~/.bashrc.d/`.

## venv Installation (All Tools)

All tools are also installable directly into the project venv as an alternative
to pipx. This is the preferred approach if you want a single venv that the
Cursor extension can point to for all tooling.

Dry-run verified against Python 3.14 venv (no conflicts):

```
ansible-navigator   26.1.3
ansible-builder     3.1.1
ansible-lint        26.3.0
ansible-dev-tools   26.2.0  (meta-package: pulls in navigator, builder,
                             lint, molecule, tox-ansible, pytest-ansible)
```

`ansible-dev-tools` is the Red Hat meta-package. Installing it installs
everything above in one step. `community-ansible-dev-tools` does not exist
on PyPI — it is not a real package name.

To install into the venv:

```bash
pip install ansible-navigator ansible-builder ansible-lint ansible-dev-tools
```

Or via the meta-package alone (installs all of the above):

```bash
pip install ansible-dev-tools
```

## Cursor Extension Configuration (redhat.ansible)

The `redhat.ansible` Cursor extension (v26.1.3) bundles its own
`ansible-language-server` at `out/server/src/server.js`. No separate npm
install of `@ansible/ansible-language-server` is required or used.

**Evidence:** `package.json` in the extension uses `"@ansible/ansible-language-server": "workspace:^"` —
a monorepo build-time reference (pnpm workspace protocol). The ALS TypeScript
source is compiled into the extension during the build. It is not a runtime
npm dependency.

The language server reads its toolchain paths from Cursor settings via the
`ansible` configuration section. This is defined in the ALS source at
`packages/ansible-language-server/src/services/settingsManager.ts`.
If a setting is blank or missing, the language server falls back to PATH.
On this machine, `ansible` and `ansible-playbook` are inside the project
venv and are not on the system PATH when Cursor launches — so without
explicit path configuration, all language features (autocomplete, validation,
hover docs, go-to-definition) are silently non-functional.

### Current Path Configuration — Manually Set, Under Test

> **Note:** The toolchain paths below are currently configured by hand in
> `.vscode/settings.json` (project-level) while we validate that the venv
> approach works end-to-end with the Cursor language server. Once confirmed,
> the `ansible_dev_tools` role will manage these settings automatically.
> Node, Python, and all tool paths are explicitly specified — nothing relies
> on system PATH.

The project-level settings file at `.vscode/settings.json` contains:

```json
"ansible.python.activationScript": "${workspaceFolder}/.venv/bin/activate",
"ansible.ansible.path":            "${workspaceFolder}/.venv/bin/ansible",
"ansible.validation.lint.path":    "${workspaceFolder}/.venv/bin/ansible-lint"
```

The user-level fallback (`~/Library/Application Support/Cursor/User/settings.json`)
contains the same paths using absolute values in case the workspace-relative
form is not resolved in a particular Cursor context.

**`ansible.python.activationScript`** — sourced by bash before every ansible
command the language server runs. When set, `ansible.python.interpreterPath`
is ignored (per ALS `settingsManager.ts` description). This is the correct
pattern for venv-based installations: no global Python or ansible needed.

**`ansible.ansible.path`** — path to the `ansible` binary. The ALS default
is the string `"ansible"` (PATH lookup). Must be set explicitly when ansible
lives inside a venv.

**`ansible.validation.lint.path`** — path to `ansible-lint`. Default is
`"ansible-lint"` (PATH lookup). Currently installed at `~/.local/bin/ansible-lint`
via pipx. If ansible-lint is moved into the venv, update this to
`/Users/joshc/develop/dotfile-vnext/.venv/bin/ansible-lint`.

### Portable Alternative (workspace-relative)

The path resolver in the extension (`src/features/utils/interpreterPathResolver.ts`)
supports `${workspaceFolder}` as a variable. This makes settings portable
across machines where the project is checked out to different paths:

```json
"ansible.python.activationScript": "${workspaceFolder}/.venv/bin/activate",
"ansible.ansible.path":            "${workspaceFolder}/.venv/bin/ansible",
"ansible.validation.lint.path":    "~/.local/bin/ansible-lint"
```

This project currently uses the absolute path option above.

## Dependencies

- `common/shell_config` — ensures `~/.bashrc.d` sourcing pattern exists
- `python` — provides pip/pipx

## MCP Server

The Red Hat Ansible Cursor extension MCP server configuration has moved to
`roles/mcp_servers/redhat-ansible`. See that role's README for extension path
detection, environment variables, and version management.
