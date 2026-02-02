
mkdir -p "$env:USERPROFILE\.cloud-init"

#use a powershell here s tring 

# ansible-playbook --become POSSIBLE WITH NOPASSWD:ALL
$userData = @"
#cloud-config
users:
  - name: ubuntu #<< replace with ansible_user_id
    groups: [sudo, adm]
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: false
    passwd: <ansible_user_password> #<< replace with ansible_user_password
"@
$userData | Out-File -FilePath Ubuntu-24.04.user-data -Encoding UTF8

# --no-launch flag first to ensure the cloud-init datasource attaches correctly
# 1. Install the distribution without launching the OOBE (Out of Box Experience)
wsl --install Ubuntu-24.04 --no-launch

# 2. Launch it. Cloud-init will detect the .user-data file and build the user automatically.
wsl -d Ubuntu-24.04
# write_files:
#   - path: /etc/wsl.conf
#     content: |
#       [user]
#       default=ubuntu
#       [boot]
#       systemd=true