#!/usr/bin/env bash
# Echo-only helper for the work laptop.
# Prints commands you run yourself. Does not copy or import.
# Not Continue-extension configuration.
# Model list: models-to-copy.list
# Each tool section below is generated from that same list.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "${SCRIPT_DIR}/share-paths.sh"

echo "# commands to run yourself on the work laptop. this script does not run them."
echo "# source ${SCRIPT_DIR}/share-paths.sh first. Fill WORK_LAPTOP_PUBLIC_FOLDER before a copy."

# ===== SECTION: paths =====
print_share_folders
# ===== END SECTION: paths =====

# ===== SECTION: echo:copy =====
# One rsync per manifest model. Same folder under ~/models as on the share.
print_echo_copy
# ===== END SECTION: echo:copy =====

# ===== SECTION: echo:ollama =====
print_echo_ollama
# ===== END SECTION: echo:ollama =====

# ===== SECTION: echo:lmstudio =====
# Same models as echo:ollama. Another tool, not a second model list.
print_echo_lmstudio
# ===== END SECTION: echo:lmstudio =====

# ===== SECTION: echo:confirm =====
echo "ollama list"
echo "lms ls"
# ===== END SECTION: echo:confirm =====

# ===== SECTION: next-cli =====
# Another runtime: add a print_echo_<tool> function in share-paths.sh that
# walks the same manifest, then call it above this marker.
# Add that tool's confirm command to echo:confirm.
# ===== END SECTION: next-cli =====
