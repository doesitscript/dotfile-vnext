# NetBox Deployment Research Intake

Captured: 2026-04-27

## Context

The next milestone is to deploy, set up, and integrate NetBox with this
Ansible project. The preferred direction is to run NetBox with Docker Compose,
but have this repo own the deployment rather than keeping NetBox as a manually
managed side project.

There is an existing intake note at `docs/intake/netbox-jumpstart.md`. This
file preserves the newer research pass and recommendation so it can be folded
into an implementation plan later.

## Recommendation

Deploy NetBox through this project.

The right shape is not "manually clone `netbox-docker` and run Compose forever."
The right shape is:

- this repo owns the desired state
- NetBox Docker versions are pinned
- Compose, environment, and plugin files are templated or copied by Ansible
- the deployment lands on the Linux Docker engine surface
- the role verifies container health and NetBox HTTP/API readiness

Docker Compose can still be the runtime mechanism. Ansible should own the
deployment lifecycle.

## Proposed Repo Shape

Create a capability-focused role and playbook:

- role: `roles/netbox_server`
- playbook: `playbooks/netbox.yaml`
- lifecycle variable: `netbox_server_state: present|absent`
- inventory group: `netbox_server`

The likely host is `nsrv-dkr-01` if the network-server Docker VM is meant to
become the authoritative shared service host. The standalone NetBox playbook
should be verified before it is composed into `playbooks/site.yaml`.

Do not base the implementation on `roles/network_server/stacks_network` as the
primary pattern. That role is useful historical context, but it writes Compose
onto the Windows surface and drives it with `win_shell`. NetBox should land on
the Linux Docker engine side and use the repo's existing Docker lifecycle
patterns.

## Vanilla Docker Compose

Pros:

- Fastest first boot.
- Closest to the upstream `netbox-docker` quickstart.
- Easy to throw away during a short spike.
- Fewer repo changes on day one.

Cons:

- Secrets, version pins, plugin config, ports, backups, and health checks drift
  outside the repo.
- It bypasses the repo's preview and targeting rules.
- It is harder to recreate on `nsrv-dkr-01` or move later.
- It is easier to forget the NetBox Docker requirement that image tags and
  supporting `netbox-docker` files stay compatible.
- It is a weak fit for this milestone because NetBox is intended to become
  integrated infrastructure, not a side experiment.

## Repo-Managed Compose

Pros:

- Matches this repo's architecture: inventory declares intent, roles converge
  state, and playbooks compose capabilities.
- Supports `netbox_server_state: present|absent`.
- Keeps NetBox, Postgres, Valkey/Redis, and plugin requirements pinned in one
  reviewable place.
- Allows a preview output before the first mutating run.
- Provides a clean path for backups, restore, API token management, Ansible
  dynamic inventory, reverse proxy, and TLS.
- Lets Ansible install the `netbox.netbox` collection through `requirements.yml`
  and add a controlled NetBox inventory source later.

Cons:

- More upfront work.
- Requires a decision on secrets and first bootstrap data.
- Plugin-enabled NetBox images may require a local custom image build rather
  than only pulling upstream images.
- Upgrades need a small process: update image tag, check NetBox/plugin
  compatibility, migrate, and verify.

## Two Different Plugin Concepts

There are two plugin ideas that should not be mixed together.

### Ansible NetBox Collection

The Ansible integration is the `netbox.netbox` collection. It includes the
`netbox.netbox.nb_inventory` inventory plugin, which lets Ansible pull hosts
from NetBox.

This is not included in `ansible-core`. It should be added to
`requirements.yml`, then installed through the repo's normal Galaxy dependency
path.

Current research found the Ansible docs listing `netbox.netbox` collection
version `3.22.0`, with supported `ansible-core` `2.15.0+`.

### NetBox Django Plugins

NetBox's own plugins are Python/Django packages that extend the NetBox app.
They must be installed into NetBox's runtime, added to `PLUGINS`, optionally
configured under `PLUGINS_CONFIG`, then migrations/static collection and service
restart must happen.

Start with the Ansible collection, not NetBox Django plugins, unless a specific
NetBox plugin is named as required.

## Draft Plan

1. Add `netbox.netbox` to `requirements.yml`.
2. Add inventory intent with a `netbox_server` group, likely pointing at
   `nsrv-dkr-01`.
3. Create `roles/netbox_server` with `netbox_server_state: present|absent`.
4. Template or copy a pinned Compose project under `/opt/netbox`.
5. Include `.env` and secrets from vault-backed inventory variables.
6. Start with no NetBox Django plugins unless a specific plugin is selected.
7. Add health verification for container health, HTTP readiness, and API
   readiness.
8. Add `inventory/netbox.yml` later as a dynamic inventory source after NetBox
   has authoritative device or VM data.

## Apply, Verify, Undo

Apply:

```bash
ansible-playbook playbooks/netbox.yaml -i inventory/inventory.yaml --tags netbox_preview
ansible-playbook playbooks/netbox.yaml -i inventory/inventory.yaml
```

Verify:

```bash
docker compose ps
curl http://<netbox-host>:8000/login/
ansible-inventory -i inventory/netbox.yml --list
```

Undo:

Set `netbox_server_state: absent` to stop and remove containers while preserving
volumes by default. Persistent volume deletion should be a separate explicit
destructive switch.

Change class:

- deployment: idempotent config
- first admin/API token and initial data modeling: bootstrap/semi-manual
- persistent volume deletion: destructive

## Sources Checked

- `AGENTS.md`, `.codex/config.toml`, and framework docs/rules.
- `playbooks/site.yaml`, `playbooks/docker.yaml`, `playbooks/docker_engine.yaml`.
- `inventory/inventory.yaml` and the Ansible inventory graph.
- `requirements.yml`.
- NetBox Docker README: https://github.com/netbox-community/netbox-docker
- NetBox plugin installation docs:
  https://netbox.readthedocs.io/en/stable/plugins/installation/
- Ansible NetBox inventory plugin docs:
  https://docs.ansible.com/projects/ansible/latest/collections/netbox/netbox/nb_inventory_inventory.html
- Ansible NetBox collection index:
  https://docs.ansible.com/projects/ansible/latest/collections/netbox/netbox/index.html
