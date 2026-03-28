# Hyper-V Network Layout on Windows with a Routed Private Guest Subnet

## Purpose

This note documents the current target networking model for
`server-225-ubuntu` on `server-225-win`.

It builds from the proven Internal switch + private guest subnet checkpoint and
adds the missing reachability layer:

- `server-225-win` acts as the transit host between the LAN and the guest
  subnet
- `mac-dev` learns a route to the guest subnet through `server-225-win`
- later, the router can learn the same route for whole-LAN reachability

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
server-225-win
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

Current target:

- keep the same private subnet
- keep the same guest gateway
- add explicit routing so the controller can reach the guest directly

So the routed-private-subnet design is not a throwaway replacement. It is the
access-layer improvement on top of the stable private guest network we already
proved out.
