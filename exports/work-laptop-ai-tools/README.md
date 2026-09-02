# Work Laptop AI Tools Export Packet

This packet is intentionally isolated from the repo's normal shared playbooks
and development-node automation. It exists to export a minimal, explicit,
local-run Ansible slice for a work MacBook.

Current scope:

- target-local execution on the exported work laptop only
- guarded `ansible_connection: local`
- Codex CLI install through `nvm` + npm
- Codex local profile/config export for the current homelab model lanes
- `/private/etc/hosts` entries for current homelab names
- VS Code install + `Continue.continue` extension + `~/.continue/config.yaml`
- minimal shared bash startup scaffolding required by the Node/Codex path

Safety posture:

- no main inventory host entry
- no SSH / remote-management path
- no participation in `playbooks/deploy_development_nodes.yaml`
- explicit `work_laptop_export_mode=true` gate
- explicit local hostname match gate

Primary files:

- `ansible.cfg`
- `bootstrap/bootstrap-contract.sh`
- `bootstrap/bootstrap-tooling.yaml`
- `bootstrap/bootstrap-macos-ansible.sh`
- `collections/requirements.yml`
- `scripts/requirements.txt`
- `playbook.yaml`
- `inventory.yaml`
- `host_vars/work-laptop.yaml`
- `roles/work_laptop_codex_cli/tasks/main.yml`
- `roles/work_laptop_packet_receipt/tasks/main.yml`
- `export-manifest.yml`

Canonical run on the exported work laptop:

Fresh-machine bootstrap:

- Xcode Command Line Tools if Homebrew is not already installed
- sudo rights for the `/private/etc/hosts` update

```bash
./bootstrap/bootstrap-macos-ansible.sh
```

That script is the intended first-touch handoff into the packet-contained
tooling bootstrap and then the packet playbook. Pass normal
`ansible-playbook` args after `--`:

```bash
./bootstrap/bootstrap-macos-ansible.sh -- -K
```

Force-upgrade path when you explicitly want to refresh existing tooling:

```bash
./bootstrap/bootstrap-macos-ansible.sh --force-upgrade-all -- -K
```

Bootstrap only, without handing off into the packet playbook:

```bash
./bootstrap/bootstrap-macos-ansible.sh --bootstrap-only
```

Direct playbook previews still work when you want them separately:

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

The round-trip helper is for packet-development proof only and now defaults to
preview-only checks from the extracted packet: extracted bootstrap `--help`,
extracted bootstrap `--dry-run --bootstrap-only`, extracted playbook
`--syntax-check`, `--list-hosts`, and `--list-tasks`. Add `--apply` only when
the extracted packet is running on the real work laptop and a mutating apply is
intended. The normal path is to export the zip and run
`ansible-playbook playbook.yaml -i inventory.yaml` on the work laptop itself.

Secret and access boundaries:

- `continue_ide` ships `REPLACE_WITH_LITELLM_KEY` by design; supply the real gateway key on the work laptop before relying on Continue.
- `codex-homelab` fetches the LiteLLM gateway key from `hom-lab-ctl-k3s-02` at launch time, so the work laptop still needs the expected SSH access path.

Bootstrap behavior:

- default behavior is bootstrap packet `.venv`, bootstrap packet-local collections, run the packet-contained tooling bootstrap playbook, then hand off into `playbook.yaml`
- default install behavior is install-if-missing only
- the packet bootstrap playbook reuses existing repo role logic for `ansible_dev_tools`, `python`, and optional `package_manager` refreshes
- packet Ansible lives at `.venv/bin/ansible-playbook` and the repo-style public entrypoint is `~/.local/bin/ansible-playbook`
- existing Homebrew, packet `.venv`, packet collections, and packet tooling are left alone unless a `--force-*` flag is passed
- a newly installed Homebrew gets its `shellenv` line appended once to the active login-shell profile
- the packet carries a local contract file so the export skill can validate path and method drift before zipping

Current target facts:

- short hostname: `MLLXLJJ2XVFJ`
- username: `a805120`
- model: `MacBook Pro 14-inch (November 2023)`
- chip: `Apple M3 Pro`
- macOS: `Tahoe 26.6.1`
