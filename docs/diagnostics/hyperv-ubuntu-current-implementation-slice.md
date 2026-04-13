# Hyper-V Ubuntu Current Implementation Slice

## Purpose

This note captures the current **working implementation slice** for the
`server-225` Hyper-V path as it exists in the repo today.

This is intentionally narrower than the full infrastructure story. It answers:

- what is currently real and wired together
- what files are the source of truth for that slice
- what access and networking contract is actually implemented now
- what remains target-state or follow-on work

## Current Working Slice

The current working slice is:

- physical/control host:
  - `server-225-win`
- guest Linux companion:
  - `server-225-ubuntu`
- guest subnet:
  - `192.168.137.0/24`
- guest IP:
  - `192.168.137.10`
- guest gateway:
  - `192.168.137.1`
- LAN/control-plane address on the Windows host:
  - `192.168.50.158`
- published Loki port:
  - `192.168.50.158:3100 -> 192.168.137.10:3100`
- controller access model currently working:
  - direct routed access to `192.168.137.10`
- controller fallback access model also still available:
  - SSH `ProxyJump` through `server-225-win`

## Source Of Truth Files

Primary source-of-truth files for this slice:

- Windows control surface:
  - [server-225-win.yaml](/Users/joshc/develop/dotfile-vnext/inventory/host_vars/server-225-win.yaml)
- Ubuntu guest surface:
  - [server-225-ubuntu.yaml](/Users/joshc/develop/dotfile-vnext/inventory/host_vars/server-225-ubuntu.yaml)
- Hyper-V routed private subnet implementation:
  - [routed_private_subnet.yml](/Users/joshc/develop/dotfile-vnext/roles/hyperv_networking/tasks/routed_private_subnet.yml)
- Hyper-V Ubuntu installer-media lifecycle:
  - [present_server_iso.yml](/Users/joshc/develop/dotfile-vnext/roles/hyperv_ubuntu_vm/tasks/present_server_iso.yml)
- Logging endpoint resolution:
  - [all.yaml](/Users/joshc/develop/dotfile-vnext/inventory/group_vars/all.yaml)
- Logging rollout:
  - [logging.yaml](/Users/joshc/develop/dotfile-vnext/playbooks/logging.yaml)

## What Is Actually Implemented

### 1. One real host + one real guest

This is not a hypothetical topology anymore.

The repo now has:

- a Windows Hyper-V host at `server-225-win`
- a defined Ubuntu guest at `server-225-ubuntu`
- host_vars for both surfaces
- a concrete guest IP and subnet assignment

### 2. Routed private guest subnet

The active network model is:

- guest switch: `Guest`
- guest subnet: `192.168.137.0/24`
- Windows host guest gateway: `192.168.137.1`
- Windows host LAN/control side: `192.168.50.158`

The Windows host enables:

- IPv4 forwarding
- Windows Routing / RRAS routing-only mode
- weak-host send/receive on the transit interfaces
- guest TCP port publishing via `netsh interface portproxy`
- Windows firewall rules for published ports

For the direct routed milestone, the repo now intentionally keeps Windows
ICS/sharing and host-side guest NAT out of the primary access path.

### 3. Current controller access contract

The current repo truth is now:

- the guest is directly reachable from `mac-dev` at `192.168.137.10`
- raw TCP to `192.168.137.10:22` succeeds from the Mac/controller
- direct SSH to `joshc@192.168.137.10` succeeds from the Mac/controller
- the generated SSH surface for `server-225-ubuntu` still supports:
  - `ProxyJump=server-225-win`

That means the current access contract is:

- primary path:
  - direct routed access to the guest IP
- fallback/generated path:
  - SSH through the Windows transit host

## Networking Milestone Ladder

The networking/access progression for this slice should be read in this order:

### Current working setup

Today, the proven working setup is:

- Windows host on the LAN at `192.168.50.158`
- Ubuntu guest on the private subnet at `192.168.137.10`
- Windows host acting as gateway/transit point for the guest subnet
- `mac-dev` has a persistent route to `192.168.137.0/24` via `192.168.50.158`
- controller access to the guest works directly at `192.168.137.10`
- generated SSH with `ProxyJump` remains available as a fallback

This is the current stable access contract.

### First direct-networking milestone

This milestone is now achieved for `mac-dev`:

- direct **Mac-to-guest** routing for `192.168.137.0/24`
- Windows host kept as the gateway/transit point
- direct SSH and raw TCP/22 to `192.168.137.10` working from the Mac/controller

That milestone is intentionally narrow:

- one controller
- one Windows host
- one Ubuntu guest

It is the first direct-network path, but it is **not** yet whole-LAN routing.

### Later whole-LAN milestone

The later networking milestone is:

- move from Mac-only route knowledge to home-LAN route knowledge
- add a router static route for:
  - destination: `192.168.137.0/24`
  - next hop: `192.168.50.158`

After that:

- other LAN clients can reach the guest subnet directly
- the Mac-specific route becomes optional rather than required

So the intended progression is:

1. current working `ProxyJump` access
2. direct Mac-to-guest route through the Windows host
3. whole-LAN route through the Windows host

### 4. Published logging path

The current slice also includes a real higher-level service path:

- Loki is published from the guest to the Windows host LAN-side address
- the published endpoint is:
  - `http://192.168.50.158:3100/loki/api/v1/push`
- the Ubuntu guest host_vars explicitly declare that public endpoint
- global logging endpoint resolution now follows the active `logging_server`
  host rather than hardcoding a node name

This matters because it means the logging path is tied to the actual current
guest topology, not to a stale assumption about a different host shape.

## Why This Counts As A Slice

A **slice** is a bounded part of the system where the whole path works together.

This current slice has:

- a concrete infrastructure boundary
- inventory truth
- role/task ownership
- an access path
- a service publication path
- current verification intent

In other words, several layers line up around one narrow capability:

- create or manage the guest
- reach the guest
- publish at least one guest-hosted service
- point repo consumers at that real service path

That is different from a **fragment**, which would be something like:

- a role that creates a switch but no guest uses it
- a host_vars file with an IP that is not actually reachable
- a logging role that assumes a hostname that does not match the current host
- a VM rebuild path with no stable access contract afterward

A fragment is an isolated piece.
A slice is an end-to-end vertical section that is narrow, but real.

## What Is Still Not Claimed Here

This note does **not** claim that all related work is complete.

Still separate from this slice:

- broader site-level convergence quality
- final Docker-host contract beyond the guest being a viable companion surface
- whole-LAN routing to `192.168.137.0/24`
- all higher-level service migrations from older companion assumptions

## Practical Interpretation

The safe way to reason about the repo now is:

- treat `server-225-win` + `server-225-ubuntu` as a real active implementation
  path
- treat this path as the current source of truth for the Hyper-V Ubuntu
  companion milestone
- treat older WSL or Multipass material as historical context unless a file is
  still directly referenced by the active inventory, playbooks, or roles
