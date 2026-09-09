#!/usr/bin/env bash
# Echo-only helper for the controller Mac (mac-dev).
# Prints commands you run yourself. Does not download.
# Not Continue-extension configuration.
# Model list: models-to-copy.list
# Paths: helpers/share_topology.md and share-paths.sh

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "${SCRIPT_DIR}/share-paths.sh"

echo "# commands to run yourself on the controller Mac. this script does not run them."
echo "# source ${SCRIPT_DIR}/share-paths.sh first so CONTROLLER_PUBLIC_FOLDER is set."

# ===== SECTION: paths =====
print_share_folders
# ===== END SECTION: paths =====

# ===== SECTION: echo:huggingface =====
# Generated from the manifest. Same models as the work-laptop tool sections.
print_echo_huggingface
# ===== END SECTION: echo:huggingface =====

# ===== SECTION: next-cli =====
# Another downloader: add a print_echo_<tool> function in share-paths.sh that
# walks the same manifest, then call it here. Do not copy model lines by hand.
# ===== END SECTION: next-cli =====
