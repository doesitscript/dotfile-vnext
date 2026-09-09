#!/usr/bin/env bash
# Pattern copy. Runnable file:
# exports/work-laptop-ai-tools/helpers/work-mac-local-models/example-commands.sh
# Format example. Not this plan's download list. Do not run it as the plan.
# Section pairs: echo:<tool> then process:<tool>. Another CLI copies that pair.
# Paths: source share-paths.sh. Topology: helpers/share_topology.md.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "${SCRIPT_DIR}/share-paths.sh"

# ===== SECTION: paths =====
print_share_folders
echo "controller huggingface models=[${CONTROLLER_PUBLIC_FOLDER}]/models/huggingface"
echo "work-laptop huggingface models=[${WORK_LAPTOP_PUBLIC_FOLDER}]/models/huggingface"
# ===== END SECTION: paths =====

# ===== SECTION: echo:huggingface =====
# Controller Mac. Printed only. One model per line.
echo "hf download Qwen/Qwen2.5-Coder-1.5B-Instruct --local-dir \"[${CONTROLLER_PUBLIC_FOLDER}]/models/huggingface/Qwen--Qwen2.5-Coder-1.5B-Instruct\""
# ===== END SECTION: echo:huggingface =====

# ===== SECTION: process:huggingface =====
# Later on the controller Mac (mac-dev). Same models as echo:huggingface.
# Do not run until the human asks.
# hf download Qwen/Qwen2.5-Coder-1.5B-Instruct --local-dir "${CONTROLLER_PUBLIC_FOLDER}/models/huggingface/Qwen--Qwen2.5-Coder-1.5B-Instruct"
# ===== END SECTION: process:huggingface =====

# ===== SECTION: echo:ollama =====
# Work laptop. Printed only. Do not use CONTROLLER_PUBLIC_FOLDER here.
echo "printf 'FROM [${WORK_LAPTOP_PUBLIC_FOLDER}]/models/huggingface/Qwen--Qwen2.5-Coder-1.5B-Instruct/REPLACE.gguf' | ollama create qwen2.5-coder-1.5b -f -"
# ===== END SECTION: echo:ollama =====

# ===== SECTION: process:ollama =====
# Later on the work laptop. Same models as echo:ollama.
# printf 'FROM %s\n' "${WORK_LAPTOP_PUBLIC_FOLDER}/models/huggingface/Qwen--Qwen2.5-Coder-1.5B-Instruct/REPLACE.gguf" | ollama create qwen2.5-coder-1.5b -f -
# ===== END SECTION: process:ollama =====

# ===== SECTION: echo:lmstudio =====
echo "lms import \"[${WORK_LAPTOP_PUBLIC_FOLDER}]/models/huggingface/Qwen--Qwen2.5-Coder-1.5B-Instruct/REPLACE.gguf\" -y"
# ===== END SECTION: echo:lmstudio =====

# ===== SECTION: process:lmstudio =====
# Later on the work laptop. Same models as echo:lmstudio.
# lms import "${WORK_LAPTOP_PUBLIC_FOLDER}/models/huggingface/Qwen--Qwen2.5-Coder-1.5B-Instruct/REPLACE.gguf" -y
# ===== END SECTION: process:lmstudio =====

# ===== SECTION: echo:confirm =====
echo "ollama list"
echo "lms ls"
# ===== END SECTION: echo:confirm =====

# ===== SECTION: process:confirm =====
# ollama list
# lms ls
# ===== END SECTION: process:confirm =====

# ===== SECTION: next-cli =====
# Another CLI: add echo:<tool> then process:<tool> above this marker.
# Controller downloaders stay on mac-dev. Import tools stay on the work laptop.
# ===== END SECTION: next-cli =====
