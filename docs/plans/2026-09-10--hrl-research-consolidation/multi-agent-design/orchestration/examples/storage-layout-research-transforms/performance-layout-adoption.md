# Performance layout adoption — storage campaign

## Status

This is the user-directed adoption of the On-site Expert's performance pass.
It materializes the placement decisions into the campaign without asserting that
any mount, migration, or hardware attachment has happened. The source is
[the layout performance evaluation](../../multi-agent-design/multi-agent-onsite-expert/examples/storage-performance-research-application.md).

Implementer/Evaluator primary package:
[`../../05-refined-technical-handoff--storage-layout.md`](../../05-refined-technical-handoff--storage-layout.md)
(owner-mapped functional areas). This file is a historical placement ledger
example; the refined handoff is what the pair must read first.

## Placement decisions

| Storage class | Selected use | Explicit exclusions |
| --- | --- | --- |
| Existing root VHDX | OS; K3s server SQLite/database and TLS; kubelet-managed pod logs, capped in place | HF model cache, containerd image store, and new local-path data |
| New 200 GiB NVMe-backed VHDX at `/mnt/k3s-cache` | `HF_HUB_CACHE`, containerd agent/image store, and new local-path PVC backing | K3s server state, TLS, Prometheus/Grafana durable state, and credentials |
| Smaller SATA SSD, only after its identity/capacity are discovered | systemd journal at `/mnt/logs`, host/system swap at `/mnt/swap`, and rebuildable compile/package/scratch caches where same-filesystem requirements permit | HF model weights, durable K3s or database state, and kubelet pod logs |

The small-drive allocation intentionally gives the lower-performance but
appropriate workloads a separate home. It isolates swap and journal I/O from
NVMe model loading rather than treating the SATA SSD as unused capacity.

## Planned changes by campaign slice

- **S3 — model and artifact placement:** use `HF_HUB_CACHE=/mnt/k3s-cache/hf/hub`
  and retain `HF_TOKEN_PATH` on the durable/internal root. Use
  `VLLM_CACHE_ROOT` for compile artifacts, preferring the SATA SSD only when
  discovered and safe for its serving environment; otherwise keep it under the
  NVMe mount. Retain the original cache until the defined health, DiskPressure,
  capacity, and rollback checks pass.
- **S4 — NVMe backing and K3s agent offload:** create and verify the 200 GiB
  VHDX before data movement. The planned mount provides separate destinations
  for HF data, containerd (via a data-preserving bind-mount migration), and
  newly provisioned local-path PVCs. Existing PV paths remain immutable until a
  deliberate migration; no destructive shortcut role may be used.
- **S5 — low-value I/O and retention:** after a separate SATA discovery receipt,
  cap and relocate the systemd journal with a `nofail` mount, add only a
  kubelet-compatible host/system swap configuration, and retain the current
  journald → Alloy → Loki/Grafana reporting path. Pod logs stay on root and are
  capped through kubelet settings; they must not be moved to a separate
  filesystem because that removes kubelet disk-pressure accounting.

## Technical corrections that constrain implementation

1. Use `HF_HUB_CACHE`, not `TRANSFORMERS_CACHE`.
2. Use the running image's supported `hf cache` subcommands, not the deprecated
   `huggingface-cli` stub.
3. If a containerd template becomes necessary on this K3s/containerd 2.x node,
   use `config-v3.toml.tmpl` and preserve the generated base template; this
   campaign does not currently authorize a containerd configuration override.
4. Any swap work must first prove the live K3s/Kubelet contract supports it
   (`failSwapOn: false`, while preserving `NoSwap` for pods) and reconcile the
   existing readiness role's swap-disabled default. This is an explicit
   compatibility gate, not an instruction to enable swap immediately.

A repository search at adoption time found no active implementation use of
`TRANSFORMERS_CACHE`, deprecated `huggingface-cli`, or a custom containerd
template. These are forward implementation constraints, not retroactive live
failures.

## Required discovery and acceptance gates

- Confirm the NVMe VHDX controller slot, guest by-id path, serial, ext4/xfs
  filesystem, and overlayfs support before containerd relocation.
- Discover the SATA SSD's physical identity, capacity, health, and guest path
  before allocating journal, swap, or compile-cache paths.
- Validate containerd relocation with `crictl imagefsinfo`, workload readiness,
  and no DiskPressure regression.
- Validate model cutover with `/health`, `/v1/models`, cache integrity, root and
  NVMe capacity, and retained rollback data.
- Treat Prometheus TSDB, Grafana state, notebooks, K3s server data, TLS keys,
  and tokens as durable data; do not place them on either offload class without
  a separate durable-storage design.
