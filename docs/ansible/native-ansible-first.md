# Native Ansible First

This repo should prefer native Ansible execution patterns over custom shell
wrappers whenever the work can be expressed clearly with playbooks, roles,
inventory, and normal `ansible-playbook` commands.

This preference does not exclude `ansible-navigator`. In this repo, navigator
is an optional terminal UX layer for exploration and inspection. It does not
replace the native `ansible-playbook` path as the default execution model.

## Preferred shape

- use focused playbooks with clear intent
- run them with explicit `ansible-playbook` commands
- keep inventory, tags, and role boundaries visible
- use `bin/fz` only where it still adds real value that native Ansible is not
  yet expressing cleanly

## Current direction

The immediate de-emphasis targets are:

- `./bin/fz role-local`
- broad local umbrella playbooks when a focused playbook is clearer
- opaque deploy-style wrapper commands that hide which playbooks actually run

## Current exception

`./bin/fz bootstrap` still exists as a legacy orchestration wrapper for bootstrap
flow and repo environment setup. It should be treated as transitional, not as
the preferred long-term execution model for normal Ansible work.

## First concrete replacement

For converging Ansible developer tooling on the Mac controller, prefer:

```bash
.venv/bin/ansible-playbook playbooks/mac/ansible_dev_tools.yaml \
  -i inventory/inventory.yaml --limit mac-dev
```

instead of:

```bash
./bin/fz role-local ansible_dev_tools
```

If you want to try navigator without changing the repo's default execution
model, start with:

```bash
.venv/bin/ansible-navigator settings --mode stdout --ee false
```

See [docs/ansible/ansible-navigator-try-it.md](/Users/joshc/develop/dotfile-vnext/docs/ansible/ansible-navigator-try-it.md)
for the low-commitment exploration path.

## Quality gate

For direct Ansible validation work in this repo, prefer the native command:

```bash
.venv/bin/ansible-lint playbooks/deploy_development_nodes.yaml roles/tunnelblick_mac
```

The thin repo wrapper exists mainly for hook usage and a stable shared entrypoint:

```bash
./bin/ansible-quality-gate.sh playbooks/deploy_development_nodes.yaml roles/tunnelblick_mac
```

If no paths are provided, it defaults to:

```bash
./bin/ansible-quality-gate.sh
```

Both paths use the repo's `.ansible-lint` configuration and inherit Ansible
syntax checking through `ansible-lint`.

## Next refinement

The current replacement is good enough for first-pass use, but there is still
one follow-up worth doing:

- make `ansible_dev_tools` more minimal so it does not rely on broader local
  workstation setup through the current dependency chain

Target shape:

- focused playbook stays
- focused role behavior becomes narrower
- controller toolchain convergence stops pulling in unrelated local setup work
