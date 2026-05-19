Yes — deploy NetBox on the network server, not on the old Mac control node and not on the RTX 5090 machine.

Your old Mac should stay the Ansible execution/control node. NetBox should become shared infrastructure that the Mac queries.

Recommended placement:

```text id="3c94ah"
NetBox home:
network-server

Runtime:
Runtime:
Ubuntu VM or WSL-backed Docker on the network server

Accessed by:
old Mac control node
other Windows servers
future automation
```

Why the network server is the right home:

```text id="0d3etw"
It is always-on infrastructure.
It is not tied to your personal laptop.
It does not consume GPU/server resources needed for vLLM or model work.
It fits the role of source-of-truth service.
It can later support PostgreSQL, Redis, backups, observability, and automation integrations.
```

Do not put NetBox on the Mac. The Mac is your operator console. If NetBox lives there, your “source of truth” depends on an old laptop being powered on and healthy.

Do not put NetBox on the 5090 server unless you have no other choice. That machine should stay focused on GPU inference/model workloads. NetBox is not GPU-heavy, but mixing source-of-truth infrastructure with experimental GPU work is not clean.

## Recommended architecture

```text id="2rbr2g"
mac-dev
  Ansible control node
  Runs ansible-playbook
  Uses NetBox dynamic inventory

network-server
  Runs NetBox
  Runs NetBox PostgreSQL/Redis, or connects to those services
  Stores NetBox backups
  May also run MinIO / backup services / observability

vllm / 5090 desktop
  GPU inference
  model serving
  model storage/workloads

other Windows servers
  Hyper-V
  Ubuntu VMs
  Docker inside Ubuntu
  managed by Ansible
  represented in NetBox
```

## Where exactly to run it

Best option for your setup:

```text id="s8b6qk"
network-server -> Ubuntu VM -> Docker Compose -> NetBox
```

That is cleaner than Windows-native and cleaner than depending directly on WSL quirks for a core service.

Second-best:

```text id="7f90gx"
network-server -> WSL2 Ubuntu -> Docker Compose -> NetBox
```

This is acceptable for your homelab if that is the fastest path right now.

My practical recommendation:

```text id="92m6y6"
Start NetBox in Docker on the network server.
Treat migration to an Ubuntu VM as an intentional maturity step, not a blocker.
```

NetBox has an official installation path and a large plugin ecosystem, and the NetBox Ansible collection provides the `netbox.netbox.nb_inventory` inventory plugin so Ansible can use NetBox as a dynamic inventory source. ([NetBox Labs][1])

## How to model your lab in NetBox

I would not start by modeling every cable and every disk. Start with the source-of-truth pieces that help Ansible.

Initial NetBox objects:

```text id="1qlpmh"
site
  your physical location alias

devices
  mac-dev
  network-server
  vllm
  server-225
  other Windows server

virtual machines
  Ubuntu VMs
  WSL instances only if you want to manage them as real endpoints

platforms
  macOS
  Windows Server
  Ubuntu
  WSL Ubuntu

roles
  control-node
  network-server
  gpu-inference-node
  hyperv-host
  docker-host
  backup-target
  managed-service-node

tags
  ansible-managed
  storage-local-artifacts
  backup-source
  hyperv
  docker
  gpu
```

For Ansible, the most important things are:

```text id="0718w8"
device / VM name
primary IP
platform
site
role
tags
custom fields for connection behavior
```

## How NetBox should feed Ansible

Eventually, your static inventory should become mostly bootstrap-only.

Maturity path:

```text id="45bcvj"
Phase 1:
Static inventory remains source of truth.
Ansible pushes facts into NetBox.

Phase 2:
NetBox becomes source of truth for host identity, IPs, roles, platforms, and tags.
Ansible still uses host_vars/group_vars for detailed provisioning policy.

Phase 3:
NetBox dynamic inventory drives playbook targeting.
Ansible reads groups from site, role, platform, tags, and custom fields.

Phase 4:
More policy moves into NetBox custom fields/config context where it makes sense.
```

Do not rush straight to Phase 4. That is how NetBox turns into a junk drawer.

The Ansible inventory plugin is part of the `netbox.netbox` collection and is used as `netbox.netbox.nb_inventory`; it is not included in `ansible-core`, so you install/check the collection separately. ([Ansible Docs][2])

Example inventory file later:

```yaml id="ljxi6l"
plugin: netbox.netbox.nb_inventory
api_endpoint: "http://<netbox_host>:8000"
token: "{{ lookup('env', 'NETBOX_TOKEN') }}"
validate_certs: false

group_by:
  - sites
  - device_roles
  - platforms
  - tags

compose:
  ansible_host: primary_ip4.address | ansible.utils.ipaddr('address')
```

Then your playbooks can target things like:

```bash id="v22des"
ansible-inventory -i inventory/netbox.yaml --graph
```

```bash id="mop3xm"
ansible-playbook -i inventory/netbox.yaml playbooks/storage_windows_local_artifacts_prepare.yaml \
  --limit tags_storage_local_artifacts
```

## The plugin part

You said “incorporating a pet products as a plug-in” — I think voice-to-text mangled that. You might have meant NetBox plugins, or maybe “the product as a plugin to my project.”

Two different things:

```text id="326e4v"
NetBox Ansible collection
  Lets Ansible query/update NetBox.

NetBox plugins
  Extend NetBox itself with additional app features.
```

Start with the Ansible collection, not NetBox plugins.

NetBox plugins are powerful, but they add maintenance and upgrade complexity. The NetBox docs specifically warn that each plugin may require its own install/config steps, so you should not make plugins the first milestone unless you already know the exact plugin you need. ([NetBox Labs][3])

## What I would do first

Step 1: Deploy NetBox on the network server.

Step 2: Create these objects manually or via Ansible:

```text id="ty2ul1"
site
device roles
platforms
devices
VMs
interfaces
primary IPs
tags
```

Step 3: Use Ansible to query NetBox inventory.

Step 4: Keep destructive policy, like disk provisioning, in Ansible inventory/vars for now.

Step 5: Later, move stable classification fields into NetBox:

```text id="ha22cx"
node_usage_class
storage_profile
authority
criticality
ansible_connection_profile
```

## My opinionated recommendation for your setup

Use this source-of-truth split:

```text id="vg3c7x"
NetBox owns:
  site
  device/VM identity
  IP addresses
  platform
  device role
  tags
  physical/virtual relationships
  interfaces
  high-level custom fields

Ansible inventory/vars own:
  exact disk formatting policy
  destructive operation gates
  SSH/WinRM bootstrap secrets
  one-time provisioning flags
  role-specific implementation details
```

That keeps NetBox clean and professional.

## Where it fits in your naming work

NetBox should reinforce the naming scheme you are building:

```text id="1vhqk8"
<namespace>/<site>/<stage>/<node>/<class>/<subject>/<artifact>/<timestamp>
```

In NetBox:

```text id="4z7m4y"
namespace
  probably a tenant, custom field, or config context value

site
  NetBox Site

stage
  custom field or tag, unless you model it as status

node
  Device or Virtual Machine

class/subject/artifact
  usually not NetBox core objects unless they represent actual services/resources
```

For now, model the physical/virtual infrastructure in NetBox. Keep backup artifact taxonomy in your backup repo/catalog.

## Final answer

Deploy NetBox here:

```text id="yhn0j7"
network-server
```

Run it like this first:

```text id="ekz8sn"
Docker Compose on Ubuntu VM or WSL2 Ubuntu
```

Use it like this:

```text id="k4fnaa"
NetBox = source of truth for infrastructure identity
Mac = Ansible control node
Ansible = enforcement/provisioning engine
Servers = managed nodes
```

Do not overcomplicate it with plugins on day one. Get NetBox running, model your devices/VMs/IPs/roles/tags, then wire in `netbox.netbox.nb_inventory`. Once that works, your project maturity jumps immediately because targeting stops being a pile of hand-maintained static groups and starts becoming data-driven.

[1]: https://netboxlabs.com/docs/v4.3/netbox/installation/netbox/?utm_source=chatgpt.com "NetBox Installation | NetBox Documentation"
[2]: https://docs.ansible.com/projects/ansible/latest/collections/netbox/netbox/nb_inventory_inventory.html?utm_source=chatgpt.com "NetBox inventory source — Ansible Community Documentation"
[3]: https://netboxlabs.com/docs/v4.2/netbox/plugins/installation/?utm_source=chatgpt.com "Installing a Plugin | NetBox Documentation"
