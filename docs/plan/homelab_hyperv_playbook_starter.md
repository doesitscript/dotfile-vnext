Hyper‑V VM Creation Playbook (Ansible)
This playbook:

Creates a VM

Sets CPU/RAM

Attaches a VHDX

Connects it to an external virtual switch

Enables secure boot

Mounts an ISO (Ubuntu cloud‑init installer or your custom image)

Starts the VM

It assumes:

You’re running this from your Mac

You’re targeting a Windows Hyper‑V host

You’re using NetBox dynamic inventory

VM attributes come from NetBox (name, CPU, RAM, disk, network)

📁 playbooks/hyperv-create-vm.yml
yaml
- name: Create Hyper-V VM from NetBox metadata
  hosts: hyperv-host
  gather_facts: false
  vars:
    vm_name: "{{ inventory_hostname }}"
    vm_cpu: "{{ hostvars[inventory_hostname].custom_fields.cpu | default(2) }}"
    vm_ram_mb: "{{ hostvars[inventory_hostname].custom_fields.ram_mb | default(4096) }}"
    vm_disk_gb: "{{ hostvars[inventory_hostname].custom_fields.disk_gb | default(40) }}"
    vm_switch: "{{ hostvars[inventory_hostname].custom_fields.vswitch | default('ExternalSwitch') }}"
    vm_iso_path: "{{ hostvars[inventory_hostname].custom_fields.iso_path | default('C:\\ISOs\\ubuntu.iso') }}"
    vm_vhdx_path: "C:\\HyperV\\Disks\\{{ vm_name }}.vhdx"

  tasks:

    - name: Ensure VHDX exists
      ansible.windows.win_powershell:
        script: |
          if (-Not (Test-Path "{{ vm_vhdx_path }}")) {
            New-VHD -Path "{{ vm_vhdx_path }}" -SizeBytes {{ vm_disk_gb }}GB -Dynamic
          }

    - name: Create VM
      community.windows.win_hyperv_guest:
        name: "{{ vm_name }}"
        state: present
        generation: 2
        memory_startup_bytes: "{{ vm_ram_mb | int * 1_048_576 }}"
        processor_count: "{{ vm_cpu }}"
        secure_boot: true
        vhdx_path: "{{ vm_vhdx_path }}"
        switch_name: "{{ vm_switch }}"

    - name: Attach ISO
      community.windows.win_hyperv_guest:
        name: "{{ vm_name }}"
        dvd_drive: "{{ vm_iso_path }}"

    - name: Start VM
      community.windows.win_hyperv_guest:
        name: "{{ vm_name }}"
        state: running
🟩 How NetBox Drives This Playbook
In NetBox, each VM gets custom fields:

Field	Example	Purpose
cpu	2	vCPUs
ram_mb	4096	RAM
disk_gb	40	Disk size
vswitch	ExternalSwitch	Hyper‑V switch
iso_path	C:\ISOs\ubuntu-24.04.iso	Installer
This means:

You don’t hardcode anything

You don’t maintain inventory files

You don’t maintain VM definitions

Everything is driven by NetBox

This is the deterministic, audit‑safe pattern you’ve been building toward.

🟦 NetBox Example VM Entry
Example for lab-hv-k3s-master-01:

Code
name: lab-hv-k3s-master-01
role: k3s-master
platform: ubuntu-22-04
cluster: k3s-homelab
primary_ip4: 192.168.10.21
custom_fields:
  cpu: 2
  ram_mb: 4096
  disk_gb: 40
  vswitch: ExternalSwitch
  iso_path: C:\ISOs\ubuntu-24.04.iso
tags:
  - k3s
  - control-plane
🟧 Dynamic Inventory (NetBox)
Your inventory/netbox.yml:

yaml
plugin: netbox.netbox.nb_inventory
api_endpoint: "http://lab-hv-netbox-01/api/"
token: "{{ lookup('env', 'NETBOX_TOKEN') }}"
validate_certs: false

group_by:
  - device_roles
  - tags
  - platforms
  - clusters

compose:
  ansible_host: primary_ip4.address
Now Ansible automatically knows:

VM names

VM IPs

VM roles

VM tags

VM cluster membership

VM custom fields (CPU, RAM, disk, switch, ISO)

🟩 How This Fits Into Your Full Pipeline
Your automation flow becomes:

Define VM in NetBox

Run hyperv-create-vm.yml

VM boots from ISO

Cloud‑init installs Ubuntu

Ansible connects via SSH

Run Ubuntu bootstrap roles

Install Docker

Install K3s

Deploy Traefik

Deploy LLM nodes (Ollama/vLLM)

This is the end‑to‑end deterministic homelab pipeline you’ve been designing.