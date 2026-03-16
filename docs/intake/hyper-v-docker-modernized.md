# Hyper-V + Multipass: Docker-Ready Ubuntu VMs (Development Workflow)
Workflow for deploying development-ready Ubuntu instances on Windows Server (Hyper‑V backend) using Multipass and Ansible.
---
NOTE: There may be a ansible resource that makes calling cmdline unecesary for many or any parts OR is may not be compatable with windows and the below is the closet to converting this setup to an ansible implmentation. See the following:
https://galaxy.ansible.com/ui/repo/published/theko2fi/multipass/content/module/multipass_vm/
https://galaxy.ansible.com/ui/repo/published/theko2fi/multipass/content/connection/multipass/
https://github.com/theko2fi/ansible-multipass-collection

---

## 1. Technical requirements
- Host OS: Windows Server (with Hyper‑V enabled) or Windows 10/11 Pro (Hyper‑V).
- Tooling: Multipass (Canonical’s lightweight VM orchestrator).
- Automation: cloud-init for Day‑0 configuration (SSH keys, packages, users).
---
## 2. Turnkey deployment process
### Step A — Identify the network adapter (for bridged mode)
To give the VM its own LAN IP, identify the active Windows network adapter:
```powershell
Get-NetAdapter
# Note the 'Name' (e.g., "Ethernet" or "Wi‑Fi")
Use that adapter name with the --network Multipass option.

Step B — Create cloud-config.yaml
Create a cloud‑init file to configure SSH access and preinstall development tools. Replace the SSH key placeholder with your public key:

# ai this shoul dbe a secret vua ansible's secret 
#cloud-config
ssh_authorized_keys:
  - ssh-rsa AAAAB3Nza...<YOUR_PUBLIC_KEY>... user@machine 
packages:
  - git
  - curl
  - docker.io
  - python3-pip
  - build-essential
runcmd:
  - usermod -aG docker ubuntu
  - systemctl enable docker
Step C — Launch the VM (bridged, dev-ready)
Run Multipass to launch a bridged instance named devbox:

multipass launch --name devbox --network "<AdapterName>" --cloud-init cloud-config.yaml
Replace <AdapterName> with the adapter name discovered in Step A.

3. Management & orchestration
Common instance lifecycle commands:

Get IP address:
multipass info devbox
SSH directly:
ssh ubuntu@<assigned-ip>
Stop instance:
multipass stop devbox
Destroy & purge:
multipass delete devbox --purge
Ansible inventory example
Use this to start orchestrating the VM immediately:

[dev_hosts]
devbox ansible_host=<assigned-ip> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa
4. Key advantages vs. legacy methods (Vagrant/manual)
Native performance: Uses Hyper‑V API without third‑party VM layers.
Speed: SSH‑ready provisioning often completes in < 60 seconds.
Networking: Native bridging gives the VM its own LAN MAC/IP.
Immutable infra: multipass delete --purge leaves minimal residue on the host.
