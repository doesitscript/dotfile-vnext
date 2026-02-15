ansible windows -m win_command -a "Get-ItemProperty HKLM:\SOFTWARE\OpenSSH" --limit server-225-win

<!-- ansible windows -i inventory.ini -m win_shell -a "Get-Service" -->
ansible  server-225-win -i inventory.ini -m win_shell -a "Get-Service"
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
