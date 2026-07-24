# Related Artifacts

Typical repo surfaces for this workflow:

- `playbooks/deploy_development_nodes.yaml`
- `skills/_shared/verification-receipt-template.md`
- `skills/validation/single-host-ansible-rollout/SKILL.md`

Common evidence commands:

- `bin/codex-env .venv/bin/ansible-playbook --list-hosts ...`
- `bin/codex-env .venv/bin/ansible-playbook --check --diff ...`
- `bin/codex-env .venv/bin/ansible-playbook ...`
- `bin/codex-env python skills/validation/single-host-apply-and-receipt/scripts/run_apply_receipt.py ...`
