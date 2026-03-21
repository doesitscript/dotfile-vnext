#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
ANSIBLE_LINT_BIN="${REPO_ROOT}/.venv/bin/ansible-lint"
CONFIG_FILE="${REPO_ROOT}/.ansible-lint"

if [ ! -x "${ANSIBLE_LINT_BIN}" ]; then
  echo "ansible-lint not found at ${ANSIBLE_LINT_BIN}" >&2
  echo "Run the controller toolchain setup first:" >&2
  echo "  .venv/bin/ansible-playbook playbooks/mac/ansible_dev_tools.yaml -i inventory/inventory.yaml --limit mac-dev" >&2
  exit 1
fi

if [ ! -f "${CONFIG_FILE}" ]; then
  echo "ansible-lint config not found at ${CONFIG_FILE}" >&2
  exit 1
fi

cd "${REPO_ROOT}"

if [ "$#" -eq 0 ]; then
  set -- playbooks roles
fi

echo "Running ansible-lint with ${CONFIG_FILE}"
echo "Note: ansible-lint also runs Ansible syntax checks."
exec "${ANSIBLE_LINT_BIN}" "$@"
