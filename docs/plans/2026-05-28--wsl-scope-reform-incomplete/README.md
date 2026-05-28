---
name: WSL scope reform
overview: >-
  Repo must not treat WSL as server automation except optional desktop paths.
  Archive WSL-centric markdown; decouple Ansible from WSL on Hyper-V/k3s/dkr nodes.
scope: implementation
lifecycle: incomplete
completion_percent: 75
child_workstreams:
  - coordinator: docs/plans/2026-05-28--wsl-scope-reform-incomplete/README.md
  - planner: docs/plans/2026-05-28--homelab-hosts-file-linux-windows-incomplete/README.md
  - docs_sweep: docs/archive/wsl-deprecating/MANIFEST.md
  - ansible_reform: docs/archive/wsl-deprecating/ansible-wsl-reform-report.md
---

# WSL scope reform — coordinator packet

**Policy (Josh):** WSL is for **desktop** setups only. Servers may run WSL locally, but **this project must not model or automate via WSL** except on desktop-class inventory (e.g. `mac-dev` / `dev_workstation` if explicitly enabled).

## Parallel agents (2026-05-28)

| Agent | Job | Output |
|-------|-----|--------|
| Planner | Expand homelab hosts linux/windows plan; **WSL prerequisite first** | `docs/plans/2026-05-28--homelab-hosts-file-linux-windows-incomplete/README.md` |
| Docs sweep | Grep WSL in `*.md`; move to `docs/archive/wsl-deprecating/*-deprecating.md` | `docs/archive/wsl-deprecating/MANIFEST.md` |
| Ansible reform | Remove WSL from functional YAML for non-desktop nodes | `docs/archive/wsl-deprecating/ansible-wsl-reform-report.md` |
| Coordinator | Review MANIFEST → `-delete` vs keep; link plans | this file |

## Coordinator review gate

For each archived doc in MANIFEST:

- **essential** → keep in archive with `-deprecating` only; extract any still-valid facts into active framework docs
- **not essential** → rename to `*-deprecating-delete.md` (or `-delete.md` per user suffix rule)

## Checklist

- [x] **WSL-R0** — Homelab hosts plan published with WSL prerequisite first → `homelab-hosts-file-linux-windows-incomplete`
- [x] **WSL-R1** — Docs MANIFEST at `docs/archive/wsl-deprecating/MANIFEST.md` (42 ops); **restored** `hyper-v-bridge-networking-role` + `k3s-cluster-deployment` (essential)
- [x] **WSL-R2** — Ansible reform → `docs/archive/wsl-deprecating/ansible-wsl-reform-report.md`; `hyperv_ubuntu_vm` README restored to role
- [ ] **WSL-R3** — Fix live `~/.ssh/config` HostName for `hom-lab-ctl-hvh-02` (operator step)
- [x] **WSL-R4** — `docs/plans/README.md` index (pending final sync this run)

## Coordinator decisions (2026-05-28)

| Item | Decision |
|------|----------|
| `hyper-v-bridge-networking-role` | **RESTORED** — active dependency, not WSL-only |
| `k3s-cluster-deployment-incomplete` | **RESTORED** — active cluster work |
| `roles/hyperv_ubuntu_vm/README.md` | **RESTORED** from archive (role doc, not disposable) |
| WSL-centric plans (`decouple-hyper-v-from-wsl`, etc.) | **ARCHIVED** with redirect stubs |
| Project state reports in archive | **delete_candidate** — rename to `*-deprecating-delete.md` when convenient |

## Diagram inventory

- N/A until planner delivers architecture diagram for hosts-file follow-on
