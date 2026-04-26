# Backup Naming Contract

This document records the current accepted backup naming contract for this
project.

It is the canonical reference for:

- backup zones
- backup path naming
- current accepted context values
- examples based on the actual project

This contract is intended to be enterprise-shaped but still appropriate for a
homelab.

It is the version-one naming reference extracted from the later naming
decisions in this conversation and the related intake note:

- [chat-gpt-intake-drive-provision.md](/Users/joshc/develop/dotfile-vnext/docs/intake/drive-provisioning-rebuildable-data-provision/chat-gpt-intake-drive-provision.md)

## Decision Summary

The accepted contract is:

```text
<zone>\<namespace>\<site>\<environment>\<stage>\<node>\<system>\<artifact>\<timestamp>
```

Accepted values and current defaults:

- `namespace = castle`
- `site = home`
- `tenant = omitted`
- default example context for this project:
  - `environment = lab`
  - `stage = authoritative`

This contract is documentation-only right now. It does not by itself rename
live folders or change playbook behavior.

## Resolved Corrections

These points are intentionally explicit because earlier brainstorming and intake
material included alternatives that were later corrected.

- `namespace = castle` is the accepted namespace for this v1 contract.
- Earlier exploratory names such as `fuzlab`, `fuzlang`, and `dotfile` are not
  the accepted namespace for this contract.
- `site = home` is the accepted current site value.
- `environment = lab` is the accepted current default environment.
- `stage` should usually be one of:
  - `authoritative`
  - `experimental`
- `tenant` is intentionally omitted for now.
- The accepted backup path contract uses:
  - `system`
  - `artifact`
  rather than the more verbose `class/subject/artifact` structure that was
  explored earlier.

The shorter `system/artifact` choice was kept because it is easier to read in
this project while still scaling cleanly enough for the current and near-future
backup surfaces.

## Zone Model

Zones are the top-level storage areas. They are not naming fields like
`namespace` or `node`.

The naming contract sits inside a zone.

In other words:

1. choose the zone
2. apply the naming contract beneath that zone
3. append the backup instance timestamp

### Accepted Logical Zones

- `native-host-recovery`
- `backupsets`
- `backup-catalog`
- `staging`

### Physical Paths

- `native-host-recovery` -> `E:\WindowsImageBackup\`
- `backupsets` -> `E:\backupsets\`
- `backup-catalog` -> `E:\backup-catalog\`
- `staging` -> `F:\staging\`

### Why `WindowsImageBackup` Is Kept

`WindowsImageBackup` is not the logical contract name. It is the physical
folder name imposed by Windows Server Backup. The project treats that path as
the physical implementation of the `native-host-recovery` zone.

So the logical zone name is clean and scalable, while the platform-native path
remains intact where Windows expects it.

## Naming Contract

The accepted path shape for repo-managed backup artifacts is:

```text
<zone>\<namespace>\<site>\<environment>\<stage>\<node>\<system>\<artifact>\<timestamp>
```

Example:

```text
E:\backupsets\castle\home\lab\authoritative\network-server\postgres\basebackup\2026-04-25T220000Z\
```

### Field Meanings

- `zone`
  The top-level storage area. Examples: `backupsets`, `backup-catalog`,
  `staging`.
- `namespace`
  The top-level naming anchor. In an enterprise this is often the company,
  platform, or business namespace. In this lab the accepted value is `castle`.
- `site`
  The physical or operational site. The accepted current value is `home`.
- `environment`
  The broad operational environment. Current recommended values:
  - `lab`
  - `dev`
  - `prod`
- `stage`
  The lifecycle or trust posture inside the environment. Current recommended
  values:
  - `authoritative`
  - `experimental`
  - `recovery`
  - `bootstrap`
- `node`
  The actual node or surface name being protected. This should use the real
  project node naming, for example:
  - `network-server`
  - `server-225-win`
  - `server-225-ubuntu`
- `system`
  The logical protected system or domain. This should be stable and readable.
  Examples:
  - `postgres`
  - `minio`
  - `k3s`
  - `control-plane`
  - `hyperv`
- `artifact`
  The restore unit or backup object produced for that system. Examples:
  - `basebackup`
  - `wal`
  - `config-export`
  - `etcd-snapshot`
  - `vm-definition`
- `timestamp`
  The backup instance identifier. Recommended format:
  - `YYYY-MM-DDTHHMMSSZ`

### Why `system/artifact` Won In v1

Two naming shapes were explored during design:

- `system/artifact`
- `class/subject/artifact`

The accepted v1 contract keeps `system/artifact` because:

- it is easier to read in day-to-day repo work
- it still maps well to restore-oriented backup naming
- it avoids overfitting the homelab to a more ceremonial enterprise taxonomy
- product names are still allowed when they are the clearest stable system name

If the backup program later grows into a much larger catalog with many more
artifact families per system, the project can revisit that decision. For v1,
`system/artifact` is the intended contract.

### Omitted Fields

- `tenant`
  Intentionally omitted for now. This project does not need tenant separation
  yet, and adding it now would create more naming overhead than value.

## Project Meaning Of `repo/inventory/vault`

When this phrase appears in backup planning, it means the project's
configuration-and-secrets backup domain.

This is not one single application. It is the automation/control-plane material
that would matter during rebuild or recovery.

In this project, that includes things like:

- repo snapshot
- inventory structure and inventory-owned host/group vars
- vault-encrypted material and secret-bearing config
- SSH/config artifacts that matter for recovery

Examples from the real repo include:

- `inventory/inventory.yaml`
- `inventory/group_vars/`
- `inventory/host_vars/`
- vault-bearing config and secret references documented in:
  - `docs/operator_runbook.md`
  - `playbooks/templates/openssh_host_keys_vault.yml.j2`
  - `playbooks/templates/ansible_ssh_vault.yml.j2`

For naming purposes, this domain is represented as:

- `system = control-plane`
- `artifact = repo-snapshot`, `inventory-bundle`, `vault-bundle`, or
  `ssh-config-bundle`

### Why `control-plane` Was Chosen

Three candidate names were considered for this domain:

- `control-plane`
- `automation`
- `config`

The accepted name is `control-plane`.

Reasoning:

- `control-plane`
  Best fit for enterprise-style thinking. It conveys that these assets are the
  project's operational brain and recovery-critical management surface.
- `automation`
  A good alternative and slightly more concrete, but narrower. It emphasizes
  tooling and workflow more than recovery-critical operational authority.
- `config`
  The simplest name, but too broad and easy to confuse with ordinary app config
  or any random settings file.

For this project, `control-plane` is the better long-term umbrella term.

### What `vault-bundle` Means

`vault-bundle` is the artifact name for the grouped vault-related material that
would matter during recovery.

It refers to a backup artifact containing the vault-bearing secret layer and
supporting encrypted material needed to restore the project's control-plane
secrets posture.

It is an artifact label, not a separate application or platform.

## Future Backup Surface Guidance

This section captures the likely future backup surfaces already visible in the
repo, intake notes, and current design work.

These are not all active implementations yet, but they are the intended naming
targets for future backup work.

### Primary backup-worthy domains already visible in the project

- Windows host recovery
- control-plane repo / inventory / vault / SSH recovery material
- PostgreSQL
- ClickHouse
- Redis
- MinIO
- Docker stack definitions and durable volume exports
- k3s control-plane state
- Loki data or retained observability state
- Hyper-V VM metadata and provisioning surfaces

### Additional guidance for how to think about them

- `Langfuse`
  Usually treat this as an application whose recovery depends mostly on its
  underlying durable systems such as Postgres, MinIO, or config. Do not create
  a separate `langfuse` backup domain unless it owns unique persistent data
  that is not already captured elsewhere.
- `WindowsImageBackup`
  Keep this as the physical Windows-native host-recovery implementation, not as
  a custom logical naming choice.
- `service-specific payload backups`
  These should use native restore objects where practical rather than generic
  folder copies.

### Recommended artifact naming by likely future domain

| System | Recommended artifact names |
|---|---|
| `host-recovery` | `system-state`, `bare-metal`, `image` |
| `control-plane` | `repo-snapshot`, `inventory-bundle`, `vault-bundle`, `ssh-config-bundle` |
| `postgres` | `basebackup`, `wal` |
| `clickhouse` | `native-backup` |
| `redis` | `rdb`, `aof` |
| `minio` | `config-export`, `policy-export`, `iam-export` |
| `docker` | `stacks-bundle`, `volume-export` |
| `k3s` | `etcd-snapshot`, `manifest-bundle` |
| `loki` | `data-snapshot`, `config-bundle` |
| `hyperv` | `vm-definition`, `cloud-init`, `host-network-config` |

## Example Matrix From The Actual Project

This section uses examples from the current actual project and shows how they
would look under the accepted naming contract.

All examples below use the current default context:

- `namespace = castle`
- `site = home`
- `environment = lab`
- `stage = authoritative`

| Backup area | Real project surface | Logical `system` | Logical `artifact` | Example path |
|---|---|---|---|---|
| Windows host recovery | `server-225-win` | `host-recovery` | `system-state` | `E:\backupsets\castle\home\lab\authoritative\server-225-win\host-recovery\system-state\2026-04-25T220000Z\` |
| Repo / inventory / vault | repo + inventory + vault-bearing config | `control-plane` | `vault-bundle` | `E:\backupsets\castle\home\lab\authoritative\network-server\control-plane\vault-bundle\2026-04-25T220000Z\` |
| Repo / inventory / vault | repo + inventory + vault-bearing config | `control-plane` | `inventory-bundle` | `E:\backupsets\castle\home\lab\authoritative\network-server\control-plane\inventory-bundle\2026-04-25T220000Z\` |
| Postgres | `network_server` stack surface | `postgres` | `basebackup` | `E:\backupsets\castle\home\lab\authoritative\network-server\postgres\basebackup\2026-04-25T220000Z\` |
| Postgres | `network_server` stack surface | `postgres` | `wal` | `E:\backupsets\castle\home\lab\authoritative\network-server\postgres\wal\2026-04-25T220000Z\` |
| ClickHouse | `network_server` stack surface | `clickhouse` | `native-backup` | `E:\backupsets\castle\home\lab\authoritative\network-server\clickhouse\native-backup\2026-04-25T220000Z\` |
| Redis | `network_server` stack surface | `redis` | `rdb` | `E:\backupsets\castle\home\lab\authoritative\network-server\redis\rdb\2026-04-25T220000Z\` |
| Redis | `network_server` stack surface | `redis` | `aof` | `E:\backupsets\castle\home\lab\authoritative\network-server\redis\aof\2026-04-25T220000Z\` |
| MinIO | `network_server` stack surface | `minio` | `config-export` | `E:\backupsets\castle\home\lab\authoritative\network-server\minio\config-export\2026-04-25T220000Z\` |
| MinIO | `network_server` stack surface | `minio` | `policy-export` | `E:\backupsets\castle\home\lab\authoritative\network-server\minio\policy-export\2026-04-25T220000Z\` |
| Docker stacks / volumes | `stacks_root`, `data_root`, `docker_data_root` on `network-server` | `docker` | `stacks-bundle` | `E:\backupsets\castle\home\lab\authoritative\network-server\docker\stacks-bundle\2026-04-25T220000Z\` |
| Docker stacks / volumes | `stacks_root`, `data_root`, `docker_data_root` on `network-server` | `docker` | `volume-export` | `E:\backupsets\castle\home\lab\authoritative\network-server\docker\volume-export\2026-04-25T220000Z\` |
| k3s | `server-225-ubuntu`, `k3s_cluster`, `/var/lib/rancher/k3s` | `k3s` | `etcd-snapshot` | `E:\backupsets\castle\home\lab\authoritative\server-225-ubuntu\k3s\etcd-snapshot\2026-04-25T220000Z\` |
| k3s | `server-225-ubuntu`, cluster manifests and recovery material | `k3s` | `manifest-bundle` | `E:\backupsets\castle\home\lab\authoritative\server-225-ubuntu\k3s\manifest-bundle\2026-04-25T220000Z\` |
| Loki | `server-225-ubuntu`, `/opt/loki` | `loki` | `data-snapshot` | `E:\backupsets\castle\home\lab\authoritative\server-225-ubuntu\loki\data-snapshot\2026-04-25T220000Z\` |
| Loki | `server-225-ubuntu`, Loki config and retention policy surfaces | `loki` | `config-bundle` | `E:\backupsets\castle\home\lab\authoritative\server-225-ubuntu\loki\config-bundle\2026-04-25T220000Z\` |
| Hyper-V VM metadata | `server-225-win`, `server-225-ubuntu` VM lifecycle | `hyperv` | `vm-definition` | `E:\backupsets\castle\home\lab\authoritative\server-225-win\hyperv\vm-definition\2026-04-25T220000Z\` |
| Hyper-V VM metadata | `server-225-win`, `server-225-ubuntu` VM lifecycle | `hyperv` | `cloud-init` | `E:\backupsets\castle\home\lab\authoritative\server-225-win\hyperv\cloud-init\2026-04-25T220000Z\` |
| Hyper-V VM metadata | `server-225-win`, host-side VM networking and provisioning surfaces | `hyperv` | `host-network-config` | `E:\backupsets\castle\home\lab\authoritative\server-225-win\hyperv\host-network-config\2026-04-25T220000Z\` |
| MinIO | `network_server` stack surface | `minio` | `iam-export` | `E:\backupsets\castle\home\lab\authoritative\network-server\minio\iam-export\2026-04-25T220000Z\` |
| Langfuse-related recovery | `network_server` app layer, usually via durable dependencies rather than a standalone app bucket | `control-plane` | `config-bundle` | `E:\backupsets\castle\home\lab\authoritative\network-server\control-plane\config-bundle\2026-04-25T220000Z\` |

## Zone Root Examples

These are the accepted top-level physical paths:

- `E:\WindowsImageBackup\`
- `E:\backupsets\`
- `E:\backup-catalog\`
- `F:\staging\`

Example catalog path:

```text
E:\backup-catalog\castle\home\lab\authoritative\network-server\
```

Example staging path:

```text
F:\staging\castle\home\lab\authoritative\network-server\
```

## Related Local State Naming

The intake note also explored naming for local provisioning markers and
volume-identity files. Those are related to the naming scheme, but they are not
backup artifact paths.

For v1, keep that distinction explicit:

- backup artifact naming uses the backup contract in this document
- local machine state should use shorter local-state paths

### Recommended local machine state path

```text
C:\ProgramData\<namespace>\state\storage\<profile>\<surface>\provisioned.json
```

Current project-shaped example:

```text
C:\ProgramData\castle\state\storage\backup_landing\data-i\provisioned.json
```

### Recommended per-volume identity path

```text
<drive_letter>:\_<namespace>\storage\identity.json
```

Current project-shaped example:

```text
I:\_castle\storage\identity.json
```

### Why these local paths are different from backup paths

These files exist to describe local provisioned state and per-volume identity,
not captured backup artifacts.

So for local-state paths:

- keep them shorter
- do not automatically repeat `site`, `environment`, `stage`, or `node`
- prefer the local machine already knowing those details through inventory or
  host context unless there is a strong reason to encode them again in the path

## Current Physical Layout Notes

The current known intended drive pattern is:

- `C:` OS
- `D:` primary host data
- `E:` backup repository
- `F:` staging / import / export

This is the durable contract direction.

Drive labels should be normalized over time. Temporary vendor-specific or
ad-hoc labels should not be treated as the durable naming contract. The project
cares about the drive purpose more than the temporary disk-vendor label.

## Practical Notes

- Use the logical zone names in documentation and planning:
  - `native-host-recovery`
  - `backupsets`
  - `backup-catalog`
  - `staging`
- Expect the physical Windows-native host-recovery path to stay:
  - `E:\WindowsImageBackup\`
- Use real project node names for `node`
- Use restore-oriented names for `artifact`
- Use `castle` consistently as the namespace in new examples and new work
- Keep this contract stable and let implementation details evolve beneath it
