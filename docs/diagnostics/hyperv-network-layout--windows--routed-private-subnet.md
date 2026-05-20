# Hyper-V Network Layout on Windows with a Routed Private Guest Subnet

## Purpose

This note documents the current target networking model for
`server-225-ubuntu` on `hom-lab-ctl-hvh-02`.

It builds from the proven Internal switch + private guest subnet checkpoint and
adds the missing reachability layer:

- `hom-lab-ctl-hvh-02` acts as the transit host between the LAN and the guest
  subnet
- `mac-dev` learns a route to the guest subnet through `hom-lab-ctl-hvh-02`
- later, the router can learn the same route for whole-LAN reachability

## Status Summary

This note now describes both the achieved first direct-routing milestone and
the next whole-LAN expansion.

Read the current progression like this:

1. current working access:
   - direct reachability from `mac-dev` to `192.168.137.10`
   - generated SSH with `ProxyJump=hom-lab-ctl-hvh-02` still available
2. later whole-LAN target:
   - router static route for `192.168.137.0/24` via `192.168.50.158`

So the first direct-network setup is now realized as:

- one Mac controller
- one Windows host
- one Ubuntu VM

The whole-home-LAN route is the later expansion of that design.

## Topology

```text
Mac / LAN clients
  |
  | 192.168.50.0/24
  |
router
  |
  | Wi-Fi LAN
  |
hom-lab-ctl-hvh-02
  |
  |- vEthernet (External)   192.168.50.158   <- LAN/control-plane side
  |
  |- vEthernet (Guest)      192.168.137.1    <- guest gateway side
       |
       | Hyper-V guest switch: Guest
       |
       +- server-225-ubuntu 192.168.137.x    <- guest private address
```

## What Part 1 Does

Part 1 keeps the existing guest subnet and adds direct controller reachability.
This is now the current working setup for `mac-dev`.

The intended path is:

1. the Windows host forwards traffic between:
   - `192.168.50.0/24`
   - `192.168.137.0/24`
2. `mac-dev` adds a persistent route:
   - destination: `192.168.137.0/24`
   - gateway: `192.168.50.158`
3. the Mac can then reach the guest by its own private-subnet IP

That means the first milestone is:

- Mac can SSH directly to `192.168.137.x`
- the guest IP can be published as `ansible_host`
- Docker services can later bind to the guest IP on that same subnet

This is the first **direct-network** milestone.
It is now working for `mac-dev`, while the whole-LAN route milestone remains
next.

## What Part 2 Adds

Part 2 moves the route from a Mac-only implementation to a LAN-wide one.

The intended change is:

- add a router static route for `192.168.137.0/24` via `192.168.50.158`

After that:

- other LAN clients can reach the guest subnet directly
- the Mac-specific route becomes optional

## Why This Is Different From The Earlier ICS-Only Checkpoint

Earlier checkpoint:

- guest got a clean private address
- Windows host could reach the guest
- Mac could not directly reach the guest

Current target/current implementation direction:

- keep the same private subnet
- keep the same guest gateway
- use explicit Windows routing so the controller can reach the guest directly
- keep ICS out of the primary access path for the direct-route milestone

So the routed-private-subnet design is not a throwaway replacement. It is the
access-layer improvement on top of the stable private guest network we already
proved out.

## Current routing posture

The active implementation now treats the Windows host as an actual routed
transit point:

- the Windows host remains the guest gateway at `192.168.137.1`
- Windows Routing / RRAS routing-only mode is enabled
- Windows forwarding and weak-host behavior are enabled on the transit
  interfaces
- `mac-dev` can reach the guest directly at `192.168.137.10`

## Current controller access note

Today, what is proven is:

- the Windows host can reach `192.168.137.10`
- `mac-dev` can also reach `192.168.137.10` directly
- raw TCP/22 succeeds to the guest IP from the Mac/controller
- direct SSH succeeds to `joshc@192.168.137.10`
- generated SSH through `hom-lab-ctl-hvh-02` still works as a fallback

Operational interpretation:

- current working primary path:
  - direct routed guest-IP access
- current working fallback path:
  - `ProxyJump`
- later broader-network path:
  - router static route for the home LAN
