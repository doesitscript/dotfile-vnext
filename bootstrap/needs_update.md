can we design a local running bootstrap ansible step that sets up only wsman, psremoting, wsl + ssh in wsl meant to only run locally, and then updaates that computers inventory with the crrect values set
Thought for 22s

yes. the clean way to do this is:

run a “local bootstrap” on the target machine that:

configures windows wsman / psremoting / winrm https listener

enables wsl + installs a distro (if missing)

configures ssh inside wsl (openssh-server + keys)

writes a single “facts” file (json/yaml) with the discovered values

updates only host_vars (not the big inventory yaml), so your inventory stays stable and idempotent

key design choice
don’t try to rewrite inventory/inventory.yaml in-place. keep inventory minimal and stable, and let per-host host_vars carry the changing values. that’s what prevents “wrong password / wrong host / wrong port” chaos.

proposed repo layout additions

bootstrap/
  local/
    local_bootstrap.yml
    templates/
      host_vars_windows.yml.j2
      host_vars_wsl.yml.j2
bin/
  bootstrap-local.ps1
  bootstrap-local.sh
facts/
  .gitkeep
host_vars/
  server-225-win.yml
  server-225-wsl.yml


inventory pattern (stable)
your inventory entry should reference vars that live in host_vars, not hard-coded values:

windows_hosts:
  hosts:
    server-225-win:
      ansible_connection: winrm
      ansible_host: "{{ host_ip }}"
      ansible_port: "{{ winrm_port }}"
      ansible_user: "{{ win_user }}"
      ansible_password: "{{ win_password }}"   # stays as vault var name in host_vars
      ansible_winrm_transport: ntlm
      ansible_winrm_server_cert_validation: ignore
      physical_node: server-225
      surface_type: windows_host

wsl_hosts:
  hosts:
    server-225-wsl:
      ansible_connection: ssh
      ansible_host: "{{ host_ip }}"
      ansible_port: "{{ wsl_ssh_port }}"
      ansible_user: "{{ wsl_user }}"
      physical_node: server-225
      surface_type: wsl


then the bootstrap’s job is to create/update host_vars/server-225-win.yml and host_vars/server-225-wsl.yml with the correct host_ip, ports, usernames, and any discovered details (like wsl distro name), while leaving secrets as vault references.

bootstrap flow (2-phase, because wsl enablement may require reboot)

phase 0: prerequisite
you need ansible runnable locally on the target. easiest: run from inside wsl once it exists.
so the very first time, you run a windows powershell script to enable wsl and reboot if needed.

phase 1: windows bootstrap (powershell, local-only)

enable psremoting

enable/configure winrm https (5986) + firewall

enable wsl features; install distro if missing (or confirm existing)

emit facts to facts/server-225.json

phase 2: wsl bootstrap (ansible playbook, local-only)

install + configure openssh-server in wsl

set up authorized_keys for your controlling laptop key (recommended)

emit facts again (merge/overwrite) and write host_vars files from templates

you end up with:

windows winrm ready for remote ansible

wsl ssh ready for remote ansible

host_vars updated so remote runs use correct values

bin/bootstrap-local.ps1 (windows local-only)
run this on the target machine as admin (double click or powershell). it’s idempotent.

# bin/bootstrap-local.ps1
# run as admin on the target windows machine

$ErrorActionPreference = "Stop"

function Write-Facts($path, $obj) {
  $dir = Split-Path -Parent $path
  if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
  $obj | ConvertTo-Json -Depth 6 | Set-Content -Path $path -Encoding UTF8
}

# basic identity
$hostname = $env:COMPUTERNAME
$ip = (Get-NetIPAddress -AddressFamily IPv4 `
  | Where-Object { $_.IPAddress -notlike "169.254.*" -and $_.InterfaceAlias -notlike "*Loopback*" } `
  | Select-Object -First 1 -ExpandProperty IPAddress)

# enable psremoting / winrm
Enable-PSRemoting -Force

# ensure winrm service
Set-Service WinRM -StartupType Automatic
Start-Service WinRM

# create/ensure https listener on 5986
$existingHttps = (winrm enumerate winrm/config/listener) -match "Transport = HTTPS"
if (-not $existingHttps) {
  $cert = New-SelfSignedCertificate -DnsName $hostname -CertStoreLocation Cert:\LocalMachine\My
  $thumb = $cert.Thumbprint
  winrm create winrm/config/Listener?Address=*+Transport=HTTPS "@{Hostname=`"$hostname`"; CertificateThumbprint=`"$thumb`"}"
} else {
  # best-effort extract thumbprint (not perfect, but ok for facts)
  $thumb = (Get-ChildItem Cert:\LocalMachine\My | Sort-Object NotAfter -Descending | Select-Object -First 1).Thumbprint
}

# firewall for 5986
if (-not (Get-NetFirewallRule -DisplayName "WinRM HTTPS 5986" -ErrorAction SilentlyContinue)) {
  netsh advfirewall firewall add rule name="WinRM HTTPS 5986" dir=in action=allow protocol=TCP localport=5986 | Out-Null
}

# enable wsl features (may require reboot)
$wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
$vmFeature  = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform

$needsReboot = $false
if ($wslFeature.State -ne "Enabled") { Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart | Out-Null; $needsReboot = $true }
if ($vmFeature.State  -ne "Enabled") { Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart | Out-Null; $needsReboot = $true }

# check if wsl exists
$wslExists = $false
try { wsl -l -q | Out-Null; $wslExists = $true } catch { $wslExists = $false }

# if wsl exists, get distro list
$distroList = @()
if ($wslExists) {
  $distroList = (wsl -l -q) | Where-Object { $_ -and $_.Trim().Length -gt 0 }
}

$facts = [ordered]@{
  physical_node = "server-225"
  windows = @{
    hostname = $hostname
    host_ip = $ip
    winrm_port = 5986
    winrm_transport = "ntlm"
    winrm_https_thumbprint = $thumb
  }
  wsl = @{
    features_enabled = ($wslFeature.State -eq "Enabled" -and $vmFeature.State -eq "Enabled")
    distros = $distroList
  }
  needs_reboot = $needsReboot
}

Write-Facts ".\facts\server-225.json" $facts

if ($needsReboot) {
  Write-Host "wsl features enabled. reboot is required before continuing."
  exit 3010
}

Write-Host "windows bootstrap complete. now run bin/bootstrap-local.sh inside wsl."


bin/bootstrap-local.sh (run inside wsl on that same machine)
this runs the ansible playbook locally and writes host_vars.

#!/usr/bin/env bash
set -euo pipefail

# run inside wsl on the target machine
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$REPO_ROOT"

# make sure ansible exists
command -v ansible-playbook >/dev/null 2>&1 || {
  sudo apt-get update
  sudo apt-get install -y ansible openssh-server jq
}

# run local bootstrap playbook
ansible-playbook -i "localhost," -c local bootstrap/local/local_bootstrap.yml

echo "wsl bootstrap complete. host_vars updated. you can now run remote ansible from your laptop."


bootstrap/local/local_bootstrap.yml (ansible, local-only, runs in wsl)
this does wsl ssh setup and writes host_vars based on discovered facts.
it also reads the windows facts json created by the ps1 script.

---
- name: local bootstrap (wsl side)
  hosts: localhost
  connection: local
  gather_facts: true

  vars:
    physical_node: "server-225"
    facts_path_windows: "{{ playbook_dir }}/../../facts/server-225.json"
    host_vars_dir: "{{ playbook_dir }}/../../host_vars"
    wsl_ssh_port: 22

  tasks:
    - name: ensure host_vars dir exists
      ansible.builtin.file:
        path: "{{ host_vars_dir }}"
        state: directory
        mode: "0755"

    - name: install and enable openssh-server in wsl
      ansible.builtin.shell: |
        set -e
        sudo apt-get update
        sudo apt-get install -y openssh-server
        sudo mkdir -p /var/run/sshd
        sudo systemctl enable ssh || true
        sudo service ssh start || sudo systemctl start ssh
      args:
        executable: /bin/bash

    - name: ensure sshd allows pubkey auth
      ansible.builtin.lineinfile:
        path: /etc/ssh/sshd_config
        regexp: '^#?PubkeyAuthentication'
        line: 'PubkeyAuthentication yes'
      become: true

    - name: restart ssh
      ansible.builtin.shell: |
        sudo service ssh restart || sudo systemctl restart ssh
      args:
        executable: /bin/bash

    - name: read windows facts json
      ansible.builtin.slurp:
        src: "{{ facts_path_windows }}"
      register: winfacts_raw

    - name: parse windows facts
      ansible.builtin.set_fact:
        winfacts: "{{ (winfacts_raw.content | b64decode) | from_json }}"

    - name: choose host ip (from windows facts)
      ansible.builtin.set_fact:
        host_ip: "{{ winfacts.windows.host_ip }}"

    - name: choose wsl user
      ansible.builtin.set_fact:
        wsl_user: "{{ ansible_user_id }}"

    - name: choose wsl distro name (best-effort)
      ansible.builtin.shell: |
        (wsl.exe -l -q 2>/dev/null || true) | head -n 1 | tr -d '\r'
      register: distro_name
      changed_when: false

    - name: write host_vars for windows surface (do not write real password)
      ansible.builtin.template:
        src: "{{ playbook_dir }}/templates/host_vars_windows.yml.j2"
        dest: "{{ host_vars_dir }}/server-225-win.yml"
        mode: "0644"

    - name: write host_vars for wsl surface
      ansible.builtin.template:
        src: "{{ playbook_dir }}/templates/host_vars_wsl.yml.j2"
        dest: "{{ host_vars_dir }}/server-225-wsl.yml"
        mode: "0644"


templates for host_vars (secrets remain vault references)
bootstrap/templates/host_vars_windows.yml.j2

physical_node: "{{ physical_node }}"
surface_type: windows_host

host_ip: "{{ host_ip }}"
winrm_port: {{ winfacts.windows.winrm_port }}
win_user: "josh"

# keep the password as a vault variable reference only
# define vault_server_225_win_password in group_vars/all/vault.yml (encrypted)
win_password: "{{ '{{ vault_server_225_win_password }}' }}"


bootstrap/templates/host_vars_wsl.yml.j2

physical_node: "{{ physical_node }}"
surface_type: wsl

host_ip: "{{ host_ip }}"
wsl_user: "{{ wsl_user }}"
wsl_ssh_port: {{ wsl_ssh_port }}

wsl_distro: "{{ distro_name.stdout | default('') }}"


how you run it end-to-end

on the target machine (server-225) in windows (admin powershell):

cd C:\path\to\your\repo
.\bin\bootstrap-local.ps1
# if it says reboot required, reboot, then run it again


then inside wsl on that same machine:

cd /mnt/c/path/to/your/repo
chmod +x bin/bootstrap-local.sh
./bin/bootstrap-local.sh


then from your controlling laptop (remote runs now work)
windows winrm:

ansible -i inventory/inventory.yaml server-225-win -m win_ping --ask-vault-pass -vv


wsl ssh:

ansible -i inventory/inventory.yaml server-225-wsl -m ping -vv


important guardrails (this is what keeps you from re-breaking it)

the bootstrap never writes real secrets. it only writes vault variable references into host_vars.

the bootstrap writes host_ip / ports / usernames. those are the drift-prone items that cause auth failures.

your playbooks should target server-225-win or server-225-wsl explicitly (not a generic “server-225” group) until the whole project is stable.

if you want, i can also give you a tiny “bootstrap gate” in your main playbook that refuses to run unless it detects:

winrm https listener exists on 5986

wsl ssh responds on 22

required host_vars keys exist (host_ip, winrm_port, wsl_user, etc.)
so you stop losing time to half-configured machines.

where do these snippes go inthat tree you gave

good catch — this only works if every snippet has a precise home. here’s the exact placement, mapped 1-to-1 to the tree I gave, with no hand-waving.

i’ll start with the full tree, then walk file-by-file.

full tree (authoritative)

repo-root/
├── ansible.cfg
├── inventory/
│   └── inventory.yaml
├── host_vars/
│   ├── server-225-win.yml
│   └── server-225-wsl.yml
├── group_vars/
│   └── all/
│       └── vault.yml        # encrypted (already or will be)
├── bootstrap/
│   └── local/
│       ├── local_bootstrap.yml
│       └── templates/
│           ├── host_vars_windows.yml.j2
│           └── host_vars_wsl.yml.j2
├── bin/
│   ├── bootstrap-local.ps1
│   └── bootstrap-local.sh
├── facts/
│   ├── .gitkeep
│   └── server-225.json      # generated
└── README.md


now, snippet-by-snippet placement

windows powershell bootstrap
this is the file you double-click or run as admin on the windows machine.

path:

bin/bootstrap-local.ps1


contains:

enable psremoting

configure winrm https

enable wsl features

write facts/server-225.json

this file is not ansible. it runs before ansible can even be trusted.

wsl bootstrap shell wrapper
this runs inside wsl on the same machine.

path:

bin/bootstrap-local.sh


contains:

install ansible + openssh-server (inside wsl)

run the ansible local bootstrap playbook

this is your bridge from “windows-only” → “ansible-controlled”.

ansible local bootstrap playbook
this is what bootstrap-local.sh calls.

path:

bootstrap/local/local_bootstrap.yml


purpose:

runs with hosts: localhost

connection: local

configures ssh inside wsl

reads facts/server-225.json

writes host_vars files from templates

this playbook never runs remotely.

host_vars templates (written by ansible)
these are jinja templates, not actual vars files.

paths:

bootstrap/local/templates/host_vars_windows.yml.j2
bootstrap/local/templates/host_vars_wsl.yml.j2


used by:

bootstrap/local/local_bootstrap.yml


they render into real host_vars files.

generated windows host vars
created automatically by the bootstrap.

path:

host_vars/server-225-win.yml


contains:

host_ip

winrm_port

win_user

vault password reference (not the password)

you do not hand-edit this unless you are overriding bootstrap output.

generated wsl host vars
also created automatically.

path:

host_vars/server-225-wsl.yml


contains:

host_ip

wsl_user

ssh port

distro name (best-effort)

again: generated, not handwritten.

facts output (machine-local discovery)
this is created by the powershell script.

path:

facts/server-225.json


used by:

bootstrap/local/local_bootstrap.yml


never committed with secrets; safe to inspect, safe to overwrite.

vault secrets (you already have or will add)
this is where the real password lives.

path:

group_vars/all/vault.yml


encrypted with ansible-vault.

contains:

vault_server_225_win_password: "REAL_PASSWORD_HERE"


this file is referenced but never written by bootstrap.

inventory stays boring and stable
you already have this, but the important point is:

path:

inventory/inventory.yaml


it should not hardcode IPs, ports, or passwords — only variable names.

the bootstrap updates host_vars, not inventory.

mental model (so this doesn’t fall apart later)

bin/ → “things a human runs”

bootstrap/local/ → “things ansible runs locally only”

facts/ → “machine-discovered truth”

host_vars/ → “resolved per-host configuration”

group_vars/all/vault.yml → “secrets only”

inventory/ → “static topology”

if you want, next we can:

add a bootstrap status marker (so ansible refuses to run remotely if bootstrap didn’t complete)

add a dry-run verifier (ansible-playbook bootstrap-check.yml)

adapt this pattern to network-server and future nodes without copy-paste drift