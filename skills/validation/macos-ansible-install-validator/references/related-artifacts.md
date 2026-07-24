# Related Artifacts

Typical repo surfaces for this workflow:

- `roles/*/tasks/mac.yml`
- `roles/*/tasks/main.yml`
- `roles/*/defaults/main.yml`
- `playbooks/deploy_development_nodes.yaml`

Common validation commands and evidence:

- `bin/codex-env .venv/bin/ansible-playbook --list-hosts ...`
- `bin/codex-env .venv/bin/ansible-playbook --check --diff ...`
- `bin/codex-env .venv/bin/ansible-playbook ...`
- Direct `which <tool>` and `<tool> --version` verification
