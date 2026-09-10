# vLLM weights: Hub to disk to GPU — instructions

## Artifacts

- script: `cst-hom-lab-ctl-dia-vllmcache-flow-01.py`
- images: `cst-hom-lab-ctl-dia-vllmcache-flow-01.svg` (primary, per folder
  policy), `.png`, `.dot`
- companion doc: `cst-hom-lab-ctl-dia-vllmcache-flow-01.md`
- icons: `assets/k8s/**`, `assets/generic/**`, `assets/onprem/network/internet.png`,
  `assets/programming/flowchart/internal-storage.png`
- stem: `cst-hom-lab-ctl-dia-vllmcache-flow-01`

## Scope

- source model: this `.py` is authority; there is no prior Mermaid source
- focus boundary: the **download-to-VRAM path for one vLLM model** on
  `hom-lab-ctl-k3s-02`
- explicit exclusions: LiteLLM gateway routing, ComfyUI GPU time-share, the
  HVH-01 SMB catalog lane, and the PVC overcommit story (that is diagram `-02`)

## Modification notes

- Numbers are point-in-time probes from 2026-09-10 (`df -h`, `Get-VHD`). Re-probe
  before reusing them; `77G total, 13G free` and `19 GB for this model` will drift.
- The GPU VRAM node uses `programming.flowchart.InternalStorage` because
  Mingrammer has no NVIDIA/GPU icon. Swap to `diagrams.custom.Custom` with a
  local PNG if branding is wanted.
- The disk node uses `generic.storage.Storage` deliberately: `onprem.storage`
  only ships Ceph/Gluster/Portworx, which would misrepresent a plain ext4 volume.
  This is a domain-correct disk glyph, not a banned blank/cube placeholder.
- Step 7 (`pvdir >> vram`) is intentionally **constrained**, so VRAM ranks as a
  peer of the root filesystem. Setting `constraint="false"` floats it to rank 0
  and reads as if the Hub feeds the GPU directly. Do not re-add it.
- `labelloc: t` keeps the title off the bottom node label. Without it the title
  collides with the `HOM-LAB-HVH-02` caption.
- If the storage lane SMB mount is ever wired into the pod, add a branch at
  step 1 rather than replacing the Hub node.

## Re-render

- local: not available on mac-dev (no Graphviz `dot`, no `diagrams` in `.venv`)
- docker:

  ```bash
  cd docs/diagrams
  bash ~/.cursor/skills/create-diagrams/scripts/render_with_docker.sh \
    ./cst-hom-lab-ctl-dia-vllmcache-flow-01.py .
  ```
