# windows_server_backup

First-milestone Windows Server Backup baseline for managed Windows hosts.

Current active scope:

- install `Windows-Server-Backup`
- validate the intended backup target drive
- create the repo-managed backup working structure under `windows_server_backup_work_root`
- write a host-local README describing the managed baseline

Not yet in active execution:

- Windows Server Backup policy/schedule creation
- service-specific backup targets for Postgres, ClickHouse, Redis, or MinIO

Those future service-target tasks are preserved in:

- `tasks/future_service_targets.yml`
