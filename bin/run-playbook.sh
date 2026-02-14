#!/usr/bin/env bash
# Script follows LOGGING_AND_OUTPUT.md contract.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# shellcheck source=../lib/log.sh
source "${REPO_ROOT}/lib/log.sh"
# shellcheck source=../lib/redact.sh
source "${REPO_ROOT}/lib/redact.sh"
# shellcheck source=../scripts/lib.sh
source "${REPO_ROOT}/scripts/lib.sh"

PLAYBOOK_PATH="${1:-}"
shift || true

if [ -z "${PLAYBOOK_PATH}" ]; then
  die 2 "Usage: bin/run-playbook.sh <playbook.yaml> [ansible args]"
fi

if [ ! -f "${REPO_ROOT}/${PLAYBOOK_PATH}" ] && [ ! -f "${PLAYBOOK_PATH}" ]; then
  die 2 "Playbook not found: ${PLAYBOOK_PATH}"
fi

PLAYBOOK_ABS="${PLAYBOOK_PATH}"
if [ -f "${REPO_ROOT}/${PLAYBOOK_PATH}" ]; then
  PLAYBOOK_ABS="${REPO_ROOT}/${PLAYBOOK_PATH}"
fi

PLAYBOOK_BASENAME="$(basename "${PLAYBOOK_ABS}")"
PLAYBOOK_NAME="${PLAYBOOK_BASENAME%.*}"
TIMESTAMP="$(date +"%Y%m%d_%H%M%S")"
RUN_DIR="${REPO_ROOT}/logs/runs/${TIMESTAMP}_${PLAYBOOK_NAME}"
RUN_LOG="${RUN_DIR}/run.log"
INVENTORY_PATH="${REPO_ROOT}/inventory/inventory.yaml"
SNAPSHOT_TAR="${RUN_DIR}/inventory_snapshot.tar.gz"

run "Create run directory" mkdir -p "${RUN_DIR}"
run "Ensure venv exists" ensure_venv
run "Setup ansible environment" setup_ansible_env

ANSIBLE_BIN="${REPO_ROOT}/.venv/bin/ansible-playbook"
if [ ! -x "${ANSIBLE_BIN}" ]; then
  die 1 "ansible-playbook not found in virtual environment: ${ANSIBLE_BIN}"
fi
if [ ! -f "${INVENTORY_PATH}" ]; then
  die 1 "Inventory file not found: ${INVENTORY_PATH}"
fi

CMD=( "${ANSIBLE_BIN}" "${PLAYBOOK_ABS}" -i "${INVENTORY_PATH}" "$@" )
section "Playbook Run"
log_info "playbook=${PLAYBOOK_ABS}"
log_info "run_dir=${RUN_DIR}"
log_info "command=${CMD[*]}"

set +e
"${CMD[@]}" 2>&1 | redact_stream | tee "${RUN_LOG}"
PLAY_RC=${PIPESTATUS[0]}
set -e

if [ -f "${REPO_ROOT}/logs/ansible.log" ]; then
  run "Copy ansible controller log" cp "${REPO_ROOT}/logs/ansible.log" "${RUN_DIR}/ansible.log"
else
  log_warn "ansible controller log not found at logs/ansible.log"
fi

if [ -d "${REPO_ROOT}/inventory/host_vars" ]; then
  run "Archive inventory snapshot" tar -czf "${SNAPSHOT_TAR}" -C "${REPO_ROOT}" inventory/inventory.yaml inventory/host_vars
else
  log_warn "inventory/host_vars not found; skipping snapshot archive"
fi

if [ "${PLAY_RC}" -ne 0 ]; then
  log_error "Playbook failed: playbook=${PLAYBOOK_BASENAME} exit_code=${PLAY_RC} run_dir=${RUN_DIR}"
  log_error "Open ${RUN_LOG}"
  exit "${PLAY_RC}"
fi

log_ok "Playbook completed: playbook=${PLAYBOOK_BASENAME} run_dir=${RUN_DIR}"
