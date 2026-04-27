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
