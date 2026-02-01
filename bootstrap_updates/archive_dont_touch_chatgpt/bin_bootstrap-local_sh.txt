#!/usr/bin/env bash
# bin/bootstrap-local.sh
# Run inside WSL on the target machine
# This script installs ansible if needed and runs the local bootstrap playbook

set -euo pipefail

# Run inside WSL on the target machine
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$REPO_ROOT"

# Make sure ansible exists
command -v ansible-playbook >/dev/null 2>&1 || {
  sudo apt-get update
  sudo apt-get install -y ansible openssh-server jq
}

# Run local bootstrap playbook
ansible-playbook -i "localhost," -c local bootstrap/local/local_bootstrap.yml

echo "WSL bootstrap complete. host_vars updated. You can now run remote ansible from your laptop."
