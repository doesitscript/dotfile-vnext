#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

retired_base="network-server"
retired_name="${retired_base}-win"
retired_label="retired network-server Windows control alias"
current_name="hom-lab-ctl-hvh-01"

failures=()

add_failure() {
  failures+=("$1")
}

# macOS controllers may not have ripgrep; fall back to grep for gate checks.
search_inventory_host_key() {
  local host_key="$1"
  local pattern="^[[:space:]]*${host_key}:"
  if command -v rg >/dev/null 2>&1; then
    rg -n "$pattern" inventory/inventory.yaml
  else
    grep -En "$pattern" inventory/inventory.yaml
  fi
}

search_fixed_string() {
  local needle="$1"
  shift
  if command -v rg >/dev/null 2>&1; then
    rg -n --fixed-strings "$needle" "$@"
  else
    grep -RFn -- "$needle" "$@"
  fi
}

if [[ -e "inventory/host_vars/${retired_name}.yaml" || -e "inventory/host_vars/${retired_name}.yml" ]]; then
  add_failure "Retired host_vars file still exists for ${retired_label}; use inventory/host_vars/${current_name}.yaml."
fi

if search_inventory_host_key "${retired_name}" >/tmp/netbox-repo-consistency-inventory.$$ 2>/dev/null; then
  while IFS= read -r line; do
    add_failure "Retired inventory host key remains active: inventory/inventory.yaml:${line}"
  done < /tmp/netbox-repo-consistency-inventory.$$
fi
rm -f /tmp/netbox-repo-consistency-inventory.$$

active_paths=(
  AGENTS.md
  bin
  contracts
  docs/brainstorming_designs
  docs/intake/k3s-on-hyperv-vm.md
  docs/operator_runbook.md
  docs/plans
  docs/reference/naming-standards
  docs/setup_openssh_via_winrm_summary.md
  inventory
  playbooks
  roles
  scripts
)

if search_fixed_string "${retired_name}" "${active_paths[@]}" >/tmp/netbox-repo-consistency-rg.$$ 2>/dev/null; then
  while IFS= read -r hit; do
    case "$hit" in
      *"legacy"*|*"Legacy"*|*"retired"*|*"Retired"*|*"former"*|*"Historical"*|*"historical"*|*"aliases"*|*"alias"*|*"old_name"*|*"migration"*|*"migrations"*|*"Do not introduce"*|*"keep it"*)
        continue
        ;;
    esac

    case "$hit" in
      docs/reports/*|docs/lessons-learned/*|docs/diagrams/*|docs/non_binding_project_layout/*|docs/diagnostics/debug-ssh-vvv.md:*)
        continue
        ;;
    esac

    if [[ "$hit" == inventory/hosts_mapping.yaml:*"legacy_physical_node_aliases"* ]] ||
       [[ "$hit" == inventory/hosts_mapping.yaml:*"- ${retired_name}"* ]] ||
       [[ "$hit" == "inventory/host_vars/${current_name}.yaml:"*"- ${retired_name}"* ]] ||
       [[ "$hit" == inventory/group_vars/hyperv_lane_storage/*:*"- ${retired_name}"* ]] ||
       [[ "$hit" == inventory/group_vars/hyperv_lane_gpu/*:*"- ${retired_name}"* ]] ||
       [[ "$hit" == roles/ipam_netbox/defaults/main.yml:*"- ${retired_name}"* ]]; then
      continue
    fi

    add_failure "Retired alias appears outside an explicit legacy/migration context: ${hit}"
  done < /tmp/netbox-repo-consistency-rg.$$
fi
rm -f /tmp/netbox-repo-consistency-rg.$$

if ! search_inventory_host_key "${current_name}" >/dev/null 2>&1; then
  add_failure "Current NetBox host name ${current_name} is missing from inventory/inventory.yaml."
fi

if [[ ! -f "inventory/host_vars/${current_name}.yaml" ]]; then
  add_failure "Current NetBox host vars file inventory/host_vars/${current_name}.yaml is missing."
fi

compact_active_paths=(
  AGENTS.md
  docs/intake/jupyter-devops-implementation-plans
  docs/reference/naming-standards
  inventory
  playbooks
  roles
  scripts
)

retired_compact_name_patterns=(
  "home-lab-auth-hvh-01"
  "home-lab-auth-hvh-02"
  "nsrv-dkr-01"
  "nsrv-k3s-01"
)

for retired_compact_name in "${retired_compact_name_patterns[@]}"; do
  if search_fixed_string "$retired_compact_name" "${compact_active_paths[@]}" >/tmp/netbox-repo-compact-rg.$$ 2>/dev/null; then
    while IFS= read -r hit; do
      case "$hit" in
        *"legacy"*|*"Legacy"*|*"retired"*|*"Retired"*|*"former"*|*"Historical"*|*"historical"*|*"aliases"*|*"alias"*|*"old_name"*|*"migration"*|*"migrations"*)
          continue
          ;;
      esac

      case "$hit" in
        scripts/validate_netbox_repo_consistency.sh:*)
          continue
          ;;
        docs/reference/naming-standards/archive/*)
          continue
          ;;
        docs/intake/jupyter-devops-implementation-plans/research/*)
          continue
          ;;
      esac

      add_failure "Retired compact-schema name appears outside an explicit legacy/migration context: ${hit}"
    done < /tmp/netbox-repo-compact-rg.$$
  fi
  rm -f /tmp/netbox-repo-compact-rg.$$
done

banned_operator_hostnames=(
  "langfuse.local"
  "litellm.local"
)

banned_active_paths=(
  AGENTS.md
  bin
  contracts
  docs/brainstorming_designs
  docs/diagnostics
  docs/intake
  docs/operator_runbook.md
  docs/plans
  docs/reference/naming-standards
  inventory
  playbooks
  roles
  scripts
)

for banned_hostname in "${banned_operator_hostnames[@]}"; do
  if search_fixed_string "$banned_hostname" "${banned_active_paths[@]}" >/tmp/netbox-repo-banned-rg.$$ 2>/dev/null; then
    while IFS= read -r hit; do
      case "$hit" in
        scripts/validate_netbox_repo_consistency.sh:*)
          continue
          ;;
        docs/reference/naming-standards/*)
          continue
          ;;
        docs/plans/2026-05-27--k3s-hyperv-traefik-implemented/README.md:*G3*)
          continue
          ;;
        docs/plans/2026-05-27--k3s-hyperv-traefik-implemented/README.md:*langfuse.local*)
          continue
          ;;
        *"deprecated"*|*"banned"*|*"Do not use"*|*"deprecated_pilot"*|*"fails on"*)
          continue
          ;;
      esac
      add_failure "Banned operator hostname ${banned_hostname} in active repo path: ${hit}"
    done < /tmp/netbox-repo-banned-rg.$$
  fi
  rm -f /tmp/netbox-repo-banned-rg.$$
done


if ((${#failures[@]} > 0)); then
  printf 'NetBox/repo consistency check failed.\n\n' >&2
  printf 'Retired alias: %s\nCurrent name: %s\n\n' "$retired_label" "$current_name" >&2
  printf '%s\n' "${failures[@]}" >&2
  exit 1
fi

printf 'NetBox/repo consistency check passed: retired alias is inactive; active repo target is %s.\n' "$current_name"
