---
# windows_steam_client
#
# Install the Steam application and deploy config **pointers** to existing
# library folders and the Game Recording folder. Does not create those
# directories and does not require games/clips to be present.
#
# Dispatched by playbooks/deploy_applications.yaml when the host lists
# `windows_steam_client` under `windows_applications`. Do not duplicate
# orchestrator targeting here.
#
# ## Placement (mature selectors)
#
# | Layer | Value |
# |---|---|
# | Host intent | `windows_applications: [windows_steam_client]` |
# | Execution role | `windows-steam-gaming` (`policy/execution_roles.yml`) |
# | Capability catalog | `windows_steam_client` + `application_orchestrator.enabled` |
# | GPU model label | `gpu: rtx-5090` |
# | Commission gate | `windows_steam_client_state: present` |
#
# Apply / Verify / Undo / Change class
# - Apply: package present; merge libraryfolders.vdf; set BackgroundRecordPath
# - Verify: `--tags verify` only (no install / stop / VDF write / uninstall)
# - Undo: `absent` removes package only; never deletes library/recording trees
# - Change class: idempotent package + config
#
# ## Commands
#
# ```bash
# bin/codex-env ansible-playbook playbooks/deploy_applications.yaml \
#   -i inventory/inventory.yaml --tags preview
#
# bin/codex-env ansible-playbook playbooks/deploy_windows_steam_client.yaml \
#   -i inventory/inventory.yaml --tags verify
# ```
