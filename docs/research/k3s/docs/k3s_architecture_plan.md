# k3s Multi-Node Cluster Architecture Plan

**Date:** February 24, 2026  
**Scope:** Three-node k3s cluster for model serving, data storage, observability, and experimentation.

---

## 🏗️ 1. Cluster Topology

### Machines

| Machine | Role | Surface(s) | GPU | Purpose |
|---------|------|-----------|-----|---------|
| **network_server** | Control Plane + Worker | network-server-wsl (SSH) | No | API Gateway, Data Store, Dashboards, Logging, Orchestration |
| **server-225** | Control Plane + Worker | server-225-wsl (SSH) | GPU | Model Serving (primary inference), shared control plane responsibility |
| **dev-3090** | Worker Only | dev-3090-wsl (SSH) | GPU | Inference Overflow, Secondary Models, Embeddings, Fact-Checking |

### Cluster Characteristics

- **Control Plane:** Embedded etcd on network_server; server-225 has optional second control plane for HA (future upgrade)
- **CNI:** Flannel (default k3s, simple, sufficient)
- **Storage:** SQLite for k3s metadata; persistent volumes mount to D:\ai\data on network_server (WSL)
- **API Server:** Exposed on network_server via kubeconfig; agents join via token
- **ServiceType:** ClusterIP (internal), NodePort (external via Ingress or direct), LoadBalancer (reserved for future)

---

## 📂 2. Directory Structure (Ansible)

```
roles/
├── k3s_control_plane/              # Initialize control plane + etcd
│   ├── README.md
│   ├── defaults/main.yml
│   ├── tasks/
│   │   ├── main.yml                # Install k3s server
│   │   ├── firewall.yml            # WSL firewall rules (if needed)
│   │   └── kubeconfig.yml          # Extract kubeconfig to host
│   ├── templates/
│   │   ├── k3s_server.service.j2   # Systemd service (already in k3s, but customize if needed)
│   │   └── kubeconfig.j2           # Template for kubeconfig distribution
│   └── handlers/main.yml           # Restart k3s
│
├── k3s_agent/                      # Install worker agents
│   ├── README.md
│   ├── defaults/main.yml
│   ├── tasks/
│   │   ├── main.yml                # Install k3s agent
│   │   └── firewall.yml
│   ├── templates/
│   │   └── k3s_agent.service.j2
│   └── handlers/main.yml
│
├── k3s_storage/                    # PersistentVolume / StorageClass setup
│   ├── README.md
│   ├── defaults/main.yml
│   ├── tasks/
│   │   ├── main.yml                # Ensure mount points, permissions
│   │   └── storage_class.yml       # Apply storage class manifests
│   └── templates/
│       └── local_storage_class.yml.j2
│
├── k3s_workloads/                  # Deploy application manifests
│   ├── README.md
│   ├── defaults/main.yml
│   ├── tasks/
│   │   ├── main.yml                # Wait for cluster readiness, apply manifests
│   │   └── manifests.yml           # Deploy individual workloads
│   ├── templates/
│   │   ├── namespace.yml.j2
│   │   ├── postgres_statefulset.yml.j2
│   │   ├── model_server_deployment.yml.j2
│   │   ├── collector_deployment.yml.j2   # Log aggregator
│   │   ├── dashboard_deployment.yml.j2
│   │   ├── pvc_models.yml.j2
│   │   └── ingress.yml.j2
│   └── handlers/main.yml
│
└── k3s_monitor/                    # (Future) Prometheus/Grafana for observability
    ├── README.md
    └── ...

playbooks/
├── k3s_bootstrap.yaml              # Full cluster init (control + workers)
├── k3s_join_worker.yaml            # (Later) Add additional workers
├── k3s_deploy_workloads.yaml       # Deploy app manifests post-cluster
├── k3s_debug.yaml                  # Troubleshooting / inspect cluster state
└── verify_k3s.yaml                 # Health checks

inventory/
├── group_vars/
│   ├── k3s_cluster.yaml            # Cluster-wide config (API, token, etc.)
│   ├── k3s_control_planes.yaml     # Control plane specifics
│   └── k3s_agents.yaml             # Worker agent config
│
└── host_vars/
    ├── network-server-wsl.yaml     # Already exists; add k3s vars
    ├── server-225-wsl.yaml         # Already exists; add k3s vars
    └── dev-3090-wsl.yaml           # Already exists; add k3s vars

params/
└── k3s.yaml                        # k3s version, channel, feature gates, etc.
```

---

## 🔧 3. Implementation Phases

### Phase 1: Infrastructure Prep (Week 1)
1. **SSH Readiness:** Verify all three WSL environments can SSH to each other via network_server's key.
2. **Storage Mounts:** Ensure `D:\ai\data` is properly mounted in WSL and has RWX permissions.
3. **Kernel Requirements:** Verify Linux capabilities on each WSL instance (for k3s).

### Phase 2: Control Plane (Week 1-2)
1. **Install k3s Server** on `network_server-wsl` with embedded etcd.
2. **Extract kubeconfig** and distribute to execution_nodes.
3. **Test API access** from mac-dev and bootstrap machines.

### Phase 3: Agent Deployment (Week 2)
1. **Install k3s Agent** on `server-225-wsl` and `dev-3090-wsl`.
2. **Verify node readiness** (`kubectl get nodes`).
3. **Check Pod Network** (Flannel).

### Phase 4: Storage & Workloads (Week 2-3)
1. **StorageClass:** Create local PV class pointing to D:\ai\data.
2. **Namespace:** Create `ai-infra` namespace for workloads.
3. **Deploy Postgres StatefulSet** with PVC.
4. **Deploy Model Server** (GPU-affinity rules so dev-3090 and server-225 prioritize inference).
5. **Deploy Log Collector** (e.g., Fluentd → ClickHouse or similar).
6. **Deploy Dashboard** (e.g., Streamlit, FastAPI web UI).

### Phase 5: Orchestration & Workflow (Week 3-4, Later Iteration)
1. **ArgoWorkflows** or simple `CronJob` for workflow engine.
2. **Secret Management** (Sealed Secrets or external vault integration).
3. **CI/CD** hooks (GitHub Actions → k3s cluster deployments).

---

## 🎯 4. Key Implementation Details

### 4.1 k3s Control Plane Initialization

**network_server-wsl:**
```bash
curl -sfL https://get.k3s.io | K3S_TOKEN=<random> \
  INSTALL_K3S_VERSION=v1.28.x \
  bash -s - server \
  --cluster-init \
  --data-dir=/var/lib/rancher/k3s
```

**Why cluster-init?** Enables high-availability setup if server-225 joins as second control plane later.

### 4.2 Agent Join (server-225-wsl, dev-3090-wsl)

```bash
curl -sfL https://get.k3s.io | K3S_URL=https://192.168.50.38:6443 \
  K3S_TOKEN=<same-token> \
  INSTALL_K3S_VERSION=v1.28.x \
  bash -s - agent
```

### 4.3 Kubeconfig Distribution

- Control plane generates `/etc/rancher/k3s/k3s.yaml` inside WSL.
- Copy to host (Windows) via Ansible.
- Merge into `~/.kube/config` on mac-dev for kubectl access.

### 4.4 Storage

**PersistentVolume (local):**
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-storage-network-server
spec:
  capacity:
    storage: 500Gi
  accessModes:
    - ReadWriteOnce
  localPath: /mnt/d/ai/data/k3s-volumes
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - "network-server-wsl"
```

### 4.5 Workload Affinity & Taints

**Taint dev-3090 for inference-only (no control plane):**
```bash
kubectl taint nodes dev-3090-wsl inference=true:NoSchedule
```

**Pod with GPU affinity:**
```yaml
nodeSelector:
  kubernetes.io/hostname: server-225-wsl
tolerations:
  - key: "inference"
    operator: "Equal"
    value: "true"
    effect: "NoSchedule"
```

---

## 📊 5. Workload Manifest Architecture

```
k3s_workloads/templates/manifests/
├── 00-namespace.yml              # ai-infra namespace
├── 10-storage.yml                # StorageClass, PV definitions
├── 20-secrets.yml                # (Vault-encrypted) API keys, tokens
├── 30-postgres/
│   ├── service.yml               # Headless service for StatefulSet
│   ├── statefulset.yml           # 1 replica (network-server)
│   └── pvc.yml
├── 40-model-server/
│   ├── service.yml               # ClusterIP for internal API
│   ├── deployment.yml            # GPU-affinity, replicas
│   └── ingress.yml               # Expose via LAN (LoadBalancer or NodePort)
├── 50-log-collector/
│   ├── deployment.yml            # Fluentd/Logstash
│   └── configmap.yml
├── 60-dashboard/
│   ├── service.yml
│   ├── deployment.yml
│   └── ingress.yml               # Expose landing page (e.g., Streamlit)
└── 99-ingress.yml                # Central Ingress controller config
```

---

## 🛠️ 6. Ansible Playbook Orchestration

### `playbooks/k3s_bootstrap.yaml`

```yaml
---
- name: k3s Cluster Bootstrap
  hosts: localhost
  gather_facts: false

  tasks:
    - name: 1. Initialize k3s Control Plane (network_server-wsl)
      include_role:
        name: k3s_control_plane
      vars:
        k3s_mode: server

    - name: 2. Wait for control plane to be ready
      pause:
        seconds: 15

    - name: 3. Deploy k3s Agents (server-225-wsl, dev-3090-wsl)
      include_role:
        name: k3s_agent
      loop:
        - server-225-wsl
        - dev-3090-wsl

    - name: 4. Verify all nodes are Ready
      ansible.builtin.include_role:
        name: k3s_storage
        tasks_from: validate_nodes

    - name: 5. Deploy storage class
      ansible.builtin.include_role:
        name: k3s_storage

    - name: 6. Deploy workloads
      ansible.builtin.include_role:
        name: k3s_workloads

    - name: 7. Final sanity checks
      include_role:
        name: k3s_monitor
        tasks_from: health_check
```

### Execution

```bash
# Full bootstrap (control + all agents + workloads)
ansible-playbook playbooks/k3s_bootstrap.yaml \
  -i inventory/inventory.yaml \
  -e k3s_version=v1.28.4 \
  -e k3s_token="$(openssl rand -base64 32)" \
  -vv
```

---

## 📋 7. Group & Host Variables

### `inventory/group_vars/k3s_cluster.yaml`

```yaml
---
k3s_version: "v1.28.4"
k3s_channel: "stable"
k3s_install_dir: /usr/local/bin

# API access
k3s_api_host: "192.168.50.38"
k3s_api_port: 6443
k3s_api_url: "https://{{ k3s_api_host }}:{{ k3s_api_port }}"

# Token (generated once, reused for all agents)
k3s_token: "{{ lookup('env', 'K3S_TOKEN') | default('') }}"

# CNI
k3s_cni: flannel
k3s_cluster_dns: "10.43.0.10"

# Storage
k3s_data_dir: /var/lib/rancher/k3s
persistent_volume_path: /mnt/d/ai/data/k3s-volumes
```

### `inventory/host_vars/network-server-wsl.yaml` (additions)

```yaml
---
k3s_role: control_plane
k3s_server_mode: true
k3s_etcd_ha: true  # Enable embedded etcd HA (for future multi-control-plane)
k3s_label_node_type: "control-storage"  # Custom label for pod affinity
```

### `inventory/host_vars/server-225-wsl.yaml` (additions)

```yaml
---
k3s_role: agent
k3s_server_mode: false
k3s_label_node_type: "gpu-compute"
k3s_gpu_enabled: true
```

### `inventory/host_vars/dev-3090-wsl.yaml` (additions)

```yaml
---
k3s_role: agent
k3s_server_mode: false
k3s_label_node_type: "gpu-inference"
k3s_gpu_enabled: true
k3s_taint_inference_only: true  # Taint for inference workloads only
```

---

## 🚀 8. Quick Reference: Full Deployment Command

```bash
# 1. Set k3s token (do once, save securely)
export K3S_TOKEN=$(openssl rand -base64 32 | tr '/' '_')
echo "Save this token: $K3S_TOKEN"

# 2. Run bootstrap
ansible-playbook playbooks/k3s_bootstrap.yaml \
  -i inventory/inventory.yaml \
  -e k3s_version=v1.28.4 \
  -e k3s_token="${K3S_TOKEN}" \
  -vv

# 3. Test cluster
kubectl --kubeconfig ~/.kube/k3s-config cluster-info

# 4. Get nodes
kubectl --kubeconfig ~/.kube/k3s-config get nodes -o wide

# 5. Deploy workloads
ansible-playbook playbooks/k3s_deploy_workloads.yaml \
  -i inventory/inventory.yaml \
  -vv
```

---

## ⚠️ 9. Known Considerations & Gotchas

1. **WSL Networking:** Each WSL instance sees itself as `127.0.0.1` but can reach other Windows/WSL hosts via LAN IP. k3s must bind to the WSL's actual LAN IP, not localhost.
2. **DNS Resolution:** Pods will use Flannel CNI with embedded CoreDNS. Make sure firewall allows UDP/53 and TCP/53.
3. **GPU Support:** k3s doesn't auto-detect GPUs; you need NVIDIA Container Toolkit + device-plugin DaemonSet.
4. **Persistent Data:** All PVs go to a single network_server node; replicate data separately if needed.
5. **High Availability Future:** To add server-225 as a second control plane later, re-cluster with HA etcd.
6. **Firewall:** Open ports:
   - 6443 (k3s API)
   - 10250 (kubelet)
   - 8472/udp (Flannel)
   - 4789/udp (VXLAN)

---

## 📋 10. Next Steps

1. **Create Roles** (per section 2, directory structure).
2. **Write Tasks** (phase 1-2: control plane, agents).
3. **Populate Templates** (Manifest YAMLs for workloads).
4. **Test on Single Node** (network_server, isolated, then expand).
5. **Iterate Workloads** (Model server, logging, dashboard).
6. **Document** (runbook for ops, troubleshooting guide).

---

**Status:** Ready for Ansible role & playbook development. Start with Phase 1 infrastructure validation.
