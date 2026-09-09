# Share paths and echo printers for the human model helpers.
# Topology: helpers/share_topology.md
# Model list: models-to-copy.list (source of truth).
#
# These helpers only print commands. They do not download, copy, or import.
#
# Two lines per command:
#   red # comment — explains the next command, parameter by parameter
#   next line — the command to paste
# A block of both can be pasted together. The # lines do nothing.

# Controller Mac (mac-dev, finder_login). Download echo only.
# Staging host is HOM-LAB-HVH-01 (\\HOM-LAB-HVH-01\public).
# That share root has: apps, artifacts, driver-staging, models, studio.
# HVH-02 public does not have models/. Do not swap this value.
CONTROLLER_PUBLIC_FOLDER="${HOME}/HomelabSMB/hvh-01-public"

# Work laptop owned weight root. Import echo points here, not at the share.
WORK_LAPTOP_LOCAL_MODELS="${HOME}/models"

_SHARE_PATHS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_LAPTOP_MODEL_MANIFEST="${_SHARE_PATHS_DIR}/models-to-copy.list"

# Work laptop mount of the HVH-01 public share, created by setup_shares.sh.
# Copy echo source only. Do not copy the controller path.
# See helpers/share_topology.md.
WORK_LAPTOP_PUBLIC_FOLDER="${HOME}/mnt/hvh-01-public"

# Red: # comment explaining the next command. Safe to paste.
# Green: Hugging Face command to run.
_READ_COLOR=$'\033[31m'
_HF_COLOR=$'\033[32m'
_RESET=$'\033[0m'

echo_for_reading() {
  local text="$*"
  text="${text#\# }"
  text="${text#\#}"
  printf '%b# %s%b\n' "${_READ_COLOR}" "${text}" "${_RESET}"
}

echo_for_huggingface() {
  printf '%b%s%b\n' "${_HF_COLOR}" "$*" "${_RESET}"
}

# First argument is the explanation. Printed as a # comment.
# Second argument is the command to paste.
print_command_pair() {
  echo_for_reading "$1"
  printf '%s\n' "$2"
}

print_huggingface_pair() {
  echo_for_reading "$1"
  echo_for_huggingface "$2"
}

print_share_folders() {
  echo_for_reading "CONTROLLER_PUBLIC_FOLDER is the controller Mac folder for the HVH-01 public share: ${CONTROLLER_PUBLIC_FOLDER}"
  echo_for_reading "WORK_LAPTOP_PUBLIC_FOLDER is the work-laptop mount of that same share: ${WORK_LAPTOP_PUBLIC_FOLDER}"
  echo_for_reading "WORK_LAPTOP_LOCAL_MODELS is the work-laptop folder that receives the copied models: ${WORK_LAPTOP_LOCAL_MODELS}"
  echo_for_reading "model list is ${WORK_LAPTOP_MODEL_MANIFEST}"
}

# Read the manifest. Skip blanks and # comments.
# Calls the given function with: share_rel hf_repo gguf_file ollama_name
each_listed_model() {
  local line share_rel hf_repo gguf_file ollama_name
  if [[ ! -f "${WORK_LAPTOP_MODEL_MANIFEST}" ]]; then
    echo "Model manifest is missing: ${WORK_LAPTOP_MODEL_MANIFEST}" >&2
    return 1
  fi
  while IFS= read -r line || [[ -n "${line}" ]]; do
    line="${line%%#*}"
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [[ -z "${line}" ]] && continue
    IFS='|' read -r share_rel hf_repo gguf_file ollama_name <<<"${line}"
    share_rel="${share_rel#"${share_rel%%[![:space:]]*}"}"
    share_rel="${share_rel%"${share_rel##*[![:space:]]}"}"
    [[ -z "${share_rel}" ]] && continue
    "$@" "${share_rel}" "${hf_repo}" "${gguf_file}" "${ollama_name}"
  done < "${WORK_LAPTOP_MODEL_MANIFEST}"
}

_echo_hf_download() {
  local share_rel="$1" hf_repo="$2" gguf_file="$3"
  local dest="${CONTROLLER_PUBLIC_FOLDER}/models/${share_rel}"
  print_huggingface_pair \
    "hf download. repo: ${hf_repo}. file: ${gguf_file}. --local-dir: write that file into ${dest}." \
    "hf download ${hf_repo} ${gguf_file} --local-dir \"${dest}\""
}

_echo_copy_one() {
  local share_rel="$1"
  local src="${WORK_LAPTOP_PUBLIC_FOLDER}/models/${share_rel}/"
  local dest="${WORK_LAPTOP_LOCAL_MODELS}/${share_rel}/"
  print_command_pair \
    "rsync -aP. source: ${src}. dest: ${dest}. shows live progress for each file and retains partial files if interrupted. On rerun, matching files are skipped; only missing or changed files transfer. copies that folder only, one way. no --delete, so nothing already on the Mac is removed." \
    "rsync -aP \"${src}\" \"${dest}\""
}

_echo_ollama_one() {
  local share_rel="$1" _hf_repo="$2" gguf_file="$3" ollama_name="$4"
  local weight="${WORK_LAPTOP_LOCAL_MODELS}/${share_rel}/${gguf_file}"
  print_command_pair \
    "ollama create. name: ${ollama_name}. FROM file: ${weight}. printf writes that one-line Modelfile. -f - reads it from stdin." \
    "printf 'FROM %s\\n' \"${weight}\" | ollama create ${ollama_name} -f -"
}

_echo_lmstudio_one() {
  local share_rel="$1" _hf_repo="$2" gguf_file="$3"
  local weight="${WORK_LAPTOP_LOCAL_MODELS}/${share_rel}/${gguf_file}"
  print_command_pair \
    "lms import. file: ${weight}. -y accepts the import prompt." \
    "lms import \"${weight}\" -y"
}

print_echo_huggingface() {
  each_listed_model _echo_hf_download
}

print_echo_copy() {
  echo_for_reading "copy section. one rsync per listed folder. same path under the work-laptop models folder as on the share."
  each_listed_model _echo_copy_one
}

print_echo_confirm() {
  print_command_pair "ollama list. no parameters. prints names already created in Ollama." "ollama list"
  print_command_pair "lms ls. no parameters. prints models already imported in LM Studio." "lms ls"
}

print_echo_ollama() {
  each_listed_model _echo_ollama_one
}

print_echo_lmstudio() {
  each_listed_model _echo_lmstudio_one
}
