# hyperv_guest_route_mac

Manage the persistent macOS route that lets `mac-dev` reach the Hyper-V guest
private subnet through `server-225-win`.

## Purpose

This role is the first access-layer improvement on top of the Internal guest
switch design:

- the guest stays on a private subnet such as `192.168.137.0/24`
- the Windows host stays on the main LAN
- macOS learns a persistent route to the guest subnet through the Windows host

The role uses macOS `networksetup -setadditionalroutes` so the route is
persistent for the chosen network service.

## Lifecycle Contract

```yaml
hyperv_guest_route_mac_state: present | absent
```

Defaults:

```yaml
hyperv_guest_route_mac_network_service: "Wi-Fi"
hyperv_guest_route_target_subnet: "192.168.137.0"
hyperv_guest_route_target_mask: "255.255.255.0"
hyperv_guest_route_gateway: "192.168.50.158"
```

## Notes

- This role is intentionally narrow and controller-local.
- It preserves unrelated additional routes on the same macOS network service.
- It does not manage router-wide reachability. That is the later whole-LAN
  milestone.
