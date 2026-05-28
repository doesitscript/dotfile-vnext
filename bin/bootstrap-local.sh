#!/usr/bin/env bash
# Redirect — desktop-only WSL bootstrap (moved to bin/desktop/).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DESKTOP="${SCRIPT_DIR}/desktop/bootstrap-local.sh"
if [[ ! -x "$DESKTOP" ]]; then
  echo "[ERROR] Desktop WSL bootstrap not found: $DESKTOP" >&2
  exit 1
fi
echo "[INFO] Server lanes must not use WSL bootstrap. Forwarding to bin/desktop/bootstrap-local.sh"
exec "$DESKTOP" "$@"
