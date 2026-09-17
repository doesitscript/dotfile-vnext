# LOGS-HOST three-part migration — instructions

## Artifacts
- script: `logs-host-three-part-migration.py`
- image: `logs-host-three-part-migration.png`
- stem: `logs-host-three-part-migration`
- plan: `../2026-09-16--physical-ssd-wiring-and-cold-artifact-migration.md`

## Scope
- source model: Codex note that inclusive label becomes `LOGS-HOST` and the
  desired end state is three sinks on `F:` with different mechanisms
- focus boundary: desired end-state wiring for logs only (not cache/cold)
- explicit exclusions: `HOT-DATA-HOST` / `COLD-DATA-HOST`, model migration,
  containerd/cache layout from `storage-architecture.py`

## Story the diagram tells
1. **Windows Event Logs** → redirect onto `F:` (native Windows path).
2. **K3s logs** → relocate the existing logs VHDX onto `F:`, keep guest mount
   `LABEL=k3s-logs` / `/mnt/k3s-logs`.
3. **Docker** → separate Linux VM (root ~92% full) cannot write directly to the
   Windows filesystem; needs its own Hyper-V-attached log/data VHDX **backed by**
   `F:`.

## Modification notes
- Volume label in Codex text is `LOGS-HOST`; applied plan family often uses
  `K3S-LOGS-HOST` for the Samsung NTFS volume — reconcile naming when promoting
  out of `diagrams-wip`.
- Docker owner / daemon paths were still being checked when this sketch was
  drawn; update the Docker cluster labels once those paths are confirmed.
- Prefer short labels; avoid adding cache/cold SSD nodes to this focused view.

## Re-render
- local (needs `diagrams` + Graphviz `dot`):
  `bin/codex-env python diagrams-wip/logs-host-three-part-migration.py`
- docker:
  `~/.cursor/skills/create-diagrams/scripts/render_with_docker.sh \
    docs/plans/2026-09-10--k3s-02-storage-upgrade/diagrams-wip/logs-host-three-part-migration.py \
    docs/plans/2026-09-10--k3s-02-storage-upgrade/diagrams-wip`
