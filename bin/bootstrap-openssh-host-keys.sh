#!/usr/bin/env bash
# Generate OpenSSH host keys into bootstrap/openssh_host_keys/; the playbook stores them in vault
# and bootstrap_windows deploys from vault to C:\ProgramData\ssh. Run on the Mac from repo root.
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
  # When forcing, remove existing keys first to avoid prompts
  if [ "${FORCE}" = true ] && [ -f "${path}" ]; then
    echo "Removing existing key (--force): ${path}"
    rm -f "${path}" "${path}.pub"
  fi
  case "$type" in
    ed25519) ssh-keygen -t ed25519 -f "${path}" -N "" -C "host" ;;
    rsa)     ssh-keygen -t rsa -b 4096 -f "${path}" -N "" -C "host" ;;
    *)       echo "Unknown type: $type" >&2; return 1 ;;
  esac
  chmod 600 "${path}"
  chmod 644 "${path}.pub"
  if [ "${FORCE}" = true ]; then
    echo "Regenerated: ${path} and ${path}.pub"
  else
    echo "Created: ${path} and ${path}.pub"
  fi
}

gen_if_missing ed25519
gen_if_missing rsa

echo "Done. Keys are in ${KEYS_DIR}. Re-run the playbook to store them in vault and deploy to Windows via ./bin/fz bootstrap --limit server-225-win"
