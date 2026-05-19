# Intake: K3s on Hyper-V VMs

**Date:** 2026-03-26
**Source:** ChatGPT conversation (docs/brainstorming_designs/hyper-v-full-vm-calassical-implementation.md)
**Repo target:** `k3s_vm_stub_hosts` for the current VM/readiness slice; `k3s_cluster` remains empty until the real K3s install is approved
**Current host identity:** the former network-server Windows control host is now modeled
as `home-lab-auth-hvh-01`; use `network-server-*` names only when describing
legacy WSL/intake state or the Ansible control alias.
**Direction:** Prepare a dedicated Hyper-V Ubuntu VM lane for K3s without installing K3s yet

---

## Decision

Move K3s cluster nodes away from WSL-backed inventory surfaces and toward
proper Hyper-V VMs. The current repository implementation stops at VM
preparation and readiness validation for `nsrv-k3s-01`; it does not install
K3s, start `k3s`/`k3s-agent`, or import `k3s.orchestration.site`.

### Why not keep K3s on WSL

The legacy `k3s_cluster` design used `network-server-wsl` (server) and `server-225-wsl`
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

## Current implementation sequence

The current engineering order is: reusable VM primitive first, prove separate
Docker and K3s VM lanes second, then install K3s in a later slice.

### Phase 0 — Repo preparation and stub lane

1. Keep `roles/hyperv_ubuntu_vm` as the generic Ubuntu VM primitive.
2. Keep Docker-specific language in Docker wrapper playbooks/vars only.
3. Use `playbooks/hyperv_ubuntu_docker_vm.yaml` for the existing Docker VM
   `nsrv-dkr-01`.
4. Use `playbooks/hyperv_ubuntu_k3s_vm.yaml` for the K3s placeholder VM
   `nsrv-k3s-01`.
5. Use `playbooks/k3s_vm_stub.yaml` to validate the K3s lane after the VM is
   reachable by SSH. The stub asserts Ubuntu, expected memory/disk facts, and
   absence of `k3s` and `k3s-agent` services.
6. Keep `nsrv-k3s-01` in `k3s_vm_stub_hosts`, not in the live `k3s_cluster`
   `server` group.

Preview commands:

```bash
ansible-playbook playbooks/hyperv_ubuntu_docker_vm.yaml -i inventory/inventory.yaml \
  --check --tags docker_vm_preview

ansible-playbook playbooks/hyperv_ubuntu_k3s_vm.yaml -i inventory/inventory.yaml \
  --check --tags k3s_vm_preview

ansible-playbook playbooks/k3s_vm_stub.yaml -i inventory/inventory.yaml \
  --check --tags k3s_stub_preview
```

NetBox seed preparation models:
- device: `home-lab-auth-hvh-01`
- cluster: `home-lab-auth-hvh-01-hyperv`
- Docker VM: `nsrv-dkr-01`
- K3s VM placeholder: `nsrv-k3s-01`
- K3s VM role/tag: `k3s-node` / `k3s`

### Later Phase 1 — Manual single-node (win condition: `kubectl get nodes` shows Ready)

This phase is out of scope for the current repo change. Once the VM lane is
proven and `nsrv-k3s-01` is reachable by SSH, the future K3s implementation can
use the following manual proof sequence before automation.

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

### Later Phase 2 — Add one agent node (win condition: `kubectl get nodes` shows 2 Ready)

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

### Later Phase 3 — Ansible automation via k3s-ansible

Once the manual phases work, encode the process using the official
k3s-ansible project: `https://github.com/k3s-io/k3s-ansible`

k3s-ansible requirements (from its README):
- Ansible 8.0+ / ansible-core 2.15+
- Managed nodes: passwordless SSH, root-equivalent access
- Inventory follows the `k3s_cluster > server > agent` group structure already
  present in this repo's `inventory/inventory.yaml`

The existing `k3s_cluster` group structure in this repo matches what k3s-ansible
expects, but it is intentionally empty during the VM/stub slice. Once the real
K3s install is approved, `nsrv-k3s-01` can be promoted from
`k3s_vm_stub_hosts` into `k3s_cluster.children.server`.

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

Current prepared state (Hyper-V VM surface, no K3s install):
```yaml
linux_vm_hosts:
  hosts:
    nsrv-k3s-01:

k3s_vm_stub_hosts:
  hosts:
    nsrv-k3s-01:

k3s_cluster:
  children:
    server:
      hosts: {}
    agent:
      hosts: {}
```

Future target state after K3s implementation is approved:
```yaml
k3s_cluster:
  children:
    server:
      hosts:
        nsrv-k3s-01:             # Hyper-V VM on home-lab-auth-hvh-01
    agent:
      hosts:
        <future-agent-vm>:        # dedicated K3s agent VM, not the Docker VM
```

Notes:
- `nsrv-k3s-01` is the approved durable inventory entry for the prepared K3s VM
  on `home-lab-auth-hvh-01`; `network-server-ubuntu` is a legacy placeholder
  name and should not be used for new implementation.
- `nsrv-dkr-01` is the existing Docker VM and must stay separate from the K3s
  stub lane.
- `server-225-ubuntu` is not a K3s agent by default. Use a dedicated future
  K3s agent VM if a second node is needed.
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
| Apply | Current slice: `hyperv_ubuntu_k3s_vm.yaml` creates/prepares `nsrv-k3s-01`; `k3s_vm_stub.yaml` validates readiness only |
| Verify | Inventory graph shows `nsrv-dkr-01` and `nsrv-k3s-01` as separate Linux VM surfaces; previews select only their own VM; stub confirms Ubuntu facts and no K3s services |
| Undo | Set `hyperv_ubuntu_k3s_vm_state: absent`; remove `nsrv-k3s-01` from active static inventory groups if the lane is backed out |
| Change class | VM base refactor: idempotent Ansible orchestration; K3s stub: idempotent readiness validation; real K3s install: out of scope |
| Lifecycle control | VM lane: `hyperv_ubuntu_k3s_vm_state` (`present`/`absent`); future K3s install: `k3s_cluster` group membership plus k3s-ansible lifecycle controls |
