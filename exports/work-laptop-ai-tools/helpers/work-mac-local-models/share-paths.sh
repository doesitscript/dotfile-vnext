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
print_share_folders() {
  echo "CONTROLLER_PUBLIC_FOLDER=[${CONTROLLER_PUBLIC_FOLDER}]"
  echo "WORK_LAPTOP_PUBLIC_FOLDER=[${WORK_LAPTOP_PUBLIC_FOLDER}]"
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

# Work laptop mount of the HVH-01 public share. Section 2 and 3 only.
# Not recorded. Do not copy the controller path. Fill this before writing
# import commands. See helpers/share_topology.md.
WORK_LAPTOP_PUBLIC_FOLDER=""
