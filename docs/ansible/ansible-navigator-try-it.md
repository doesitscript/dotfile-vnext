# ansible-navigator: Try It

`ansible-navigator` is already available in this repo through
[`ansible_dev_tools`](/Users/joshc/develop/dotfile-vnext/roles/ansible_dev_tools/README.md).
It is an optional controller-side UX tool, not the main execution path.

## What it is

`ansible-navigator` is a terminal-based interface for working with Ansible.
For this repo, the two useful first-pass modes are:

- `--mode stdout`: CLI-style output that is easy to scan and copy
- default interactive mode: a TUI for exploring results in the terminal

It is not a desktop application, and this repo does not treat it as a
replacement for native `ansible-playbook`.

## Why it is already present here

This repo installs the Ansible development toolchain into the project `.venv`
through [`ansible_dev_tools`](/Users/joshc/develop/dotfile-vnext/roles/ansible_dev_tools/README.md).
That includes `ansible-navigator`.

The normal default remains:

```bash
.venv/bin/ansible-playbook ...
```

Navigator is here as a low-commitment exploration path when you want a little
more terminal UX without restructuring the project around it.

## Why start with `--ee false`

For this repo, start with:

```bash
--ee false
```

That keeps navigator on the same local-first path as the project `.venv`
toolchain instead of immediately adding execution-environment/container
behavior into the mix. It is the least surprising first pass.

Execution environments are still available later if navigator turns out to be
useful enough to justify more project surface area.

## Known-good repo examples

Inspect navigator settings:

```bash
.venv/bin/ansible-navigator settings --mode stdout --ee false
```

Inspect the full repo inventory:

```bash
.venv/bin/ansible-navigator inventory --list -i inventory/inventory.yaml --mode stdout --ee false
```

Inspect one host from inventory:

```bash
.venv/bin/ansible-navigator inventory -i inventory/inventory.yaml --host server-225-win --mode stdout --ee false
```

This is useful when you want to answer questions like:

- what connection method does this host use?
- which port, user, or SSH/WinRM settings are active?
- which host vars are shaping the target right now?

Be careful: host inspection can print sensitive values if they are present in
inventory or resolved variables.

Inspect a focused local controller playbook in stdout mode:

```bash
.venv/bin/ansible-navigator run playbooks/mac/ansible_dev_tools.yaml -i inventory/inventory.yaml --limit mac-dev --mode stdout --ee false
```

That is a good first pass when you want to see how navigator presents a small,
controller-side playbook before using it on broader infrastructure.

Inspect a real repo playbook in stdout mode:

```bash
.venv/bin/ansible-navigator run playbooks/deploy_development_nodes.yaml -i inventory/inventory.yaml --limit mac-dev --mode stdout --ee false
```

That is useful when you want a playbook-oriented view of a real repo workflow
without switching the project away from native `ansible-playbook`.

Try the interactive terminal UI:

```bash
.venv/bin/ansible-navigator run playbooks/deploy_development_nodes.yaml -i inventory/inventory.yaml --limit mac-dev --ee false
```

Use the interactive mode when you want to browse task results, host outcomes,
or other execution details from inside the terminal instead of reading a plain
stdout stream.

## Suggested first scenarios

If you are just learning what navigator adds, these are the best first uses in
this repo:

1. Check settings to see how navigator is currently configured.
2. Inspect one host with `inventory --host ...` to understand what Ansible
   thinks is true for that target.
3. Run one focused local playbook in `stdout` mode to see the UX without a lot
   of unrelated output.
4. Try one interactive run once the stdout view makes sense.

## Current stance in this repo

- native `ansible-playbook` remains the preferred execution path
- `ansible-navigator` is optional
- `stdout` mode is the recommended first exploration path
- local-first execution with `--ee false` is the recommended default
