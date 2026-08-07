#!/bin/bash
# Seeded to /root/user-scripts/pre-start.sh and *sourced* by yanwk entrypoint.
# Must use return (never exit) so the parent entrypoint keeps running.
set -uo pipefail

export PIP_USER=true
export PIP_ROOT_USER_ACTION=ignore
export PATH="${PATH}:/root/.local/bin"

PVC_MODELS="/mnt/comfy-models"
COMFY_MODELS="/root/ComfyUI/models"

# Wire PVC into ComfyUI model folders (PVC is NOT mounted over /root/ComfyUI —
# yanwk clones there on boot). Symlink each file from PVC subdirs.
link_pvc_models() {
  local sub src dst f base
  if [ ! -d "${PVC_MODELS}" ]; then
    echo "[WARN] pre-start: ${PVC_MODELS} missing; skip model linking"
    return 0
  fi
  for sub in checkpoints clip clip_vision controlnet diffusion_models embeddings \
             loras text_encoders unet upscale_models vae vae_approx; do
    mkdir -p "${PVC_MODELS}/${sub}"
    src="${PVC_MODELS}/${sub}"
    dst="${COMFY_MODELS}/${sub}"
    mkdir -p "${dst}"
    for f in "${src}"/*; do
      [ -e "${f}" ] || continue
      base="$(basename "${f}")"
      case "${base}" in
        put_*_here|README*|.*) continue ;;
      esac
      ln -sfn "${f}" "${dst}/${base}"
    done
  done
  mkdir -p "${PVC_MODELS}/output" "${PVC_MODELS}/input" \
           "${PVC_MODELS}/workflows"
  # Optional operator input/output on PVC
  mkdir -p /root/ComfyUI/input /root/ComfyUI/output
  if [ -d "${PVC_MODELS}/input" ]; then
    ln -sfn "${PVC_MODELS}/input" /root/ComfyUI/input/pvc 2>/dev/null || true
  fi
  echo "[INFO] pre-start: linked PVC models from ${PVC_MODELS}"
}

link_pvc_models || echo "[WARN] pre-start: model link step failed (continuing)"

install_pkgs() {
  local py="$1"
  if "${py}" -m pip --version >/dev/null 2>&1; then
    "${py}" -m pip install --quiet comfy-aimdo blake3 comfy-kitchen || true
    return 0
  fi
  return 1
}

if install_pkgs python3; then
  return 0 2>/dev/null || true
  return 0
fi

for py in /opt/python/bin/python3 /usr/local/bin/python3 /venv/bin/python3 /root/ComfyUI/.venv/bin/python3; do
  if [ -x "${py}" ] && install_pkgs "${py}"; then
    return 0 2>/dev/null || true
    return 0
  fi
done

echo "[WARN] pre-start: no usable pip; continuing with image-bundled packages"
return 0 2>/dev/null || true
