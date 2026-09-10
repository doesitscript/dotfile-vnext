# PVC claims vs real disk — instructions

## Artifacts

- script: `cst-hom-lab-ctl-dia-vllmcache-overcommit-02.py`
- images: `cst-hom-lab-ctl-dia-vllmcache-overcommit-02.svg` (primary, per folder
  policy), `.png`, `.dot`
- companion doc: `cst-hom-lab-ctl-dia-vllmcache-overcommit-02.md`
- icons: `assets/k8s/**`, `assets/generic/storage/storage.png`,
  `assets/programming/flowchart/stored-data.png`
- stem: `cst-hom-lab-ctl-dia-vllmcache-overcommit-02`

## Scope

- source model: this `.py` is authority; there is no prior Mermaid source
- focus boundary: **why a PVC size request is not a limit** under K3s
  `local-path`, and the shared-node blast radius when the disk fills
- explicit exclusions: the Hub-to-VRAM download path (diagram `-01`), remediation
  sequencing, and any VHDX migration design

## Modification notes

- Numbers are point-in-time probes from 2026-09-10. The 33/19/5/13 G split and
  `64G used` will drift; re-run `du -sh` and `df -h` before reuse.
- `k8s.clusterconfig.Quota` is used as a **negative** node ("No ResourceQuota").
  Keep the dashed firebrick edge and `constraint="false"` so it stays a
  side-annotation and does not join the main rank chain.
- The three clusters are intentional here — grouping *claimed* vs *real* vs
  *blast radius* is the whole argument. Do not flatten them into a linear chain.
- `ranksep: 1.5` is load-bearing. Below about 1.2 the "ENOSPC hits both" label
  overlaps the "Shared failure when it fills" cluster border.
- The failed `vllm-primary` pods observed on the node failed on
  `nvidia.com/gpu` allocation, not disk. Do not redraw them as storage failures.
- If a real CSI backend or ext4 `prjquota` is ever adopted, this diagram becomes
  obsolete rather than needing an update — supersede it, do not patch it.

## Re-render

- local: not available on mac-dev (no Graphviz `dot`, no `diagrams` in `.venv`)
- docker:

  ```bash
  cd docs/diagrams
  bash ~/.cursor/skills/create-diagrams/scripts/render_with_docker.sh \
    ./cst-hom-lab-ctl-dia-vllmcache-overcommit-02.py .
  ```
