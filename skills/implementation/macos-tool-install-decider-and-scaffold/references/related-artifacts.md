# Related Artifacts

Typical repo surfaces for this workflow:

- `playbooks/deploy_development_nodes.yaml`
- `inventory/host_vars/mac-dev.yaml`
- `roles/*/defaults/main.yml`
- `roles/*/tasks/main.yml`
- `roles/*/meta/main.yml`
- `roles/*/meta/argument_specs.yml`
- `roles/*/README.md`

Validation and rollout surfaces usually include:

- `bin/codex-env .venv/bin/ansible-playbook --list-hosts ...`
- `bin/codex-env .venv/bin/ansible-playbook --check --diff ...`
- `bin/codex-env .venv/bin/ansible-playbook ...`
