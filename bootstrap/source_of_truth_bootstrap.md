dotfile-vnext/
├── .gitignore
├── ansible.cfg
├── README.md
├── assemble_checkpoints.md
├── CHECKPOINT_.md (multiple checkpoint files)
├── PARAMETER_.md (parameter files)
│
├── bin/
│ ├── fz
│ ├── <span style="color:teal">bootstrap-local.ps1</span> (new)
│ └── <span style="color:teal">bootstrap-local.sh</span> (new)
│
├── bootstrap/
│ ├── README.md
│ ├── bootstrap_inventory.bat
│ ├── bootstrap_inventory.ps1
│ └── <span style="color:teal">local/</span> (new dir)
│ ├── <span style="color:teal">local_bootstrap.yml</span> (new)
│ └── <span style="color:teal">templates/</span> (new dir)
│ ├── <span style="color:teal">host_vars_windows.yml.j2</span> (new)
│ └── <span style="color:teal">host_vars_wsl.yml.j2</span> (new)
│
├── content/
│ ├── contract-completed-negotiated.md
│ ├── contract-mac-main-network.md
│ ├── spec-main-wsl2.md
│ ├── winrm-actual_setup_cursor_windows_server_crash_dump_and_pa.md
│ ├── winrm_ssh_checkpoints.md
│ └── archive_ignore_chatgpt/
│ ├── bookmarks_1_30_26.html
│ ├── contract-vantage-network-server-to-main-llm.md
│ └── cursor_project_assembly_with_checkpoint.md
│
├── contracts/
│ └── fuzlang.contract.yaml
│
├── docs/
│ ├── architecture_rules.md
│ ├── bin_tools.md
│ ├── operator_runbook.md
│ └── suggested_improvements.md
│
├── inventory/
│ ├── <span style="color:teal">inventory.yaml</span> (update)
│ ├── hosts_mapping.yaml
│ ├── group_vars/
│ │ ├── all.yaml
│ │ ├── dev_gpu.yaml
│ │ ├── mac_dev.yaml
│ │ ├── main_server.yaml
│ │ └── network_server.yaml
│ └── host_vars/
│ ├── dev-3090.yaml
│ ├── mac-dev.yaml
│ ├── network-server.yaml
│ ├── server-225.yaml
│ ├── <span style="color:teal">server-225-win.yaml</span> (new)
│ └── <span style="color:teal">server-225-wsl.yaml</span> (new)
│
├── params/
│ └── site.yaml
│
├── playbooks/
│ ├── bootstrap_dev_3090.yaml
│ ├── bootstrap_mac.yaml
│ ├── bootstrap_network_server.yaml
│ ├── bootstrap_server_225.yaml
│ ├── deploy_dev_stacks.yaml
│ ├── deploy_main_stacks.yaml
│ ├── deploy_network_stacks.yaml
│ ├── verify_fabric.yaml
│ └── <span style="color:teal">bootstrap_local_only.yaml</span> (new, optional)
│
├── rendered/
│ ├── dev/
│ │ └── .env
│ ├── main/
│ │ └── .env
│ └── network/
│ └── .env
│
├── roles/
│ ├── README.md
│ │
│ ├── common/
│ │ ├── baseline/
│ │ ├── docker_runtime_verify/
│ │ ├── endpoint_verify/
│ │ ├── firewall/
│ │ ├── gpu_verify/
│ │ ├── health_checks/
│ │ ├── scheduled_task_verify/
│ │ ├── secrets_render/
│ │ ├── secrets_verify/
│ │ ├── ssh_keys/
│ │ └── volume_location_verify/
│ │
│ ├── dev_3090/
│ │ ├── gpu_driver_validation/
│ │ ├── ssh/
│ │ ├── stacks_dev/
│ │ ├── windows_base/
│ │ └── wsl2_or_windows_docker_runtime/
│ │
│ ├── mac_dev/
│ │ ├── ansible_runner/
│ │ ├── dev_tools/
│ │ ├── dotfiles/
│ │ └── homebrew/
│ │
│ ├── network_server/
│ │ ├── backup_baseline/
│ │ ├── docker_runtime/
│ │ ├── stacks_network/
│ │ ├── storage_layout/
│ │ └── windows_base/
│ │
│ └── server_225/
│ ├── docker_in_wsl/
│ ├── gpu_driver_validation/
│ ├── stacks_main/
│ ├── task_scheduler_autostart/
│ ├── windows_base/
│ └── wsl2/
│
├── scripts/
│ ├── lib.sh
│ └── requirements.txt
│
└── vault/
├── <span style="color:teal">shared.vault.yml</span> (update)
├── dev.vault.yml
├── main.vault.yml
└── network.vault.yml

what gets created vs updated (explicit)

new files/dirs (teal in tree)

bin/bootstrap-local.ps1

bin/bootstrap-local.sh

bootstrap/local/

bootstrap/local/local_bootstrap.yml

bootstrap/local/templates/

bootstrap/local/templates/host_vars_windows.yml.j2

bootstrap/local/templates/host_vars_wsl.yml.j2

inventory/host_vars/server-225-win.yaml

inventory/host_vars/server-225-wsl.yaml

playbooks/bootstrap_local_only.yaml (optional)

updated files (teal in tree)

inventory/inventory.yaml
update: add 2 inventory hosts (server-225-win, server-225-wsl) OR add groups for windows_hosts and wsl_hosts referencing these host_vars overlays.

vault/shared.vault.yml
update: ensure it contains vault_server_225_win_password (and any other shared secrets you want the bootstrap references to point at).

important note about your existing server-225.yaml
leave inventory/host_vars/server-225.yaml as-is for node-level truths (drive letters, roles, etc).
the new server-225-win.yaml and server-225-wsl.yaml are “surface overlays” so your playbooks can target windows vs wsl explicitly and never accidentally pick the wrong connection or password.

if you want this even cleaner, we can instead update server-225.yaml (single file) to include nested keys winrm + wsl, and avoid adding two new host_vars files. but the overlay approach is safer for avoiding ansible var collisions.