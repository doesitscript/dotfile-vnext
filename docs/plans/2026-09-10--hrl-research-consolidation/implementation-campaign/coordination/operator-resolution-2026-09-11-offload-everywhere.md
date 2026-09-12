# Operator resolution — 2026-09-11T19:34Z

## User decision (binding)

Do **not** ask which of S1 / S2 / S4 / S5 / S6 to pick next.

Campaign outcome intent:

1. Move rebuildable / relocatable data **off the constrained root (guest C: analogue)
   and off D:-class local volumes** whenever the refined handoff + HRL research
   already name a suitable replacement (NVMe `/mnt/k3s-cache`, SATA SSD for
   journal/swap/scratch when identity is proven, etc.).
2. For every functional area that has options, configure the **research-library /
   refined-handoff recommended** choice — not a fresh debate.
3. Treat the dynamic work queue as the work list: advance **all ready Light
   functional areas** (`FA-hf-cache-desired-state`, `FA-containerd-imagefs-bind`,
   `FA-local-path-new-only`, `FA-capacity-signal`, `FA-ansible-tag-hygiene`)
   through Implementer → Evaluator under `orchestration_profile: light`.
4. `live-attach-and-apply` (physical disk attach / live Apply / S4-A1-class work)
   stays **Apply-gated**. Encode source desired state in Light. When identity
   is missing, summon Expert to **discover** it with project capabilities
   (inventory, Ansible, SSH/bash, Windows PowerShell helpers)—never invent
   by-id and never ask the human for a probeable fact.

## Parent run mode

- `orchestration_profile: light`
- Refined handoff is the short research memo (not a ceremony)
- Expert Best list + this resolution are default technical authority
- Stuck technical forks → Expert consultation (`coordination/requests/`), not human chat
- Expert may run **read-only** live probes to bind target identity
- No `execution-records/` unless explicitly requested later

## Does not authorize

- Guessing an unproven disk by-id / serial (discover it instead)
- Destructive delete of retained cache without gates
- Silent Apply / attach / format without an explicit Apply-authorized step
