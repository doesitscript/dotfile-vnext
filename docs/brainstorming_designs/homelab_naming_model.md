🧩 1. NetBox Data Model for Your Entire Homelab
This is the model you’ll load into NetBox so it becomes your source of truth for:

Hyper‑V hosts

Ubuntu VMs

Docker nodes

K3s nodes

Traefik nodes

LLM nodes

Networks

IPs

Naming conventions

Tags

Roles

Platforms

This is the exact structure I recommend.

🟦 Sites
You only need one unless you expand later.

Code
homelab
🟩 Device Roles
These define the purpose of each VM or host.

Code
hyperv-host
ubuntu-vm
docker-node
k3s-master
k3s-worker
traefik-node
llm-node
netbox-server
🟧 Platforms
These define the OS.

Code
windows-server-2022
ubuntu-22-04
ubuntu-24-04
🟦 Tags
Tags are how you group things dynamically.

Code
hyperv
k3s
docker
traefik
llm
control-plane
worker
infra

---

## Tagging Schema

There are two distinct tagging layers in this project. Do not conflate them.

### Layer 1 — Ansible Play Tags (CLI `--tags`)

These control which tasks execute when `ansible-playbook --tags` is passed.
They live inside the Ansible role and playbook YAML files.

**Rules (from project standards and Ansible content best practices):**

- Use exactly two tag types: **role name** and **specific meaningful sub-operation**
- Every tag must be prefixed with the role name
- Every tag must be usable standalone (`--tags <tag>` must produce a meaningful, safe result)
- Do not create tags that cannot stand alone
- Do not create destructive tags (tags that delete data, tear down infra, or are irreversible
  if run accidentally)
- Document all tags in the role's README under a Tags section

**Naming pattern:**

```
<role_name>                         # selects the entire role capability
<role_name>_<sub_operation>         # selects a specific sub-path
```

**Examples from this project:**

| Tag | Role | Selects |
| --- | ---- | ------- |
| `ipam_netbox` | `ipam_netbox` | Entire NetBox capability |
| `ipam_netbox_present` | `ipam_netbox` | Deploy path only |
| `ipam_netbox_absent` | `ipam_netbox` | Remove path only |
| `ipam_netbox_smoke_test` | `ipam_netbox` | Health check only |
| `ipam_netbox_seed_tags` | `ipam_netbox` | Seed NetBox API tags only |
| `hyperv_networking` | `hyperv_networking` | Networking role capability |
| `docker` | `docker` | Docker capability |

**Usage:**

```bash
# Run only a specific capability in a large site playbook
ansible-playbook playbooks/site.yaml --tags ipam_netbox

# Skip a capability
ansible-playbook playbooks/site.yaml --skip-tags ipam_netbox

# Run a single sub-operation
ansible-playbook playbooks/deploy_ipam_netbox.yaml --ask-vault-pass --tags ipam_netbox_smoke_test
```

---

### Layer 2 — NetBox Object Tags (Labels Inside NetBox)

These are labels applied to **objects within the NetBox application** — devices,
virtual machines, IP prefixes, IP addresses, etc. They are managed via the
NetBox API and the `netbox.netbox` Ansible collection.

**Purpose:** create queryable dimensions for grouping objects across types.
For example: all objects tagged `ansible-managed` can be retrieved in one
API call regardless of whether they are devices, VMs, or prefixes.

**Rules:**

- Tags are lowercase, hyphen-separated slugs (NetBox convention, not underscore)
- Tag names should reflect **dimension**, not state or lifecycle
- Tags should be seeded via Ansible (`netbox.netbox.netbox_tag`) so they are
  version-controlled and reproducible, not created by hand in the UI
- Scope tags to specific object types when they only apply to a subset
  (the `object_types` parameter on `netbox_tag`)
- Use `ansible-managed` on every object whose state is owned by an Ansible role

**Canonical project tags:**

| Tag name | Slug | Dimension | Scope |
| --- | --- | --- | --- |
| `ansible-managed` | `ansible-managed` | Ownership — repo automation owns this object | any |
| `homelab` | `homelab` | Environment — this environment vs future envs | any |
| `ipam-netbox-role` | `ipam-netbox-role` | Role provenance — created by `ipam_netbox` role | any |
| `hyperv` | `hyperv` | Technology layer | devices, VMs |
| `k3s` | `k3s` | Technology layer | devices, VMs, clusters |
| `docker` | `docker` | Technology layer | devices, VMs |
| `traefik` | `traefik` | Technology layer | devices, VMs |
| `llm` | `llm` | Technology layer | devices, VMs |
| `control-plane` | `control-plane` | Role within a cluster | VMs |
| `worker` | `worker` | Role within a cluster | VMs |
| `infra` | `infra` | Classification — infrastructure service vs workload | devices, VMs |

**Querying tagged objects via API:**

```bash
# All objects tagged ansible-managed (requires NetBox v4.3+)
GET /api/extras/tags/ansible-managed/tagged-objects/

# Filter inventory by tag in Ansible dynamic inventory plugin
group_by:
  - tags
# → produces inventory group: tag_ansible_managed
```

**Seeding tags via Ansible (run once after deploy):**

```bash
ansible-playbook playbooks/deploy_ipam_netbox.yaml --ask-vault-pass \
  --tags ipam_netbox_seed_tags
```

The seed task lives at `roles/ipam_netbox/tasks/seed_tags.yml`.

---

### Tag Hygiene Rules

1. **Ansible play tags use underscores** — they are Python identifiers (`ipam_netbox_present`)
2. **NetBox object tags use hyphens** — they are URL slugs (`ansible-managed`)
3. Never reuse the same string as both a play tag and a NetBox slug — they live in different systems and the naming convention difference makes that separation visible
4. Destructive operations (absent, remove, wipe) should never be reachable via a single `--tags` run without also passing an explicit state variable
5. Every role that has play tags must document them in its `README.md`
🟩 Clusters
You’ll want a K3s cluster object.

Code
k3s-homelab
Nodes assigned to this cluster:

lab-hv-k3s-master-01

lab-hv-k3s-worker-01

lab-hv-k3s-worker-02

🟧 IP Prefixes
Define your networks.

Example:

Code
192.168.1.0/24    # LAN
192.168.10.0/24   # VM network
192.168.20.0/24   # K3s service network
192.168.30.0/24   # K3s pod network
🟦 Naming Scheme (your specialty)
Deterministic, sortable, machine‑friendly:

Code
<env>-<provider>-<role>-<index>
Examples:

Code
lab-hv-k3s-master-01
lab-hv-k3s-worker-01
lab-hv-traefik-01
lab-hv-llm-01
lab-hv-netbox-01
🟩 VMs (modeled in NetBox)
Example entries:

Hyper‑V Host
Code
name: lab-hv-host-01
role: hyperv-host
platform: windows-server-2022
tags: [hyperv, infra]
NetBox Server
Code
name: lab-hv-netbox-01
role: netbox-server
platform: ubuntu-22-04
tags: [infra]
K3s Master
Code
name: lab-hv-k3s-master-01
role: k3s-master
platform: ubuntu-22-04
cluster: k3s-homelab
tags: [k3s, control-plane]
K3s Worker
Code
name: lab-hv-k3s-worker-01
role: k3s-worker
platform: ubuntu-22-04
cluster: k3s-homelab
tags: [k3s, worker]
Traefik Node
Code
name: lab-hv-traefik-01
role: traefik-node
platform: ubuntu-22-04
tags: [traefik]
LLM Node
Code
name: lab-hv-llm-01
role: llm-node
platform: ubuntu-24-04
tags: [llm, docker]

🟦 Dynamic Inventory Plugin
Your inventory file:

Code
inventory/netbox.yml
yaml
plugin: netbox.netbox.nb_inventory
api_endpoint: "http://lab-hv-netbox-01/api/"
token: "{{ lookup('env', 'NETBOX_TOKEN') }}"
validate_certs: false

group_by:
  - device_roles
  - platforms
  - tags
  - clusters

compose:
  ansible_host: primary_ip4.address
Now Ansible automatically discovers:

all VMs

their IPs

their roles

their tags

their cluster membership

This is the backbone of your automation.