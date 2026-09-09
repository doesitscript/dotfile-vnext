#!/usr/bin/env bash
# Human-run example. Not Ansible.
# Section 1: controller Mac. Section 2 and 3: work laptop.
# Paths: share-paths.sh. Do not reuse one folder variable for both machines.

# --- 1. Download to public folder (controller Mac) ---
CONTROLLER_PUBLIC_FOLDER="${HOME}/HomelabSMB/hvh-01-public"
# other controller public folder: ${HOME}/HomelabSMB/hvh-02-public
# huggingface cli
hf download Qwen/Qwen2.5-Coder-1.5B-Instruct --local-dir "${CONTROLLER_PUBLIC_FOLDER}/models/huggingface/Qwen--Qwen2.5-Coder-1.5B-Instruct"

# --- 2. Import onto work Mac (work laptop) ---
# WORK_LAPTOP_PUBLIC_FOLDER is not recorded. Do not run these until it is set
# in share-paths.sh. Do not use CONTROLLER_PUBLIC_FOLDER here.
WORK_LAPTOP_PUBLIC_FOLDER=""
# ollama
printf 'FROM %s\n' "${WORK_LAPTOP_PUBLIC_FOLDER}/models/huggingface/Qwen--Qwen2.5-Coder-1.5B-Instruct/REPLACE.gguf" | ollama create qwen2.5-coder-1.5b -f -

# lmstudio
lms import "${WORK_LAPTOP_PUBLIC_FOLDER}/models/huggingface/Qwen--Qwen2.5-Coder-1.5B-Instruct/REPLACE.gguf" -y

# --- 3. Confirm (work laptop) ---
# ollama
ollama list

# lmstudio
lms ls
