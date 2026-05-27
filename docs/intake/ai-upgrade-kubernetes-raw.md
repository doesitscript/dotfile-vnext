Quick note
You’re basically asking: “Design me the policy surface and file layout so AI + Ansible + NetBox + K8s + Docker all behave sanely, modularly, and deeply.”
So here’s a single, comprehensive pass, with separate files, no Docker/Kubernetes mixing, and NetBox split out. Explanations are brief; content is dense.

1. README.md
Purpose: Top‑level orientation.

markdown
# Homelab Automation (NetBox + Ansible + Kubernetes + Docker)

This repository defines a deterministic, NetBox-driven automation framework for my homelab.

Goals:

- Single source of truth: NetBox
- Orchestration: Ansible
- Cluster workloads: Kubernetes (K3s)
- Host-level containers: Docker
- Ingress/routing: Traefik
- AI assistance: Cursor/Copilot constrained by explicit policies

Key properties:

- Declarative over imperative
- Idempotent over ad-hoc
- No `kubectl` or `docker` CLI when modules exist
- Deterministic naming and tagging
- Strict separation of concerns:
  - Kubernetes vs Docker
  - NetBox vs execution
  - Policy vs implementation

See:

- `ARCHITECTURE.md`
- `policy/ANSIBLE_POLICY.md`
- `policy/KUBERNETES_POLICY.md`
- `policy/DOCKER_POLICY.md`
- `policy/NETBOX_POLICY.md`
- `.cursorrules`
2. ARCHITECTURE.md
Purpose: Mental model + flows (2–3 levels deep).

markdown
# Architecture

## 1. Sources of Truth

### 1.1 NetBox
- Devices (controller, workers, infra nodes)
- Roles (k8s-control, k8s-worker, infra, storage)
- IP addresses and interfaces
- Tags (ansible-managed, kubernetes-node, docker-host, traefik-node)
- Sites and tenants

### 1.2 Git Repository
- Ansible playbooks and roles
- Kubernetes manifests / Helm values
- Docker host configuration
- Policy files for AI and humans

---

## 2. Execution Flow

### 2.1 Inventory Build

1. Ansible uses NetBox inventory plugin or custom script.
2. Hosts are grouped by:
   - Site
   - Device role
   - Tags
3. `group_vars` and `host_vars` refine behavior.

### 2.2 Node Bootstrap

- `roles/base-node`:
  - OS baseline (packages, users, SSH, time, logging)
- `roles/docker-host` (if tagged `docker-host`):
  - Install Docker engine
  - Configure Docker daemon
  - Run host-level containers
- `roles/k8s-node` (if tagged `kubernetes-node`):
  - Install K3s
  - Configure node labels/taints
  - Join cluster

### 2.3 Cluster & Services

- `roles/k8s-core`:
  - Core namespaces (infra, monitoring, traefik, apps)
  - Core CRDs (if needed)
- `roles/k8s-apps-*`:
  - App-specific deployments, services, ingresses
- `roles/traefik`:
  - Traefik deployment (Helm or manifests)
  - IngressRoutes / Middleware

### 2.4 Host-Level Services (Docker)

- `roles/docker-services-*`:
  - Node exporter
  - Backup agents
  - Utility containers

---

## 3. Name Resolution & Routing

### 3.1 DNS

- Primary mechanism for name resolution.
- Hostnames follow `NAMING_POLICY.md`.
- Internal domain example: `hom.lab`.

### 3.2 mDNS / LLMNR / WS-Discovery

- Convenience for ad-hoc discovery.
- Not relied upon for automation.

### 3.3 NetBIOS

- Ignored as a design constraint.
- Windows truncation tolerated.

---

## 4. AI Integration

### 4.1 Cursor / Copilot Role

- Generate Ansible roles and playbooks.
- Generate Kubernetes manifests and Helm values.
- Generate Docker tasks using `community.docker`.
- Generate NetBox integration code.

### 4.2 Constraints

- Must follow policies in `policy/`.
- Must not mix Docker and Kubernetes logic in the same role or policy file.
- Must not use `shell`/`command` when a module exists.
- Must not use `kubectl` or `docker` CLI unless explicitly justified and documented.
3. policy/ANSIBLE_POLICY.md
Purpose: Global Ansible rules.

markdown
# Ansible Policy

## 1. Core Principles

1. Declarative where possible.
2. Idempotent always.
3. No `shell` or `command` when a native module exists.
4. No `kubectl` or `docker` CLI for steady-state configuration.
5. Inventory is NetBox-driven.
6. Roles are single-domain and composable.

---

## 2. Module Preferences

### 2.1 Kubernetes

- Use:
  - `kubernetes.core.k8s`
  - `kubernetes.core.k8s_info`
- Do not:
  - Use `shell: kubectl ...`
  - Use `command: kubectl ...`

### 2.2 Docker

- Use:
  - `community.docker.docker_container`
  - `community.docker.docker_image`
  - `community.docker.docker_network`
- Do not:
  - Use `shell: docker ...`
  - Use `command: docker ...`

### 2.3 System & Files

- Use:
  - `ansible.builtin.package`
  - `ansible.builtin.service`
  - `ansible.builtin.user`
  - `ansible.builtin.group`
  - `ansible.builtin.template`
  - `ansible.builtin.copy`
  - `ansible.builtin.lineinfile`
  - `ansible.builtin.blockinfile`

---

## 3. Inventory Structure

```text
ansible/
  inventory/
    hom/
      lab/
        netbox_inventory.yml
  group_vars/
    all.yml
    k8s-control.yml
    k8s-worker.yml
    docker-host.yml
    infra.yml
  host_vars/
    hom-lab-ctl-k8s-01.yml
  roles/
    base-node/
    docker-host/
    docker-services-node-exporter/
    k8s-node/
    k8s-core/
    k8s-apps-<appname>/
    traefik/
4. Role Design Rules
Each role:

Has defaults/main.yml for tunables.

Has tasks/main.yml as orchestrator.

May include tasks/install.yml, tasks/configure.yml, tasks/services.yml.

Roles must be single-domain:

docker-host → Docker engine only.

k8s-node → Kubernetes node only.

k8s-apps-* → Kubernetes apps only.

docker-services-* → Docker containers only.

No role should:

Configure both Docker and Kubernetes.

Depend on hardcoded IPs (use inventory/NetBox).

5. AI-Specific Guidance
When AI generates Ansible:

Prefer roles over monolithic playbooks.

Use import_role / include_role for reuse.

Use when for OS-specific logic.

Avoid inline shell unless:

No module exists,

It is guarded for idempotency,

It is documented with a comment explaining why.

Code

---

## 4. `policy/KUBERNETES_POLICY.md`

**Purpose:** K8s-only rules (no Docker).

```markdown
# Kubernetes Policy

## 1. Scope

This file governs **only** Kubernetes behavior.  
Docker is handled separately in `DOCKER_POLICY.md`.

---

## 2. Cluster Model

- K3s cluster:
  - Controller: `hom-lab-ctl-k8s-01`
  - Workers: `hom-lab-wrk-k8s-0X`
- Nodes are tagged in NetBox as:
  - `k8s-control`
  - `k8s-worker`

---

## 3. Node Labels & Taints

### 3.1 Labels

Derived from naming and NetBox:

- `homelab.namespace=hom`
- `homelab.environment=lab`
- `homelab.stage=ctl|wrk`
- `homelab.service=k8s`
- `homelab.index=01`

Managed via Ansible:

```yaml
- name: Get node info
  kubernetes.core.k8s_info:
    kind: Node
    name: "{{ inventory_hostname }}"
  register: node_info

- name: Ensure node labels
  kubernetes.core.k8s:
    kind: Node
    name: "{{ inventory_hostname }}"
    definition:
      metadata:
        labels: "{{ node_info.resources[0].metadata.labels | default({}) | combine(k8s_required_labels) }}"
3.2 Taints
Control-plane nodes may be tainted to restrict workloads.

Managed via kubernetes.core.k8s with Node definitions.

4. Resource Management
4.1 Manifests
All Kubernetes resources are defined as YAML manifests in Git.

Ansible applies them using kubernetes.core.k8s:

yaml
- name: Apply core namespaces
  kubernetes.core.k8s:
    state: present
    src: files/namespaces.yaml
4.2 Namespaces
Recommended:

infra – infra services (NetBox agents, cluster tools)

monitoring – Prometheus, Grafana, exporters

traefik – Traefik ingress controller

apps – homelab applications

4.3 Ingress
Prefer Traefik (via Helm or manifests).

Use:

Standard Ingress resources, or

Traefik CRDs (IngressRoute, Middleware) if enabled.

5. Helm (Optional)
If Helm is used:

Use community.kubernetes.helm or kubernetes.core.helm (depending on collection).

Values files stored in roles/k8s-apps-*/files/values.yaml.

6. Prohibited Patterns
No shell: kubectl apply -f ....

No kubectl for steady-state configuration.

No mixing Docker modules in Kubernetes roles.

7. AI-Specific Guidance
When AI generates Kubernetes-related content:

Use kubernetes.core.k8s and kubernetes.core.k8s_info.

Keep manifests in files, not giant inline YAML blobs.

Use labels and annotations consistent with NAMING_POLICY.md.

Do not introduce Docker logic in Kubernetes roles or files.

Code

---

## 5. `policy/DOCKER_POLICY.md`

**Purpose:** Docker-only rules (no Kubernetes).

```markdown
# Docker Policy

## 1. Scope

This file governs **only** Docker behavior.  
Kubernetes is handled separately in `KUBERNETES_POLICY.md`.

---

## 2. Role of Docker

- Host-level services:
  - Monitoring agents (e.g., node exporter if not using native)
  - Backup agents
  - Utility containers
- Not for primary app workloads that belong in Kubernetes.

---

## 3. Module Usage

- Use:
  - `community.docker.docker_container`
  - `community.docker.docker_image`
  - `community.docker.docker_network`
- Do not:
  - Use `shell: docker ...`
  - Use `command: docker ...`

Example:

```yaml
- name: Run node exporter container
  community.docker.docker_container:
    name: node-exporter
    image: prom/node-exporter:latest
    restart_policy: always
    network_mode: host
    state: started
4. Role Structure
roles/docker-host:

Install Docker engine

Configure daemon

roles/docker-services-*:

Each service in its own role:

docker-services-node-exporter

docker-services-backup-agent

etc.

5. Naming
Container names:

<host>-<service>-<purpose> where useful.

Networks:

hom-lab-monitoring

hom-lab-backup

6. Prohibited Patterns
No Kubernetes modules in Docker roles.

No kubectl anywhere in Docker-related files.

No mixing host-level Docker services with cluster-level workloads in the same role.

7. AI-Specific Guidance
When AI generates Docker-related Ansible:

Use community.docker modules exclusively.

Keep roles small and single-purpose.

Do not introduce Kubernetes logic or references.

Code

---

## 6. `policy/NETBOX_POLICY.md`

**Purpose:** NetBox-only rules.

```markdown
# NetBox Policy

## 1. Role of NetBox

NetBox is the authoritative source for:

- Devices and roles
- Interfaces and IPs
- Tags (k8s-control, k8s-worker, docker-host, traefik-node, ansible-managed)
- Sites and tenants
- Optionally: services and custom fields

---

## 2. Inventory Integration

Use NetBox inventory plugin or custom script:

```yaml
# ansible/inventory/hom/lab/netbox_inventory.yml
plugin: netbox.netbox.nb_inventory
api_endpoint: https://netbox.hom.lab
token: !vault |
  # ansible-vault encrypted token
validate_certs: true
group_by:
  - site
  - device_roles
  - tags
compose:
  ansible_host: primary_ip.address
3. Tagging Conventions
Device roles:

k8s-control

k8s-worker

infra

storage

Tags:

ansible-managed

kubernetes-node

docker-host

traefik-node

These drive:

Ansible group membership

Role assignment

Kubernetes label derivation

Docker host selection

4. Custom Fields (Optional)
Examples:

cf_k8s_role: control / worker

cf_docker_host: true / false

cf_traefik_node: true / false

Ansible can read these via NetBox API and adjust behavior.

5. AI-Specific Guidance
When AI generates NetBox-related code:

Assume NetBox is authoritative for host/IP/role data.

Do not hardcode IPs when NetBox can provide them.

Use tags and roles to drive Ansible grouping and behavior.

Keep NetBox logic separate from Kubernetes and Docker logic.

Code

---

## 7. `NAMING_POLICY.md`

**Purpose:** Deterministic naming (used by all layers).

```markdown
# Naming Policy

## 1. Hostnames

Pattern:

<namespace>-<environment>-<stage>-<service>-<index>

Example:

- `hom-lab-ctl-k8s-01`
- `hom-lab-wrk-k8s-01`
- `hom-lab-wrk-dkr-01`

Fields:

- `namespace`: `hom`
- `environment`: `lab`, `dev`, `prd`
- `stage`: `ctl`, `wrk`, `inf`, `stg`
- `service`: `k8s`, `dkr`, `nbx`, `mon`, `str`
- `index`: `01`..`99`

## 2. NetBIOS

- Windows truncates to first 15 characters.
- We do not design around NetBIOS.
- Truncation is tolerated.

## 3. Kubernetes

- Node names: same as hostnames.
- Labels:
  - `homelab.namespace`
  - `homelab.environment`
  - `homelab.stage`
  - `homelab.service`
  - `homelab.index`

## 4. Docker

- Container names:
  - `<host>-<service>-<purpose>` where helpful.

## 5. DNS / Traefik

- Internal domain: `hom.lab` (example).
- Hostnames:
  - `traefik.hom.lab`
  - `netbox.hom.lab`
  - `grafana.hom.lab`
  - `prometheus.hom.lab`
8. .cursorrules (AI guidance file)
Purpose: Direct rules for Cursor/Copilot.

markdown
# AI Guidance for This Repository

## 1. Context

You are generating code and configuration for a NetBox-driven, Ansible-based homelab that uses:

- Kubernetes (K3s) for cluster workloads
- Docker for host-level containers
- Traefik for ingress
- NetBox as source of truth

## 2. Hard Constraints

- Do not mix Docker and Kubernetes logic in the same role or policy file.
- Do not use `shell` or `command` when a native module exists.
- Do not use `kubectl` or `docker` CLI for steady-state configuration.
- Do not hardcode IPs when NetBox can provide them.

## 3. Ansible

- Use:
  - `kubernetes.core.k8s`, `kubernetes.core.k8s_info`
  - `community.docker.*`
  - `ansible.builtin.*` for system and files
- Prefer:
  - Roles over monolithic playbooks
  - `import_role` / `include_role` for reuse
- Follow:
  - `policy/ANSIBLE_POLICY.md`

## 4. Kubernetes

- Use `kubernetes.core.k8s` and `kubernetes.core.k8s_info`.
- Keep manifests in files, not giant inline YAML.
- Use labels/annotations consistent with `NAMING_POLICY.md`.
- Follow:
  - `policy/KUBERNETES_POLICY.md`

## 5. Docker

- Use `community.docker.docker_container`, `docker_image`, `docker_network`.
- No `docker` CLI.
- Follow:
  - `policy/DOCKER_POLICY.md`

## 6. NetBox

- Assume NetBox is authoritative for host/IP/role/tag data.
- Use NetBox inventory plugin or API.
- Follow:
  - `policy/NETBOX_POLICY.md`

## 7. Naming

- Follow:
  - `NAMING_POLICY.md`

## 8. Style

- Generate deterministic, readable, minimal-but-complete code.
- Prefer explicit over clever.
- Add brief comments where behavior is non-obvious.
9. Example Ansible layout (2–3 levels deep)
Purpose: Concrete structure AI can mirror.

text
ansible/
  inventory/
    hom/
      lab/
        netbox_inventory.yml
  group_vars/
    all.yml
    k8s-control.yml
    k8s-worker.yml
    docker-host.yml
    infra.yml
  host_vars/
    hom-lab-ctl-k8s-01.yml
  roles/
    base-node/
      defaults/main.yml
      tasks/main.yml
      tasks/packages.yml
      tasks/users.yml
    docker-host/
      defaults/main.yml
      tasks/main.yml
      tasks/install.yml
      tasks/configure.yml
    docker-services-node-exporter/
      defaults/main.yml
      tasks/main.yml
    k8s-node/
      defaults/main.yml
      tasks/main.yml
      tasks/install.yml
      tasks/join.yml
      tasks/labels.yml
    k8s-core/
      defaults/main.yml
      tasks/main.yml
      files/namespaces.yaml
    k8s-apps-example/
      defaults/main.yml
      tasks/main.yml
      files/deployment.yaml
      files/service.yaml
      files/ingress.yaml
    traefik/
      defaults/main.yml
      tasks/main.yml
      files/values.yaml
If you drop these files and structures into your repo, you’ve effectively created a modular, deep, AI-aware contract for how Kubernetes, Docker, Ansible, and NetBox must behave—without needing more back-and-forth.
