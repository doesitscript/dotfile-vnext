# Intake: Hyper-V Guest Networking Options — For Comparison

**Date:** 2026-03-27
**Status:** comparison note across considered designs and partial implementations

---

## Purpose

This note groups the main Hyper-V guest networking options considered for
`server-225-ubuntu` on `server-225-win`.

It exists because the project has now explored multiple overlapping networking
directions:

- direct LAN exposure through an External switch
- Internal switch plus ICS
- Internal switch plus NAT
- routed private-subnet ideas
- host recovery mechanisms around Hyper-V changing the host network shape

The goal is to keep these options side by side so we can compare:

- what each design is trying to optimize for
- what tradeoffs each design introduces
- what the repo has already partially implemented
- what remains only intake/research

---

## Quick Comparison

| Option | Guest gets its own LAN IP | Mac can directly reach guest IP | Host/guest DHCP collision risk | Complexity | Current repo state |
|---|---|---|---|---|---|
| External switch on Wi-Fi | intended yes | intended yes | higher on this host | low on paper, high in practice | previously tried, not current path |
| External switch + bridge-driver tweak | intended yes | intended yes | may improve old path | medium, environment-sensitive | intake only |
| External switch + static guest IP | yes if manually set right | yes | avoids DHCP ambiguity but stays on fragile Wi-Fi path | medium | considered, not chosen |
| Internal switch + ICS | no, private subnet | no, not directly | low | medium | currently implemented and validated partway |
| Internal switch + WinNAT | no, private subnet | no, not directly unless ports/routes added | low | medium | researched, not implemented |
| Internal switch + routed private subnet | no, private subnet | yes if routes are added | low | higher | partially implemented, guest bootstrap still blocked |

---

## Option 1: External Switch on Wi-Fi

### What it is

- attach the VM directly to a Hyper-V External switch bound to the host's
  Wi-Fi path
- expect the router to see the guest as a normal LAN client

### Why it was attractive

- simple mental model
- guest should be directly reachable from the Mac and the rest of the LAN
- Docker ports should be reachable like a normal LAN host

### Why it became a problem on this host

- the guest and host did not reliably stay separate DHCP identities
- the guest/host IP conflict behavior appeared repeatedly on this Wi-Fi-backed
  path
- the router did not consistently behave as though the guest was its own clean
  client

### Repo state

- previously tried
- not the current chosen path

---

## Option 2: External Switch + Bridge Driver Tweak

### What it is

- keep the External-switch design
- additionally rely on the `Network Bridge` and its `Bridge Driver` state to
  help the router see the guest MAC independently

### Why it is interesting

- preserves direct LAN reachability if it works
- reported by others as a fix for the "same IP on guest and host" class of
  problem

### Why it is not the current primary design

- appears highly dependent on:
  - Wi-Fi adapter/driver behavior
  - Windows bridge behavior
  - router/AP behavior
  - roaming between networks

### Repo state

- captured in:
  [hyper-v-external-switch-bridge-driver-alternative.md](/Users/joshc/develop/dotfile-vnext/docs/intake/hyper-v-external-switch-bridge-driver-alternative.md)
- intake only

---

## Option 3: External Switch + Static Guest IP

### What it is

- keep the External-switch path
- manually or declaratively pin the guest to a static address on the LAN

### Why it can look appealing

- direct guest reachability remains simple
- it sidesteps some DHCP ambiguity

### Why it was not chosen

- it keeps us on the weaker Wi-Fi External-switch path
- it treats the symptom more than the path quality
- it becomes awkward when the host moves to other networks/subnets

### Repo state

- discussed
- not implemented

---

## Option 4: Internal Switch + ICS

### What it is

- create a Hyper-V Internal switch for the guest
- use Windows Internet Connection Sharing from the host's public side to the
  guest-side `vEthernet`
- guest lives on a private subnet, currently `192.168.137.0/24`

### Why it was chosen

- it cleanly separates host and guest network identity
- it avoids the Wi-Fi-backed External-switch DHCP collision issue
- it gives the guest outbound connectivity without depending on direct Wi-Fi
  bridge behavior

### Tradeoffs

- the Mac/controller does not automatically have direct routed access to the
  guest private IP
- guest IP evidence is valid as guest-network evidence, but not automatically a
  controller-reachable `ansible_host`

### Repo state

- currently implemented
- current working evidence:
  - guest gets a private address on the ICS subnet
  - Windows host can probe the guest on that subnet
  - old host/guest IP collision is no longer the active blocker
- current remaining gap:
  - controller-side direct guest access strategy
  - final guest SSH/bootstrap verification path

Reference:
- [hyperv-network-layout--windows--wifi-ics.md](/Users/joshc/develop/dotfile-vnext/docs/diagnostics/hyperv-network-layout--windows--wifi-ics.md)

---

## Option 5: Internal Switch + WinNAT

### What it is

- create a Hyper-V Internal switch
- assign a host-side gateway IP to the guest-side `vEthernet`
- create a NAT with `New-NetNat`
- optionally publish ports with `Add-NetNatStaticMapping`

### Why it is attractive

- more explicit and infrastructure-like than ICS
- better fit for deliberate published ports such as:
  - SSH
  - Docker service ports
- easier to reason about from PowerShell and Ansible than consumer-style ICS

### Tradeoffs

- still a private-subnet design
- still does not automatically give the Mac direct reachability to the guest IP
- often needs more deliberate address and port-publishing management

### Repo state

- researched
- not implemented

Primary reference discussed:
- https://www.thomasmaurer.ch/2016/05/set-up-a-hyper-v-virtual-switch-using-a-nat-network/

---

## Option 6: Internal Switch + Routed Private Subnet

### What it is

- keep the guest on a private subnet behind the host
- add routing so the Mac or the wider LAN can reach that subnet

Possible shapes:

- route on the Mac only
- route on the router for the whole LAN
- host-side forwarding/routing services

### Why it is attractive

- keeps the cleaner private-subnet topology
- can still give direct guest-IP reachability from the controller or LAN
- better long-term fit if multiple guest services need to be reachable

### Tradeoffs

- more routing design work
- may require router participation or host forwarding configuration
- more infrastructure responsibility than plain ICS

### Repo state

- partially implemented
- current proven pieces:
  - guest private subnet stayed separate from the Windows host
  - Windows host reached guest-private-subnet addresses
  - Mac route was installed toward the guest subnet
- current remaining gap:
  - Mac/controller still did not prove direct guest reachability
  - guest image/bootstrap path remained the bigger blocker

---

## Separate But Related: Host Management OS Recovery

This is not a guest-networking option by itself, but it is a critical related
design because Hyper-V changes to the host network can break the Windows
control plane.

### What it solves

- host OpenSSH/WinRM disappearing after Hyper-V network changes or reboot

### Current implementation

- a temporary host-local scheduled task is staged before risky Hyper-V work
- it can run:
  - `Clear-DnsClientCache`
  - `ipconfig /flushdns`
  - `ipconfig /release`
  - `ipconfig /renew`

Reference:
- [hyper-v-management-os-network-recovery.md](/Users/joshc/develop/dotfile-vnext/docs/intake/hyper-v-management-os-network-recovery.md)

---

## Current Working Judgment

### Best current implementation checkpoint

Keep:

- Internal switch + ICS
- host-local recovery task for management OS control-plane survival

Why:

- it is the first direction that actually broke the old DHCP/IP collision loop
- it is implemented enough to produce real evidence on this host

### Best next comparison target

Compare the current ICS design against:

- Internal switch + WinNAT
- Internal switch + routed private subnet

Why:

- those are the most credible next-step designs if the goal is:
  - reach the guest from the Mac
  - expose Docker services on the network cleanly

### Design to treat as secondary

- External switch + bridge-driver tweak

Why:

- it is a credible convenience-first workaround
- but it appears more environment-sensitive than the internal-network designs

---

## Suggested Next Decision Questions

1. Is the real goal "guest has any outbound internet" or "guest is a stable
   network-reachable Docker host from the Mac/LAN"?
2. If direct network reachability matters more than consumer simplicity, should
   we pivot from ICS to WinNAT or to a routed private-subnet design?
3. If we keep ICS short-term, what is the cleanest interim access path:
   - host-side SSH hop
   - host-side port forward
   - route from the Mac to the guest subnet

## Considered But Rejected References

These references were useful for comparison or for clarifying specific routing
ideas, but are not the current primary implementation path.

### External-switch bridge-driver workaround

- useful because it describes one way some users got Wi-Fi-backed External
  switching to expose the guest MAC cleanly to the router
- rejected as a primary repo design because it appears more sensitive to
  driver, AP, bridge, and roaming behavior

Reference:
- https://superuser.com/questions/1137818/hyper-v-virtual-switch-issue-same-ip-on-guest-and-host

### Hyper-V Network Virtualization (HNV) routing

- useful as a conceptual reminder that routed designs are often cleaner than
  pretending everything is bridged
- rejected because HNV is the wrong abstraction layer for this single-host,
  single-guest repo problem

Reference:
- https://blog.ipspace.net/2014/01/complex-routing-in-hyper-v-network/

### Host-as-router lab designs

- useful because they show that Windows can route between internal Hyper-V
  subnets
- rejected as the primary path because they are lab-oriented, broader than our
  immediate need, and not the clearest route to direct Mac-to-guest access for
  this repo

References:
- https://igorpuhalo.wordpress.com/2023/02/09/enable-connectivity-between-hyper-v-internal-switches-or-create-ultimate-lab-on-one-pc/
- https://bhargavs.com/index.php/2013/10/21/routing-for-hyper-v-lab-part-2/
- https://woshub.com/hyper-v-enable-routing/
