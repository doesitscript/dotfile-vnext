#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
artifact_root="${1:-${repo_root}/artifacts/netbox-reconciliation}"
netbox_inventory_file="${NETBOX_INVENTORY_FILE:-inventory/netbox.yml}"
date_dir="$(date -u +%F)"

mkdir -p "${artifact_root}/${date_dir}"

static_json="$(mktemp)"
netbox_json="$(mktemp)"
trap 'rm -f "${static_json}" "${netbox_json}"' EXIT

(
  cd "${repo_root}"
  bin/codex-env ansible-inventory -i inventory/inventory.yaml --list > "${static_json}"
  bin/codex-env ansible-inventory -i "${netbox_inventory_file}" --list > "${netbox_json}"
)

report_path="${artifact_root}/${date_dir}/inventory-compatibility.json"
latest_path="${artifact_root}/latest.inventory-compatibility.json"

NETBOX_INVENTORY_FILE="${netbox_inventory_file}" \
jq -n \
  --slurpfile static "${static_json}" \
  --slurpfile netbox "${netbox_json}" '
  def uniqsort: unique | sort;
  def hosts_for($root; $group):
    (
      ($root[$group].hosts // [])
      + ((($root[$group].children // [])) | map(hosts_for($root; .)) | add // [])
    ) | uniqsort;
  def intersection($left; $right):
    [$left[] as $item | select($right | index($item)) | $item] | uniqsort;
  def difference($left; $right):
    [$left[] as $item | select(($right | index($item)) | not) | $item] | uniqsort;
  def mapped_hosts($root; $groups):
    (($groups | map(hosts_for($root; .)) | add) // []) | uniqsort;
  def surface_report($static_group; $netbox_groups; $strategy; $cutover_ready):
    (hosts_for($static[0]; $static_group)) as $static_hosts |
    (mapped_hosts($netbox[0]; $netbox_groups)) as $netbox_hosts |
    {
      static_group: $static_group,
      static_hosts: $static_hosts,
      candidate_netbox_groups: $netbox_groups,
      netbox_hosts: $netbox_hosts,
      overlap_hosts: intersection($static_hosts; $netbox_hosts),
      static_only_hosts: difference($static_hosts; $netbox_hosts),
      netbox_only_hosts: difference($netbox_hosts; $static_hosts),
      parity: ($static_hosts == $netbox_hosts),
      cutover_ready: $cutover_ready,
      compatibility_strategy: $strategy
    };
  {
    comparison_mode: "shadow-inventory-compatibility",
    generated_at_utc: (now | strftime("%Y-%m-%dT%H:%M:%SZ")),
    current_inventory_root: "inventory/inventory.yaml",
    shadow_inventory_root: (env.NETBOX_INVENTORY_FILE // "inventory/netbox.yml"),
    playbook_surface: "playbooks/site.yaml",
    cutover_ready: false,
    cutover_summary: "Keep inventory/netbox.yml in shadow mode until a compatibility overlay preserves execution_nodes and docker_clients semantics.",
    surfaces: [
      surface_report(
        "execution_nodes";
        [];
        "Retain a static companion overlay. mac-dev is the controller surface and is not NetBox-managed.";
        false
      ),
      surface_report(
        "windows_hosts";
        ["device_roles_hvh"];
        "Map windows_hosts to NetBox device_roles_hvh when using the shadow inventory.";
        true
      ),
      surface_report(
        "linux_vm_hosts";
        ["is_virtual"];
        "Map linux_vm_hosts to NetBox is_virtual hosts.";
        true
      ),
      surface_report(
        "docker_clients";
        ["device_roles_hvh"];
        "Use a compatibility overlay: NetBox device_roles_hvh plus the static execution_nodes controller host mac-dev.";
        false
      )
    ]
  }' > "${report_path}"

cp "${report_path}" "${latest_path}"

echo "NetBox inventory compatibility report written:"
echo "  ${report_path}"
echo "  ${latest_path}"
