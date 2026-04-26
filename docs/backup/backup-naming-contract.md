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
| Loki | `server-225-ubuntu`, `/opt/loki` | `loki` | `data-snapshot` | `E:\backupsets\castle\home\lab\authoritative\server-225-ubuntu\loki\data-snapshot\2026-04-25T220000Z\` |
| Hyper-V VM metadata | `server-225-win`, `server-225-ubuntu` VM lifecycle | `hyperv` | `vm-definition` | `E:\backupsets\castle\home\lab\authoritative\server-225-win\hyperv\vm-definition\2026-04-25T220000Z\` |
| Hyper-V VM metadata | `server-225-win`, `server-225-ubuntu` VM lifecycle | `hyperv` | `cloud-init` | `E:\backupsets\castle\home\lab\authoritative\server-225-win\hyperv\cloud-init\2026-04-25T220000Z\` |

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
- Keep this contract stable and let implementation details evolve beneath it
