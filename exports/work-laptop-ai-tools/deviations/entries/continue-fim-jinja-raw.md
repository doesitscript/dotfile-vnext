---
id: continue-fim-jinja-raw
status: promoted
behavior_group: continue-local-models
title: Escape Continue FIM {{{placeholders}}} so Ansible Jinja does not parse them
---

## Trigger

- Continue autocomplete FIM prompt uses literal `{{{prefix}}}` / `{{{suffix}}}`.
- Ansible templates `host_vars` and `roles/continue_ide/templates/config.yaml.j2`.
- Day-2 apply fails while validating `continue_ide` (Jinja parse error on `{{{`).

## Accommodation

- Wrap FIM strings in `{% raw %}…{% endraw %}` in packet `host_vars/work-laptop.yaml`
  when `prompt_templates.autocomplete` is set there.
- Use the same `{% raw %}` form for hardcoded FIM defaults in parent
  `roles/continue_ide/templates/config.yaml.j2` (synced into the sibling).
- Source packet remains authoritative; do not invent laptop-only Continue
  provider/model overrides unless registered.

## Re-apply

```bash
# From sibling after sync
.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml --skip-tags hosts_file --tags continue
# Expect: no Jinja error; ~/.continue/config.yaml still contains {{{prefix}}} etc.
```

## Generalize

| Peer | Same risk? | Action |
| --- | --- | --- |
| Other Continue promptTemplates with `{{{` | yes | raw-wrap in vars or template |
| Any Jinja-managed IDE YAML with vendor `{{{` | yes | raw or `| to_json` without exposing braces to the parser |
