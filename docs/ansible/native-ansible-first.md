# Native Ansible First

This repo should prefer native Ansible execution patterns over custom shell
wrappers whenever the work can be expressed clearly with playbooks, roles,
inventory, and normal `ansible-playbook` commands.

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

## Next refinement

The current replacement is good enough for first-pass use, but there is still
one follow-up worth doing:

- make `ansible_dev_tools` more minimal so it does not rely on broader local
  workstation setup through the current dependency chain

Target shape:

- focused playbook stays
- focused role behavior becomes narrower
- controller toolchain convergence stops pulling in unrelated local setup work
