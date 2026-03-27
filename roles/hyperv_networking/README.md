# hyperv_networking

Pure infrastructure role: enables Hyper-V and creates an External Virtual Switch
bridged to a physical NIC. No guest awareness (WSL, VMs, containers).

Consumers (WSL bridged networking, dev VMs, test labs) use the switch
independently by referencing the switch name from `hyperv_config`.

**WARNING**: Creating or changing an External VMSwitch temporarily disconnects
the host's network. The role handles this with async + `wait_for_connection`.

## API Contract

The role receives a single dictionary variable `hyperv_config`:

```yaml
hyperv_config:
  external_switch_enabled: true    # gate — role skips when false
  switch_name: "External"          # name of the Hyper-V External VMSwitch
  adapter_name: "Wi-Fi,Ethernet"   # comma-separated fallback list; first Up adapter wins
  allow_management_os: true        # keep Windows host connected through the bridge
```

Set in `host_vars` or `group_vars`. The role provides safe defaults in
`defaults/main.yml` (switch disabled, adapter fallback `Wi-Fi,Ethernet`).

The Hyper-V prerequisite features are also lifecycle-driven:

```yaml
hyperv_feature_state: present | absent
```

Use `present` for the normal path. Use `absent` when you need to intentionally
tear down the Hyper-V prerequisite stack before rebuilding it. The feature
taskfile removes and reinstalls the same role-owned prerequisites so cleanup
does not drift into one-off host surgery.

## Playbook Integration

Use `include_role` to prevent variable bleed:

```yaml
tasks:
  - name: Configure Hyper-V bridge infrastructure
    ansible.builtin.include_role:
      name: hyperv_networking
    when: (hyperv_config | default({})).external_switch_enabled | default(false) | bool
```

Standalone:

```bash
ansible-playbook playbooks/hyperv_networking.yaml -i inventory/inventory.yaml --limit server-225-win
```

Feature-only teardown / rebuild through the Multipass flow:

```bash
.venv/bin/ansible-playbook playbooks/server_225_multipass_ubuntu_vm.yaml \
  -i inventory/inventory.yaml \
  --limit 'execution_nodes,server-225-win' \
  --tags hyperv_feature_prereq \
  -e hyperv_feature_state=absent
```

## What This Role Does NOT Do

- Deploy `.wslconfig` (that is a WSL consumer concern in `access_identity_windows`)
- Create Hyper-V firewall rules for specific guests
- Configure guest networking (Netplan, portproxy, DNS)
- Export cross-role `set_fact` state

## Related

- `roles/access_identity_windows/tasks/ubuntu.yml` — WSL guest networking
  (consumer of the switch, deploys `.wslconfig`, HV firewall rules)
