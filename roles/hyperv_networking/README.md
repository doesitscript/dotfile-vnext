# hyperv_networking

Pure infrastructure role: enables Hyper-V and manages the host-side switch
prerequisites used by Linux guests and VMs. It supports both an External Virtual Switch
bridged to a physical NIC and an Internal Virtual Switch shared through
Internet Connection Sharing (ICS) for Wi-Fi-backed guests, plus a routed
private-subnet mode that lets the Windows host act as the transit point to the
guest subnet.

Consumers (Linux guests, dev VMs, test labs) use the resulting
switches independently by referencing the switch name from `hyperv_config` or
their own role defaults.

**WARNING**: Creating or changing an External VMSwitch temporarily disconnects
the host's network. The role stages the one-time boot recovery helper before
that work and waits for reconnection afterwards.

## API Contract

The role receives a single dictionary variable `hyperv_config`:

```yaml
hyperv_config:
  external_switch_enabled: true    # create/verify the Hyper-V External VMSwitch
  switch_name: "External"          # name of the Hyper-V External VMSwitch
  adapter_interface_description: "RZ608 Wi-Fi 6E 80MHz"  # preferred exact physical NIC selector
  adapter_mac_address: ""          # optional exact physical NIC selector
  adapter_name: "Wi-Fi"            # fallback exact adapter alias for the external-switch path
  adapter_name_contains: ""        # optional unique substring selector; fails if ambiguous
  allow_management_os: true        # keep Windows host connected through the bridge
  internal_ics_switch_enabled: true
  internal_ics_switch_name: "Guest"
  guest_network_mode: "routed_private_subnet"
  guest_switch_name: "Guest"
  guest_subnet_ipv4: "192.168.137.0/24"
  guest_gateway_ipv4: "192.168.137.1"
  public_gateway_ipv4: "192.168.50.1"        # optional explicit IPv4 default gateway for the management vNIC
  public_dns_servers_ipv4: ["192.168.50.1"]  # optional explicit IPv4 DNS list for the management vNIC
  guest_remote_access_routing_enabled: false
  internal_ics_public_adapter_name: "vEthernet (External)"
  internal_ics_private_adapter_alias: "vEthernet (Guest)"
  internal_ics_psmodule_state: present
  management_os_boot_recovery_state: present  # stage one-time DHCP refresh on next boot
  management_os_boot_recovery_trigger_delay: "PT45S"
```

Set in `host_vars` or `group_vars`. The role provides safe defaults in
`defaults/main.yml`.

Selector precedence for the external-switch create path is:

1. `adapter_mac_address`
2. `adapter_interface_description`
3. `adapter_name`
4. `adapter_name_contains`

The role never picks the "first" substring match. If a substring selector
matches more than one physical adapter, the role fails and shows the candidate
pool in preview/debug output.

The Hyper-V prerequisite features are also lifecycle-driven:

```yaml
hyperv_feature_state: present | absent
hyperv_networking_feature_prereqs_enabled: true
```

Use `present` for the normal path. Use `absent` when you need to intentionally
tear down the Hyper-V prerequisite stack before rebuilding it. The feature
taskfile removes and reinstalls the same role-owned prerequisites so cleanup
does not drift into one-off host surgery.

For day-2 hosts where Hyper-V is already installed and verified, set:

```yaml
hyperv_networking_feature_prereqs_enabled: false
```

That keeps steady-state switch and routed-subnet convergence away from slow or
blocked ServerManager feature checks. The `absent` lifecycle still runs the
feature taskfile so teardown remains explicit.

## Management OS Boot Recovery

On Windows hosts that are expected to stay reachable through the Hyper-V
management OS, the safest first-pass recovery path is a temporary boot task
that runs locally on the next reboot and applies the soft DHCP refresh sequence
that already proved effective for `HOM-LAB-HVH-02`:

```powershell
Clear-DnsClientCache
ipconfig /flushdns
ipconfig /release
ipconfig /renew
```

The role enables this behavior when:

```yaml
hyperv_config:
  management_os_boot_recovery_state: present
```

When enabled, the role:

1. Stages a small PowerShell recovery script under
   `C:\ProgramData\Ansible\hyperv_networking\scripts\`
2. Registers a temporary boot-triggered scheduled task before risky Hyper-V
   feature or switch work
3. Uses the host's existing `host_ip` as the expected control-plane IPv4
4. Lets the task unregister itself after the next boot
5. Removes the staged task and script once Ansible reconnects successfully

This keeps the first implementation simple and DHCP-based. It does not force a
static management IP.

If a host has the correct management IPv4 but still loses its IPv4 default
route or DNS after Hyper-V switch convergence, you can explicitly model the
public management gateway/DNS in `hyperv_config`:

```yaml
hyperv_config:
  public_gateway_ipv4: "192.168.50.1"
  public_dns_servers_ipv4:
    - "192.168.50.1"
```

That path is intended as a role-owned recovery/convergence surface for lab
hosts whose management vNIC no longer keeps the expected IPv4 gateway via DHCP.

## Internal Guest Switch + ICS

On Wi-Fi-backed Windows hosts, bridged External switching can leave Linux guest
DHCP unreliable. The safer first path for Hyper-V Ubuntu guests is:

1. create an Internal Hyper-V switch
2. enable ICS from the public Wi-Fi adapter to the Internal switch adapter
3. attach the guest VM to that Internal switch

The role uses the `PSInternetConnectionSharing` PowerShell module as the
building block for the ICS pairing instead of hand-rolled COM calls.
When `internal_ics_sharing_enabled: false`, routed/direct guest networking does
not require that optional module unless it is already present and available for
cleanly disabling an existing ICS pair.

Important nuance:

- `internal_ics_public_adapter_name` is the Windows connection name that ICS
  should share from
- on hosts where the public uplink is already mediated through an External
  Hyper-V switch, that may be `vEthernet (External)` rather than the raw
  physical adapter name

### Reachability model

ICS gives the guest outbound connectivity by NATing the private guest subnet
through the Windows host. It does **not** automatically make the guest's
private IP directly routable from the rest of the LAN.

So in the current intended layout:

- the Windows host can reach the guest's `192.168.137.x` address directly
- the Mac/controller should not be assumed to reach that private IP directly
  without an added access strategy such as port forwarding, a host jump path,
  or explicit routing

Reference layout note:

- [hyperv-network-layout--windows--wifi-ics.md](/Users/joshc/develop/dotfile-vnext/docs/diagnostics/hyperv-network-layout--windows--wifi-ics.md)

## Routed Private Subnet Mode

The repo now treats the Internal guest switch and private guest subnet as the
durable guest-network foundation. When:

```yaml
hyperv_config:
  guest_network_mode: "routed_private_subnet"
```

the role adds the next access layer on top of that existing guest network:

1. keeps the guest-side `vEthernet (Guest)` gateway on `192.168.137.1`
2. enables IPv4 forwarding on the Windows host for the public and private
   adapters involved in guest access
3. persists `IpEnableRouter=1` so the host remains a valid forwarding point
   across reboots

The heavier Windows RemoteAccess/Routing role is optional and remains disabled
by default because `Get-WindowsFeature Routing` can block host convergence on
some lab Windows Server installs. Enable it only when the host specifically
needs RRAS-managed routing:

```yaml
hyperv_config:
  guest_remote_access_routing_enabled: true
```

This does not remove the value of the current ICS checkpoint. It builds from
it:

- ICS/private-subnet mode fixed the host/guest DHCP collision
- routed-private-subnet mode is the access-layer improvement that lets other
  systems learn a route to that subnet through the Windows host

Current milestone:

- first implementation target is `mac-dev` direct reachability to the guest IP
  through a persistent route
- the next milestone is a router-managed static route for the whole LAN

Important routing nuance:

- if `guest_outbound_nat_enabled: false`, the Windows host stops source-NATing
  guest traffic
- that restores true direct controller-to-guest TCP reachability, but guest
  internet egress and whole-LAN return traffic still depend on the upstream
  router learning the guest subnet through the Windows host
- for the current `HOM-LAB-HVH-02` lane, that means the upstream router
  needs a static route for `192.168.137.0/24` via `192.168.50.158`

Router operator guide:

- [docs/diagnostics/hyperv-router-static-route-guide.md](/Users/joshc/develop/dotfile-vnext/docs/diagnostics/hyperv-router-static-route-guide.md)
- this role manages the Windows host side only; it does not program the
  upstream router
- if a lane stays on `guest_outbound_nat_enabled: true`, the router route is
  not required for guest internet egress, but that lane is still using the
  host-NAT tradeoff rather than the final routed design

Published guest TCP ports have an additional recovery guard:

- if a `netsh interface portproxy` rule exists but Windows is not actually
  listening on that `listen_address:listen_port`, the role now treats that as
  drift
- during the next `hyperv_networking` apply, it recreates the affected
  portproxy rule and restarts `iphlpsvc`

This protects the common failure mode where the configured rules still exist
but the LAN-published service path is dead.

## Playbook Integration

Canonical capability playbook:

```bash
ansible-playbook playbooks/configure_hyperv_windows_hosts.yaml -i inventory/inventory.yaml
```

Use `include_role` to prevent variable bleed:

```yaml
tasks:
  - name: Configure Hyper-V bridge infrastructure
    ansible.builtin.include_role:
      name: hyperv_networking
    when: >-
      (
        (hyperv_config | default({})).external_switch_enabled | default(false) | bool
      ) or (
        (hyperv_config | default({})).internal_ics_switch_enabled | default(false) | bool
      )
```

Low-level standalone validation surface:

```bash
ansible-playbook playbooks/hyperv_networking.yaml -i inventory/inventory.yaml --limit HOM-LAB-HVH-02
```

The legacy Multipass teardown playbook has been retired after cleanup.
Keep this role focused on Hyper-V feature and switch prerequisites for the
Hyper-V-native Ubuntu VM flow.

## What This Role Does NOT Do

- Deploy guest-specific Linux configuration (that is a consumer concern outside this role)
- Create Hyper-V firewall rules for specific guests
- Configure guest networking (Netplan, portproxy, DNS)
- Export cross-role `set_fact` state

## Related

- Linux guest bootstrap/configuration roles
  (consumers of the switch and routed/private guest network)
