# Intake: K3s on Hyper-V VMs

**Date:** 2026-03-26
**Source:** ChatGPT conversation (docs/brainstorming_designs/hyper-v-full-vm-calassical-implementation.md)
**Repo target:** `k3s_cluster` group — server: `network-server-wsl` / agent: `server-225-wsl`
**Direction:** Migrate K3s off WSL-backed surfaces to dedicated Hyper-V VMs with External Switch

---

## Decision

Move K3s cluster nodes from WSL-backed inventory surfaces to proper Hyper-V VMs.

### Why not keep K3s on WSL

The current `k3s_cluster` uses `network-server-wsl` (server) and `server-225-wsl`
(agent). WSL surfaces introduce a networking abstraction layer between the Windows
host and the Linux environment. K3s networking relies on stable L2/L3 behavior
between nodes — service IPs, DNS, Flannel VXLAN, and the API endpoint on port 6443
all depend on node IPs that are consistent and directly reachable.

WSL adds:
- NAT between host and WSL instance
- DNS resolution via a generated `/etc/resolv.conf` that can diverge from host DNS
- Network interfaces that reset on WSL restart or Windows update
- No persistent IP across restarts without manual netplan workarounds

This is the same class of problem that caused Multipass to fail (DNS split-brain
across networking layers). The correct fix is not to work around WSL networking —
it is to remove the layer entirely by running K3s on real VMs with External Switch
networking.

### Why not K3s in Docker (k3d)

k3d and Docker-nested K3s are fast for throwaway dev clusters and Helm chart
testing. They are the wrong choice for this use case because:

- Networking stack: Windows → Docker → K3s → Pods = multiple NAT layers.
  Service IPs, LoadBalancer behavior, and node networking are all abstracted
  or simulated. You lose signal when debugging.
- Kubernetes networking does not behave the same as it does on real nodes.
  Service discovery, DNS, and cluster communication hit Docker bridge
  limitations that do not exist in VM-based deployments.
- GPU workloads (future): nested container runtimes with CUDA passthrough are
  painful. VM-based nodes with direct PCI passthrough are the clean path.
- Ansible integration: k3d clusters are not inventory nodes. They cannot be
  managed the same way as real SSH-accessible hosts.

Use k3d when: throwaway cluster for testing Helm charts, CI pipelines, local
development where you do not care about networking realism.

Do NOT use k3d for: this repo's infra cluster, observability stack, LLM workloads,
or anything that will eventually run on multi-node or GPU hardware.

### Why External Switch (not Default Switch or NAT)

External Switch is Hyper-V's implementation of bridged networking. VMs attached to
an External Switch receive a real LAN IP from the router, appear on the same subnet
as other devices, and have no NAT between them and other nodes or the host. This
is the correct networking surface for K3s because:

- Kubernetes node IPs are stable and real (not NAT addresses)
- The API endpoint (port 6443) is directly reachable from the Ansible controller
  and other nodes without port forwarding
- Flannel VXLAN traffic (UDP 8472) flows between nodes over the real LAN
- No DNS split-brain between nodes

The `hyperv_networking` role already creates an External Switch on hosts in this
repo. K3s VMs attach to that same switch.

---

## VM specifications (per K3s node)

| Setting | Value |
|---|---|
| Generation | 2 |
| vCPU | 2 minimum (4 recommended for server node) |
| RAM | 8 GB (minimum for K3s + test workloads) |
| Disk | 40–60 GB VHDX |
| Network | External Switch (created by `hyperv_networking`) |
| OS | Ubuntu Server 24.04 LTS |
| User | `ubuntu` (cloud image default) |
| Bootstrap | cloud-init (SSH key, hostname, minimal packages) |

K3s documented requirements: https://docs.k3s.io/installation/requirements

---

## Implementation sequence

The correct engineering order is: manual proof first, then automation.
Building Ansible automation before the manual path works creates fake progress.

### Phase 1 — Manual single-node (win condition: `kubectl get nodes` shows Ready)

1. Create one Ubuntu VM on Hyper-V (External Switch) — see `hyperv-ubuntu-docker-vm--replacing-multipass.md` for the VM creation approach
2. SSH into the VM from the controller
3. Verify internet access and DNS resolution from the VM
4. Install K3s server:
   ```bash
   curl -sfL https://get.k3s.io | sh -
   ```
5. Verify:
   ```bash
   sudo systemctl status k3s
   sudo kubectl get nodes -o wide
   sudo kubectl get pods -A
   ```
6. Configure kubeconfig for non-root use:
   ```bash
   mkdir -p ~/.kube
   sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
   sudo chown $USER:$USER ~/.kube/config
   kubectl get nodes
   ```
   Note: the default kubeconfig references `127.0.0.1`. For remote access from
   the Mac controller, edit the server address to the VM's LAN IP.
7. Deploy one throwaway workload to prove scheduling works:
   ```bash
   kubectl create deployment hello --image=nginx
   kubectl expose deployment hello --port=80 --type=ClusterIP
   kubectl get pods
   kubectl get svc
   ```

**Stop here.** Do not add agents, MetalLB, Helm, custom CNI, or Ansible until
this checkpoint is clean.

### Phase 2 — Add one agent node (win condition: `kubectl get nodes` shows 2 Ready)

Once the server node is stable:

- Create a second Ubuntu VM (same specs, same External Switch)
- SSH into the agent VM
- Join it to the server using the K3s agent install command:
  ```bash
  curl -sfL https://get.k3s.io | K3S_URL=https://<server-ip>:6443 K3S_TOKEN=<node-token> sh -
  ```
  The node token is at `/var/lib/rancher/k3s/server/node-token` on the server.
- Verify from the server: `kubectl get nodes`

Port requirements between nodes (must be open):
- TCP 6443 — Kubernetes API server (agents → server)
- UDP 8472 — Flannel VXLAN inter-node traffic
- TCP 10250 — kubelet metrics

Reference: https://docs.k3s.io/installation/requirements

### Phase 3 — Ansible automation via k3s-ansible

Once Phase 1 and Phase 2 work manually, encode the process using the official
k3s-ansible project: `https://github.com/k3s-io/k3s-ansible`

k3s-ansible requirements (from its README):
- Ansible 8.0+ / ansible-core 2.15+
- Managed nodes: passwordless SSH, root-equivalent access
- Inventory follows the `k3s_cluster > server > agent` group structure already
  present in this repo's `inventory/inventory.yaml`

The existing `k3s_cluster` group structure in this repo matches what k3s-ansible
expects. Once VMs are promoted to direct SSH access, they slot into `server`
and `agent` child groups with no inventory restructuring.

---

## Inventory migration path

Current state (WSL-backed surfaces):
```yaml
k3s_cluster:
  children:
    server:
      hosts:
        network-server-wsl:
    agent:
      hosts:
        server-225-wsl:
```

Target state (Hyper-V VM surfaces):
```yaml
k3s_cluster:
  children:
    server:
      hosts:
        network-server-ubuntu:   # new Hyper-V VM on network-server
    agent:
      hosts:
        server-225-ubuntu:       # Hyper-V VM on server-225 (same host, different VM than Docker VM)
```

Notes:
- `network-server-ubuntu` is a new inventory entry (new Hyper-V VM on network-server host)
- `server-225-ubuntu` is an existing `linux_vm_hosts` entry (the Docker VM) — OR a
  dedicated K3s agent VM named differently. Decide whether to share the Ubuntu VM
  (Docker + K3s agent co-located) or use separate VMs.
- WSL-backed hosts (`server-225-wsl`, `network-server-wsl`) are not removed from
  inventory — they serve other purposes. They are removed from `k3s_cluster` only.
- `linux_vm_hosts` group is the correct category for the new VMs. Move them from
  `k3s_agents_deferred` / `wsl_hosts_deferred` into `linux_vm_hosts` once SSH is ready.

---

## What phases to skip (Day 1)

Do not implement on the first pass:

- Multi-node cluster (Phase 1 only)
- Custom CNI (Flannel default is correct for now)
- MetalLB (not needed until external LoadBalancer is required)
- GPU workloads (vLLM, CUDA — future, after cluster is stable)
- Helm-based observability stack (Langfuse, Loki, etc. — after cluster is proven)
- Ansible automation via k3s-ansible (Phase 3 — after manual path works twice)

---

## What k3d is still useful for

k3d has a legitimate role in this repo:
- Fast throwaway cluster for testing Helm charts before applying to real cluster
- CI pipeline cluster testing
- Local development on Mac without spinning up VMs

Keep k3d available as a dev tool. Do not use it as a substitute for the real
cluster. The two are not interchangeable for the workloads this repo manages.

---

## Reference links

| Resource | URL |
|---|---|
| K3s quick start | https://docs.k3s.io/quick-start |
| K3s installation | https://docs.k3s.io/installation |
| K3s requirements | https://docs.k3s.io/installation/requirements |
| K3s server CLI/config | https://docs.k3s.io/cli/server |
| K3s agent CLI | https://docs.k3s.io/cli/agent |
| K3s networking overview | https://docs.k3s.io/networking |
| K3s basic network options | https://docs.k3s.io/networking/basic-network-options |
| K3s networking services | https://docs.k3s.io/networking/networking-services |
| k3s-ansible (official) | https://github.com/k3s-io/k3s-ansible |
| Helm install | https://helm.sh/docs/intro/install/ |
| Microsoft: Hyper-V networking | https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/plan/plan-hyper-v-networking-in-windows-server |

---

## Change contract

| Field | Value |
|---|---|
| Apply | Phase 1: manual VM + K3s install. Phase 3: k3s-ansible playbook run against `k3s_cluster` inventory group |
| Verify | `kubectl get nodes` (all Ready), `kubectl get pods -A` (system pods healthy), deploy nginx and confirm pod scheduling |
| Undo | Delete VMs from Hyper-V; remove hosts from `k3s_cluster` inventory group; revert to `k3s_agents_deferred` or `wsl_hosts` |
| Change class | Phase 1-2: bootstrap/semi-manual. Phase 3: idempotent Ansible (k3s-ansible role) |
| Lifecycle control | k3s-ansible `state` variable (present/absent per node); inventory group membership gates whether a node is targeted |
