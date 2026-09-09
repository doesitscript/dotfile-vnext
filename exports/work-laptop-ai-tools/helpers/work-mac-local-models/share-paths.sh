# Share paths for human model commands.
# Topology (UNC, hosts, mount methods): helpers/share_topology.md
# Do not invent a path. Read that file and this file before writing
# section 1 or section 2.
#
# Mounts are not managed here. A later role may own them. Controller Mac
# mounts today come from parent role macos_smb_public_mounts (finder_login).

# Controller Mac (mac-dev, finder_login). Section 1 only.
# Staging host is HOM-LAB-HVH-01 (\\HOM-LAB-HVH-01\public).
# That share root has: apps, artifacts, driver-staging, models, studio.
# HVH-02 public does not have models/. Do not swap this value.
CONTROLLER_PUBLIC_FOLDER="${HOME}/HomelabSMB/hvh-01-public"
# other controller public folder, not model staging:
# ${HOME}/HomelabSMB/hvh-02-public (\\HOM-LAB-HVH-02\public)

# Bracket the value so an empty variable still shows where it was printed.
# Work laptop owned weight root. Same children as the share's models/ folder
# (huggingface, ollama, and any other ecosystem folder copied across).
# Import commands point here, not at the share. See helpers/share_topology.md.
WORK_LAPTOP_LOCAL_MODELS="${HOME}/models"

print_share_folders() {
  echo "CONTROLLER_PUBLIC_FOLDER=[${CONTROLLER_PUBLIC_FOLDER}]"
  echo "WORK_LAPTOP_PUBLIC_FOLDER=[${WORK_LAPTOP_PUBLIC_FOLDER}]"
  echo "WORK_LAPTOP_LOCAL_MODELS=[${WORK_LAPTOP_LOCAL_MODELS}]"
}

# Copy share models/ onto the work laptop, preserving ecosystem folders.
# Does not copy apps, artifacts, or the rest of the public root.
copy_public_models_to_local() {
  local src="${WORK_LAPTOP_PUBLIC_FOLDER}/models/"
  local dest="${WORK_LAPTOP_LOCAL_MODELS}/"
  if [[ -z "${WORK_LAPTOP_PUBLIC_FOLDER}" ]]; then
    echo "WORK_LAPTOP_PUBLIC_FOLDER is empty. Cannot copy models onto the work laptop." >&2
    return 1
  fi
  if [[ ! -d "${src}" ]]; then
    echo "Share models folder is missing: [${src}]" >&2
    return 1
  fi
  mkdir -p "${WORK_LAPTOP_LOCAL_MODELS}"
  rsync -a "${src}" "${dest}"
}

require_controller_model_staging() {
  local root="${CONTROLLER_PUBLIC_FOLDER}"
  local name
  for name in apps artifacts driver-staging models studio; do
    if [[ ! -d "${root}/${name}" ]]; then
      echo "CONTROLLER_PUBLIC_FOLDER is not the HVH-01 model staging share: missing [${root}/${name}]" >&2
      echo "Expected \\\\HOM-LAB-HVH-01\\public (apps, artifacts, driver-staging, models, studio). Do not use hvh-02-public." >&2
      return 1
    fi
  done
}

# Work laptop mount of the HVH-01 public share. Copy source only.
# Not recorded. Do not copy the controller path. Fill this before the copy
# step. Import commands use WORK_LAPTOP_LOCAL_MODELS, not this mount.
# See helpers/share_topology.md.
WORK_LAPTOP_PUBLIC_FOLDER=""
