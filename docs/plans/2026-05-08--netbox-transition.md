# NetBox Transition Marker

Date: 2026-05-08

This repo is now in the NetBox integration transition. NetBox should become the
preferred source of truth for durable infrastructure data wherever it can do
that job cleanly: sites, devices, VMs, platforms, roles, tags, IP addresses,
prefixes, clusters, and object ownership metadata.

The intent is not to replace Ansible with NetBox. The intent is to use NetBox
for facts and classification, and use Ansible for execution.

## Current Repo State

- NetBox deployment is represented by `roles/ipam_netbox`.
- The owning playbook is `playbooks/deploy_ipam_netbox.yaml`.
- The deployment target is `server-225-ubuntu`.
- The role keeps a state-based lifecycle interface through
  `ipam_netbox_state: present|absent`.
- NetBox object-tag seeding exists in `roles/ipam_netbox/tasks/seed_tags.yml`.
- The standard Ansible NetBox collection is a declared dependency in
  `requirements.yml`.

## Programmatic Access Standard

The standard repo access path is:

1. Ansible modules from the `netbox.netbox` collection for NetBox object
   management.
2. `netbox.netbox.nb_inventory` for dynamic inventory after the initial NetBox
   model is populated.
3. A vault-backed NetBox API token, referenced by Ansible, for API operations.

Direct ad hoc API calls or custom scripts are fallback tools, not the primary
integration pattern.

## Design Rule From This Point

When a new or touched capability needs stable host, device, VM, IPAM, platform,
role, tag, cluster, or ownership data, prefer this order:

1. Model the durable fact in NetBox if NetBox has a native object or clean custom
   field for it.
2. Pull that fact into Ansible through `nb_inventory`, composed variables, or
   collection modules.
3. Keep static inventory only for bootstrap, controller reachability, emergency
   fallback, or facts that are not ready to move yet.

Avoid adding new hand-maintained static groups when the grouping can be derived
from NetBox role, platform, tag, site, cluster, tenant, or custom-field data.

## Immediate Integration Points

- Keep `ipam_netbox` as the NetBox stack owner.
- Seed canonical tags through `ipam_netbox_seed_tags`.
- Add a real `inventory/netbox.yml` only after the NetBox URL and token are
  wired and a first useful object model exists.
- Migrate inventory semantics gradually: static inventory remains the bootstrap
  surface until NetBox can safely answer the same question.

## Apply / Verify / Undo

- Apply: `ansible-playbook playbooks/deploy_ipam_netbox.yaml --tags ipam_netbox`
- Verify: `ansible-playbook playbooks/deploy_ipam_netbox.yaml --tags ipam_netbox_smoke_test`
- API seed verify: `ansible-playbook playbooks/deploy_ipam_netbox.yaml --tags ipam_netbox_seed_tags`
- Undo: `ansible-playbook playbooks/deploy_ipam_netbox.yaml -e ipam_netbox_state=absent --tags ipam_netbox_absent`

## Change Class

This transition is idempotent configuration and source-of-truth modeling. NetBox
stack removal is state-driven, but preserving or deleting persistent volumes is
controlled separately by `ipam_netbox_remove_volumes_on_absent`.
