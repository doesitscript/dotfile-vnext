# Use either hostname or IP from physical_nodes.server-225 above
Make that a variable instead of a comment.

Example pattern:

physical_nodes:
  server-225:
    hostname: "DESKTOP-VLLM"
    ip_address: "192.168.50.158"
    ansible_address_preference: hostname  # or ip
Then in your inventory rendering logic:

if hostname → use DESKTOP-VLLM

if ip → use 192.168.50.158

This prevents Cursor (or future-you) from “helpfully choosing” later.

#
“Make network-server a WSL-runtime node, consistent with server-225. Remove optional wording.

Update only:

inventory/inventory.yaml: uncomment/add network-server-wsl under linux surfaces

add inventory/host_vars/network-server-wsl.yaml (placeholders OK)

ensure deploy_network_stacks targets network-server-wsl (not network-server-win)
Do not modify contracts or roles.”


#### REQUIRED ####
A) true SSH into WSL (openssh-server inside ubuntu)


###
Where you specify which OS to use (Ubuntu version)

This is separate. You need a variable like:

wsl_distro_os: ubuntu

wsl_distro_release: 22.04 (or 24.04)
or as a single value:

wsl_distro_image: ubuntu-22.04

That choice is used only when installing the distro.

wsl_distro_name: ubuntu-wsl-dev

wsl_distro_image: ubuntu-22.04