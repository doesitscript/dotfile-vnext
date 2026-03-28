# hyperv_networking

Pure infrastructure role: enables Hyper-V and manages the host-side switch
prerequisites used by WSL and VMs. It supports both an External Virtual Switch
bridged to a physical NIC and an Internal Virtual Switch shared through
Internet Connection Sharing (ICS) for Wi-Fi-backed guests.

Consumers (WSL bridged networking, dev VMs, test labs) use the resulting
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
  adapter_name: "Wi-Fi"            # public adapter for the external-switch path
  allow_management_os: true        # keep Windows host connected through the bridge
  internal_ics_switch_enabled: true
  internal_ics_switch_name: "Guest"
  internal_ics_public_adapter_name: "vEthernet (External)"
  internal_ics_private_adapter_alias: "vEthernet (Guest)"
  internal_ics_psmodule_state: present
  management_os_boot_recovery_state: present  # stage one-time DHCP refresh on next boot
  management_os_boot_recovery_trigger_delay: "PT45S"
```

Set in `host_vars` or `group_vars`. The role provides safe defaults in
`defaults/main.yml`.

The Hyper-V prerequisite features are also lifecycle-driven:

```yaml
hyperv_feature_state: present | absent
```

Use `present` for the normal path. Use `absent` when you need to intentionally
tear down the Hyper-V prerequisite stack before rebuilding it. The feature
taskfile removes and reinstalls the same role-owned prerequisites so cleanup
does not drift into one-off host surgery.

## Management OS Boot Recovery

On Windows hosts that are expected to stay reachable through the Hyper-V
management OS, the safest first-pass recovery path is a temporary boot task
that runs locally on the next reboot and applies the soft DHCP refresh sequence
that already proved effective for `server-225-win`:

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

## Internal Guest Switch + ICS

On Wi-Fi-backed Windows hosts, bridged External switching can leave Linux guest
DHCP unreliable. The safer first path for Hyper-V Ubuntu guests is:

1. create an Internal Hyper-V switch
2. enable ICS from the public Wi-Fi adapter to the Internal switch adapter
3. attach the guest VM to that Internal switch

The role uses the `PSInternetConnectionSharing` PowerShell module as the
building block for the ICS pairing instead of hand-rolled COM calls.

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

## Playbook Integration

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

Standalone:

```bash
ansible-playbook playbooks/hyperv_networking.yaml -i inventory/inventory.yaml --limit server-225-win
```

The legacy Multipass teardown playbook has been retired after cleanup.
Keep this role focused on Hyper-V feature and switch prerequisites for the
Hyper-V-native Ubuntu VM flow.

## What This Role Does NOT Do

- Deploy `.wslconfig` (that is a WSL consumer concern in `access_identity_windows`)
- Create Hyper-V firewall rules for specific guests
- Configure guest networking (Netplan, portproxy, DNS)
- Export cross-role `set_fact` state

## Related

- `roles/access_identity_windows/tasks/ubuntu.yml` — WSL guest networking
  (consumer of the switch, deploys `.wslconfig`, HV firewall rules)
