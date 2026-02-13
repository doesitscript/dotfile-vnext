VERBOSE: [STEP] Dynamic Bootstrap Local

VERBOSE: Starting main bootstrap execution.
[CHECK] Loading mapping from: D:\develop\dotfile-vnext\inventory\hosts_mapping.yaml
VERBOSE: [CHECK] Loading mapping from:
D:\develop\dotfile-vnext\inventory\hosts_mapping.yaml
VERBOSE: Load-MappingYaml: 
path=D:\develop\dotfile-vnext\inventory\hosts_mapping.yaml
VERBOSE: Loading module from path 'C:\Program
Files\WindowsPowerShell\Modules\powershell-yaml\powershell-yaml.psm1'.        
VERBOSE: PowerShell-YAML module found. Attempting ConvertFrom-Yaml path.
VERBOSE: Loading module from path 'C:\Program 
Files\WindowsPowerShell\Modules\powershell-yaml\powershell-yaml.psd1'.        
VERBOSE: Importing function 'ConvertFrom-Yaml'.
VERBOSE: Importing function 'ConvertTo-Yaml'.
VERBOSE: Importing alias 'cfy'.
VERBOSE: Importing alias 'cty'.
VERBOSE: Mapping loaded successfully.
VERBOSE: Get-PreferredIPv4: collecting IPv4 addresses.
VERBOSE: Filtered IPv4 candidates: 192.168.50.158
VERBOSE: Mapping subnets considered: 192.168.50., 192.168.50., 192.168.50.,   
192.168.50.
[INFO] Detected hostname: DESKTOP-VLLM
VERBOSE: [INFO] Detected hostname: DESKTOP-VLLM
[INFO] Detected IPs: 192.168.50.158
VERBOSE: [INFO] Detected IPs: 192.168.50.158
[INFO] Chosen IP: 192.168.50.158
VERBOSE: [INFO] Chosen IP: 192.168.50.158
[INFO] Reason: matched mapping subnet 192.168.50.0/24
VERBOSE: [INFO] Reason: matched mapping subnet 192.168.50.0/24
VERBOSE: Preferred IP decision reason: matched mapping subnet 192.168.50.0/24
VERBOSE: Get-PhysicalNodeFromMapping: hostname=DESKTOP-VLLM
preferredIP=192.168.50.158 allIPs=192.168.50.158
Matched physical_node 'server-225' by hostname: DESKTOP-VLLM
VERBOSE: Get-DesiredAnsibleHost: physical_node=server-225 use_dns=True        
[OK] Physical node: server-225
VERBOSE: [OK] Physical node: server-225
[OK] Ansible host: DESKTOP-VLLM
VERBOSE: [OK] Ansible host: DESKTOP-VLLM

[STEP] Collecting runtime facts
VERBOSE: [STEP] Collecting runtime facts
VERBOSE: Beginning privileged setup and fact collection.
[SET] Configuring WinRM HTTP listener/service/firewall (port 5985)
VERBOSE: [SET] Configuring WinRM HTTP listener/service/firewall (port 5985)   
VERBOSE: Running winrm quickconfig -force
[CHECK] Checking for WinRM HTTPS listener
VERBOSE: [CHECK] Checking for WinRM HTTPS listener
[SKIP] WinRM HTTPS listener already exists
VERBOSE: [SKIP] WinRM HTTPS listener already exists
[CHECK] Checking WinRM HTTPS firewall rule (port 5986)
VERBOSE: [CHECK] Checking WinRM HTTPS firewall rule (port 5986)
[SKIP] WinRM HTTPS firewall rule already exists
VERBOSE: [SKIP] WinRM HTTPS firewall rule already exists
[CHECK] Checking WSL feature state
VERBOSE: [CHECK] Checking WSL feature state
VERBOSE: Target Image Version 10.0.26100.32230
VERBOSE: WSL feature state: Enabled
VERBOSE: Initial WSL installed check: True
VERBOSE: Querying installed WSL distros via 'wsl.exe --list --quiet'
VERBOSE: Parsed WSL distro list: Ubuntu-24.04
[OK] WSL distribution found: Ubuntu-24.04
VERBOSE: [OK] WSL distribution found: Ubuntu-24.04
[SET] Writing facts to: D:\develop\dotfile-vnext\facts\server-225.json        
VERBOSE: [SET] Writing facts to:
D:\develop\dotfile-vnext\facts\server-225.json
VERBOSE: Write-Facts: path=D:\develop\dotfile-vnext\facts\server-225.json     
VERBOSE: Facts written successfully.
VERBOSE: Existing Windows host_vars found at:
D:\develop\dotfile-vnext\inventory\host_vars\server-225-win.yaml
Preserved win_password from existing file
VERBOSE: Existing WSL host_vars found at:
D:\develop\dotfile-vnext\inventory\host_vars\server-225-wsl.yaml
Preserved win_password in generated file
[SET] Writing Windows host_vars to: D:\develop\dotfile-vnext\inventory\host_vars\server-225-win.yaml
VERBOSE: [SET] Writing Windows host_vars to:
D:\develop\dotfile-vnext\inventory\host_vars\server-225-win.yaml
VERBOSE: Write-Yaml:
path=D:\develop\dotfile-vnext\inventory\host_vars\server-225-win.yaml
keys=ansible_host, ansible_password, surface_type, host_ip,
ansible_connection, win_ssh_port, winrm_port, ansible_port, win_user,
ansible_user, physical_node, win_password, ansible_winrm_password,
ansible_winrm_scheme, ansible_winrm_transport
VERBOSE: Windows host_vars write complete.
[SET] Writing WSL host_vars to: D:\develop\dotfile-vnext\inventory\host_vars\server-225-wsl.yaml
VERBOSE: [SET] Writing WSL host_vars to:
D:\develop\dotfile-vnext\inventory\host_vars\server-225-wsl.yaml
VERBOSE: Write-Yaml:
path=D:\develop\dotfile-vnext\inventory\host_vars\server-225-wsl.yaml
keys=wsl_user, physical_node, ansible_port, ansible_host, host_ip,
surface_type, ansible_user, wsl_distro, ansible_ssh_private_key_file,
wsl_ssh_port, ansible_connection, ansible_python_interpreter
VERBOSE: WSL host_vars write complete.

[OK] Bootstrap Complete
VERBOSE: [OK] Bootstrap Complete
[STEP] Generated files
VERBOSE: [STEP] Generated files
  - D:\develop\dotfile-vnext\facts\server-225.json
  - D:\develop\dotfile-vnext\inventory\host_vars\server-225-win.yaml
  - D:\develop\dotfile-vnext\inventory\host_vars\server-225-wsl.yaml

[STEP] Configuring OpenSSH Server on Windows (port 22, default shell WSL bash)
VERBOSE: [STEP] Configuring OpenSSH Server on Windows (port 22, default shell 
 WSL bash)
VERBOSE: Target Image Version 10.0.26100.32230
[SKIP] OpenSSH Server already installed
VERBOSE: [SKIP] OpenSSH Server already installed
[SKIP] Firewall rule 'sshd' already exists
VERBOSE: [SKIP] Firewall rule 'sshd' already exists
VERBOSE: sshd_config already has Port 22 in global section
[OK] Default shell set to WSL (Ubuntu-24.04)
VERBOSE: [OK] Default shell set to WSL (Ubuntu-24.04)
VERBOSE: OpenSSH host keys: project dir=, found=0 (repo:
D:\develop\dotfile-vnext)
[SET] Ensuring all OpenSSH host key types exist (ssh-keygen -A adds only missing keys)
VERBOSE: [SET] Ensuring all OpenSSH host key types exist (ssh-keygen -A adds  
only missing keys)
VERBOSE: Generated/updated host key files in C:\ProgramData\ssh : 
ssh_host_ecdsa_key, ssh_host_ecdsa_key.pub, ssh_host_ed25519_key,
ssh_host_ed25519_key.pub, ssh_host_rsa_key, ssh_host_rsa_key.pub
[OK] Host key set verified/updated (no project keys in bootstrap/openssh_host_keys or .mgmt)
VERBOSE: [OK] Host key set verified/updated (no project keys in
bootstrap/openssh_host_keys or .mgmt)
  [WARNING] sshd failed to start: Failed to start service 'OpenSSH SSH Server (sshd)'.
  Check: port 22 not in use, C:\ProgramData\ssh permissions, Event Viewer (Windows Logs / Application).
  Bootstrap will continue (firewall, config, default shell, authorized_keys are still applied).
VERBOSE: sshd restart skipped or failed (non-fatal): Failed to start service 
'OpenSSH SSH Server (sshd)'.
VERBOSE: Checking key sources for authorized_keys:
D:\develop\dotfile-vnext\.mgmt\ansible_ssh.pub,
D:\develop\dotfile-vnext\bootstrap\mac_ssh_key.pub ->
C:\Users\josh\.ssh\authorized_keys
VERBOSE:   Skip (empty/invalid):
D:\develop\dotfile-vnext\.mgmt\ansible_ssh.pub
VERBOSE:   Skip (not found): 
D:\develop\dotfile-vnext\bootstrap\mac_ssh_key.pub
  [INFO] No SSH public key found for Windows authorized_keys.
  To fix (pick one):
    1) From Mac: run  ./bin/fz bootstrap --limit server-225-win   (deploys .mgmt/ansible_ssh.pub to this host, then re-run this script)
    2) Or: copy your Mac public key into repo as  bootstrap/mac_ssh_key.pub  (e.g.  cat ~/.ssh/id_ed25519.pub on Mac), sync repo, then re-run this script   

