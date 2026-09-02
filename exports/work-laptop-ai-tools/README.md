# Work Laptop AI Tools Export Packet

This packet is intentionally isolated from the repo's normal controller and
development-node playbooks. It exists to export a minimal, explicit, local-run
Ansible slice for a work MacBook.

Current scope:

- target-local execution on the exported work laptop only
- guarded `ansible_connection: local`
- hello-world targeting check role

Future intended scope:

- Cursor app + Cursor CLI
- Codex CLI/config
- Continue extension/config

Safety posture:

- no main inventory host entry
- no SSH / remote-management path
- no participation in `playbooks/deploy_development_nodes.yaml`
- explicit `work_laptop_export_mode=true` gate
- explicit local hostname match gate

Primary files:

- `playbook.yaml`
- `inventory.yaml`
- `host_vars/work-laptop.yaml`
- `roles/work_laptop_hello/tasks/main.yml`
- `export-manifest.yml`

Canonical run on the exported work laptop:

```bash
ansible-playbook \
  playbook.yaml \
  -i inventory.yaml \
  --list-hosts
```

```bash
ansible-playbook \
  playbook.yaml \
  -i inventory.yaml \
  --list-tasks
```

```bash
ansible-playbook \
  playbook.yaml \
  -i inventory.yaml
```

Project skill helpers:

```bash
bin/codex-env python \
  skills/implementation/work-laptop-export-pack/scripts/build_export_archive.py \
  --overwrite
```

```bash
bin/codex-env python \
  skills/implementation/work-laptop-export-pack/scripts/roundtrip_smoke.py \
  --ansible-command "$PWD/bin/codex-env ansible-playbook"
```

The round-trip helper is for packet-development proof only. The normal path is
to export the zip and run `ansible-playbook playbook.yaml -i inventory.yaml` on
the work laptop itself.

Current target facts:

- short hostname: `MLLXLJJ2XVFJ`
- username: `a805120`
- model: `MacBook Pro 14-inch (November 2023)`
- chip: `Apple M3 Pro`
- macOS: `Tahoe 26.6.1`
