#!/usr/bin/env bash
# Format example. The live helpers print from models-to-copy.list.
# Red line: # comment explaining the next command. Next line: the command.
# Hugging Face commands are green. Paste both. The # lines do not run.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "${SCRIPT_DIR}/share-paths.sh"

echo_for_reading "example only. add or remove models in models-to-copy.list."
print_share_folders
echo
print_huggingface_pair \
  "hf download. repo: <hf_repo>. file: <gguf_file>. --local-dir: write that file into \${CONTROLLER_PUBLIC_FOLDER}/models/<share_rel>." \
  "hf download <hf_repo> <gguf_file> --local-dir \"\${CONTROLLER_PUBLIC_FOLDER}/models/<share_rel>\""
echo
print_command_pair \
  "rsync -aP. source: \${WORK_LAPTOP_PUBLIC_FOLDER}/models/<share_rel>/. dest: \${WORK_LAPTOP_LOCAL_MODELS}/<share_rel>/. progress + partial resume; copies that folder only, one way. no --delete." \
  "rsync -aP \"\${WORK_LAPTOP_PUBLIC_FOLDER}/models/<share_rel>/\" \"\${WORK_LAPTOP_LOCAL_MODELS}/<share_rel>/\""
echo
echo_for_reading "work laptop script: continue-mac-local-work-laptop.sh"
print_command_pair \
  "ollama create. name: <ollama_name>. FROM file: \${WORK_LAPTOP_LOCAL_MODELS}/<share_rel>/<gguf_file>. printf writes that one-line Modelfile. -f - reads it from stdin." \
  "printf 'FROM %s\\n' \"\${WORK_LAPTOP_LOCAL_MODELS}/<share_rel>/<gguf_file>\" | ollama create <ollama_name> -f -"
echo
print_command_pair \
  "lms import. file: \${WORK_LAPTOP_LOCAL_MODELS}/<share_rel>/<gguf_file>. -y accepts the import prompt." \
  "lms import \"\${WORK_LAPTOP_LOCAL_MODELS}/<share_rel>/<gguf_file>\" -y"
echo
print_command_pair "ollama list. no parameters. prints names already created in Ollama." "ollama list"
print_command_pair "lms ls. no parameters. prints models already imported in LM Studio." "lms ls"
