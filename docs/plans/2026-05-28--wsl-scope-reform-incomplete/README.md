---
name: Connection-surface reform (formerly WSL scope reform)
overview: >-
  Repo must not treat WSL as server automation. Connection surfaces per inventory
  hostname are authoritative. WSL is desktop-only (optional).
scope: implementation
lifecycle: implemented
completion_percent: 100
child_workstreams:
  - coordinator: docs/plans/2026-05-28--wsl-scope-reform-incomplete/README.md
  - planner: docs/plans/2026-05-28--homelab-hosts-file-linux-windows-incomplete/README.md
  - docs_sweep: docs/archive/wsl-deprecating/MANIFEST.md
  - ansible_reform: docs/archive/wsl-deprecating/ansible-wsl-reform-report.md
  - framework_ssot: docs/reference/connection-surfaces.md
---

# Connection-surface reform — coordinator packet

**Policy:** Use [connection-surfaces.md](../../reference/connection-surfaces.md) per inventory hostname. **WSL** is only for optional **desktop** dev ([desktop-wsl-optional.md](../../reference/desktop-wsl-optional.md)). Servers are not automated through WSL in this repo.

## Checklist

- [x] **REF-0** — `docs/reference/connection-surfaces.md` + `desktop-wsl-optional.md`
- [x] **REF-1** — `AGENTS.md`, `partner_process.md`, framework rules updated (no server WSL defaults)
- [x] **REF-2** — Docs MANIFEST at `docs/archive/wsl-deprecating/MANIFEST.md`; WSL-centric plans archived with redirect stubs
- [x] **REF-3** — Ansible reform → `ansible-wsl-reform-report.md`; `hyperv_ubuntu_vm` server lanes default off WSL mount
- [x] **REF-4** — `hyper-v-bridge` + `k3s-cluster-deployment` plan folders → redirect stubs (full text in archive)
- [x] **REF-5** — `docs/plans/README.md` + root `README.md` aligned to connection surfaces
- [x] **REF-6** — Operator: fix live `~/.ssh/config` `HOM-LAB-HVH-02` → `HostName 192.168.50.158`
- [x] **REF-7** — MANIFEST delete-candidate rename pass (`*-deprecating-delete.md` / `*-deprecating-delete/`)

## Unblocks

| Downstream | Blocked on |
|------------|------------|
| [homelab-hosts-file-linux-windows](../2026-05-28--homelab-hosts-file-linux-windows-incomplete/README.md) | **Unblocked** — scaffold + apply DNS-3 |

## Coordinator decisions (2026-05-28)

| Item | Decision |
|------|----------|
| `roles/hyperv_ubuntu_vm/README.md` | Active role doc — WSL mount is desktop opt-in only |
| WSL-centric plans | **ARCHIVED** under `docs/archive/wsl-deprecating/plans/` |
| `.cursor/skills/capture-wsl-systemctl` | **Keep** — desktop diagnostics only |

## Diagram inventory

- N/A (policy/coordinator packet)
