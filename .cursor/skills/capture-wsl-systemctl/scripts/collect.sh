#!/usr/bin/env bash
# Collect systemctl diagnostics from WSL via ansible WinRM.
# Copies collect-logs.sh to Windows temp, runs it inside WSL, captures output.
# Usage: collect.sh [distro] [output_file]

set -euo pipefail

DISTRO="${1:-Ubuntu-24.04}"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../../.." && pwd)"
OUT="${2:-${PROJECT_ROOT}/logs/wsl-systemctl/${TIMESTAMP}_server-225-wsl.log}"
REMOTE_SCRIPT="C:\\Windows\\Temp\\wsl_collect_logs.sh"

mkdir -p "$(dirname "${OUT}")"
cd "${PROJECT_ROOT}"
source .envrc 2>/dev/null || true
source .venv/bin/activate 2>/dev/null || true

echo "Connection method:"
echo "  [1] ansible win_copy → hom-lab-ctl-hvh-02 (WinRM port 5985)"
echo "      src:  ${SCRIPT_DIR}/collect-logs.sh"
echo "      dest: ${REMOTE_SCRIPT} (Windows temp)"
echo "  [2] ansible win_shell → hom-lab-ctl-hvh-02 (WinRM port 5985)"
echo "      cmd:  wsl -d ${DISTRO} -u root -- bash /mnt/c/Windows/Temp/wsl_collect_logs.sh"
echo "  Note: WinRM → win_shell → wsl.exe bypasses SSH entirely."
echo "        Works even when the WSL SSH server is not running."
echo ""

# Step 1: copy the remote script to Windows temp
ansible hom-lab-ctl-hvh-02 -i inventory/inventory.yaml \
  -m ansible.windows.win_copy \
  -a "src=${SCRIPT_DIR}/collect-logs.sh dest=${REMOTE_SCRIPT}" \
  2>&1 | grep -v "^$" || true

# Step 2: run it inside WSL, capture output
ansible hom-lab-ctl-hvh-02 -i inventory/inventory.yaml \
  -m ansible.windows.win_shell \
  -a "wsl -d ${DISTRO} -u root -- bash /mnt/c/Windows/Temp/wsl_collect_logs.sh" \
  2>&1 > "${OUT}"

echo "Written: ${OUT}"
echo ""
echo "--- Failed units ---"
grep -E "● .* failed" "${OUT}" || echo "(none)"
echo ""
echo "--- keepwsl.service ---"
grep -A5 "keepwsl.service status" "${OUT}" | grep "Active:" || echo "(not found)"
