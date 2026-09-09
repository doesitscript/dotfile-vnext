#!/usr/bin/env bash
# Format example. The live helpers print from models-to-copy.list.
# Do not run this file as the model list. Do not wrap paths in [].

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "${SCRIPT_DIR}/share-paths.sh"

echo "# example only. add or remove models in models-to-copy.list."
print_share_folders
echo
echo "# echo:huggingface  (controller Mac)"
echo "hf download <hf_repo> <gguf_file> --local-dir \"\${CONTROLLER_PUBLIC_FOLDER}/models/<share_rel>\""
echo
echo "# echo:copy  (work laptop, one-way, listed folders only)"
echo "rsync -a \"\${WORK_LAPTOP_PUBLIC_FOLDER}/models/<share_rel>/\" \"\${WORK_LAPTOP_LOCAL_MODELS}/<share_rel>/\""
echo
echo "# echo:ollama  (same models)"
echo "printf 'FROM %s\\n' \"\${WORK_LAPTOP_LOCAL_MODELS}/<share_rel>/<gguf_file>\" | ollama create <ollama_name> -f -"
echo
echo "# echo:lmstudio  (same models, another tool section)"
echo "lms import \"\${WORK_LAPTOP_LOCAL_MODELS}/<share_rel>/<gguf_file>\" -y"
