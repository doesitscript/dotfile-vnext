# Share paths and echo printers for the human model helpers.
# Topology: helpers/share_topology.md
# Model list: models-to-copy.list (source of truth).
#
# These helpers only print commands. They do not download, copy, or import.
# Do not wrap folder values in []. A previous print form created a real
# directory named [/Users/joshc/HomelabSMB/hvh-01-public] under this folder.

# Controller Mac (mac-dev, finder_login). Download echo only.
# Staging host is HOM-LAB-HVH-01 (\\HOM-LAB-HVH-01\public).
# That share root has: apps, artifacts, driver-staging, models, studio.
# HVH-02 public does not have models/. Do not swap this value.
CONTROLLER_PUBLIC_FOLDER="${HOME}/HomelabSMB/hvh-01-public"

# Work laptop owned weight root. Import echo points here, not at the share.
WORK_LAPTOP_LOCAL_MODELS="${HOME}/models"

_SHARE_PATHS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_LAPTOP_MODEL_MANIFEST="${_SHARE_PATHS_DIR}/models-to-copy.list"

# Work laptop mount of the HVH-01 public share. Copy echo source only.
# Not recorded. Do not copy the controller path. Fill this before you run
# a printed copy command. See helpers/share_topology.md.
WORK_LAPTOP_PUBLIC_FOLDER=""

print_share_folders() {
  echo "CONTROLLER_PUBLIC_FOLDER=${CONTROLLER_PUBLIC_FOLDER}"
  if [[ -n "${WORK_LAPTOP_PUBLIC_FOLDER}" ]]; then
    echo "WORK_LAPTOP_PUBLIC_FOLDER=${WORK_LAPTOP_PUBLIC_FOLDER}"
  else
    echo "WORK_LAPTOP_PUBLIC_FOLDER is unset. Fill it in share-paths.sh before you run a copy command."
  fi
  echo "WORK_LAPTOP_LOCAL_MODELS=${WORK_LAPTOP_LOCAL_MODELS}"
  echo "model manifest=${WORK_LAPTOP_MODEL_MANIFEST}"
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
  echo "hf download ${hf_repo} ${gguf_file} --local-dir \"\${CONTROLLER_PUBLIC_FOLDER}/models/${share_rel}\""
}

_echo_copy_one() {
  local share_rel="$1"
  echo "rsync -a \"\${WORK_LAPTOP_PUBLIC_FOLDER}/models/${share_rel}/\" \"\${WORK_LAPTOP_LOCAL_MODELS}/${share_rel}/\""
}

_echo_ollama_one() {
  local share_rel="$1" _hf_repo="$2" gguf_file="$3" ollama_name="$4"
  echo "printf 'FROM %s\\n' \"\${WORK_LAPTOP_LOCAL_MODELS}/${share_rel}/${gguf_file}\" | ollama create ${ollama_name} -f -"
}

_echo_lmstudio_one() {
  local share_rel="$1" _hf_repo="$2" gguf_file="$3"
  echo "lms import \"\${WORK_LAPTOP_LOCAL_MODELS}/${share_rel}/${gguf_file}\" -y"
}

print_echo_huggingface() {
  each_listed_model _echo_hf_download
}

print_echo_copy() {
  echo "# one-way copy of listed model folders only. no --delete. does not clean the Mac."
  each_listed_model _echo_copy_one
}

print_echo_ollama() {
  each_listed_model _echo_ollama_one
}

print_echo_lmstudio() {
  each_listed_model _echo_lmstudio_one
}
