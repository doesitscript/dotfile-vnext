# k3s Implementation Guide

**Start Date:** February 24, 2026  
**Status:** Phase 1 Infrastructure Complete (Ready for Testing)

---

## 📦 What's Been Implemented

### 1. Ansible Roles (4 core roles)

| Role | Location | Purpose |
|------|----------|---------|
| **k3s_control_plane** | `roles/k3s_control_plane/` | Install & configure k3s server (control plane) |
| **k3s_agent** | `roles/k3s_agent/` | Install & configure k3s agent (worker nodes) |
| **k3s_storage** | `roles/k3s_storage/` | Setup PersistentVolume infrastructure |
| **k3s_workloads** | `roles/k3s_workloads/` | Deploy namespace & manifest infrastructure |

Each role includes:
- `README.md` – Purpose & variables
- `defaults/main.yml` – Default configuration
- `tasks/main.yml` – Core tasks
- `templates/*.j2` – Jinja2 manifests (K8s YAML)
- `handlers/main.yml` – Service restarts (where needed)

### 2. Playbooks (3 orchestration playbooks)

| Playbook | Location | Purpose |
|----------|----------|---------|
| **k3s_bootstrap.yaml** | `playbooks/` | Phase 1-4: Full cluster init (control + agents + storage) |
| **k3s_deploy_workloads.yaml** | `playbooks/` | Phase 5: Deploy app manifests (Model Server, logging, etc.) |
| **k3s_debug.yaml** | `playbooks/` | Inspect cluster state (nodes, pods, storage, services) |

### 3. Inventory Configuration

**Group Variables:**
- `inventory/group_vars/k3s_cluster.yaml` – Cluster-wide config (API, token, CNI)
- `inventory/group_vars/k3s_control_planes.yaml` – Control plane specifics
- `inventory/group_vars/k3s_agents.yaml` – Agent/worker specifics

**Host Variables (Updated):**
- `inventory/host_vars/network-server-wsl.yaml` – Added k3s control plane vars
- `inventory/host_vars/server-225-wsl.yaml` – Added k3s agent vars (GPU compute)
- `inventory/host_vars/dev-3090-wsl.yaml` – Created (k3s agent, GPU inference, tainted)

### 4. Manifest Templates

Stored in role `templates/`:
- `storage_class.yml.j2` – Kubernetes StorageClass
- `persistent_volume.yml.j2` – Local PersistentVolume
- `namespace.yml.j2` – ai-infra namespace

---

## 🚀 Quick Start

### Step 1: Set k3s Token (One-Time)

```bash
cd /Users/joshc/develop/dotfile-vnext

# Generate a secure token
export K3S_TOKEN=$(openssl rand -base64 32 | tr '/' '_')
echo "Save this token for later: $K3S_TOKEN"
```

### Step 2: Run Bootstrap (Full Cluster Init)

```bash
# From dotfile-vnext root, activate Ansible environment
source activate  # or: source .venv/bin/activate

# Execute bootstrap playbook
ansible-playbook playbooks/k3s_bootstrap.yaml \
  -i inventory/inventory.yaml \
  -e "k3s_version=v1.28.4" \
  -e "K3S_TOKEN=${K3S_TOKEN}" \
  -vv
```

**What this does:**
1. SSH into network-server-wsl
2. Install k3s server (control plane) with embedded etcd
3. Extract kubeconfig
4. SSH into server-225-wsl → install k3s agent, join cluster, label node (gpu-compute)
5. SSH into dev-3090-wsl → install k3s agent, join cluster, label node (gpu-inference), apply inference-only taint
6. Setup local storage (PV + StorageClass)
7. Create ai-infra namespace

**Expected output:**
```
✓ k3s cluster bootstrap complete!
✓ Control Plane: https://192.168.50.38:6443
✓ Nodes: control + 2 agents
✓ CNI: flannel
✓ Storage: local-storage configured
✓ Namespace: ai-infra ready
```

### Step 3: Verify Cluster Health

```bash
# On network-server-wsl, check nodes
/usr/local/bin/k3s kubectl --kubeconfig=/etc/rancher/k3s/k3s.yaml get nodes -o wide

# Expected output:
# NAME                STATUS   ROLES                  AGE   VERSION
# network-server-wsl  Ready    control-plane,master   5m    v1.28.4
# server-225-wsl      Ready    <none>                 3m    v1.28.4
# dev-3090-wsl        Ready    <none>                 3m    v1.28.4
```

### Step 4: Check Cluster Readiness

```bash
# Run debug playbook
ansible-playbook playbooks/k3s_debug.yaml \
  -i inventory/inventory.yaml \
  -vv

# This will show:
# - All nodes (Ready/NotReady)
# - System pods (coredns, flannel, etc.)
# - Storage status
# - Services
```

### Step 5: Deploy Workloads (Later)

```bash
# Prepare workload manifests in roles/k3s_workloads/templates/
# (Currently only namespace is scaffolded; add Model Server, Postgres, etc.)

# Then deploy:
ansible-playbook playbooks/k3s_deploy_workloads.yaml \
  -i inventory/inventory.yaml \
  -vv
```

---

## 📋 Implementation Checklist

- [x] **Architecture documented** in `docs/current_state/k3s_architecture_plan.md`
- [x] **Roles created** (k3s_control_plane, k3s_agent, k3s_storage, k3s_workloads)
- [x] **Task files** with install, join, label, taint workflows
- [x] **Manifest templates** for StorageClass, PV, Namespace
- [x] **Playbooks** for bootstrap, workload deployment, debugging
- [x] **Inventory** group/host vars configured
- [ ] **Phase 1: Local Testing** (run bootstrap on network-server alone first)
- [ ] **Phase 2: Multi-Node Validation** (add server-225, dev-3090)
- [ ] **Phase 3: Storage Verification** (PV mount, local path RW)
- [ ] **Phase 4: Workload Templates** (Model Server, Postgres, Logger, Dashboard)
- [ ] **Phase 5: End-to-End Deployment** (full app stack)
- [ ] **Phase 6: Documentation** (runbook, troubleshooting, ops guide)
- [ ] **Phase 7: GitOps / ArgoCD** (optional, future)

---

## 🔧 Next Steps (Immediate)

### 1. Test on network-server-wsl Alone (Safer Start)

Before joining server-225 and dev-3090, validate control plane in isolation:

```bash
# Modify playbook or run role directly
ansible-playbook playbooks/k3s_bootstrap.yaml \
  -i inventory/inventory.yaml \
  --limit "network-server-wsl" \
  -e "K3S_TOKEN=${K3S_TOKEN}" \
  -vv
```

Expected: 1 Ready node (control plane).

### 2. Inspect Control Plane

```bash
# SSH into network-server-wsl
ssh -i ~/.ssh/id_ed25519_ansible joshc@192.168.50.240

# Inside:
sudo /usr/local/bin/k3s kubectl --kubeconfig=/etc/rancher/k3s/k3s.yaml get nodes
sudo systemctl status k3s
sudo journalctl -u k3s -f
sudo ls -la /var/lib/rancher/k3s/server/
```

### 3. Check Firewall / Network

Ensure these ports are open on Windows Hosts ⇌ WSL:

- `6443/tcp` – k3s API
- `10250/tcp` – kubelet
- `8472/udp` – Flannel VXLAN
- `4789/udp` – VXLAN alt

On network-server Windows:
```powershell
# Check if port 6443 is listening inside WSL
netsh interface portproxy show all

# Open firewall (if needed)
New-NetFirewallRule -DisplayName "k3s API" -Direction Inbound -LocalPort 6443 -Protocol TCP -Action Allow
```

### 4. Extract Kubeconfig to Mac

```bash
# Copy kubeconfig from network-server-wsl to mac-dev
kubectl --kubeconfig=<path>/k3s.yaml get nodes

# Or merge into ~/.kube/config for global access
# (Ansible should automate this in a later phase)
```

### 5. Create Workload Manifests

In `roles/k3s_workloads/templates/`, add:

1. **Model Server** (GPU-aware Deployment)
2. **Postgres** (StatefulSet with PVC)
3. **Log Collector** (Fluentd/Logstash Deployment)
4. **Dashboard** (Web UI Deployment + Service)
5. **Ingress** (Route external traffic)

Templates follow `XY-<component>.yml.j2` naming.

### 6. Test Pod Scheduling & Affinity

```bash
# Deploy a test pod with GPU request
# Verify it lands on server-225-wsl (gpu-compute), not dev-3090-wsl (inference-only)

# Deploy a test pod with taint toleration
# Verify inference-only pods land on dev-3090-wsl only
```

---

## 📚 References

- **Architecture:** `docs/current_state/k3s_architecture_plan.md`
- **Ansible Docs:** (Already indexed in Cursor) `ansible-roles`, `ansible-inventory-guide`, etc.
- **k3s Docs:** https://docs.k3s.io/
- **Kubernetes Docs:** https://kubernetes.io/docs/
- **Local Storage:** https://kubernetes.io/docs/concepts/storage/volumes/#local

---

## ⚠️ Known Issues & Workarounds

1. **WSL Networking:** Each WSL instance is a separate network entity. Ensure firewall allows cross-WSL traffic.
2. **GPU Support:** NVIDIA Container Toolkit must be pre-installed; device plugin DaemonSet needed.
3. **PersistentVolume Path:** Must exist and be RW on the host before PV claim.
4. **Systemd in WSL:** Roles assume `systemd_in_wsl: true` (already set in group_vars).

---

## 💡 Tips

- **Dry-run:** Add `--check` flag to playbook for safety.
- **Verbose:** Use `-vvv` (very verbose) for detailed debugging.
- **Specific Node:** Use `--limit server-225-wsl` to target single host.
- **Fact Cache:** Ansible caches facts in `.facts_cache/`; clear if stale: `rm -rf .facts_cache/`.

---

**Status:** Ready to execute Phase 1 (control plane) on network-server-wsl. Proceed when ready.
