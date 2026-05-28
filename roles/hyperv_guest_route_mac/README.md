# hyperv_guest_route_mac

Manage persistent macOS routes that let `mac-dev` reach Hyper-V guest private
subnets through their owning Windows hosts.

## Purpose

This role is the first access-layer improvement on top of the Internal guest
switch design:

- each guest stays on a private subnet such as `192.168.137.0/24`
- each Windows host stays on the main LAN
- macOS learns persistent routes to guest subnets through the owning Windows
  hosts

The role uses macOS `networksetup -setadditionalroutes` so the route is
persistent for the chosen network service.

## Lifecycle Contract

```yaml
hyperv_guest_route_mac_state: present | absent
```

Preferred route list:

```yaml
hyperv_guest_route_mac_routes:
  - destination: "192.168.137.0"
    mask: "255.255.255.0"
    gateway: "192.168.50.158"
  - destination: "192.168.138.0"
    mask: "255.255.255.0"
    gateway: "192.168.50.234"
```

Legacy single-route vars are still supported for direct role callers:

```yaml
hyperv_guest_route_mac_network_service: "Wi-Fi"
hyperv_guest_route_target_subnet: "192.168.137.0"
hyperv_guest_route_target_mask: "255.255.255.0"
hyperv_guest_route_gateway: "192.168.50.158"
```

## Notes

- This role is intentionally controller-local.
- It preserves unrelated additional routes on the same macOS network service.
- In the Docker Ubuntu VM playbook, the route list is derived from the selected
  Hyper-V Windows hosts instead of hand-maintained as a static controller list.
- It does not manage router-wide reachability. That is the later whole-LAN
  milestone.
- If a Hyper-V lane disables host NAT, direct `mac-dev` access can work through
  this role while guest outbound internet still remains blocked until the
  upstream router learns the guest subnet.
- Router-side guidance lives here:
  [docs/diagnostics/hyperv-router-static-route-guide.md](/Users/joshc/develop/dotfile-vnext/docs/diagnostics/hyperv-router-static-route-guide.md)

## Related DNS (separate from this role)

This role manages **mac-dev routes** to guest subnets. It does **not** publish
LAN-wide DNS names on the ASUS router.

| Job | What it does | Doc |
|-----|----------------|-----|
| Job 1 — routing | Packets to `192.168.137.x` (router static route + this role on Mac) | [hyperv-router-static-route-guide.md](/Users/joshc/develop/dotfile-vnext/docs/diagnostics/hyperv-router-static-route-guide.md) |
| Job 2 — host DNS | Optional `*.hom.lab` on GT6 manual DHCP table | [asus-gt6-stock-local-dns-option-c.md](/Users/joshc/develop/dotfile-vnext/docs/diagnostics/asus-gt6-stock-local-dns-option-c.md) |

Stock GT6 **cannot** add manual DHCP rows for `192.168.137.10` / `.11`. Use IP
or future `homelab_hosts_file_mac` on `mac-dev`. See
[router_local_dns README](../router_local_dns/README.md).
