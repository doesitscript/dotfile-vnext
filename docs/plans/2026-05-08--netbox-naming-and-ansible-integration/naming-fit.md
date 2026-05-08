# Naming Fit Check

Date: 2026-05-08

Status: draft workspace for Option 1.

## Question

Does the repo's compact VM naming pattern fit NetBox's native model, and what
should move out of names into NetBox fields?

## Current Repo Pattern

```text
<host-scope>-<role>-<nn>
```

Examples:

- `s225-dkr-01`
- `nsrv-dkr-01`
- `s225-k3s-01`

## Initial Mapping

| Repo concept | Current example | NetBox field candidate | Keep in name? | Notes |
| --- | --- | --- | --- | --- |
| Physical node | `server-225` | Device | No | Physical host should be modeled as a device. |
| Scope code | `s225` | Derived from device or cluster; maybe custom field | Yes, for compact VM identity | Needs decision: scope code may be operator shorthand rather than a NetBox-native field. |
| VM function | `dkr`, `k3s` | VM role | Yes, as compact role code | NetBox role should carry the full meaning. |
| Sequence | `01` | VM name | Yes | Keeps names stable and compact. |
| OS | Ubuntu | Platform | No | NetBox platform is the better home. |
| Hypervisor placement | server-225 Hyper-V | Cluster or device relation | No | NetBox VM can be assigned to site, cluster, or device. |
| Management IP | `192.168.137.10` | VM interface + primary IP | No | IPs should be NetBox IPAM data. |
| LAN-published endpoint | `192.168.50.158:8000` | Service or documented relation | No | Need a later decision on service modeling. |
| Ansible ownership | `ansible-managed` | Tag | No | Tag should drive grouping/selection later. |

## Current Working Decision

Keep compact VM names, but avoid growing them.

Recommended shape:

```text
s225-dkr-01
```

Where:

- `s225` is the compact scope identity.
- `dkr` is the compact function code.
- `01` is the sequence.

Everything else belongs in NetBox metadata.

## Option 2 Seed Shape

The first concrete seed path uses the current live names rather than renaming
anything:

| NetBox object | Name | Why |
| --- | --- | --- |
| Site | `Homelab` | Small lab-wide scope for current nodes. |
| Device | `server-225` | Physical Windows Hyper-V host. |
| Cluster type | `Hyper-V` | Virtualization technology. |
| Cluster | `server-225-hyperv` | VM placement boundary for Server-225. |
| VM | `server-225-ubuntu` | Current live Docker VM identity; future compact names can be introduced intentionally. |
| VM role | `Docker engine` | Full meaning of compact role code `dkr`. |
| Device role | `Hyper-V host` | Physical host function. |
| Platform | `Windows Server 2025`, `Ubuntu 24.04` | OS belongs in metadata, not compact names. |
| Tags | `ansible-managed`, `homelab`, `hyperv`, `docker`, `infra` | Automation ownership and grouping bridge. |

## Things To Validate Before Seeding Objects

- Whether `s225` should be a custom field, a cluster slug, or only a naming
  convention.
- Whether current `server-225-ubuntu` should remain as-is until a rebuild.
- Whether VM role names should be human names such as `docker-engine` while the
  object name uses `dkr`.
- Whether service endpoints should be represented using NetBox service objects
  or kept in Ansible inventory for now.

## Next Step

Review this mapping, then seed the smallest controlled vocabulary:

- tags
- platforms
- device roles
- VM roles

Do not create dynamic inventory yet.
