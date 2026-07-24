# Related Artifacts

Common commands:

- `bin/codex-env .venv/bin/ansible-playbook <playbook> -i inventory/inventory.yaml --list-hosts --limit <host>`
- `bin/codex-env .venv/bin/ansible-playbook <playbook> -i inventory/inventory.yaml --limit <host> --tags <tag> --check --diff`
- `bin/codex-env .venv/bin/ansible-playbook <playbook> -i inventory/inventory.yaml --limit <host> --tags <tag>`

Common direct verification:

- `test -x <binary>`
- `<binary> version`
- `test -f <managed-note>`
