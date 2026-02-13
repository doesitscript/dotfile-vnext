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


X
X
WINRM_HTTP_PORT
WINRM_HTTPS_PORT
WINRM_TRANSPORT
SSH_PORT

ansible_user: Username
ansible_password: Password

Enable-WSManCredSSP -Role Server -Force


# winrm
ansible_connection: winrm
ansible_winrm_transport: credssp

Enable-WSManCredSSP -Role Server -Force
pipx inject "pypsrp[credssp]<=1.0.0"  # for psrp
pipx inject "pywinrm[credssp]>=0.4.0"  # for winrm


####

# Enables the WinRM service and sets up the HTTP listener
Enable-PSRemoting -Force

# Opens port 5985 for all profiles
$firewallParams = @{
    Action      = 'Allow'
    Description = 'Inbound rule for Windows Remote Management via WS-Management. [TCP 5985]'
    Direction   = 'Inbound'
    DisplayName = 'Windows Remote Management (HTTP-In)'
    LocalPort   = 5985
    Profile     = 'Any'
    Protocol    = 'TCP'
}
New-NetFirewallRule @firewallParams

# Allows local user accounts to be used with WinRM
# This can be ignored if using domain accounts
$tokenFilterParams = @{
    Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    Name         = 'LocalAccountTokenFilterPolicy'
    Value        = 1
    PropertyType = 'DWORD'
    Force        = $true
}
New-ItemProperty @tokenFilterParams



#########
Using the winrm or psrp connection plugins in Ansible on MacOS in the latest releases typically fails. This is a known problem that occurs deep within the Python stack and cannot be changed by Ansible. The only workaround today is to set the environment variable OBJC_DISABLE_INITIALIZE_FORK_SAFETY=yes, no_proxy=* and avoid using Kerberos auth.

pipx inject ansible "pywinrm>=0.4.0"  # for winrm
