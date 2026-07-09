# Hyper-V Network Layout on Wi-Fi Hosts with ICS

## Purpose

This note documents the intended network layout for `HOM-LAB-HVH-02` when a
Hyper-V Ubuntu guest is attached to an Internal switch and Windows Internet
Connection Sharing (ICS) is used to give the guest outbound network access.

Historical note:

- this remains the important checkpoint that fixed the original guest/host DHCP
  collision problem
- the newer target design now builds on this checkpoint with explicit routing
  for controller reachability
- see
  [hyperv-network-layout--windows--routed-private-subnet.md](/Users/joshc/develop/dotfile-vnext/docs/diagnostics/hyperv-network-layout--windows--routed-private-subnet.md)
  for the current access-layer direction

This is the preferred topology for the current repo when:

- the Windows host uplink is Wi-Fi
- the old Hyper-V External-switch guest DHCP path proved unreliable
- the guest needs a stable outbound network path without borrowing the host's
  LAN IP identity

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
HOM-LAB-HVH-02
  |
  |- vEthernet (External)   192.168.50.158   <- host-side public/control-plane
  |    ^
  |    | ICS public side
  |
  |- vEthernet (Guest)      192.168.137.1    <- ICS private/gateway side
       |
       | Hyper-V Internal switch: Guest
       |
       +- server-225-ubuntu 192.168.137.x    <- guest private address
```

## What ICS does here

ICS turns the Windows host into the gateway for the private guest subnet.

In the current working shape:

- `vEthernet (External)` is the ICS public side
- `vEthernet (Guest)` is the ICS private side
- Windows assigns the private side the gateway IP `192.168.137.1`
- the guest gets a private address on that subnet, such as `192.168.137.63`
- guest outbound traffic is NATed through the Windows host and then exits via
  the host's public uplink

This means the guest should be able to:

- reach the internet through the Windows host
- reach the Windows host on the private side

## Residual operational note

This setup can still have some residual adapter churn when the Windows host
moves between networks.

Pinned field note worth preserving:

- moving the host between networks, such as work Wi-Fi to home Wi-Fi, may
  require resetting or renewing one or more adapters before everything settles
  again
- this may happen even without the Hyper-V + ICS setup, but it appears to show
  up more often with this topology
- the current first-response soft recovery remains:
  - `Clear-DnsClientCache`
  - `ipconfig /flushdns`
  - `ipconfig /release`
  - `ipconfig /renew`

Interpretation:

- treat this as residual operational fallout to monitor, not as proof that the
  ICS design is wrong
- if it becomes frequent, the next improvement point is host-side recovery
  automation around network-change or boot events

## What direct reachability should and should not mean

The host and the guest are on the same private ICS subnet, so the Windows host
should be able to:

- ping the guest's `192.168.137.x` address
- attempt direct TCP connections to services on that address

But the wider LAN, including the Mac controller, should **not** be assumed to
have direct routed access to `192.168.137.x`.

Why:

- `192.168.137.0/24` is behind the Windows host
- ICS is providing NAT for outbound guest traffic
- the rest of the LAN does not automatically learn a route to that private
  subnet
- ICS is not the same thing as publishing the guest directly onto the LAN

So this is expected:

- Windows host can reach `192.168.137.63`
- Mac cannot directly SSH to `192.168.137.63` unless we add another access
  strategy

## Implication for automation

With this topology, a guest IP like `192.168.137.63` is valid guest-network
evidence, but it is not automatically a controller-reachable `ansible_host`.

If we want controller-side access from the Mac, the repo needs one of these
follow-on strategies:

1. publish a Windows-host port-forward or proxy surface for guest SSH
2. use the Windows host as the SSH/command hop for guest verification
3. add a routed path from the LAN to the ICS subnet
4. move to a different networking model that publishes the guest directly on
   the LAN

For the current implementation, the ICS/Internal-switch work solves the guest
DHCP/IP conflict. It does **not** by itself solve controller-side direct SSH to
the guest private IP.

## Current milestone state

Working now:

- Hyper-V Ubuntu guest no longer collides with the host LAN IP
- the guest can obtain a private ICS-subnet address
- the Windows host can identify and probe the guest on the private subnet

Still in progress:

- controller-side direct access from the Mac to the guest private subnet
- guest SSH/bootstrap verification from a topology-appropriate access path
