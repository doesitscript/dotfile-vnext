# Linux data-disk mount

Initializes and mounts one explicitly identified non-OS disk. The public
interface is `linux_data_disk_mount_state: present|absent`; mutations remain off
until `linux_data_disk_mount_apply: true` and the required by-id path, observed
serial, mount path, backup evidence, authority reference and
initialization authorization are supplied.

Partition 1 is derived as `<device_by_id>-part1`; an optional legacy
`partition_path` is accepted only when it exactly equals that derived stable
path. The role resolves the partition and asserts its parent is the verified
non-OS disk before filesystem or mount operations. The present path rejects
`/dev/sda` and any serial mismatch before partitioning.
It uses `community.general.parted`, `community.general.filesystem` and
`ansible.posix.mount`. The absent path verifies the live mount and fstab source,
unmounts the matching partition, and removes its fstab entry after explicit
authority; it does not format or delete data.

This role establishes the persistent backing mount. A later authorized vLLM
cache cutover must separately stop the workload, copy and verify data, update
the PV/PVC ownership contract, prove `/health` and `/v1/models`, and retain a
reversal source. This role deliberately does not disguise that migration as a
filesystem mount.
