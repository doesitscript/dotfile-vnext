# homelab_hosts_file_linux

Writes operator-facing `hom.lab` hostnames to `/etc/hosts` on Hyper-V Linux guests
(`linux_vm_hosts`), using `homelab_hosts_file_web_catalog` rows with
`linux_hosts_enabled: true`.

**Not for:** service-to-service DNS inside guests (see
`docs/lessons-learned/networking/guest-vm-hom-lab-dns-lesser-solution.md`).

| | |
|---|---|
| **Apply** | `playbooks/homelab_hosts_file_linux.yaml` or `playbooks/site.yaml` (`--tags homelab_hosts_file`) |
| **Verify** | `getent hosts langfuse.hom.lab` → LAN publish IP |
| **Undo** | `homelab_hosts_file_linux_enabled: false` |
| **Class** | Idempotent config |
