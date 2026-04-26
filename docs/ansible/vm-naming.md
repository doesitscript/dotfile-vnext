# VM Naming

This repo follows a compact VM naming pattern for new lab VMs:

```text
<host-scope>-<role>-<nn>
```

Examples:

- `s225-dkr-01` - Docker VM on server-225
- `nsrv-dkr-01` - Docker VM on network-server
- `s225-k3s-01` - future k3s VM on server-225

Existing live VMs do not need to be renamed just to satisfy this convention.
For example, `server-225-ubuntu` remains valid while it is the live Docker VM
identity on server-225.

## Scope Codes

- `s225` - server-225
- `nsrv` - network-server

Add new scope codes here before introducing new VM names.

## Role Codes

- `dkr` - Docker Engine host
- `k3s` - k3s node

Use NetBox-style metadata for operating system, platform, VM role, IP address,
and host placement instead of encoding all of that in the VM name. The name is
the scoped identity; inventory and NetBox-style fields carry the rest.

Optional future NetBox validation for new names:

```regex
^(s225|nsrv)-[a-z0-9]+-[0-9]{2}$
```

Do not enforce that regex against legacy names until their exceptions are
retired intentionally.
