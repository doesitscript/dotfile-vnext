#!/usr/bin/env bash
# Mount the HVH-01 public share containing models/ for work-laptop model imports.
# Topology: helpers/share_topology.md
# HVH-02 alternative (does not contain models/): 192.168.50.158
#
# Why this exists: Finder often mounts \\HOM-LAB-HVH-01\public under /Volumes.
# macOS rejects a second mount of the same share, so the stable path
# ~/mnt/hvh-01-public (WORK_LAPTOP_PUBLIC_FOLDER) never appears unless the
# Finder mount is unmounted first. Re-run after wipe/reinstall or after Finder
# remounts the share.

set -euo pipefail

SERVER_IP="192.168.50.234"
SHARE_NAME="public"
MOUNT_POINT="${HOME}/mnt/hvh-01-public"
# Default to the logged-in macOS user (work laptop: a805120). Override with SMB_USER=.
SMB_USER="${SMB_USER:-${USER}}"

existing_mount="$(mount -t smbfs 2>/dev/null | awk -v server="${SERVER_IP}" -v share="${SHARE_NAME}" '$1 ~ ("@" server "/" share "$") { print $3; exit }')"
if [[ -n "${existing_mount}" && "${existing_mount}" == "${MOUNT_POINT}" ]]; then
  echo "HVH-01 public share is already mounted: ${MOUNT_POINT}"
else
  if [[ -n "${existing_mount}" ]]; then
    echo "Unmounting existing HVH-01 public share: ${existing_mount}"
    umount "${existing_mount}"
  fi
  mkdir -p "${MOUNT_POINT}"
  echo "Mounting //${SMB_USER}@${SERVER_IP}/${SHARE_NAME} at ${MOUNT_POINT}"
  echo "macOS may prompt for the SMB password."
  mount_smbfs "//${SMB_USER}@${SERVER_IP}/${SHARE_NAME}" "${MOUNT_POINT}"
fi

if [[ ! -d "${MOUNT_POINT}/models" ]]; then
  echo "Mounted share is missing models/: ${MOUNT_POINT}/models" >&2
  echo "Confirm this is HVH-01 (192.168.50.234), not HVH-02." >&2
  exit 1
fi

echo "Model share ready: ${MOUNT_POINT}/models"
echo "To inspect this path in an interactive shell: source share-paths.sh"
