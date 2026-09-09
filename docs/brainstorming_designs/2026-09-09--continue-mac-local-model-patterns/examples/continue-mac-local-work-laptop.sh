#!/usr/bin/env bash
# Pattern copy. Runnable file:
# exports/work-laptop-ai-tools/helpers/work-mac-local-models/continue-mac-local-work-laptop.sh
# Human-run on the work laptop only.
# Prints copy and import commands, then runs process blocks only after the
# share mount is set. Imports point at ~/models, not the share.
# Continue config is a later ansible role pass, not this script.
# Plan: docs/brainstorming_designs/2026-09-09--continue-mac-local-model-patterns
#
# Divider contract (skills add lines only inside these markers):
#   SECTION: paths
#   SECTION: echo:<tool>     printed only; one model per line; folder value in []
#   SECTION: process:<tool>  matching work on the work laptop; same models as that echo block
#   SECTION: next-cli        insert the next runtime's echo+process pair above this marker
# Ollama is the first runtime. Another CLI gets its own echo+process pair.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "${SCRIPT_DIR}/share-paths.sh"

# ===== SECTION: paths =====
print_share_folders
echo "work-laptop share models=[${WORK_LAPTOP_PUBLIC_FOLDER}]/models"
echo "work-laptop local models=[${WORK_LAPTOP_LOCAL_MODELS}]"
# ===== END SECTION: paths =====

# ===== SECTION: echo:copy =====
# Printed only. Copy share models/ onto ~/models, same child folders.
echo "rsync -a [${WORK_LAPTOP_PUBLIC_FOLDER}]/models/ [${WORK_LAPTOP_LOCAL_MODELS}]/"
# ===== END SECTION: echo:copy =====

# ===== SECTION: echo:ollama =====
# Add printed import lines here. One model per line. Do not run ollama in this block.
# Point FROM at the local copy. Do not point at the share.
echo "printf 'FROM [${WORK_LAPTOP_LOCAL_MODELS}]/huggingface/ggml-org--Qwen2.5-Coder-1.5B-Q8_0-GGUF/qwen2.5-coder-1.5b-q8_0.gguf' | ollama create qwen2.5-coder:1.5b-base -f -"
echo "printf 'FROM [${WORK_LAPTOP_LOCAL_MODELS}]/huggingface/bartowski--Qwen2.5-Coder-3B-GGUF/Qwen2.5-Coder-3B-Q4_K_M.gguf' | ollama create qwen2.5-coder:3b-base -f -"
echo "printf 'FROM [${WORK_LAPTOP_LOCAL_MODELS}]/huggingface/Qwen--Qwen2.5-Coder-7B-Instruct-GGUF/qwen2.5-coder-7b-instruct-q4_k_m.gguf' | ollama create qwen2.5-coder:7b-instruct -f -"
echo "printf 'FROM [${WORK_LAPTOP_LOCAL_MODELS}]/huggingface/nomic-ai--nomic-embed-text-v1.5-GGUF/nomic-embed-text-v1.5.Q8_0.gguf' | ollama create nomic-embed-text -f -"
# ===== END SECTION: echo:ollama =====

# ===== SECTION: echo:confirm =====
echo "ollama list"
# ===== END SECTION: echo:confirm =====

if [[ -z "${WORK_LAPTOP_PUBLIC_FOLDER}" ]]; then
  echo "WORK_LAPTOP_PUBLIC_FOLDER is empty in share-paths.sh. Fill the work-laptop mount of \\\\HOM-LAB-HVH-01\\public. Do not use CONTROLLER_PUBLIC_FOLDER=[${CONTROLLER_PUBLIC_FOLDER}]." >&2
  exit 1
fi

# ===== SECTION: process:copy =====
# Same copy as echo:copy. Preserves huggingface/, ollama/, and other children.
copy_public_models_to_local
# ===== END SECTION: process:copy =====

# ===== SECTION: process:ollama =====
# Matching process on the work laptop. Same models as echo:ollama.
# Use "${WORK_LAPTOP_LOCAL_MODELS}" without brackets. Do not point at the share.
printf 'FROM %s\n' "${WORK_LAPTOP_LOCAL_MODELS}/huggingface/ggml-org--Qwen2.5-Coder-1.5B-Q8_0-GGUF/qwen2.5-coder-1.5b-q8_0.gguf" | ollama create qwen2.5-coder:1.5b-base -f -
printf 'FROM %s\n' "${WORK_LAPTOP_LOCAL_MODELS}/huggingface/bartowski--Qwen2.5-Coder-3B-GGUF/Qwen2.5-Coder-3B-Q4_K_M.gguf" | ollama create qwen2.5-coder:3b-base -f -
printf 'FROM %s\n' "${WORK_LAPTOP_LOCAL_MODELS}/huggingface/Qwen--Qwen2.5-Coder-7B-Instruct-GGUF/qwen2.5-coder-7b-instruct-q4_k_m.gguf" | ollama create qwen2.5-coder:7b-instruct -f -
printf 'FROM %s\n' "${WORK_LAPTOP_LOCAL_MODELS}/huggingface/nomic-ai--nomic-embed-text-v1.5-GGUF/nomic-embed-text-v1.5.Q8_0.gguf" | ollama create nomic-embed-text -f -
# ===== END SECTION: process:ollama =====

# ===== SECTION: process:confirm =====
ollama list
# ===== END SECTION: process:confirm =====

# ===== SECTION: next-cli =====
# Another runtime on the work laptop: add SECTION: echo:<tool> then SECTION: process:<tool>
# above this marker. Confirm lines go in echo:confirm and process:confirm.
# First extra tool after Ollama is LM Studio (`lms import`, then `lms ls`).
# ===== END SECTION: next-cli =====
