# RUn a command on a remote system:

ansible  server-225-win -m win_shell -a "bash --version"



ansible windows -m win_command -a "Get-ItemProperty HKLM:\SOFTWARE\OpenSSH" --limit server-225-win

<!-- ansible windows -i inventory.ini -m win_shell -a "Get-Service" -->
# debug outpout
(.venv) Joshs-MBP:dotfile-vnext joshc$ ssh -i ~/.ssh/id_ed25519_ansible joshc@DESKTOP-VLLM -vvv

# works
ansible  server-225-win -m win_shell -a "Get-ItemProperty HKLM:\SOFTWARE\OpenSSH"
ansible  server-225-win -m win_shell -a "wsl -d Ubuntu-24.04"

server-225-win -m win_shell -a "Get-ItemProperty HKLM:\SOFTWARE\OpenSSH"
server-225-win | CHANGED | rc=0 >>


DefaultShell              : bash.exe
DefaultShellCommandOption : -d Ubuntu-24.04
PSPath                    : Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SOFTWARE\OpenSSH
PSParentPath              : Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SOFTWARE
PSChildName               : OpenSSH
PSDrive                   : HKLM
PSProvider                : Microsoft.PowerShell.Core\Registry
####

---
- name: Run a command on Windows host
  hosts: windows
  gather_facts: false
  tasks:
    - name: Execute a PowerShell command
      ansible.windows.win_shell: |
        # Example PowerShell command
        Get-Service -Name WinRM

source .envrc && source .venv/bin/activate && ansible-playbook playbooks/transport_10_windows_openssh_via_winrm.yaml -i inventory/inventory.yaml --limit server-225-win

source .envrc && source .venv/bin/activate && ansible-playbook playbooks/transport_10_windows_openssh_via_winrm.yaml -i inventory/inventory.yaml --limit server-225-win


ansible server-225-win -m win_command -a "Get-ItemProperty HKLM:\SOFTWARE\OpenSSH" -i inventory/inventory.yaml 
ansible server-225-win -m win_command -a "Get-ItemProperty HKLM:\SOFTWARE\OpenSSH" 
ansible server-225-win -m win_command -a '([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")'


ls -l ~/.ssh/id_ed25519_ansible*

-rw-------  1 joshc  staff  387 Feb 15 16:20 /Users/joshc/.ssh/id_ed25519_ansible
-rw-------  1 joshc  staff   82 Feb 15 16:20 /Users/joshc/.ssh/id_ed25519_ansible.pub
PS C:\ProgramData\ssh> cat administrators_authorized_keys
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINfuz30l/udmapF0YQVmeUwDuyrfi5YHxtGmJLhTczZq
ssh-keygen -lf <(echo "AAAAC3NzaC1lZDI1NTE5AAAAINfuz30l/udmapF0YQVmeUwDuyrfi5YHxtGmJLhTczZq")