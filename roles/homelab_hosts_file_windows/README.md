# homelab_hosts_file_windows

Writes operator-facing `hom.lab` hostnames to the Windows hosts file on
**interactive desktop** inventory only (`node_purpose: interactive_desktop`).

Server control hosts (`hom-lab-ctl-hvh-*`) are out of scope.

| | |
|---|---|
| **Apply** | `playbooks/homelab_hosts_file_windows.yaml` when host is commissioned |
| **Verify** | `Resolve-DnsName langfuse.hom.lab` |
| **Undo** | `homelab_hosts_file_windows_enabled: false` |
| **Class** | Idempotent config |
