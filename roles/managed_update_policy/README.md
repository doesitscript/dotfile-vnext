---
# managed_update_policy
#
# Curtail silent unattended OS / package-manager upgrades so Ansible inventory
# pins remain the authority. Alpha fleet capability.
#
# Surfaces:
# - Ubuntu: apt.conf.d periodic disable, stop unattended-upgrades + apt-daily timers,
#   optional dpkg holds
# - Windows: NoAutoUpdate / AUOptions policy registry, optional Chocolatey pins
# - macOS: HOMEBREW_NO_AUTO_UPDATE via brew.env
#
# Apply / Verify / Undo / Change class
# - Apply: playbooks/deploy_managed_update_policy.yaml
# - Verify: --tags verify,never after apply
# - Undo: managed_update_policy_state: absent
# - Change class: idempotent config
#
# Companion: roles/package_manager defaults package_update/upgrade to false so
# bootstrap includes no longer dist-upgrade / choco upgrade all / brew upgrade_all.
