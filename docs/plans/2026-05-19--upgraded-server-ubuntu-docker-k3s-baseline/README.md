# Implementation Plan: Upgraded Server Ubuntu Docker K3s Baseline

## Executive Summary

This plan outlines the phased implementation of an upgraded server baseline leveraging Ubuntu 26.04 LTS, Docker, and a K3s Kubernetes cluster, integrated with NetBox for IPAM/DCIM. The approach emphasizes idempotent Ansible automation, GitOps principles via ArgoCD, and a layered architecture for infrastructure provisioning, OS configuration, and application deployment.

## Phased Rollout Plan

### Phase 1: Foundation (Weeks 1-2)

**Goal:** Establish core Ansible control plane, Hyper-V host access, and NetBox instance.

**Apply:**
- Set up an Ansible control node capable of managing Windows and Linux hosts.
- Configure WinRM/SSH access to Hyper-V hosts.
- Create base Ubuntu 26.04 LTS VM templates or leverage Hyper-V Quick Create.
- Deploy a functional NetBox instance with API access and initial seed data.

**Verify:**
- Ansible can successfully connect to Hyper-V hosts.
- Ubuntu VMs can be provisioned manually from templates.
- NetBox UI is accessible, and API token is valid.

**Undo:**
- Delete Ansible control node (if VM).
- Remove WinRM/SSH configurations from Hyper-V.
- Delete Ubuntu VM templates/Quick Create images.
- Tear down NetBox instance.

**Change Class:** Bootstrap/Semi-manual

### Phase 2: Baseline Deployment (Weeks 3-4)

**Goal:** Automate Ubuntu VM provisioning, apply a hardened baseline, and register in NetBox.

**Apply:**
- Develop Ansible playbooks to provision Ubuntu VMs on Hyper-V.
- Implement a comprehensive Ubuntu 26.04 LTS baseline configuration role (packages, SSH hardening, firewall, sudo-rs).
- Automate VM registration in NetBox, including IP assignments, using `netbox.netbox` collection.
- Configure `netbox.netbox.nb_inventory` for dynamic inventory sourcing.

**Verify:**
- Ubuntu VMs are provisioned correctly on Hyper-V.
- Baseline configuration is applied idempotently (verified via `--check` and `--diff`).
- VMs appear in NetBox with correct attributes (IP, platform, role, site).
- Ansible `nb_inventory` can list provisioned hosts.

**Undo:**
- Destroy provisioned VMs on Hyper-V.
- Remove VM entries from NetBox.

**Change Class:** Idempotent config (VM provisioning is idempotent where possible, config is idempotent).

### Phase 3: Docker Infrastructure (Weeks 5-6)

**Goal:** Deploy and configure Docker on designated Ubuntu VMs.

**Apply:**
- Integrate `geerlingguy.docker` role into existing playbooks for Docker installation.
- Configure Docker daemon settings (logging, storage drivers).
- Set up Docker networks and volumes via Ansible.
- Update NetBox with `docker` service roles and tags for Docker hosts.

**Verify:**
- Docker daemon is running and enabled on Docker VMs.
- Docker Compose plugin is installed and functional.
- Docker-specific entries (tags, roles) are present in NetBox.

**Undo:**
- Uninstall Docker and associated components.
- Remove Docker-specific entries from NetBox.

**Change Class:** Idempotent config.

### Phase 4: K3s Cluster (Weeks 7-8)

**Goal:** Deploy a highly available K3s Kubernetes cluster.

**Apply:**
- Utilize `k3s-io.k3s_ansible` collection for K3s deployment.
- Configure HA with embedded etcd on 3 server nodes.
- Deploy additional agent nodes for workloads.
- Set up a load balancer (HAProxy/NGINX) for K3s API.

**Verify:**
- K3s cluster is operational and healthy (`kubectl get nodes`).
- HA is functional (e.g., stopping a server node doesn't break cluster).
- Workloads can be scheduled on agent nodes.

**Undo:**
- Uninstall K3s from all nodes.
- Tear down load balancer configuration.

**Change Class:** Idempotent config (with careful planning for HA).

### Phase 5: GitOps Integration (Weeks 9-10)

**Goal:** Implement GitOps for application deployment using ArgoCD.

**Apply:**
- Deploy ArgoCD onto the K3s cluster via Ansible (initial bootstrap).
- Configure Git repository connections for ArgoCD.
- Migrate initial application deployments to ArgoCD (Helm charts, CRDs).
- Document the end-to-end GitOps workflow.

**Verify:**
- ArgoCD UI is accessible and connected to Git repositories.
- Applications are deployed and reconciled by ArgoCD.
- Application deployments are triggered by Git commits.

**Undo:**
- Uninstall ArgoCD and associated resources from K3s.
- Remove Git repository connections.

**Change Class:** Idempotent config.

### Phase 6: Monitoring and Observability (Weeks 11-12)

**Goal:** Establish comprehensive monitoring and logging for the infrastructure.

**Apply:**
- Deploy Prometheus and Grafana on K3s via ArgoCD.
- Configure node exporters via Ansible on all Ubuntu servers.
- Set up centralized logging with Loki (deployed via ArgoCD).
- Create essential dashboards in Grafana.
- Define alerting rules for critical infrastructure metrics.

**Verify:**
- Prometheus is collecting metrics from all nodes.
- Grafana dashboards display relevant data.
- Logs are aggregated in Loki.
- Alerting rules are functional.

**Undo:**
- Uninstall Prometheus, Grafana, Loki, and node exporters.

**Change Class:** Idempotent config.

---

## Architecture/Structure Diagram

```mermaid
graph TD
 subgraph dotfile_vnext [dotfile-vnext Repository]
 subgraph inventory [Inventory Layer]
 all_group[inventory/group_vars/all.yaml<br/>version_contracts]
 host_vars[inventory/host_vars/<br/>hom-lab-ctl-hvh-02.yaml]
 nb_inventory_yml[inventory/netbox.yml<br/>nb_inventory plugin config]
 end
 
 subgraph playbooks [Playbook Layer]
 site_yml[playbooks/site.yaml<br/>Master Playbook]
 deploy_ipam_netbox[playbooks/deploy_ipam_netbox.yaml<br/>tags: ipam_netbox]
 configure_hyperv[playbooks/configure_hyperv_windows_hosts.yaml<br/>tags: hyperv]
 hyperv_ubuntu_docker_vm[playbooks/hyperv_ubuntu_docker_vm.yaml<br/>tags: hyperv_vms]
 k3s_bootstrap[playbooks/k3s_bootstrap.yaml<br/>tags: k3s]
 docker_engine[playbooks/docker_engine.yaml<br/>tags: docker]
 ubuntu_baseline_pb[playbooks/baseline/ubuntu_baseline.yml<br/>tags: ubuntu_baseline]
 end
 
 subgraph roles [Role Layer]
 ipam_netbox_role[roles/ipam_netbox/<br/>NetBox API interaction]
 hyperv_ubuntu_vm_role[roles/hyperv_ubuntu_vm/<br/>Hyper-V VM creation]
 common_node_role[roles/common/node/<br/>NVM & Node.js management]
 k3s_node_config_role[roles/k3s_node_config/<br/>K3s specific config]
 geerlingguy_docker_role[geerlingguy.docker (external)<br/>Docker installation]
 k3s_ansible_coll[k3s-io.k3s_ansible (external)<br/>K3s cluster deployment]
 ubuntu_baseline_role[roles/ubuntu_baseline/<br/>Ubuntu OS hardening]
 end
 
 subgraph docs [Documentation]
 naming_standards[docs/reference/naming-standards/<br/>NetBox & Ansible Conventions]
 plan_current[docs/plans/2026-05-19--upgraded-server-ubuntu-docker-k3s-baseline/README.md<br/>This plan]
 research_file[docs/intake/jupyter-devops-implementation-plans/research/00-upgraded-research.md<br/>Original Research]
 end
 end
 
 subgraph external [External Resources]
 hyperv_host[Hyper-V Host<br/>Windows Server]
 netbox_instance[NetBox Instance<br/>IPAM/DCIM Source of Truth]
 ubuntu_vm[Ubuntu VMs<br/>Managed Nodes]
 npm_registry[npm Registry<br/>Docker/Node Packages]
 github_ansible_coll[GitHub<br/>External Ansible Collections]
 argo_cd[ArgoCD<br/>GitOps Controller]
 git_repo[Git Repository<br/>Application Manifests]
 end
 
 subgraph data_flow [Data Flow]
 version_contracts[Version Contracts<br/>inventory/group_vars/all.yaml]
 netbox_data[NetBox Data<br/>VMs, IPs, Roles, Tags]
 ansible_facts[Ansible Facts<br/>Gathered from VMs]
 k3s_config[K3s Configuration<br/>Cluster Settings]
 docker_config[Docker Configuration<br/>Daemon Settings]
 app_manifests[Application Manifests<br/>GitOps]
 end
 
 site_yml -->|includes| deploy_ipam_netbox
 site_yml -->|includes| configure_hyperv
 site_yml -->|includes| hyperv_ubuntu_docker_vm
 site_yml -->|includes| k3s_bootstrap
 site_yml -->|includes| docker_engine
 site_yml -->|includes| ubuntu_baseline_pb
 
 deploy_ipam_netbox -->|manages| ipam_netbox_role
 ipam_netbox_role -->|seeds/updates| netbox_instance
 ipam_netbox_role -->|uses| naming_standards
 
 configure_hyperv -->|configures| hyperv_host
 hyperv_ubuntu_docker_vm -->|provisions| hyperv_ubuntu_vm_role
 hyperv_ubuntu_vm_role -->|creates| ubuntu_vm
 hyperv_ubuntu_vm_role -->|targets| hyperv_host
 
 docker_engine -->|installs| geerlingguy_docker_role
 geerlingguy_docker_role -->|configures| ubuntu_vm
 geerlingguy_docker_role -->|uses| npm_registry
 
 k3s_bootstrap -->|deploys| k3s_ansible_coll
 k3s_ansible_coll -->|orchestrates| ubuntu_vm
 k3s_bootstrap -->|configures| k3s_node_config_role
 
 ubuntu_baseline_pb -->|applies| ubuntu_baseline_role
 ubuntu_baseline_role -->|hardens| ubuntu_vm
 
 nb_inventory_yml -->|queries| netbox_instance
 nb_inventory_yml -->|provides hosts to| site_yml
 
 version_contracts -->|defines versions for| geerlingguy_docker_role
 version_contracts -->|defines versions for| k3s_ansible_coll
 
 ubuntu_vm -->|provides| ansible_facts
 ubuntu_vm -->|receives| k3s_config
 ubuntu_vm -->|receives| docker_config
 
 argo_cd -->|deploys from| git_repo
 argo_cd -->|manages applications on| ubuntu_vm
 app_manifests -->|define| argo_cd
 
 research_file -->|informs| plan_current
 naming_standards -->|guides| plan_current
 
 style all_group fill:#2a2a2a
 style version_contracts fill:#2a2a2a
 style netbox_data fill:#2a2a2a
 style ansible_facts fill:#2a2a2a
 style k3s_config fill:#2a2a2a
 style docker_config fill:#2a2a2a
 style app_manifests fill:#2a2a2a
 style hyperv_host fill:#1e3a5f
 style netbox_instance fill:#1e3a5f
 style ubuntu_vm fill:#1e3a5f
 style npm_registry fill:#1e3a5f
 style github_ansible_coll fill:#1e3a5f
 style argo_cd fill:#1e3a5f
 style git_repo fill:#1e3a5f
 
```

---

## Diagram Inventory

### Diagrams Included
- **Architecture/Structure Diagram**: Shows repository organization, naming schemes, and integration points

### Additional Diagrams Available On Request
- **Deployment Flow**: Sequential deployment steps across environments
- **State Transition Diagram**: Object lifecycle and state changes
- **Integration Sequence**: Detailed API/service interaction timeline
- **Network Topology**: Host/cluster/network relationships (when infrastructure is in scope)
