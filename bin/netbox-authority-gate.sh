#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
MODE="full"

usage() {
  cat <<'EOF'
Usage: bin/netbox-authority-gate.sh [--static-only] [--full]

Runs the repo-local NetBox authority enforcement path.

Modes:
  --static-only   Plan/governance checks only; no live NetBox or runtime probes.
  --full          Full gate: static checks, repo consistency, live reconciliation.
EOF
}

while (($# > 0)); do
  case "$1" in
    --static-only)
      MODE="static"
      shift
      ;;
    --full)
      MODE="full"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

cd "${REPO_ROOT}"

"${REPO_ROOT}/scripts/check_netbox_plan_governance.sh"

if [[ "${MODE}" == "static" ]]; then
  echo "NetBox authority gate: static plan/governance checks passed."
  exit 0
fi

artifact_date="$(date -u +%F)"
artifact_dir="${REPO_ROOT}/artifacts/netbox-reconciliation/${artifact_date}"
inventory_file="${NETBOX_INVENTORY_FILE:-inventory/netbox.yml}"
mkdir -p "${artifact_dir}"

echo "Running repo consistency gate..."
"${REPO_ROOT}/scripts/validate_netbox_repo_consistency.sh"

echo "Capturing NetBox inventory graph..."
"${REPO_ROOT}/bin/codex-env" ansible-inventory -i "${inventory_file}" --graph \
  > "${artifact_dir}/inventory.graph.txt"

echo "Capturing NetBox inventory compatibility report..."
"${REPO_ROOT}/scripts/check_netbox_inventory_compatibility.sh" \
  "${REPO_ROOT}/artifacts/netbox-reconciliation"

echo "Running read-only NetBox authority reconciliation playbook..."
reconcile_args=(ansible-playbook playbooks/reconcile_netbox.yaml --tags netbox_authority_reconciliation)
if [[ -n "${IPAM_NETBOX_API_URL:-}" ]]; then
  reconcile_args+=(-e "ipam_netbox_api_url=${IPAM_NETBOX_API_URL}")
fi
"${REPO_ROOT}/bin/codex-env" "${reconcile_args[@]}"

echo "NetBox authority gate passed. Artifacts:"
echo "  ${artifact_dir}/inventory.graph.txt"
echo "  ${REPO_ROOT}/artifacts/netbox-reconciliation/latest.inventory-compatibility.json"
echo "  ${REPO_ROOT}/artifacts/netbox-reconciliation/latest.json"
echo "  ${REPO_ROOT}/artifacts/netbox-service-inventory/latest.json"
