# Related Artifacts

Typical files:

- `roles/<role>/defaults/main.yml`
- `roles/<role>/tasks/main.yml`
- `roles/<role>/tasks/mac.yml`
- `roles/<role>/meta/main.yml`
- `roles/<role>/meta/argument_specs.yml`

Typical verification:

- `bin/codex-env .venv/bin/ansible-playbook ... --check --diff`
- `bin/codex-env .venv/bin/ansible-playbook ...`
- direct `test -x <binary>` and `<binary> version`
