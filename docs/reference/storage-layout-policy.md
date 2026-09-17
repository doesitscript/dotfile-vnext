# Storage Layout Policy

This is the reusable explanation of how this lab separates storage. It is
intended to make future rebuilds understandable without reverse-engineering
individual playbooks or host variables.

## Placement Logic

Storage placement is based on five questions:

1. **Can the data be regenerated?** Cache and derived artifacts tolerate a disk
   loss more readily than unique databases, credentials, or user files.
2. **How latency-sensitive is it?** Active model weights, container layers, and
   databases benefit from NVMe or SSD; backups do not.
3. **How write-heavy is it?** Journals, event logs, and pod logs need bounded
   retention and should not consume OS-disk capacity.
4. **How large and cold is it?** Inactive model archives can trade latency for
   capacity.
5. **What failure should be isolated?** OS failure, cache exhaustion, log
   growth, and backup capacity should not all consume one filesystem.

The result is a policy classification, not a rule based only on device names.
Guest mounts, host VHDX paths, stable disk identities, purposes, durability,
and monitoring expectations should agree before a storage change is applied.

## Good, Better, Best

### Good: Operational

- Keep OS and application data on the available system disk.
- Apply retention limits to logs and container data.
- Keep at least one backup or export on a different physical device.

This is functional, but an OS-disk failure or runaway workload can still affect
several storage concerns at once.

### Better: Separated Workloads

- Put OS and boot files on one disk.
- Put active working data, container layers, or model caches on SSD/NVMe.
- Put logs on a separate SSD filesystem or VHDX with explicit retention.
- Put cold archives and backups on spinning disk or external USB storage.
- Monitor each mount independently.

This is the current shape of the Hyper-V K3s and Docker lane.

### Best: Tiered and Isolated

- Use NVMe for latency-sensitive active workloads and databases.
- Use SSD for service logs, pod logs, and frequently read working data.
- Use a separate SSD for regenerable caches when cache churn is substantial.
- Use spinning disks or external USB disks for cold archives, backups, and
  offline copies.
- Keep at least one backup in a different failure domain from the host.
- Record stable identities and enforce placement through inventory and
  idempotent playbooks.

Best is not simply "more disks." It is independent failure behavior, enough
free-space headroom, and a documented recovery path.

## Current Lab Mapping

| Class | Current location | Workload | Why it belongs there |
|---|---|---|---|
| OS / VM system | Host `D:` | Hyper-V VM OS VHDXs | Stable system storage; not a cache or log target |
| Hot data | Host `G:` `HOT-DATA-HOST` | K3s containerd, HF/model cache, future active workloads | High churn and expensive-to-regenerate data; fast SSD |
| Service logs | Host `F:` `LOGS-HOST` | Windows Event Logs, K3s pod logs, Docker journald/Loki/JSON logs | Write-heavy, bounded-retention data isolated from OS and app data |
| Cold data | Host `H:` `COLD-DATA-HOST` | Inactive model archives, experimental artifacts, future durable cold data | Large, reproducible, not latency-sensitive |
| Backup / external archive | Spinning disk or external USB | Backups, exports, long-term copies | Capacity and failure separation matter more than latency |
| Future hot tier | NVMe, where available | Active databases, active model weights, high-IOPS application data | Lowest latency and highest I/O demand |

The physical labels identify ownership and intent. The guest does not need to
know whether its stable data disk is backed by a host SSD or another medium;
the host-side inventory makes that decision explicit.

## Workload Class vs Media Class

These are related but different classifications:

- **Workload class** describes how the data behaves: hot/active, logs,
  reproducible cache, cold archive, or backup.
- **Media class** describes what the device is: NVMe, SATA SSD, spinning disk,
  or external USB storage.

The workload class chooses the placement intent; the media class determines
the performance, capacity, and failure tradeoff. Therefore a cold archive may
temporarily live on an SSD when fast promotion is useful, and a hot cache may
be placed on SATA SSD when NVMe capacity is reserved for more latency-sensitive
work.

## Workload-to-Media Fit

| Workload | Preferred media | Acceptable fallback | Avoid |
|---|---|---|---|
| OS, VM boot, active databases | NVMe | SATA SSD | Spinning or USB for primary runtime |
| Active model weights and high-IOPS working set | NVMe | SATA SSD | Spinning disk when startup or serving latency matters |
| Regenerable container and HF caches | NVMe or SATA SSD | Local SSD-backed VHDX | External USB as the active cache |
| Windows, K3s, and Docker logs | SATA SSD | NVMe | Spinning disk if write latency or service availability matters |
| Cold model archives and experiment artifacts | SATA SSD | Spinning disk or USB | OS/root disk when growth is unbounded |
| Backups and long-term exports | Spinning disk or external USB | SATA SSD | The same physical device as the source data |

## Current-State Assessment

The current host is in a **better, operationally sound state**, not a fully
optimal state:

- NVMe is used for the Windows/Hyper-V system and VM OS storage on C:/D:.
- SATA SSDs are separated by behavior: `HOT-DATA-HOST` for high-churn cache,
  `LOGS-HOST` for write-heavy logs, and `COLD-DATA-HOST` for archives.
- The log and cache workloads are no longer competing with VM OS capacity.
- K3s guest mounts and Docker logging mounts are independently monitored.
- The external USB/spinning tier is appropriately kept out of active VM and
  cache workloads.

The remaining Best-tier opportunities are deliberate tradeoffs, not errors:

1. Move the most latency-sensitive active model or database workload to NVMe
   if it needs more performance than the SATA hot-data tier provides.
2. Move truly cold archives and backup copies to the spinning/USB tier when
   capacity matters more than quick model promotion.
3. Keep at least one backup in a different physical failure domain; a second
   partition or another folder is not a backup boundary.

## Current Guest Paths

- K3s cache: `/mnt/k3s-cache`
- K3s logs: `/mnt/k3s-logs`
- K3s cold artifacts: `/mnt/k3s-cold`
- Docker logging filesystem: `/mnt/logs-host`
- Windows Event Logs: `F:\LOGS-HOST\WindowsEventLogs`
- Windows historical archive: `F:\LOGS-HOST\historical\WindowsEventLogs`

Docker application data under `/srv/data` is intentionally separate from the
Docker logging filesystem. K3s cold archives are separate from the active cache
so an archive does not consume the cache's working headroom.

## Rebuild Checklist

For a new lab system, document these items before applying storage changes:

- device type: NVMe, SSD, spinning disk, or external USB;
- physical identity and failure domain;
- host label or mount label;
- guest mount path or native host path;
- workload class and whether the data is regenerable;
- expected growth and minimum free-space reserve;
- backup or recovery source;
- monitoring and retention policy.

The existing storage playbooks intentionally keep disk discovery, VHDX
attachment, filesystem initialization, migration, and runtime verification as
separate steps. That separation is part of the safety model and should remain
visible when a future hardware layout is different.
