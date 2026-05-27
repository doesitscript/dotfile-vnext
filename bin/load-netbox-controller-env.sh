#!/usr/bin/env bash
# Export controller-side NetBox variables for nb_inventory and ad-hoc API checks.
#
# - NETBOX_TOKEN from vault.yml (vault_netbox_api_token) — never store in .envrc
# - API URL is fixed per inventory file (netbox.yml = LAN; netbox_tunnel.yml = tunnel)
#
# Source from .envrc (direnv) or bin/codex-env. Safe to source repeatedly.
# See roles/ipam_netbox/README.md (Shadow Dynamic Inventory) and inventory/netbox.yml.

_netbox_env_is_sourced=0
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
  _netbox_env_is_sourced=1
fi

_netbox_repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ -n "${NETBOX_TOKEN:-}" ]; then
  if [ "${_netbox_env_is_sourced}" -eq 1 ]; then
    return 0
  fi
  exit 0
fi

_vault_file="${_netbox_repo_root}/vault.yml"
_vault_pass_script="${_netbox_repo_root}/vault_pass.sh"
if [ ! -f "${_vault_file}" ] || [ ! -x "${_vault_pass_script}" ]; then
  if [ "${_netbox_env_is_sourced}" -eq 1 ]; then
    return 0
  fi
  exit 0
fi

_ansible_vault="${_netbox_repo_root}/.venv/bin/ansible-vault"
if [ ! -x "${_ansible_vault}" ]; then
  _ansible_vault="$(command -v ansible-vault 2>/dev/null || true)"
fi
if [ -z "${_ansible_vault}" ]; then
  if [ "${_netbox_env_is_sourced}" -eq 1 ]; then
    return 0
  fi
  exit 0
fi

_token="$(
  "${_ansible_vault}" view "${_vault_file}" --vault-password-file "${_vault_pass_script}" 2>/dev/null \
    | awk '/^vault_netbox_api_token:/ {
        gsub(/^vault_netbox_api_token:[[:space:]]*/, "");
        gsub(/["'\'']/, "");
        print;
        exit
      }'
)"

if [ -n "${_token}" ]; then
  export NETBOX_TOKEN="${_token}"
fi

if [ "${_netbox_env_is_sourced}" -eq 1 ]; then
  return 0
fi
exit 0
