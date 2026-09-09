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
echo "work-laptop share models=[${WORK_LAPTOP_PUBLIC_FOLDER}]/models"
echo "work-laptop local models=[${WORK_LAPTOP_LOCAL_MODELS}]"
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

# ===== SECTION: echo:copy =====
# Work laptop. Printed only. Same child folders as the share models/ tree.
echo "rsync -a [${WORK_LAPTOP_PUBLIC_FOLDER}]/models/ [${WORK_LAPTOP_LOCAL_MODELS}]/"
# ===== END SECTION: echo:copy =====

# ===== SECTION: process:copy =====
# Later on the work laptop. Needs the share mount.
# copy_public_models_to_local
# ===== END SECTION: process:copy =====

# ===== SECTION: echo:ollama =====
# Work laptop. Printed only. Point at ~/models, not the share.
echo "printf 'FROM [${WORK_LAPTOP_LOCAL_MODELS}]/huggingface/Qwen--Qwen2.5-Coder-1.5B-Instruct/REPLACE.gguf' | ollama create qwen2.5-coder-1.5b -f -"
# ===== END SECTION: echo:ollama =====

# ===== SECTION: process:ollama =====
# Later on the work laptop. Same models as echo:ollama.
# printf 'FROM %s\n' "${WORK_LAPTOP_LOCAL_MODELS}/huggingface/Qwen--Qwen2.5-Coder-1.5B-Instruct/REPLACE.gguf" | ollama create qwen2.5-coder-1.5b -f -
# ===== END SECTION: process:ollama =====

# ===== SECTION: echo:lmstudio =====
echo "lms import \"[${WORK_LAPTOP_LOCAL_MODELS}]/huggingface/Qwen--Qwen2.5-Coder-1.5B-Instruct/REPLACE.gguf\" -y"
# ===== END SECTION: echo:lmstudio =====

# ===== SECTION: process:lmstudio =====
# Later on the work laptop. Same models as echo:lmstudio.
# lms import "${WORK_LAPTOP_LOCAL_MODELS}/huggingface/Qwen--Qwen2.5-Coder-1.5B-Instruct/REPLACE.gguf" -y
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
