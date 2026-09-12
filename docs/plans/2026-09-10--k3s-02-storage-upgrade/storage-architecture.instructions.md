# Storage architecture diagram

Source model: `storage-architecture.py`.

The diagram represents the applied 2026-09-11 state: three separate host SSD
volumes, two separate dynamic VHDXs attached to K3s, root retained for the OS,
and cache/log workload boundaries inside the guest. It intentionally excludes
RAID0, pagefile/hibernation relocation, and Prometheus TSDB placement.

Render with the repository environment:

```bash
bin/codex-env python docs/plans/2026-09-10--k3s-02-storage-upgrade/storage-architecture.py
```
