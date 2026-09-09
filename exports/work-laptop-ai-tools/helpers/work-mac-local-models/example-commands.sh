#!/usr/bin/env bash
# Human-run example. Not Ansible.
# Section 1: controller Mac. Section 2 and 3: work laptop.
# Do not run this whole file on one machine.

# --- 1. Download to public folder (controller Mac) ---
PUBLIC_FOLDER="${HOME}/HomelabSMB/hvh-01-public"
# other public folder: ${HOME}/HomelabSMB/hvh-02-public
# huggingface cli
hf download Qwen/Qwen2.5-Coder-1.5B-Instruct --local-dir "${PUBLIC_FOLDER}/models/huggingface/Qwen--Qwen2.5-Coder-1.5B-Instruct"

# --- 2. Import onto work Mac (work laptop) ---
# Set PUBLIC_FOLDER to this Mac's mount of the same share before these lines.
# ollama
printf 'FROM %s\n' "${PUBLIC_FOLDER}/models/huggingface/Qwen--Qwen2.5-Coder-1.5B-Instruct/REPLACE.gguf" | ollama create qwen2.5-coder-1.5b -f -

# lmstudio
lms import "${PUBLIC_FOLDER}/models/huggingface/Qwen--Qwen2.5-Coder-1.5B-Instruct/REPLACE.gguf" -y

# --- 3. Confirm (work laptop) ---
# ollama
ollama list

# lmstudio
lms ls
