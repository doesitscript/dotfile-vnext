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