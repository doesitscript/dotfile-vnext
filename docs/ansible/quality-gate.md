# Ansible Quality Gate

This repo already defines its Ansible lint policy in
[.ansible-lint](../../.ansible-lint).

The native command for direct Ansible verification work is:

```bash
.venv/bin/ansible-lint playbooks/deploy_development_nodes.yaml roles/tunnelblick_mac
```

The repo also provides a thin wrapper for hook use and a stable shared
entrypoint:

```bash
./bin/ansible-quality-gate.sh
```

You can also target specific playbooks or roles:

```bash
./bin/ansible-quality-gate.sh playbooks/deploy_development_nodes.yaml roles/tunnelblick_mac
```

## What it does

- runs the repo's `.venv` copy of `ansible-lint`
- uses the repo's `.ansible-lint` configuration
- gets Ansible syntax checking as part of `ansible-lint`
- expects the repo's Galaxy dependencies to already be installed

That last point matters: the Ansible Lint docs state that `ansible-lint`
internally runs `ansible-playbook --syntax-check` on playbooks and creates
temporary playbooks for roles.

If required collections or roles are missing, `ansible-lint` may try to
install them from `requirements.yml`. That is a toolchain/bootstrap issue, not
necessarily a code issue.

## Why this exists

The goal is to make lint and syntax checking a project behavior, not something
that only happens when an agent remembers to be disciplined.

This repo now enforces that intent in two layers:

- native `.venv/bin/ansible-lint` for direct use
- `./bin/ansible-quality-gate.sh` as the thin hook/wrapper entrypoint
- `.pre-commit-config.yaml` as the commit-time hook configuration

## Configured vs active

This repo currently has the hook configuration file:

- `.pre-commit-config.yaml`

That means commit-time enforcement is configured in the repo, but it is not
active until `pre-commit` is installed and the hook is installed into
`.git/hooks/`.

As of this update, the repo does not have an installed `.git/hooks/pre-commit`
hook yet, only the sample hook file that Git ships by default.

## Debugging exception

There are times when active debugging should focus on runtime behavior first.
That is allowed.

What is not allowed is being vague about it.

If lint, syntax, idempotence checks, or runtime verification were not run, the
agent should say so explicitly and say why.
