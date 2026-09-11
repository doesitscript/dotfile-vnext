# Hyper-V VM data disk

Manages one explicitly selected secondary VHDX attachment. The role exposes
`hyperv_vm_data_disk_state: present|absent` and defaults to preview-only
(`hyperv_vm_data_disk_apply: false`). Present requires the exact VM, host path,
capacity, disk type, controller slot, backup evidence and authority reference.
Present also requires an explicit host free-space reserve, rejects an existing
VHDX whose virtual size/type differs, and rejects slot or same-VM path conflicts.
All VM/path inputs reach PowerShell through structured module parameters.
Absent previews the exact path and controller identity, detaches only after
explicit authority, and never deletes the VHDX file.

Use [deploy_k3s_data_disk.yaml](../../playbooks/deploy_k3s_data_disk.yaml) so the
Hyper-V attachment precedes guest disk initialization. Always preview the exact
Hyper-V and guest aliases with `--list-hosts --list-tasks --list-tags`, then use
check mode. Apply is prohibited until the campaign authorization ledger records
the selected values and user authority.

Undo: unmount the guest first, then use the absent path to detach the selected
VHDX while preserving its file and retained backup.
