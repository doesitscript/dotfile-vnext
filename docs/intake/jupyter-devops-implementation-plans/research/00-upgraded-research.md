# Research: Ubuntu/Docker/K3s Baseline

**Research Date:** May 19, 2026  
**Focus:** Ansible implementation patterns for Ubuntu/Docker/K3s baseline infrastructure

---

## Executive Summary

This research covers current (2026) documentation and established patterns for implementing a multi-node Ubuntu baseline with Docker, K3s, and NetBox integration using Ansible automation. All sources are current and reflect 2026 versions and best practices.

### Key Findings
- K3s-ansible v1.2.0 (March 2026) is the official Ansible collection for K3s clusters
- Ubuntu 26.04 LTS releases April 2026 with Python 3.13, sudo-rs, and OpenSSH 10.0
- NetBox Ansible collection v3.22.0 (December 2025) supports VM/IP modeling automation
- Hyper-V provisioning requires community.windows collection and PowerShell-based modules
- GitOps patterns place Ansible as the middle layer between Terraform and ArgoCD

---

## 1. K3s Installation and Configuration

### Official Documentation

**K3s Official Docs**  
https://docs.k3s.io/installation

Comprehensive installation guide covering:
- Installation methods (curl, air-gap, systemd)
- Configuration options and server/agent roles
- Private registry setup
- Component management (disable built-in components)

**k3s-io/k3s-ansible (Official Ansible Collection)**  
https://github.com/k3s-io/k3s-ansible

- **Latest Release:** v1.2.0 (March 11, 2026)
- **Stars:** 2,760
- **Requirements:** Ansible 8.0+ (ansible-core 2.15+)
- **Supported OS:** Ubuntu, Debian, RHEL family, SUSE, ArchLinux
- **Architectures:** x64, arm64, armhf

### Installation Methods

```bash
# Install via ansible-galaxy
ansible-galaxy collection install git+https://github.com/k3s-io/k3s-ansible.git

# Run provisioning
ansible-playbook playbooks/site.yml -i inventory.yml
```

**Two Primary Approaches:**
1. **Standard Installation** – For internet-connected environments
2. **Air-gapped Installation** – For isolated environments

### High Availability Configuration

**Key Requirements:**
- Odd number of server nodes (3, 5, or 7) for etcd quorum
- Load balancer in front of server nodes (HAProxy, NGINX, cloud LB)
- All server nodes must share identical network/component/feature flags

**HA Architecture Options:**

**Embedded etcd (Recommended)**
- No external database dependency
- Bundled directly with K3s server nodes
- Requires odd number of nodes for quorum
- Full cluster recovery from etcd snapshots

**External Database**
- Requires only 2+ server nodes
- Supports MySQL and other external datastores
- Useful for larger deployments

**Quorum Fault Tolerance:**
- 3 nodes: tolerates 1 failure
- 5 nodes: tolerates 2 failures

**Critical Configuration Consistency:**

All server nodes must have identical settings for:
```yaml
# Network flags
--cluster-dns
--cluster-domain
--cluster-cidr
--service-cidr

# Component flags
--disable-helm-controller
--disable-kube-proxy
--disable-network-policy

# Feature flags
--secrets-encryption
```

**Load Balancer Setup:**

Include load balancer IP in TLS SANs when initializing:
```bash
--tls-san=<LOAD_BALANCER_IP>
```

**Network Requirements:**
- Low-latency network between server nodes (< 10ms recommended)
- Essential for etcd quorum communication

**Automated Upgrades:**
- Use `system-upgrade-controller` for rolling upgrades while maintaining HA

### Ansible Implementation Notes

**Inventory Structure:**
```yaml
[server]
k3s-server-1
k3s-server-2
k3s-server-3

[agent]
k3s-agent-1
k3s-agent-2
```

**Automatic HA:**
- HA mode is automatically configured when multiple hosts are in the server group
- Must be odd numbers (3, 5, or 7 nodes)

**Passwordless SSH:**
- All managed nodes need passwordless SSH access and root access (or equivalent)
- Recommended to disable firewalls and swap on managed nodes

**Further Reading:**
- High Availability Embedded etcd: https://docs.k3s.io/datastore/ha-embedded
- High Availability External DB: https://docs.k3s.io/datastore/ha
- The Basic HA Cluster: https://docs.k3s.io/blog/2025/03/10/simple-ha
- How to Configure K3s with Embedded HA: https://oneuptime.com/blog/post/2026-03-20-k3s-embedded-ha-etcd/view

---

## 2. Docker on Ubuntu

### Official Ansible Role: geerlingguy.docker

**Repository:**  
https://github.com/geerlingguy/ansible-role-docker

- **Stars:** 2,243
- **Created:** 2017
- **Last Updated:** March 2026
- **License:** MIT
- **Maintained by:** Jeff Geerling

**Key Features:**
- Supports both Docker CE and EE
- Installs docker-cli, rootless-extras, containerd.io
- Optional Docker Compose plugin installation (enabled by default)
- Removes obsolete Docker packages before installation
- Compatible with multiple distributions (Ubuntu, Debian, CentOS, Red Hat, SUSE)
- Configurable service management and start-on-boot settings
- No external requirements

**Installation:**
```bash
ansible-galaxy install geerlingguy.docker
```

**Basic Playbook Usage:**
```yaml
- hosts: docker_hosts
  roles:
    - geerlingguy.docker
```

**Variables:**
```yaml
docker_edition: 'ce'  # or 'ee'
docker_install_compose_plugin: true
docker_service_manage: true
docker_service_state: started
docker_service_enabled: true
```

### Ubuntu 26.04 LTS Test Container

**Repository:**  
https://github.com/geerlingguy/docker-ubuntu2604-ansible

Docker container specifically for testing Ansible playbooks on Ubuntu 26.04 LTS (Resolute Raccoon)

**Docker Hub:**  
https://hub.docker.com/r/geerlingguy/docker-ubuntu2604-ansible

Useful for CI/CD testing workflows before applying to production Ubuntu 26.04 systems.

### Ubuntu 24.04 LTS Test Container

**Repository:**  
https://github.com/geerlingguy/docker-ubuntu2404-ansible

Similar container for Ubuntu 24.04 LTS (Noble Numbat) testing.

### Ansible Implementation Notes

**Role Installation:**
1. Add to `requirements.yml`:
```yaml
roles:
  - name: geerlingguy.docker
    version: latest
```

2. Install via ansible-galaxy:
```bash
ansible-galaxy install -r requirements.yml
```

**Docker Compose Management:**
- The role installs Docker Compose as a plugin by default
- Compose commands use `docker compose` (not `docker-compose`)
- Legacy standalone Docker Compose can be disabled via variables

**Service Management:**
- Docker daemon starts automatically on boot (default)
- Can be controlled via `docker_service_state` and `docker_service_enabled` variables

**Security Considerations:**
- Add users to docker group for non-root access
- Consider rootless Docker for enhanced security
- Configure daemon.json for logging and resource limits

---

## 3. NetBox Integration

### Official Ansible Collection: netbox.netbox

**Documentation:**  
https://netbox-ansible-collection.readthedocs.io/en/stable

- **Latest Version:** 3.22.0 (December 31, 2025)
- **Requirements:** Python 3.11+, Ansible 2.18+
- **Repository:** https://github.com/netbox-community/ansible_modules

**Installation:**
```bash
ansible-galaxy collection install netbox.netbox
```

**Required Python Packages:**
```bash
pip install pytz pynetbox
```

### Key Modules for VM/IP Modeling

**netbox_virtual_machine**  
https://netbox-ansible-collection.readthedocs.io/en/latest/plugins/netbox_virtual_machine_module.html

Creates, updates, or deletes virtual machines within NetBox.

**Key Parameters:**
- `cluster`: Cluster assignment (required)
- `vcpus`: Virtual CPU count
- `memory`: Memory in MB
- `platform`: Operating system platform
- `status`: VM status (active, offline, staged, etc.)
- `custom_fields`: Additional metadata

**Example:**
```yaml
- name: Create virtual machine in NetBox
  netbox.netbox.netbox_virtual_machine:
    netbox_url: "{{ netbox_url }}"
    netbox_token: "{{ netbox_token }}"
    data:
      name: docker-vm-01
      cluster: homelab-cluster
      vcpus: 4
      memory: 8192
      platform: Ubuntu 26.04
      status: active
    state: present
```

**netbox_ip_address**  
https://netbox-ansible-collection.readthedocs.io/en/latest/plugins/netbox_ip_address_module.html

Creates or removes IP addresses from NetBox.

**Key Parameters:**
- `address`: IP address with CIDR notation
- `assigned_object`: Virtual machine and interface assignment
  - `virtual_machine`: VM name
  - `name`: Interface name
- `status`: IP status (active, reserved, deprecated, etc.)
- `dns_name`: DNS hostname

**Example:**
```yaml
- name: Assign IP to VM interface
  netbox.netbox.netbox_ip_address:
    netbox_url: "{{ netbox_url }}"
    netbox_token: "{{ netbox_token }}"
    data:
      address: "192.168.1.10/24"
      assigned_object:
        virtual_machine: docker-vm-01
        name: eth0
      status: active
      dns_name: docker-vm-01.homelab.local
    state: present
```

### NetBox Inventory Plugin

**netbox.netbox.nb_inventory**

Dynamic inventory plugin that queries NetBox for hosts, groups, and variables.

**Configuration (netbox.yml):**
```yaml
plugin: netbox.netbox.nb_inventory
api_endpoint: https://netbox.example.com
token: your_api_token_here
validate_certs: true
config_context: true
group_by:
  - device_roles
  - platforms
  - sites
  - clusters
```

**Usage:**
```bash
ansible-inventory -i netbox.yml --list
ansible-playbook -i netbox.yml playbook.yml
```

### Ansible Implementation Notes

**Authentication:**
- Requires write-enabled API token for modules
- Token should be stored in Ansible vault or environment variable

**Using FQCN:**
```yaml
# Preferred: Fully Qualified Collection Name
- name: Create VM
  netbox.netbox.netbox_virtual_machine:
    # ...

# Alternative: Collections directive at play level
- hosts: localhost
  collections:
    - netbox.netbox
  tasks:
    - name: Create VM
      netbox_virtual_machine:
        # ...
```

**IP Assignment Workflow:**
1. Ensure VM exists in NetBox
2. Create VM interface (`netbox_vm_interface`)
3. Assign IP to interface (`netbox_ip_address`)
4. Set as primary IP on VM if needed

**Known Considerations:**
- When assigning IPs to VM interfaces, use proper `assigned_object` structure
- Both `virtual_machine` and interface `name` must be specified
- Requires NetBox 3.x or 4.x (one of the two most recent releases)

**Further Reading:**
- Modules Documentation: https://netbox-ansible-collection.readthedocs.io/en/latest/getting_started/how-to-use/modules.html
- Ansible Collections Index: https://docs.ansible.com/ansible/latest/collections/netbox/netbox

---

## 4. Hyper-V and Ubuntu VM Provisioning

### Hyper-V Management with Ansible

**Primary Collection: community.windows**  
https://docs.ansible.com/ansible/latest/collections/community/windows

- **Latest Release:** v3.1.0 (November 2025)
- **Tested Against:** Ansible 2.16 and newer
- **Repository:** https://github.com/ansible-collections/community.windows

**Installation:**
```bash
ansible-galaxy collection install community.windows
```

**Note:** The community.windows collection does not include comprehensive built-in Hyper-V modules as of 2026. Hyper-V automation typically requires:
1. Custom PowerShell-based modules
2. Community-developed Hyper-V collections (e.g., jamesdkelly88.win_hyperv)
3. Direct PowerShell execution via win_powershell or win_shell

### Hyper-V VM Provisioning Patterns

**Basic Approach:**
1. Execute PowerShell commands on Hyper-V host via Ansible
2. Create Generation 2 VMs with specified memory/storage
3. Attach Ubuntu installation media
4. Configure firmware and boot settings
5. Start VM and proceed with installation

**Example PowerShell Commands (via Ansible):**
```powershell
# Create VM
New-VM -Name "ubuntu-vm-01" -Generation 2 -MemoryStartupBytes 4GB -SwitchName "vSwitch"

# Create VHD
New-VHD -Path "C:\VMs\ubuntu-vm-01.vhdx" -SizeBytes 50GB -Dynamic

# Add VHD to VM
Add-VMHardDiskDrive -VMName "ubuntu-vm-01" -Path "C:\VMs\ubuntu-vm-01.vhdx"

# Attach ISO
Add-VMDvdDrive -VMName "ubuntu-vm-01" -Path "C:\ISO\ubuntu-26.04-server-amd64.iso"

# Disable Secure Boot (required for Ubuntu)
Set-VMFirmware -VMName "ubuntu-vm-01" -EnableSecureBoot Off

# Set boot order
Set-VMFirmware -VMName "ubuntu-vm-01" -FirstBootDevice (Get-VMDvdDrive -VMName "ubuntu-vm-01")

# Start VM
Start-VM -Name "ubuntu-vm-01"
```

**Ansible Playbook Pattern:**
```yaml
- name: Provision Ubuntu VM on Hyper-V
  hosts: hyperv_hosts
  tasks:
    - name: Check if VM already exists
      ansible.windows.win_powershell:
        script: |
          Get-VM -Name "{{ vm_name }}" -ErrorAction SilentlyContinue
      register: vm_check
      failed_when: false

    - name: Create VM if it doesn't exist
      ansible.windows.win_powershell:
        script: |
          New-VM -Name "{{ vm_name }}" -Generation 2 -MemoryStartupBytes {{ vm_memory }} -SwitchName "{{ vm_switch }}"
      when: vm_check.output == ""

    # Additional tasks for VHD, ISO, firmware, etc.
```

### Ubuntu on Hyper-V Compatibility

**Supported Ubuntu Versions:**  
https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/supported-ubuntu-virtual-machines-on-hyper-v

- **Ubuntu 16.04 LTS through 24.04 LTS** supported on Windows Server 2016-2025
- All supported versions include built-in Linux Integration Services (LIS)
- Support for networking, storage, dynamic memory, live migration

**Ubuntu 26.04 LTS** (releasing April 2026):
- Expected to be supported on Hyper-V (pattern based on previous LTS releases)
- Built-in LIS in kernel
- Generation 2 VM support
- Secure Boot compatibility (must be disabled during installation)

**Official Ubuntu Hyper-V Setup Guide:**  
https://documentation.ubuntu.com/server/how-to/virtualisation/ubuntu-on-hyper-v/

### Advanced Provisioning with AWX/Ansible

**Reference Guide:**  
https://adminjournal.substack.com/p/provisioning-and-deprovisioning-hyper (May 2025)

**Key Features:**
- Execute provisioning scripts on Hyper-V hosts
- Check for existing VMs before provisioning
- Automatically update Ansible inventory with newly provisioned VM IP addresses
- Manage multiple VM deployments in a single playbook

**Required Collections:**
- `community.windows`
- `microsoft.ad` (for Active Directory integration if needed)

### Ansible Implementation Notes

**Connection Requirements:**
- Ansible runs playbooks against the Hyper-V host (Windows machine), not the Ubuntu VMs directly
- Requires WinRM or SSH access to Windows host
- PowerShell must be available on the Ansible control node for Windows module execution

**VM Configuration Workflow:**
1. Create VM on Hyper-V host
2. Attach virtual disks and network adapters
3. Mount Ubuntu ISO for installation
4. Configure firmware settings (disable Secure Boot)
5. Start VM and monitor for installation completion
6. Post-installation: SSH to Ubuntu guest for configuration
7. Update Ansible inventory with new VM details

**Post-Provisioning:**
- Use Ubuntu baseline configuration playbooks (see Section 5)
- Install Docker or K3s roles as needed
- Register VM in NetBox with IP assignments

**Alternative Approaches:**
- Quick Create VMs (pre-built images from Hyper-V gallery)
- Packer for creating Ubuntu VM templates
- Cloud-init for automated Ubuntu configuration

---

## 5. Ubuntu Server Baseline Configuration

### Ubuntu 26.04 LTS Specifications (April 2026)

**Key Changes:**
- **Default sudo:** sudo-rs (Rust rewrite) replaces traditional sudo
- **Default Python:** 3.13
- **Default OpenSSH:** 10.0
- **Default kernel:** 6.14
- **Support:** Standard until April 2031, ESM until April 2036

**Ansible Compatibility:**
- Use **ansible-core 2.20** or later (2.21 when available)
- Python 3.13 on managed nodes requires ansible-core >= 2.18
- Pin Python interpreter explicitly: `ansible_python_interpreter=/usr/bin/python3`
- `ansible_become_method=sudo` works transparently with sudo-rs

### Baseline Configuration Ansible Roles

**konstruktoid/ansible-role-baseline**  
https://github.com/konstruktoid/ansible-role-baseline

Comprehensive security hardening role for Ubuntu/Debian systems.

**andrewdanser/ansible-server-hardening**  
https://github.com/andrewdanser/ansible-server-hardening

Security baseline playbook covering multiple distributions.

**elpy1/vps-secure-baseline**  
https://github.com/elpy1/vps-secure-baseline

VPS-focused security baseline configuration.

### Essential Baseline Elements

**1. Package Management**

Install baseline packages:
- vim, curl, htop, tmux
- chrony (time synchronization)
- ufw (firewall)
- apparmor-utils
- unattended-upgrades
- sudo-rs
- fail2ban

**2. sudo-rs Configuration**

Create sudoers.d policies for Ansible group access:
```yaml
- name: Configure sudo for Ansible
  ansible.builtin.copy:
    content: |
      %ansible ALL=(ALL) NOPASSWD: ALL
    dest: /etc/sudoers.d/ansible
    mode: '0440'
    validate: 'visudo -cf %s'
```

**3. Security Hardening**

- **SSH Hardening:**
  - Disable root login
  - Disable password authentication
  - Configure via `/etc/ssh/sshd_config.d/` drop-ins

- **Firewall Configuration:**
  - Enable UFW (Uncomplicated Firewall)
  - Allow only required ports (SSH, HTTP/HTTPS, etc.)

- **Fail2ban:**
  - Install and configure for SSH protection
  - Protect against brute-force attacks

- **Automatic Security Updates:**
  - Enable unattended-upgrades
  - Configure to install security updates automatically

- **Audit Logging:**
  - Enable auditd for security event logging

**4. System Configuration**

- Update and upgrade all packages
- Configure systemd timesyncd for NTP
- Set timezone
- Configure persistent journald storage
- Disable unnecessary services

### Security Baseline Best Practices

**Reference Guide:**  
https://readthemanual.co.uk/ansible-linux-security-baseline-tutorial/

**Key Practices:**
1. Run baseline automation on fresh installations
2. Test in non-production environments first
3. Review variables before applying to established hosts
4. Use inventory grouping for managed hosts
5. Document deviations from baseline in inventory variables

### Baseline Playbook Structure

```yaml
---
- name: Ubuntu Server Baseline Configuration
  hosts: ubuntu_servers
  become: true
  vars:
    ansible_python_interpreter: /usr/bin/python3
    
  tasks:
    - name: Update apt cache
      ansible.builtin.apt:
        update_cache: yes
        cache_valid_time: 3600

    - name: Upgrade all packages
      ansible.builtin.apt:
        upgrade: dist
        autoremove: yes
        autoclean: yes

    - name: Install baseline packages
      ansible.builtin.apt:
        name:
          - vim
          - curl
          - htop
          - chrony
          - ufw
          - fail2ban
          - unattended-upgrades
          - sudo-rs
        state: present

    - name: Configure time synchronization
      ansible.builtin.systemd:
        name: systemd-timesyncd
        state: started
        enabled: yes

    - name: Configure UFW firewall
      community.general.ufw:
        state: enabled
        policy: deny
        direction: incoming

    - name: Allow SSH through firewall
      community.general.ufw:
        rule: allow
        port: '22'
        proto: tcp

    - name: Disable SSH root login
      ansible.builtin.lineinfile:
        path: /etc/ssh/sshd_config
        regexp: '^#?PermitRootLogin'
        line: 'PermitRootLogin no'
        validate: '/usr/sbin/sshd -t -f %s'
      notify: Restart SSH

  handlers:
    - name: Restart SSH
      ansible.builtin.systemd:
        name: ssh
        state: restarted
```

### Ansible Implementation Notes

**Idempotency:**
- Ensure all tasks are idempotent (can run multiple times safely)
- Use `state: present` instead of commands where possible
- Use `changed_when` for shell/command tasks

**Testing:**
- Use `--check` mode for dry runs
- Test on a single host before rolling out to fleet
- Validate SSH configuration before restarting sshd

**Documentation:**
- Document baseline in README.md
- List all installed packages and their purposes
- Document firewall rules and ports

---

## 6. Multi-Node Infrastructure and GitOps Patterns

### Three-Layer Architecture

Modern multi-node server infrastructure employs separation of concerns:

**Layer 1: Infrastructure Provisioning (Terraform)**
- Creates VMs and bare metal nodes
- Provisions storage and networking
- Manages cloud resources

**Layer 2: OS Configuration (Ansible)**
- Handles system hardening
- Installs base packages
- Configures container runtimes
- Sets up Kubernetes packages
- Manages SSH and network settings
- Performs node health checks

**Layer 3: Application Deployment (GitOps/ArgoCD)**
- Manages Kubernetes workloads
- Deploys applications via Helm charts
- Watches Git repositories as source of truth
- Handles cluster state reconciliation

**Reference Architecture:**  
https://daltonousley.com/blog/homelab-ansible-middle-layer

### Ansible's Middle Layer Role

Ansible serves as the configuration management bridge between infrastructure and applications.

**Key Responsibilities:**
- OS-level configuration (users, packages, services)
- Container runtime setup (Docker, containerd configuration)
- Kubernetes package installation (kubelet, kubectl)
- SSH hardening and network connectivity
- Node health checks and service monitoring
- Certificate management
- Log aggregation setup

**What Ansible Should NOT Manage:**
- Application deployments inside Kubernetes (use ArgoCD/Flux)
- Infrastructure resource creation (use Terraform)
- Secrets management at application level (use Sealed Secrets/Vault)

### GitOps Integration with ArgoCD

**Reference Guide:**  
https://docs.sudhanva.me/explanation/automation-model/

**ArgoCD Responsibility:**
- Infrastructure components running inside the cluster
- Application workloads
- Helm chart deployments
- Custom resource definitions (CRDs)
- ConfigMaps and Secrets (from Vault)

**ArgoCD + Ansible Pattern:**
```yaml
# Ansible handles:
- Node preparation
- Kubernetes installation
- Initial cluster bootstrap
- System-level configuration

# ArgoCD handles (via GitOps):
- Installing cert-manager
- Deploying ingress controllers
- Application deployments
- Continuous deployment from Git
```

### Production-Grade Multi-Node Patterns (2026)

**Reference Article:**  
https://dev.to/ezejioforog/kubeadm-to-rke2-transformed-my-k8s-homelab-into-production-grade-infra-m7f

**21-Node Multi-Zone Cluster Example:**
- Three physical datacenters
- RKE2 distribution (replacing kubeadm)
- Security-first architecture
- True HA with external etcd
- Specialized worker pools:
  - Database nodes (persistent storage)
  - AI/ML workload nodes (GPU-enabled)
  - Latency-sensitive application nodes

**Key Features:**
- Deterministic, repeatable infrastructure
- Self-healing through automation
- Version-controlled configuration
- Complete rebuild capability from code

### MicroK8s on Hybrid Hardware

**Reference:**  
https://github.com/VX1632/Ansible-playbooks

Deployment patterns for MicroK8s on mixed architectures:
- ARM and x86_64 nodes in same cluster
- Raspberry Pi integration
- Edge computing use cases

### Ansible Implementation Notes

**Inventory Organization:**

```yaml
all:
  children:
    infrastructure:
      children:
        hyperv_hosts:
          hosts:
            hyperv-server-01:
        
    kubernetes:
      children:
        k3s_servers:
          hosts:
            k3s-server-01:
            k3s-server-02:
            k3s-server-03:
        k3s_agents:
          hosts:
            k3s-agent-01:
            k3s-agent-02:
    
    docker_hosts:
      hosts:
        docker-vm-01:
        docker-vm-02:
```

**Playbook Organization:**

```
playbooks/
├── site.yml                    # Master playbook
├── infrastructure/
│   └── provision_vms.yml       # Hyper-V VM provisioning
├── baseline/
│   └── ubuntu_baseline.yml     # Ubuntu baseline config
├── docker/
│   └── install_docker.yml      # Docker installation
├── k3s/
│   └── deploy_cluster.yml      # K3s cluster deployment
└── netbox/
    └── sync_inventory.yml      # NetBox synchronization
```

**Tag Strategy:**

```yaml
# Run full stack
ansible-playbook playbooks/site.yml

# Run only VM provisioning
ansible-playbook playbooks/site.yml --tags provision

# Run only baseline configuration
ansible-playbook playbooks/site.yml --tags baseline

# Run only Docker installation
ansible-playbook playbooks/site.yml --tags docker

# Run only K3s deployment
ansible-playbook playbooks/site.yml --tags k3s

# Run only NetBox sync
ansible-playbook playbooks/site.yml --tags netbox
```

**GitOps Integration:**

```yaml
# After Ansible provisions and configures nodes:
1. K3s cluster is operational
2. Deploy ArgoCD via Ansible (initial bootstrap)
3. ArgoCD takes over application management
4. Future application changes via Git commits
5. ArgoCD automatically syncs cluster state

# Ansible continues to manage:
- OS updates and patches
- System configuration changes
- Node additions/removals
- Infrastructure-level changes
```

### Best Practices for Multi-Node Deployments

**Rolling Updates:**
- Use serial execution for critical updates
- Implement health checks between nodes
- Maintain quorum during updates (K3s/etcd)

**Monitoring and Observability:**
- Deploy Prometheus/Grafana via GitOps
- Use Ansible for node-level metric exporters
- Centralized logging (Loki, Elasticsearch)

**Disaster Recovery:**
- Regular etcd backups (K3s)
- Infrastructure as Code repository backups
- Document manual recovery procedures
- Test disaster recovery regularly

**Security:**
- Network segmentation (firewall rules)
- RBAC in Kubernetes
- Secrets management (Vault, Sealed Secrets)
- Regular security updates via Ansible

---

## 7. Additional Resources and Tools

### Ansible Collections to Consider

**ansible.posix**  
https://docs.ansible.com/ansible/latest/collections/ansible/posix/

Essential for Linux system management (mount, selinux, firewalld, etc.)

**community.general**  
https://docs.ansible.com/ansible/latest/collections/community/general/

Broad collection with ufw, snap, various package managers, etc.

**kubernetes.core**  
https://docs.ansible.com/ansible/latest/collections/kubernetes/core/

Kubernetes resource management from Ansible (k8s, helm modules)

### Testing and Validation Tools

**Molecule**  
https://molecule.readthedocs.io/

Testing framework for Ansible roles

**Ansible Lint**  
https://ansible-lint.readthedocs.io/

Linter for Ansible playbooks and roles

**Testinfra**  
https://testinfra.readthedocs.io/

Infrastructure testing framework (works with Pytest)

### Infrastructure as Code Tools

**Terraform**  
https://www.terraform.io/

Infrastructure provisioning (VMs, networks, cloud resources)

**Packer**  
https://www.packer.io/

VM image building and templating

**cloud-init**  
https://cloudinit.readthedocs.io/

Cloud instance initialization

### Monitoring and Observability

**Prometheus**  
https://prometheus.io/

Metrics collection and alerting

**Grafana**  
https://grafana.com/

Metrics visualization and dashboards

**Loki**  
https://grafana.com/oss/loki/

Log aggregation (Prometheus-style)

---

## 8. Implementation Roadmap

### Phase 1: Foundation
1. Set up Ansible control node
2. Configure Hyper-V host access (WinRM/SSH)
3. Create Ubuntu VM templates or Quick Create images
4. Establish baseline Ubuntu configuration playbook
5. Set up NetBox instance and API access

### Phase 2: Baseline Deployment
1. Provision Ubuntu VMs on Hyper-V
2. Apply Ubuntu baseline configuration
3. Register VMs in NetBox with IP assignments
4. Configure dynamic inventory (NetBox plugin)
5. Validate SSH access and privilege escalation

### Phase 3: Docker Infrastructure
1. Deploy geerlingguy.docker role to Docker VMs
2. Configure Docker daemon settings
3. Set up Docker networks and volumes
4. Deploy container workloads
5. Update NetBox with service roles and tags

### Phase 4: K3s Cluster
1. Deploy K3s using k3s-ansible collection
2. Configure HA with embedded etcd (3 server nodes)
3. Add agent nodes for workloads
4. Set up load balancer (HAProxy/NGINX)
5. Validate cluster health and networking

### Phase 5: GitOps Integration
1. Deploy ArgoCD on K3s cluster
2. Configure Git repository connections
3. Migrate application deployments to ArgoCD
4. Set up CI/CD pipelines
5. Document GitOps workflow

### Phase 6: Monitoring and Observability
1. Deploy Prometheus/Grafana via ArgoCD
2. Configure node exporters via Ansible
3. Set up centralized logging (Loki)
4. Create dashboards for infrastructure metrics
5. Configure alerting rules

---

## Sources Checked

**K3s:**
- K3s Official Documentation: https://docs.k3s.io/installation
- k3s-ansible GitHub: https://github.com/k3s-io/k3s-ansible
- K3s HA Embedded etcd: https://docs.k3s.io/datastore/ha-embedded
- K3s HA External DB: https://docs.k3s.io/datastore/ha
- How to Configure K3s HA: https://oneuptime.com/blog/post/2026-02-02-k3s-high-availability/view
- How to Configure K3s Embedded HA: https://oneuptime.com/blog/post/2026-03-20-k3s-embedded-ha-etcd/view

**Docker:**
- geerlingguy.docker GitHub: https://github.com/geerlingguy/ansible-role-docker
- Ubuntu 26.04 Test Container: https://github.com/geerlingguy/docker-ubuntu2604-ansible
- Ubuntu 24.04 Test Container: https://github.com/geerlingguy/docker-ubuntu2404-ansible

**NetBox:**
- netbox.netbox Collection Docs: https://netbox-ansible-collection.readthedocs.io/en/stable
- netbox_virtual_machine Module: https://netbox-ansible-collection.readthedocs.io/en/latest/plugins/netbox_virtual_machine_module.html
- netbox_ip_address Module: https://netbox-ansible-collection.readthedocs.io/en/latest/plugins/netbox_ip_address_module.html
- Ansible Collections NetBox: https://docs.ansible.com/ansible/latest/collections/netbox/netbox
- NetBox Community GitHub: https://github.com/netbox-community/ansible_modules

**Hyper-V and Ubuntu:**
- community.windows Collection: https://docs.ansible.com/ansible/latest/collections/community/windows
- community.windows GitHub: https://github.com/ansible-collections/community.windows
- Provisioning Hyper-V with Ansible: https://adminjournal.substack.com/p/provisioning-and-deprovisioning-hyper
- Ubuntu on Hyper-V Support: https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/supported-ubuntu-virtual-machines-on-hyper-v
- Ubuntu Hyper-V Setup: https://documentation.ubuntu.com/server/how-to/virtualisation/ubuntu-on-hyper-v/

**Ubuntu Baseline:**
- Ansible on Ubuntu 26.04: https://www.ansiblepilot.com/articles/ansible-on-ubuntu-26-04-lts-automation-complete-guide
- ansible-server-hardening: https://github.com/andrewdanser/ansible-server-hardening
- ansible-role-baseline: https://github.com/konstruktoid/ansible-role-baseline
- vps-secure-baseline: https://github.com/elpy1/vps-secure-baseline
- Secure Linux Servers with Ansible: https://readthemanual.co.uk/ansible-linux-security-baseline-tutorial/

**Multi-Node and GitOps:**
- Ansible Middle Layer: https://daltonousley.com/blog/homelab-ansible-middle-layer
- GitOps with ArgoCD: https://docs.sudhanva.me/explanation/automation-model/
- RKE2 Production Infrastructure: https://dev.to/ezejioforog/kubeadm-to-rke2-transformed-my-k8s-homelab-into-production-grade-infra-m7f
- Ansible GitOps with ArgoCD: https://www.ansiblebyexample.com/articles/ansible-gitops-argocd-infrastructure-delivery
- Ansible-playbooks (MicroK8s): https://github.com/VX1632/Ansible-playbooks

---

**Last Updated:** May 19, 2026  
**Researcher:** Cursor AI Agent  
**Next Steps:** Review with project team and begin Phase 1 implementation
