1. Hyper‑V Host Automation (Windows side)
You need these to create VMs, configure switches, attach disks, and manage checkpoints.

Collections
Code
ansible-galaxy collection install ansible.windows
ansible-galaxy collection install community.windows
Modules you’ll actually use
win_hyperv_guest

win_hyperv_host

win_hyperv_network

win_feature

win_shell

win_command

Design pattern
Treat Hyper‑V as a provider

Treat Ubuntu VMs as artifacts

Use a naming scheme that encodes purpose + environment + index

Example:

Code
vm-hv-k3s-master-01
vm-hv-k3s-worker-01
vm-hv-traefik-01