#!/usr/bin/env bash
# Human-run on the controller Mac (mac-dev) only.
# Prints download commands, then stops. Process blocks are for later on this Mac.
# Plan: docs/brainstorming_designs/2026-09-09--continue-mac-local-model-patterns
# Paths: helpers/share_topology.md and share-paths.sh
#
# Divider contract (skills add lines only inside these markers):
#   SECTION: paths
#   SECTION: echo:<tool>     printed only; one model per line; folder value in []
#   SECTION: process:<tool>  matching work later on mac-dev; same models as that echo block
#   SECTION: next-cli        insert the next tool's echo+process pair above this marker
# Hugging Face is the first downloader. Another CLI gets its own echo+process pair.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "${SCRIPT_DIR}/share-paths.sh"

# ===== SECTION: paths =====
print_share_folders
echo "controller huggingface models=[${CONTROLLER_PUBLIC_FOLDER}]/models/huggingface"
# ===== END SECTION: paths =====

# ===== SECTION: echo:huggingface =====
# Add printed hf download lines here. One model per line. Do not run hf in this block.
# Lands in HVH-01 public models/huggingface (not HVH-02).
echo "hf download ggml-org/Qwen2.5-Coder-1.5B-Q8_0-GGUF qwen2.5-coder-1.5b-q8_0.gguf --local-dir \"[${CONTROLLER_PUBLIC_FOLDER}]/models/huggingface/ggml-org--Qwen2.5-Coder-1.5B-Q8_0-GGUF\""
echo "hf download bartowski/Qwen2.5-Coder-3B-GGUF Qwen2.5-Coder-3B-Q4_K_M.gguf --local-dir \"[${CONTROLLER_PUBLIC_FOLDER}]/models/huggingface/bartowski--Qwen2.5-Coder-3B-GGUF\""
echo "hf download Qwen/Qwen2.5-Coder-7B-Instruct-GGUF qwen2.5-coder-7b-instruct-q4_k_m.gguf --local-dir \"[${CONTROLLER_PUBLIC_FOLDER}]/models/huggingface/Qwen--Qwen2.5-Coder-7B-Instruct-GGUF\""
echo "hf download nomic-ai/nomic-embed-text-v1.5-GGUF nomic-embed-text-v1.5.Q8_0.gguf --local-dir \"[${CONTROLLER_PUBLIC_FOLDER}]/models/huggingface/nomic-ai--nomic-embed-text-v1.5-GGUF\""
echo "hf download Qwen/Qwen3-4B-GGUF Qwen3-4B-Q4_K_M.gguf --local-dir \"[${CONTROLLER_PUBLIC_FOLDER}]/models/huggingface/Qwen--Qwen3-4B-GGUF\""

# ===== END SECTION: echo:huggingface =====

# ===== SECTION: process:huggingface =====
# Matching process for later on the controller Mac (mac-dev). Same models as echo:huggingface.
# Do not run until the human asks. Use "${CONTROLLER_PUBLIC_FOLDER}" without brackets.
# Order: require_controller_model_staging, source HF_TOKEN, then one hf download per echo line.
#
# require_controller_model_staging
# HF_ENV_FILE="${HOME}/.config/homelab/huggingface_cli_mac.env"
# . "${HF_ENV_FILE}"
# hf download ggml-org/Qwen2.5-Coder-1.5B-Q8_0-GGUF qwen2.5-coder-1.5b-q8_0.gguf --local-dir "${CONTROLLER_PUBLIC_FOLDER}/models/huggingface/ggml-org--Qwen2.5-Coder-1.5B-Q8_0-GGUF"
# hf download bartowski/Qwen2.5-Coder-3B-GGUF Qwen2.5-Coder-3B-Q4_K_M.gguf --local-dir "${CONTROLLER_PUBLIC_FOLDER}/models/huggingface/bartowski--Qwen2.5-Coder-3B-GGUF"
# hf download Qwen/Qwen2.5-Coder-7B-Instruct-GGUF qwen2.5-coder-7b-instruct-q4_k_m.gguf --local-dir "${CONTROLLER_PUBLIC_FOLDER}/models/huggingface/Qwen--Qwen2.5-Coder-7B-Instruct-GGUF"
# hf download nomic-ai/nomic-embed-text-v1.5-GGUF nomic-embed-text-v1.5.Q8_0.gguf --local-dir "${CONTROLLER_PUBLIC_FOLDER}/models/huggingface/nomic-ai--nomic-embed-text-v1.5-GGUF"
# hf download Qwen/Qwen3-4B-GGUF Qwen3-4B-Q4_K_M.gguf --local-dir "${CONTROLLER_PUBLIC_FOLDER}/models/huggingface/Qwen--Qwen3-4B-GGUF"
# ===== END SECTION: process:huggingface =====

# ===== SECTION: next-cli =====
# Another downloader on mac-dev: add SECTION: echo:<tool> then SECTION: process:<tool>
# above this marker. One blank line between tool pairs. Do not add a second share root.
# ===== END SECTION: next-cli =====
