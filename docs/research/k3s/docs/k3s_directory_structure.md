# k3s Implementation: Directory Structure Created

**Date:** February 24, 2026

Below is the complete directory tree of k3s-related infrastructure created during implementation.

---

## Directory Listing

```
/Users/joshc/develop/dotfile-vnext/

roles/
├── k3s_control_plane/
│   ├── README.md                     # Role documentation
│   ├── defaults/
│   │   └── main.yml                  # Default variables (k3s version, API host, token, etc.)
│   ├── tasks/
│   │   └── main.yml                  # Control plane installation, service startup, kubeconfig extraction
│   └── templates/
│       (none yet; uses direct shell commands for k3s installation)
│
├── k3s_agent/
│   ├── README.md                     # Role documentation
│   ├── defaults/
│   │   └── main.yml                  # Default variables (API URL, labels, taints)
│   └── tasks/
│       └── main.yml                  # Agent installation, cluster join, labeling, taint application
│
├── k3s_storage/
│   ├── README.md                     # Role documentation
│   ├── defaults/
│   │   └── main.yml                  # PV path, StorageClass name, capacity, access mode
│   ├── tasks/
│   │   └── main.yml                  # Mount point creation, permissions, manifest application
│   └── templates/
│       ├── storage_class.yml.j2      # Kubernetes StorageClass manifest (local provisioner)
│       └── persistent_volume.yml.j2  # Kubernetes PersistentVolume manifest (local path)
│
└── k3s_workloads/
    ├── README.md                     # Role documentation
    ├── defaults/
    │   └── main.yml                  # Namespace, replicas, resource limits, feature toggles
    ├── tasks/
    │   └── main.yml                  # Cluster readiness wait, namespace creation
    └── templates/
        └── namespace.yml.j2          # Kubernetes Namespace manifest (ai-infra)

playbooks/
├── k3s_bootstrap.yaml                # Phase 1-4: Full cluster init (control plane + agents + storage)
├── k3s_deploy_workloads.yaml         # Phase 5: Application deployment
└── k3s_debug.yaml                    # Diagnostic playbook (inspect cluster state)

inventory/
├── group_vars/
│   ├── k3s_cluster.yaml              # Cluster-wide configuration (API, token, CNI)
│   ├── k3s_control_planes.yaml       # Control plane specifics (HA, feature gates)
│   └── k3s_agents.yaml               # Agent/worker specifics
│
└── host_vars/
    ├── network-server-wsl.yaml       # (UPDATED) Added k3s control plane vars
    ├── server-225-wsl.yaml           # (UPDATED) Added k3s agent vars (gpu-compute)
    └── dev-3090-wsl.yaml             # (CREATED) Added k3s agent vars (gpu-inference, tainted)

docs/current_state/
├── k3s_architecture_plan.md          # Full architecture & design (10 sections)
├── k3s_implementation_guide.md       # Quick start & implementation checklist
└── k3s_directory_structure.md        # This file
```

---

## File Counts & Sizes

| Component | Count | Files |
|-----------|-------|-------|
| Roles | 4 | `k3s_control_plane`, `k3s_agent`, `k3s_storage`, `k3s_workloads` |
| Playbooks | 3 | `k3s_bootstrap`, `k3s_deploy_workloads`, `k3s_debug` |
| Group Vars | 3 | `k3s_cluster`, `k3s_control_planes`, `k3s_agents` |
| Host Vars | 3 | `network-server-wsl`, `server-225-wsl`, `dev-3090-wsl` |
| Jinja2 Templates | 4 | `storage_class`, `persistent_volume`, `namespace` + more (TBD for workloads) |
| Documentation | 3 | `k3s_architecture_plan`, `k3s_implementation_guide`, `k3s_directory_structure` |

---

## File Breakdown

### Core Roles Directory Structure

Each role follows Ansible best practices:

```
roles/k3s_<role>/
├── README.md                         # Human-readable docs (what, why, how)
├── defaults/main.yml                 # Default variables (low precedence, can be overridden)
├── tasks/main.yml                    # Task execution (install, join, configure, verify)
├── templates/                        # Jinja2 templates for manifests (if applicable)
│   └── *.yml.j2                      # Kubernetes YAML or service configs
├── handlers/main.yml                 # Service restart handlers (if applicable)
└── (vars/main.yml optional)          # Role-specific vars (rarely needed here)
```

### Key Variables & Their Purpose

#### Control Plane Defaults (`k3s_control_plane/defaults/main.yml`)

```yaml
k3s_version: "v1.28.4"
k3s_api_host: "192.168.50.38"         # network-server LAN IP
k3s_api_port: 6443
k3s_api_url: "https://{{ k3s_api_host }}:{{ k3s_api_port }}"
k3s_token: ""                          # Passed via environment K3S_TOKEN
k3s_data_dir: /var/lib/rancher/k3s
k3s_etcd_ha: true                      # High-availability embed etcd
```

#### Agent Defaults (`k3s_agent/defaults/main.yml`)

```yaml
k3s_api_url: "https://192.168.50.38:6443"
k3s_label_node_type: ""                # Set per host_vars (gpu-compute, gpu-inference)
k3s_taint_inference_only: false        # Set per host_vars (true for dev-3090-wsl)
k3s_gpu_enabled: false                 # Set per host_vars
```

#### Storage Defaults (`k3s_storage/defaults/main.yml`)

```yaml
persistent_volume_path: "/mnt/d/ai/data/k3s-volumes"
pv_capacity: "500Gi"
storageclass_name: "local-storage"
```

#### Workloads Defaults (`k3s_workloads/defaults/main.yml`)

```yaml
workload_namespace: "ai-infra"
postgres_replica_count: 1
model_server_replica_count: 2
log_collector_enabled: true
dashboard_enabled: true
```

---

## Inventory Hierarchy (Variable Precedence)

When Ansible runs, variables are loaded in this order (highest to lowest precedence):

1. **Host Variables** (`host_vars/<hostname>.yaml`)
   - Most specific; overrides group vars
   - Example: `network-server-wsl.yaml` sets `k3s_role: control_plane`

2. **Group Variables** (`group_vars/<group>.yaml`)
   - Applied to hosts in matching group
   - Example: `k3s_cluster.yaml` sets cluster-wide API URL

3. **Role Defaults** (`roles/<role>/defaults/main.yml`)
   - Lowest precedence
   - Example: `k3s_control_plane/defaults/main.yml` sets default k3s version

### Leveraged Groups (from existing inventory)

```yaml
all:
  children:
    execution_nodes:              # mac-dev (runs ansible-playbook)
      hosts: mac-dev
    
    wsl_hosts:                     # All WSL surfaces
      hosts:
        - server-225-wsl
        - network-server-wsl
        - dev-3090-wsl
    
    windows_hosts:                 # All Windows surfaces (WinRM)
      hosts:
        - server-225-win
        - network-server-win
        - dev-3090-win
```

New group associations for k3s:

```yaml
# Logical grouping (not in inventory yet; can be added)
k3s_cluster:                       # All k3s nodes
  children:
    k3s_control_planes:            # Control plane + etcd
      hosts:
        - network-server-wsl       # (derived from host role assignment)
    
    k3s_agents:                    # Worker/agent nodes
      hosts:
        - server-225-wsl
        - dev-3090-wsl
```

---

## Manifest Templates (Jinja2)

### `storage_class.yml.j2`

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: {{ storageclass_name }}
provisioner: kubernetes.io/local
volumeBindingMode: WaitForFirstConsumer
reclaimPolicy: Delete
```

**Used by:** `k3s_storage` role  
**Output file:** `/tmp/storage_class.yml` (applied to cluster)  
**Purpose:** Register local storage provisioner with Kubernetes

### `persistent_volume.yml.j2`

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-storage-network-server
spec:
  capacity:
    storage: {{ pv_capacity }}
  persistentVolumeReclaimPolicy: Delete
  storageClassName: {{ storageclass_name }}
  local:
    path: {{ persistent_volume_path }}
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - "network-server-wsl"
```

**Used by:** `k3s_storage` role  
**Output file:** `/tmp/persistent_volume.yml` (applied to cluster)  
**Purpose:** Declare 500Gi local storage bound to network-server-wsl

### `namespace.yml.j2`

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: {{ workload_namespace }}
  labels:
    name: {{ workload_namespace }}
```

**Used by:** `k3s_workloads` role  
**Output file:** `/tmp/namespace.yml` (applied to cluster)  
**Purpose:** Create `ai-infra` namespace for application workloads

---

## Task Execution Flow

### `k3s_bootstrap.yaml` Playbook Sequence

```
Phase 1: Control Plane Init
  ├─ include_role: k3s_control_plane
  │  ├─ Install k3s server (curl | bash)
  │  ├─ Start systemd service
  │  ├─ Wait for API readiness
  │  └─ Verify control plane Ready
  └─ pause: 20 seconds (stabilization)

Phase 2: Agent Deployment
  ├─ include_role: k3s_agent (server-225-wsl)
  │  ├─ Install k3s agent
  │  ├─ Join cluster via token
  │  ├─ Label node (node-type=gpu-compute)
  │  └─ Verify agent Ready
  └─ include_role: k3s_agent (dev-3090-wsl)
     ├─ Install k3s agent
     ├─ Join cluster via token
     ├─ Label node (node-type=gpu-inference)
     ├─ Apply taint (inference=true:NoSchedule)
     └─ Verify agent Ready

Phase 3: Verification
  ├─ Get all nodes
  └─ Display node status and labels

Phase 4: Storage Setup
  ├─ include_role: k3s_storage
  │  ├─ Create mount point
  │  ├─ Apply StorageClass
  │  ├─ Apply PersistentVolume
  │  └─ Wait for PV Available

Phase 5: Workloads Infrastructure
  └─ include_role: k3s_workloads
     ├─ Wait for cluster API
     └─ Create ai-infra namespace
```

---

## Next: Workload Templates (TBD)

The following manifest templates still need to be created in `roles/k3s_workloads/templates/`:

1. **postgres_statefulset.yml.j2** – Postgres with PVC, bound to network-server-wsl
2. **model_server_deployment.yml.j2** – GPU-aware deployment (server-225-wsl primary)
3. **model_server_service.yml.j2** – ClusterIP service for model server API
4. **log_collector_deployment.yml.j2** – Fluentd/Logstash for centralized logging
5. **dashboard_deployment.yml.j2** – Web UI (Streamlit or FastAPI + React)
6. **ingress.yml.j2** – Ingress controller routing (optional, future)

These will be added as workloads are refined.

---

## Execution Checklist

- [x] Role structure created (4 roles)
- [x] Task files written (install, join, label, taint, storage, namespace)
- [x] Manifest templates created (StorageClass, PV, Namespace)
- [x] Playbooks written (bootstrap, workloads, debug)
- [x] Group variables configured
- [x] Host variables updated/created
- [ ] Phase 1 testing (control plane alone)
- [ ] Phase 2 testing (add agents)
- [ ] Phase 3 testing (storage verification)
- [ ] Workload templates created (Model Server, Postgres, Logger, Dashboard)
- [ ] Phase 4 testing (end-to-end app deployment)

---

## Troubleshooting Quick Links

- **k3s Installation Issues:** Check `journalctl -u k3s` on network-server-wsl
- **Agent Join Failures:** Verify token, API URL, firewall ports (6443, 10250, 8472/udp, 4789/udp)
- **Flannel Not Ready:** Wait 30+ seconds; Flannel CNI setup takes time
- **Volume Mount Errors:** Ensure `/mnt/d/ai/data/k3s-volumes` exists and is RW
- **GPU Not Found:** NVIDIA Container Toolkit must be pre-installed on GPU nodes

---

**Status:** Implementation complete. Awaiting Phase 1 testing on network-server-wsl.
