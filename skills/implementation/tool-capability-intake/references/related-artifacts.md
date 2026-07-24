# Related Artifacts

Typical repo surfaces for this workflow:

- `playbooks/deploy_development_nodes.yaml`
- `inventory/host_vars/mac-dev.yaml`
- `roles/*/defaults/main.yml`
- `roles/*/tasks/main.yml`
- `roles/*/meta/main.yml`
- `roles/*/meta/argument_specs.yml`
- `roles/*/README.md`
- Specialized handoffs:
  - `skills/implementation/windows-tool-capability-intake/`
  - `skills/implementation/hf-model-weight-lifecycle/`
  - `skills/implementation/macos-tool-install-decider-and-scaffold/`

Validation surfaces usually include:

- `bin/codex-env .venv/bin/ansible-lint ...`
- `bin/codex-env .venv/bin/ansible-playbook --list-hosts ...`
- `bin/codex-env .venv/bin/ansible-playbook --check --diff ...`
