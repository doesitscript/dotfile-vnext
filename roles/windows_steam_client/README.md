---
# windows_steam_client
#
# Install the Steam application and deploy config **pointers** to existing
# library folders and the Game Recording folder. Does not create those
# directories and does not require games/clips to be present.
#
# ## Placement (mature selectors)
#
# | Layer | Value |
# |---|---|
# | Inventory intersection | `windows_server_2025:&windows_nvidia_gpu_hosts` |
# | Execution role | `windows-steam-gaming` (`policy/execution_roles.yml`) |
# | Capability catalog | `windows_steam_client` (`policy/capability_catalog.yml`) |
# | GPU model label | `gpu: rtx-5090` (host_vars + live-object-registry) |
# | K8s-style labels | `homelab.workload/steam-client=true`, `homelab.role=windows-gaming` |
# | Commission gate | `windows_steam_client_state: present` |
#
# Do **not** target `hosts: HOM-LAB-HVH-02`. Classify + class intersection +
# role + gpu label select the host.
#
# Apply / Verify / Undo / Change class
# - Apply: package present; merge libraryfolders.vdf paths; set
#   BackgroundRecordPath in userdata/*/config/localconfig.vdf (Steam stopped).
# - Verify: --tags verify compares live pointers to inventory (read-only).
# - Undo: state absent uninstalls the Chocolatey/winget package; does not
#   delete library or recording trees.
# - Change class: idempotent package + config. First intended use: Windows
#   rebuild recovery (declare paths that match current live targets).
#
# Evidence (HOM-LAB-HVH-02 / rtx-5090, 2026-09-23):
# - Libraries: config\libraryfolders.vdf path entries
# - Recording: userdata\<id>\config\localconfig.vdf → GameRecording.BackgroundRecordPath
# - Registry is NOT the recording-path surface on that host

## Variables

| Variable | Purpose |
|---|---|
| `windows_steam_client_state` | `present` \| `absent` |
| `windows_steam_client_library_roots` | Extra library paths (e.g. `D:\SteamLibrary`, `I:\SteamLibrary`) |
| `windows_steam_client_recording_root` | Recording folder (e.g. `I:\Gamerecordings`) |
| `windows_steam_client_ensure_paths` | Must stay `false` in v1 |
| `windows_steam_client_required_gpu` | Inventory `gpu:` label gate (default `rtx-5090`) |

## Playbook

```bash
# Class + role + gpu selection preview
bin/codex-env ansible-playbook playbooks/deploy_windows_steam_client.yaml \
  -i inventory/inventory.yaml --tags preview

# Read-only pointer compare (no package/config write)
bin/codex-env ansible-playbook playbooks/deploy_windows_steam_client.yaml \
  -i inventory/inventory.yaml --tags verify

# Apply (rebuild / explicit): NOT run in the 2026-09-23 scaffold pass
bin/codex-env ansible-playbook playbooks/deploy_windows_steam_client.yaml \
  -i inventory/inventory.yaml
```
