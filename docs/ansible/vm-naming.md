# VM Naming

This repo follows the compact inventory/VM naming pattern used across the
active homelab surfaces:

```text
<tenant>-<env>-<domain>-<role>-<nn>
```

Examples:

- `hom-lab-ctl-dkr-01` - Docker VM on HOM-LAB-HVH-01
- `hom-lab-ctl-k3s-01` - K3s VM on HOM-LAB-HVH-01
- `hom-lab-ctl-dkr-02` - Docker VM on HOM-LAB-HVH-02
- `hom-lab-ctl-k3s-02` - K3s VM on HOM-LAB-HVH-02

Older names such as `server-225-ubuntu`, `nsrv-dkr-01`, and `nsrv-k3s-01` are
legacy identities and should not be used for new repo references outside
explicit migration or historical context.

## Canonical Segments

- `hom` - tenant
- `lab` - environment
- `ctl` - control/management domain
- `dkr` - Docker runtime role
- `k3s` - K3s role

Add or change segments only through the naming standards registry before
introducing new VM names.

Use NetBox-style metadata for operating system, platform, VM role, IP address,
and host placement instead of encoding all of that in the VM name.

Optional future NetBox validation for new names:

```regex
^hom-lab-[a-z0-9]+-[a-z0-9]+-[0-9]{2}$
```

Do not enforce that regex against legacy names until their exceptions are
retired intentionally.
