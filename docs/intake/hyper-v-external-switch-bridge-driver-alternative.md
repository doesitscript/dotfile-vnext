# Intake: Hyper-V External Switch Bridge Driver Alternative

**Date:** 2026-03-27
**Status:** considered alternative, not the chosen primary design
**Primary reference:** https://superuser.com/questions/1137818/hyper-v-virtual-switch-issue-same-ip-on-guest-and-host#:~:text=Shared%20IP%20Issue:%20When%20using%20an%20external,same%20IP%20address%20from%20the%20DHCP%20server.

---

## Purpose

This intake note captures an alternative Hyper-V networking approach suggested
by a Super User post and its attached screenshots.

It is worth preserving because it appears to address the original symptom we
saw on the old Wi-Fi-backed External switch path:

- the guest and host appearing to share or collide on the same DHCP identity
- the router not reliably treating the guest as its own client

This note does **not** replace the current repo direction. The current chosen
direction remains:

- Internal switch for the guest
- Internet Connection Sharing (ICS) from the host
- guest on the private `192.168.137.0/24` subnet

---

## Suggestion Summary

The reported working setup was:

1. Create a Hyper-V **External** switch attached to the Wi-Fi adapter.
2. Let Windows create:
   - a `Network Bridge`
   - `vEthernet (Passthrough Switch)`
3. Open the **Network Bridge** properties in `ncpa.cpl`.
4. Ensure the **Bridge Driver** option is enabled/applied.
5. Reboot the VM.
6. After that, the router reportedly sees the VM's MAC address separately and
   assigns it a different DHCP lease from the host.

Framed another way:

- keep the guest directly on the LAN
- rely on the bridge path to expose the guest MAC to the router
- avoid the guest borrowing the host's DHCP identity

---

## Why It Is Interesting

If this works consistently on a given host/router/driver stack, it has an
important upside over the current ICS design:

- the guest stays directly on the main LAN
- the router can hand the guest a normal `192.168.50.x` address
- the Mac/controller should be able to reach the guest directly without an
  extra hop, port forward, or proxy surface

That is exactly the convenience we do **not** currently get from the
ICS/Internal-switch design.

---

## Screenshots Summarized

The referenced post included screenshots showing the following:

### 1. Windows Network Connections view

Visible surfaces included:

- `Network Bridge`
- `vEthernet (Passthrough Switch)`
- `Wi-Fi`

The `Network Bridge` properties dialog showed:

- `Wi-Fi` selected as a bridged adapter
- `vEthernet (Passthrough Switch)` selected as a bridged adapter
- `Bridge Driver` enabled in the component list

This is the clearest visual clue in the post: the bridge path was not just the
Hyper-V External switch alone. The bridge driver state on the resulting Network
Bridge was part of the reported fix.

### 2. Hyper-V Manager / VM view

The VM was shown attached to:

- `Passthrough Switch`

And Hyper-V reported a normal guest IP address on the LAN side.

### 3. Router DHCP lease view

The router DHCP page showed:

- the Windows host with one LAN IP and MAC
- the VM with a different LAN IP and a different MAC

That screenshot is the strongest evidence from the post that, in that user's
environment, the router was finally seeing the VM as a distinct DHCP client.

---

## What This Means For Our Project

This approach is best understood as an **alternative design**, not as a tweak
to the current ICS design.

### If adopted, it would aim for

- guest directly on the LAN
- guest directly reachable from the Mac/controller
- router-issued DHCP lease for the guest

### If we keep the current ICS design, we instead get

- deterministic separation between host and guest identity
- no guest dependence on the flaky Wi-Fi External-switch DHCP path
- but the guest lives on a private subnet and is not directly reachable from
  the Mac without another access strategy

---

## Why It Was Not Chosen As The Primary Path

Even if the post is correct, this design still appears more sensitive to:

- Wi-Fi adapter/driver behavior
- Windows bridge behavior
- router/AP behavior
- network changes when moving the host between environments

That makes it attractive as a convenience-first path, but weaker as the
default automation target for a repo that wants a more stable control-plane
shape.

Current repo judgment:

- worth preserving
- worth testing manually if direct LAN presence becomes the priority
- not yet preferred over the current Internal switch + ICS path

---

## Suggested Evaluation Criteria If We Ever Test It

If this is revisited later, validate all of these explicitly:

1. Does the guest consistently get its own LAN DHCP lease?
2. Does the router always show the guest MAC separately from the host?
3. Is the guest reachable directly from the Mac on the LAN?
4. Does it stay stable across:
   - host reboot
   - Hyper-V restart
   - Wi-Fi reconnect
   - moving between different networks
5. Does it remain more reliable than the current ICS design on this specific
   hardware and router stack?

---

## Current Position

Preserve this as:

- a credible alternative networking path
- evidence that some users have made Wi-Fi-backed External switching behave
  more like true passthrough on their setup

Do not treat it as the current chosen implementation until it is tested
directly on `server-225-win`.
