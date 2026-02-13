#!/usr/bin/env bash
# Generate OpenSSH host keys into bootstrap/openssh_host_keys/ for use by Windows
# (bootstrap-local.ps1 copies them to C:\ProgramData\ssh). Run on the Mac from repo root.
# Idempotent: creates keys only if missing. Use --force to regenerate.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
KEYS_DIR="${REPO_ROOT}/bootstrap/openssh_host_keys"
FORCE=false

for arg in "$@"; do
  case "$arg" in
    --force) FORCE=true ;;
    -h|--help)
      echo "Usage: $0 [--force]"
      echo "  Generates ssh_host_ed25519_key and ssh_host_rsa_key into bootstrap/openssh_host_keys/."
      echo "  Idempotent unless --force (then overwrites). Run from repo root on the Mac."
      exit 0
      ;;
  esac
done

mkdir -p "${KEYS_DIR}"

gen_if_missing() {
  local type="$1"
  local path="${KEYS_DIR}/ssh_host_${type}_key"
  if [ -f "${path}" ] && [ "${FORCE}" != true ]; then
    echo "Skip (exists): ${path}"
    return 0
  fi
  case "$type" in
    ed25519) ssh-keygen -t ed25519 -f "${path}" -N "" -C "host" ;;
    rsa)     ssh-keygen -t rsa -b 4096 -f "${path}" -N "" -C "host" ;;
    *)       echo "Unknown type: $type" >&2; return 1 ;;
  esac
  chmod 600 "${path}"
  chmod 644 "${path}.pub"
  echo "Created: ${path} and ${path}.pub"
}

gen_if_missing ed25519
gen_if_missing rsa

echo "Done. Keys are in ${KEYS_DIR} (gitignored). Sync this folder to Windows and run .\\bin\\bootstrap-local.ps1 there."
