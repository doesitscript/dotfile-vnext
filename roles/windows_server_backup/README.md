# windows_server_backup

First-milestone Windows Server Backup baseline for managed Windows hosts.

> Status: active but intentionally incomplete. This role is the current
> first-milestone baseline for Windows backup capability in the repo. It is
> meant to install and shape the baseline safely, not to represent a finished
> Windows backup program yet.

Canonical naming and zone contract:

- [docs/backup/backup-naming-contract.md](/Users/joshc/develop/dotfile-vnext/docs/backup/backup-naming-contract.md)

Current active scope:

- install `Windows-Server-Backup`
- validate the intended backup target drive
- create the repo-managed backup working structure under the accepted zones:
  - `native-host-recovery`
  - `backupsets`
  - `backup-catalog`
  - `staging`
- write a host-local README describing the managed baseline

Current validation status:

- the milestone-one `present` path has been used as active repo work
- the broader backup program beyond this baseline is still in progress
- schedule/policy automation and service-specific payload backups are not yet
  part of the active managed scope
- the `absent` path exists as a lifecycle surface, but should still be treated
  as a cautious cleanup path rather than a fully matured teardown workflow

Current milestone-one physical direction:

- `E:\WindowsImageBackup\` for the native Windows host-recovery path
- `E:\backupsets\...` for repo-managed backup artifacts
- `E:\backup-catalog\...` for metadata and manifests
- `F:\staging\...` for temporary backup workspace

Not yet in active execution:

- Windows Server Backup policy/schedule creation
- service-specific backup targets for Postgres, ClickHouse, Redis, or MinIO

Those future service-target tasks are preserved in:

- `tasks/future_service_targets.yml`
