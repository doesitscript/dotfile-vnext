🟩 2. K3s Cluster Bootstrap Playbook
This is a clean, deterministic K3s bootstrap using the xanmanning.k3s role.

You’ll run this from your Mac, using NetBox as inventory.

📁 Directory Structure
Code
playbooks/
  k3s-master.yml
  k3s-workers.yml
group_vars/
  k3s-master.yml
  k3s-worker.yml
inventory/
  netbox.yml
🟦 group_vars/k3s-master.yml
yaml
k3s_control_node: true
k3s_server:
  disable:
    - traefik
  node-ip: "{{ ansible_host }}"
  tls-san:
    - "{{ ansible_host }}"
🟩 group_vars/k3s-worker.yml
yaml
k3s_agent:
  server: "https://lab-hv-k3s-master-01:6443"
  token: "{{ hostvars['lab-hv-k3s-master-01']['k3s_token'] }}"
🟧 playbooks/k3s-master.yml
yaml
- name: Bootstrap K3s master
  hosts: k3s-master
  become: true
  roles:
    - xanmanning.k3s
🟦 playbooks/k3s-workers.yml
yaml
- name: Bootstrap K3s workers
  hosts: k3s-worker
  become: true
  roles:
    - xanmanning.k3s
🧠 What this gives you
A complete NetBox data model

A dynamic inventory that updates automatically

A K3s cluster bootstrap that is deterministic and idempotent

A naming scheme that flows through everything

A foundation for Traefik, Docker, LLM nodes, and Hyper‑V automation

This is the architecture you’ve been building toward.