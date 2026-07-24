# Context7 Ansible Notes

Date checked: **Friday, July 24, 2026**

Context7 library used:

- `/websites/ansible_projects_ansible`

Topics used for this skill:

- `ansible-playbook` preview flags: `--syntax-check`, `--list-hosts`, `--list-tasks`, `--limit`, `--tags`
- inventory guide limit patterns
- `ansible.builtin.command`
- `ansible.builtin.stat`
- `ansible.builtin.find`
- `ansible.builtin.set_fact`
- `ansible.builtin.assert`
- `ansible.builtin.include_role`
- `community.general.homebrew`

Implementation takeaways:

- use `command` with `argv` when exact argument boundaries matter
- treat read-only probes as `changed_when: false`
- prefer role defaults and tasks over README prose for install and completion truth
- keep auditing read-only and leave live mutation to rollout skills

Durable research note:

- `homelab-reference-library/notes/investigations/ansible-cli-surface-auditor-context7-research.md`
