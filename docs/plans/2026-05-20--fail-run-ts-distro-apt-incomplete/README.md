
20 #   when: ansible_facts['system'] != "Windows"
21
22 - name: Deploy Docker CLI shell config to .bashrc.d
     ^ column 3

<<< caused by >>>

Finalization of task args for 'ansible.builtin.template' failed.
Origin: /Users/joshc/develop/dotfile-vnext/roles/docker_client/tasks/main.yml:23:3

21
22 - name: Deploy Docker CLI shell config to .bashrc.d
23   ansible.builtin.template:
     ^ column 3

<<< caused by >>>

Error while resolving value for 'dest': object of type 'dict' has no attribute 'HOME'
Origin: /Users/joshc/develop/dotfile-vnext/roles/docker_client/tasks/main.yml:25:11

23   ansible.builtin.template:
24     src: docker.bash.j2
25     dest: "{{ ansible_env.HOME }}/.bashrc.d/docker.bash"
             ^ column 11

fatal: [hom-lab-ctl-hvh-02]: FAILED! => {"changed": false, "msg": "Task failed: Finalization of task args for 'ansible.builtin.template' failed: Error while resolving value for 'dest': object of type 'dict' has no attribute 'HOME'"}
fatal: [hom-lab-ctl-hvh-01]: FAILED! => {"changed": false, "msg": "Task failed: Finalization of task args for 'ansible.builtin.template' failed: Error while resolving value for 'dest': object of type 'dict' has no attribute 'HOME'"}
ok: [mac-dev]

TASK [docker_client : Inspect existing Docker context (mac-dev)] ***************
ok: [mac-dev]

TASK [docker_client : Set expected Docker engine endpoint] *********************
ok: [mac-dev]

TASK [docker_client : Check current Docker context] ****************************
ok: [mac-dev]

TASK [docker_client : Set Docker default context to mac-dev] *******************
changed: [mac-dev]

TASK [docker_client : Report Docker client configuration] **********************
ok: [mac-dev] => {
    "msg": "Docker client on mac-dev: context=mac-dev, engine=ssh://joshc@server-225-wsl:22"
}

PLAY [Docker - verify client connectivity] *************************************

TASK [Validate Docker client can reach engine] *********************************
included: verify_docker for mac-dev

TASK [verify_docker : Validate Docker CLI is installed] ************************
ok: [mac-dev]

TASK [verify_docker : Check Docker engine connectivity via context] ************
ok: [mac-dev]

TASK [verify_docker : Show Docker client verification results] *****************
ok: [mac-dev] => {
    "msg": [
        "CLI: Docker version 29.2.1, build a5c7197d72",
        "Engine: "
    ]
}

PLAY RECAP *********************************************************************
dev-workstation-win        : ok=0    changed=0    unreachable=1    failed=0    skipped=0    rescued=0    ignored=0   
mac-dev                    : ok=14   changed=1    unreachable=0    failed=0    skipped=8    rescued=0    ignored=0   
hom-lab-ctl-hvh-01         : ok=5    changed=3    unreachable=0    failed=1    skipped=3    rescued=0    ignored=0   
network-server-wsl         : ok=0    changed=0    unreachable=1    failed=0    skipped=0    rescued=0    ignored=0   
hom-lab-ctl-hvh-02             : ok=5    changed=0    unreachable=0    failed=1    skipped=3    rescued=0    ignored=0   
server-225-wsl             : ok=0    changed=0    unreachable=1    failed=0    skipped=0    rescued=0    ignored=0   

(.venv) Joshs-MBP:dotfile-vnext joshc$ ansible-playbook playbooks/docker.yaml -i inventory/inventory.yaml
 *  History restored 

direnv: loading ~/develop/dotfile-vnext/.envrc
direnv: export +OBJC_DISABLE_INITIALIZE_FORK_SAFETY +no_proxy ~XPC_SERVICE_NAME
Joshs-MBP:dotfile-vnext joshc$ git add .
Joshs-MBP:dotfile-vnext joshc$ git commit -m "vAlpha log envirment"
[main 054f1b4] vAlpha log envirment
 6 files changed, 84 insertions(+), 4 deletions(-)
 create mode 100644 .ansible-lint
 create mode 100644 playbooks/logging.yaml
Joshs-MBP:dotfile-vnext joshJoshs-MBP:dotfile-vnext josh
Joshs-MBP:dotfile-vnext joshJoshs-MBP:dotfile-vnext josh
Joshs-MBP:dotfile-vnext joshJoshs-MBP:dotfile-vnext josh
Joshs-MBP:dotfile-vnext joshJoshs-MBP:dotfile-vnext josh
Joshs-MBP:dotfile-vnext joshc$ ansible-playbook pl^Cbooks/access.yaml -i inventory/inventory.yaml --limit 'execution_nodes,network_server
,hom-lab-ctl-hvh-02'
Joshs-MBP:dotfile-vnext joshc$ ansible-playbook playbooks/access_windows.yaml \
  -i inventory/inventory.yaml \
  --limit hom-lab-ctl-hvh-02 \
  --tags wsl-^Cset,wsl
Joshs-MBP:dotfile-vnext joshc$ ansible-playbook playbooks/access_windows.yaml \
  -i inventory/inventory.yaml \
  --limit 'hom-lab-ctl-hvh-02,network_server' \
  --tags wsl-reset,wsl

PLAY [Access - windows identity] ********************************************************************************************************

TASK [Configure Hyper-V bridge infrastructure] ******************************************************************************************
included: hyperv_networking for hom-lab-ctl-hvh-02, hom-lab-ctl-hvh-01

TASK [Configure Windows identity and WSL] ***********************************************************************************************
included: access_identity_windows for hom-lab-ctl-hvh-02, hom-lab-ctl-hvh-01

TASK [access_identity_windows : Read controller public key from execution node] *********************************************************
ok: [hom-lab-ctl-hvh-01 -> mac-dev]
ok: [hom-lab-ctl-hvh-02 -> mac-dev]

TASK [access_identity_windows : Set controller public key content fact] *****************************************************************
ok: [hom-lab-ctl-hvh-02]
ok: [hom-lab-ctl-hvh-01]

TASK [access_identity_windows : Verify controller public key was loaded] ****************************************************************
ok: [hom-lab-ctl-hvh-02] => {
    "changed": false,
    "msg": "All assertions passed"
}
ok: [hom-lab-ctl-hvh-01] => {
    "changed": false,
    "msg": "All assertions passed"
}

TASK [access_identity_windows : Resolve WSL companion for reset] ************************************************************************
ok: [hom-lab-ctl-hvh-02]
ok: [hom-lab-ctl-hvh-01]

TASK [access_identity_windows : Check if WSL distro is registered] **********************************************************************
[ERROR]: Task failed: winrm or requests is not installed: No module named 'winrm'
Origin: /Users/joshc/develop/dotfile-vnext/roles/access_identity_windows/tasks/wsl_reset.yml:16:3

14     _wsl_distro: "{{ hostvars[inventory_hostname | regex_replace('-win$', '-wsl')]['wsl_distro'] | default(wsl_dis...
15
16 - name: Check if WSL distro is registered
     ^ column 3

fatal: [hom-lab-ctl-hvh-02]: FAILED! => {"changed": false, "msg": "Task failed: winrm or requests is not installed: No module named 'winrm'"}
fatal: [hom-lab-ctl-hvh-01]: FAILED! => {"changed": false, "msg": "Task failed: winrm or requests is not installed: No module named 'winrm'"}

PLAY RECAP ******************************************************************************************************************************
hom-lab-ctl-hvh-01         : ok=6    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   
hom-lab-ctl-hvh-02             : ok=6    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   

Joshs-MBP:dotfile-vnext joshc$ ansible-playbook playbooks/access_windows.yaml   -i inventory/inventory.yaml   --limit 'hom-lab-ctl-hvh-02,network_server'   --tags wsl-reset,wsl^C
Joshs-MBP:dotfile-vnext joshc$ source .envrc && source .venv/bin/
activate && ansible-playbook playbooks/windows_base.yaml -i inven
tory/inventory.yaml
[ERROR]: the playbook: playbooks/windows_base.yaml could not be found
(.venv) Joshs-MBP:dotfile-vnext joshc$ ^C
(.venv) Joshs-MBP:dotfile-vnext joshc$ source .envrc && source .venv/bin/activate && ansible-playbook playbooks/access_windows.yam
l   -i inventory/inventory.yaml   --limit 'hom-lab-ctl-hvh-02,network
_server'   --tags wsl-reset,wsl

PLAY [Access - windows identity] ***********************************************

TASK [Configure Hyper-V bridge infrastructure] *********************************
included: hyperv_networking for hom-lab-ctl-hvh-02, hom-lab-ctl-hvh-01

TASK [Configure Windows identity and WSL] **************************************
included: access_identity_windows for hom-lab-ctl-hvh-02, hom-lab-ctl-hvh-01

TASK [access_identity_windows : Read controller public key from execution node] ***
ok: [hom-lab-ctl-hvh-01 -> mac-dev]
ok: [hom-lab-ctl-hvh-02 -> mac-dev]

TASK [access_identity_windows : Set controller public key content fact] ********
ok: [hom-lab-ctl-hvh-02]
ok: [hom-lab-ctl-hvh-01]

TASK [access_identity_windows : Verify controller public key was loaded] *******
ok: [hom-lab-ctl-hvh-02] => {
    "changed": false,
    "msg": "All assertions passed"
}
ok: [hom-lab-ctl-hvh-01] => {
    "changed": false,
    "msg": "All assertions passed"
}

TASK [access_identity_windows : Resolve WSL companion for reset] ***************
ok: [hom-lab-ctl-hvh-02]
ok: [hom-lab-ctl-hvh-01]

TASK [access_identity_windows : Check if WSL distro is registered] *************
ok: [hom-lab-ctl-hvh-02]
ok: [hom-lab-ctl-hvh-01]

TASK [access_identity_windows : Unregister WSL distro (Ubuntu-24.04)] **********
changed: [hom-lab-ctl-hvh-02]
changed: [hom-lab-ctl-hvh-01]

TASK [access_identity_windows : Report WSL reset result] ***********************
ok: [hom-lab-ctl-hvh-02] => {
    "msg": "WSL distro 'Ubuntu-24.04': unregistered — will be re-provisioned by the wsl tag"
}
ok: [hom-lab-ctl-hvh-01] => {
    "msg": "WSL distro 'Ubuntu-24.04': unregistered — will be re-provisioned by the wsl tag"
}

TASK [access_identity_windows : Resolve WSL companion hostname] ****************
ok: [hom-lab-ctl-hvh-02]
ok: [hom-lab-ctl-hvh-01]

TASK [access_identity_windows : Verify WSL companion host exists in inventory] ***
ok: [hom-lab-ctl-hvh-02] => {
    "changed": false,
    "msg": "All assertions passed"
}
ok: [hom-lab-ctl-hvh-01] => {
    "changed": false,
    "msg": "All assertions passed"
}

TASK [access_identity_windows : Resolve WSL variables from companion host] *****
ok: [hom-lab-ctl-hvh-02]
ok: [hom-lab-ctl-hvh-01]

TASK [access_identity_windows : Resolve WSL config contract] *******************
ok: [hom-lab-ctl-hvh-02]
ok: [hom-lab-ctl-hvh-01]

TASK [access_identity_windows : Display resolved WSL configuration] ************
ok: [hom-lab-ctl-hvh-02] => {
    "msg": "WSL companion: server-225-wsl | distro: Ubuntu-24.04 | user: joshc | ssh_port: 22 | ssh_dir: /home/joshc/.ssh | authorized_keys: /home/joshc/.ssh/authorized_keys | networking_mode: bridged"
}
ok: [hom-lab-ctl-hvh-01] => {
    "msg": "WSL companion: network-server-wsl | distro: Ubuntu-24.04 | user: joshc | ssh_port: 22 | ssh_dir: /home/joshc/.ssh | authorized_keys: /home/joshc/.ssh/authorized_keys | networking_mode: bridged"
}

TASK [access_identity_windows : Ensure bridged WSL requires Hyper-V bridge infrastructure] ***
ok: [hom-lab-ctl-hvh-02] => {
    "changed": false,
    "msg": "All assertions passed"
}
ok: [hom-lab-ctl-hvh-01] => {
    "changed": false,
    "msg": "All assertions passed"
}

TASK [access_identity_windows : Install WSL (Windows Subsystem for Linux)] *****
ok: [hom-lab-ctl-hvh-02]
ok: [hom-lab-ctl-hvh-01]

TASK [access_identity_windows : Deploy .wslconfig with bridged networking] *****
ok: [hom-lab-ctl-hvh-02]
ok: [hom-lab-ctl-hvh-01]

TASK [access_identity_windows : Ensure Hyper-V firewall allows inbound SSH to WSL] ***
ok: [hom-lab-ctl-hvh-02]
ok: [hom-lab-ctl-hvh-01]

TASK [access_identity_windows : Resolve Windows USERPROFILE path] **************
changed: [hom-lab-ctl-hvh-02]
changed: [hom-lab-ctl-hvh-01]

TASK [access_identity_windows : Ensure cloud-init directory exists] ************
ok: [hom-lab-ctl-hvh-02]
ok: [hom-lab-ctl-hvh-01]

TASK [access_identity_windows : Create cloud-init user-data for WSL distro] ****
ok: [hom-lab-ctl-hvh-02]
ok: [hom-lab-ctl-hvh-01]

TASK [access_identity_windows : Normalise cloud-init user-data to LF line endings] ***
ok: [hom-lab-ctl-hvh-02]
ok: [hom-lab-ctl-hvh-01]

TASK [access_identity_windows : Read cloud-init user-data for verification] ****
ok: [hom-lab-ctl-hvh-02]
ok: [hom-lab-ctl-hvh-01]

TASK [access_identity_windows : Report cloud-init user-data path and contents] ***
ok: [hom-lab-ctl-hvh-02] => {
    "msg": "Cloud-init user-data: C:\\Users\\joshc\\.cloud-init\\Ubuntu-24.04.user-data\nStatus: already current\nContents:\n#cloud-config\nusers:\n  - name: joshc\n    groups: [sudo, adm]\n    sudo: \"ALL=(ALL) NOPASSWD:ALL\"\n    shell: /bin/bash\n    lock_passwd: false\n    passwd: Pass@w0rd1\n\nwrite_files:\n  - path: /etc/wsl.conf\n    content: |\n      [boot]\n      systemd=true\n      [user]\n      default=joshc\n  - path: /etc/profile.d/wsl-path.sh\n    permissions: '0644'\n    content: |\n      # Ensure core Linux paths are always present in WSL shells.\n      # Without this, wsl.exe entry points may only have Windows paths,\n      # making systemctl, journalctl, and other system binaries unavailable.\n      for _d in /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin; do\n        case \":$PATH:\" in\n          *\":$_d:\"*) ;;\n          *) export PATH=\"$_d:$PATH\" ;;\n        esac\n      done\n      unset _d\n"
}
ok: [hom-lab-ctl-hvh-01] => {
    "msg": "Cloud-init user-data: C:\\Users\\joshc\\.cloud-init\\Ubuntu-24.04.user-data\nStatus: already current\nContents:\n#cloud-config\nusers:\n  - name: joshc\n    groups: [sudo, adm]\n    sudo: \"ALL=(ALL) NOPASSWD:ALL\"\n    shell: /bin/bash\n    lock_passwd: false\n    passwd: Pass@w0rd1\n\nwrite_files:\n  - path: /etc/wsl.conf\n    content: |\n      [boot]\n      systemd=true\n      [user]\n      default=joshc\n  - path: /etc/profile.d/wsl-path.sh\n    permissions: '0644'\n    content: |\n      # Ensure core Linux paths are always present in WSL shells.\n      # Without this, wsl.exe entry points may only have Windows paths,\n      # making systemctl, journalctl, and other system binaries unavailable.\n      for _d in /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin; do\n        case \":$PATH:\" in\n          *\":$_d:\"*) ;;\n          *) export PATH=\"$_d:$PATH\" ;;\n        esac\n      done\n      unset _d\n"
}

TASK [access_identity_windows : Check installed WSL distributions] *************
ok: [hom-lab-ctl-hvh-02]
ok: [hom-lab-ctl-hvh-01]

TASK [access_identity_windows : Install WSL distribution (Ubuntu-24.04)] *******
changed: [hom-lab-ctl-hvh-02]
changed: [hom-lab-ctl-hvh-01]

TASK [access_identity_windows : First launch and shutdown WSL distro (cloud-init + wsl.conf apply)] ***
changed: [hom-lab-ctl-hvh-01]
changed: [hom-lab-ctl-hvh-02]

TASK [access_identity_windows : Set default WSL distribution to Ubuntu-24.04] ***
ok: [hom-lab-ctl-hvh-02]
ok: [hom-lab-ctl-hvh-01]

TASK [access_identity_windows : Report WSL distribution status] ****************
ok: [hom-lab-ctl-hvh-02] => {
    "msg": "WSL distro 'Ubuntu-24.04': just installed"
}
ok: [hom-lab-ctl-hvh-01] => {
    "msg": "WSL distro 'Ubuntu-24.04': just installed"
}

TASK [access_identity_windows : Pre-warm WSL to trigger bridged network initialization] ***
changed: [hom-lab-ctl-hvh-02]
changed: [hom-lab-ctl-hvh-01]

TASK [access_identity_windows : Wait for WinRM to recover after WSL bridged network initialization] ***
ok: [hom-lab-ctl-hvh-02]
ok: [hom-lab-ctl-hvh-01]

TASK [access_identity_windows : Update WSL distribution packages] **************
changed: [hom-lab-ctl-hvh-01]

^C[ERROR]: User interrupted execution
(.venv) Joshs-MBP:dotfile-vnext joshc$ source .envrc && source .venv/bin/activate && ansible-playbook playbooks/access_windows.yaml   -i inventory/inventory.yaml   --limit 'hom-lab-ctl-hvh-02,network_server'   --tags wsl-reset,wsl

PLAY [Access - windows identity] ********************************************************************************************************

TASK [Configure Hyper-V bridge infrastructure] ******************************************************************************************
included: hyperv_networking for hom-lab-ctl-hvh-02, hom-lab-ctl-hvh-01

TASK [Configure Windows identity and WSL] ***********************************************************************************************
included: access_identity_windows for hom-lab-ctl-hvh-02, hom-lab-ctl-hvh-01

TASK [access_identity_windows : Read controller public key from execution node] *********************************************************
ok: [hom-lab-ctl-hvh-01 -> mac-dev]
ok: [hom-lab-ctl-hvh-02 -> mac-dev]

TASK [access_identity_windows : Set controller public key content fact] *****************************************************************
ok: [hom-lab-ctl-hvh-02]
ok: [hom-lab-ctl-hvh-01]

TASK [access_identity_windows : Verify controller public key was loaded] ****************************************************************
ok: [hom-lab-ctl-hvh-02] => {
    "changed": false,
    "msg": "All assertions passed"
}
ok: [hom-lab-ctl-hvh-01] => {
    "changed": false,
    "msg": "All assertions passed"
}

TASK [access_identity_windows : Resolve WSL companion for reset] ************************************************************************
ok: [hom-lab-ctl-hvh-02]
ok: [hom-lab-ctl-hvh-01]

TASK [access_identity_windows : Check if WSL distro is registered] **********************************************************************
ok: [hom-lab-ctl-hvh-02]
ok: [hom-lab-ctl-hvh-01]
