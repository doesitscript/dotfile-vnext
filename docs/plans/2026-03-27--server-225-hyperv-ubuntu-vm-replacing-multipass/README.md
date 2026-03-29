# Server-225 Hyper-V Ubuntu VM Replacing Multipass

Canonical implementation packet for replacing the retired Multipass-backed
`server-225-ubuntu` surface with a Hyper-V-native Ubuntu VM on `server-225-win`.

Tracked in GitHub issue [#4](https://github.com/doesitscript/dotfile-vnext/issues/4).

Supporting background and proof remain here:

- [research.md](/Users/joshc/develop/dotfile-vnext/docs/plans/2026-03-27--server-225-hyperv-ubuntu-vm-replacing-multipass/research.md)
- [evidence--hyperv-live-runs.md](/Users/joshc/develop/dotfile-vnext/docs/plans/2026-03-27--server-225-hyperv-ubuntu-vm-replacing-multipass/evidence--hyperv-live-runs.md)

## Summary

Multipass is no longer the active implementation path for `server-225-ubuntu`.

The current working replacement is:

- `server-225-win` as the Windows control surface
- `server-225-ubuntu` as the active Linux companion surface
- Hyper-V-native Ubuntu created from the official Ubuntu Server ISO installer
- autoinstall-driven bootstrap
- routed private subnet via the Windows host
- host-owned outbound NAT on the Windows side for `192.168.137.0/24`
- static guest address `192.168.137.10/24`
- active SSH surface `joshc@server-225-ubuntu`

The repo is now converging on one canonical full-stack entrypoint:

- [site.yaml](/Users/joshc/develop/dotfile-vnext/playbooks/site.yaml)

Specialized playbooks remain as narrower operator loops, but they are no longer
treated as competing primary entrypoints.

## Current Architecture

### Canonical full-stack entrypoint

- [site.yaml](/Users/joshc/develop/dotfile-vnext/playbooks/site.yaml)

Current call hierarchy:

1. Windows base
2. Hyper-V networking
3. Access / identity surfaces
4. Controller route to the guest subnet
5. Hyper-V Ubuntu guest lifecycle
6. Controller SSH config refresh after guest lifecycle
7. Docker engine / client verification

### Focused operator entrypoints

- [provision_windows_host.yml](/Users/joshc/develop/dotfile-vnext/playbooks/provision_windows_host.yml)
  - Windows baseline only
- [server_225_hyperv_ubuntu_vm.yaml](/Users/joshc/develop/dotfile-vnext/playbooks/server_225_hyperv_ubuntu_vm.yaml)
  - server-225 guest-oriented orchestration
- [server_225_hyperv_ubuntu_vm_lifecycle_only.yaml](/Users/joshc/develop/dotfile-vnext/playbooks/server_225_hyperv_ubuntu_vm_lifecycle_only.yaml)
  - fast VM reinstall / iteration loop
- [access.yaml](/Users/joshc/develop/dotfile-vnext/playbooks/access.yaml)
  - identity/access-only orchestration
- [docker.yaml](/Users/joshc/develop/dotfile-vnext/playbooks/docker.yaml)
  - Docker-only orchestration and verification

### Role ownership

- `windows_base`
  - Windows baseline features, policy, and host defaults
- `hyperv_networking`
  - Hyper-V features plus guest-network infrastructure on `server-225-win`
- `hyperv_guest_route_mac`
  - controller route to the guest private subnet
- `access_identity_controller`
  - controller SSH keypair and generated SSH config
- `access_identity_windows`
  - Windows OpenSSH and Windows access surfaces
- `hyperv_ubuntu_vm`
  - Ubuntu guest bootstrap, install, lifecycle, and publication
- Docker roles
  - consume the realized Linux companion surface instead of inventing it

## Fixed Now

- Multipass has been retired from the active implementation path.
- Active WSL surfaces have been removed from playbooks, roles, and inventory as
  first-class runtime targets.
- `server-225-ubuntu` is the active Linux companion surface.
- The guest is installed through the Ubuntu Server ISO installer path, not the
  earlier Azure-image or Quick Create candidate paths.
- Bootstrap is handled through autoinstall.
- The networking model is routed private subnet via `server-225-win`, not the
  older Wi-Fi External-switch path.
- The guest now uses:
  - `192.168.137.10/24`
  - gateway `192.168.137.1`
- Guest outbound internet is now proven:
  - DNS resolution works
  - `curl` to Ubuntu mirrors works
  - `apt update` works
- The generated SSH surface is:
  - `server-225-ubuntu`
- The active runtime user is:
  - `joshc`
- SSH reachability is proven from the Windows host and from the Mac/controller
  via the generated `server-225-ubuntu` surface.
- Docker engine targeting now points at the Ubuntu guest surface, not a legacy
  WSL surface.
- Docker Engine is installed and verified on the Ubuntu guest.
- The Mac Docker client can reach the remote engine over the generated SSH
  surface.

## Verification Ladder

### Windows host

- `Get-VM -Name server-225-ubuntu | Select-Object Name,State,Status,Uptime`
- `Get-VMDvdDrive -VMName server-225-ubuntu`
- `Test-Connection 192.168.137.10 -Count 1`
- `Test-NetConnection -ComputerName 192.168.137.10 -Port 22`
- `Get-NetNeighbor -IPAddress 192.168.137.10`

### Mac/controller

- `route -n get 192.168.137.10`
- `ssh server-225-ubuntu`
- `ansible server-225-ubuntu -i inventory/inventory.yaml -m ping`
- `docker --context mac-dev info`

### Guest console

- `ip -br addr`
- `ip route`
- `systemctl is-active ssh`
- `ss -ltnp | grep ':22'`

## Remaining Near-Term Gaps

- decide whether the Mac-to-guest access story should remain:
  - direct routed-subnet SSH
  - or the now-working generated SSH surface that can proxy through
    `server-225-win`
- keep tightening site-level comments/examples so readers see one canonical
  entrypoint instead of several almost-primary ones
- validate higher-level consumers against the realized Ubuntu guest surface as
  more services move onto `server-225-ubuntu`
- review background/history docs that still describe older implementation
  mechanics as if they were current
- explicitly review service-role semantics that were previously expressed
  through legacy WSL naming so role ownership stays intentional

## What This Packet Does Not Own

This packet documents the current Hyper-V replacement implementation. It does
not own the broader vNext design work for:

- future `linux_companion` / `node_companion_linux` role-family refactors
- planner / observer / coordinator maturity improvements
- larger deprecation-framework lessons beyond the current implementation packet

Those belong in the future-state planning track, not in this fixed-now packet.
