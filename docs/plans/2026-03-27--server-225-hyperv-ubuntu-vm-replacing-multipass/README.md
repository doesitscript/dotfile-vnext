# Server-225 Hyper-V Ubuntu VM Replacing Multipass

Canonical approvedb plan for replacing the deprecated Multipass-backed
`server-225-ubuntu` surface with a Hyper-V-native Ubuntu VM on `HOM-LAB-HVH-02`.

Tracked in GitHub issue [#4](https://github.com/doesitscript/dotfile-vnext/issues/4).

Supporting research for the approved implementation direction lives in
[research.md](/Users/joshc/develop/dotfile-vnext/docs/plans/2026-03-27--server-225-hyperv-ubuntu-vm-replacing-multipass/research.md).
Runtime command evidence for the first implementation pass lives in
[evidence--hyperv-live-runs.md](/Users/joshc/develop/dotfile-vnext/docs/plans/2026-03-27--server-225-hyperv-ubuntu-vm-replacing-multipass/evidence--hyperv-live-runs.md).

## Summary

Abandon Multipass as the provisioning mechanism for `server-225-ubuntu`.

The repo direction is now:

- keep `server-225-ubuntu` as the inventory host
- retire the existing `multipass_ubuntu_vm` capability through its `absent`
  lifecycle
- replace it with a new Hyper-V-native Ubuntu VM role built around:
  - Canonical Azure VHD as the primary source artifact
  - source normalization on the Windows host before conversion
  - Hyper-V-native `Convert-VHD` to the final fixed VHDX
  - cloud-init ISO
  - External Switch networking
  - SSH publication back into inventory/controller config

## Adapted Repo-Specific Direction

The intake note is already close to the right answer. The main repo-specific
adaptation is sequencing:

1. first checkpoint
   - stop driving Multipass as `present`
   - keep the legacy role and playbooks only as teardown/deprecation paths
   - commit that checkpoint
2. cleanup checkpoint
   - run the legacy `absent` path to remove the old Multipass package/runtime
   - remove active Multipass playbooks, host vars, and troubleshooting
     entrypoints from the repo
   - keep only background evidence and temporary reference material
3. replacement checkpoint
   - introduce a new `hyperv_ubuntu_vm` role instead of rewriting
     `multipass_ubuntu_vm` in place
   - add a dedicated `server_225_hyperv_ubuntu_vm` playbook
   - keep cutover out of the broad server-225 provisioning path until runtime
     verification succeeds
4. cutover checkpoint
   - switch active server-225 provisioning to the new Hyper-V-native role
   - remove the old Multipass role/playbook once the replacement is proven

## Why This Order

- the repo already has a working `absent` path for the old capability
- using that path first is safer than deleting Multipass surfaces before the
  old VM is intentionally retired
- it gives a clean git checkpoint between deprecation and replacement
- it preserves the reusable cloud-init/bootstrap ideas without pretending the
  old implementation is still the desired direction

## Chosen Replacement Shape

Recommended path:

- new role: `hyperv_ubuntu_vm`
- keep lifecycle state-based:
  - `hyperv_ubuntu_vm_state: present | absent`
- primary disk path:
  - download Canonical Azure VHD tarball
  - extract the published VHD on `HOM-LAB-HVH-02`
  - clear sparse/compression on the source artifact
  - run native `Convert-VHD` to the final fixed VHDX
- keep the old raw `.img -> qemu-img -> vhdx` path only as fallback/legacy
  experiment material, not as the first implementation candidate
- carry forward from `multipass_ubuntu_vm`:
  - cloud-init template pattern
  - SSH key bootstrap pattern
  - SSH publication outcome
  - troubleshooting-mode evidence vocabulary where it still fits

Do not carry forward:

- Multipass MSI install
- `multipass` CLI calls
- Multipass-specific networking probes and diagnostics as part of normal VM
  lifecycle

## Current Checkpoint Scope

The completed cleanup work is still intentionally narrow.

In scope now:

- set the active Multipass control surface to `absent`
- reframe active playbooks/docs as legacy teardown paths
- preserve the old capability only long enough to retire it safely
- commit that state as a durable checkpoint
- run host-side teardown and remove active deprecated Multipass entrypoints
  from the repo
- remove the live repo implementation role once the replacement direction is
  proven and no playbook still depends on it

Not in scope for this checkpoint:

- full cutover into the broad server-225 provisioning play
- deleting the archived Multipass reference role before the replacement is
  proven

## Apply / Verify / Undo / Change Class

Apply:
- run the legacy `absent` path to remove Multipass from `HOM-LAB-HVH-02`
- remove active Multipass playbooks, host vars, and troubleshooting entrypoints
  from the repo

Verify:
- verify the Multipass MSI/runtime is gone from `HOM-LAB-HVH-02`
- syntax-check touched playbooks
- inspect the active control surfaces to confirm they no longer advertise
  Multipass as a supported path

Undo:
- restore the deleted playbooks/vars/docs from git
- reinstall/recreate Multipass only as a deliberate exception, not as the
  default direction

Change class:
- destructive host teardown plus idempotent repo cleanup

## Current Replacement Update

The original raw Ubuntu cloud-image conversion path is no longer the preferred
implementation direction.

Pinned runtime finding:

- Canonical's published Azure VHD, after source normalization on
  `HOM-LAB-HVH-02`, converted cleanly with native `Convert-VHD`
- the resulting fixed VHDX booted `server-225-ubuntu` successfully

Implementation consequence:

- make the Azure VHD route the primary candidate
- probe both source and destination artifacts before Hyper-V attach/start
- keep the raw `.img` route only as fallback or legacy experiment material

Current correction after live boot evidence:

- the Azure-image / local-seed bootstrap path stopped producing new evidence
- repeated boots reached `cloud-init`, but the guest kept falling back to Azure
  datasource / IMDS behavior instead of consuming the local provisioning media
  as intended
- that path is now preserved as research, not as the active implementation
  target
- Quick Create follow-up result:
  - Canonical Hyper-V Quick Create VHDX is now a validated Hyper-V-native
    bootability checkpoint
  - it reached the Ubuntu desktop first-run configuration UI in VMConnect
  - that makes it a useful fallback, but not the right active target for an
    unattended SSH/Docker server surface
- next active image target:
  - official Ubuntu Server ISO on Hyper-V
- next explicit bootstrap follow-up:
  - installer/autoinstall handoff for the Ubuntu Server ISO path
  - current sub-checkpoint:
    - installer ISO and `cidata` autoinstall seed are both attached
    - fast VM-only lifecycle loops now preserve the large installer download
    - if the installer still shows the normal welcome flow, the next solve is
      bootloader/autoinstall handoff rather than seed creation

## Current Networking Milestone

The networking direction has now moved past the original External-switch plan
and the earlier ICS-only checkpoint.

Current preferred topology on `HOM-LAB-HVH-02`:

- keep the host control plane on `vEthernet (External)` on the LAN
- keep the Ubuntu guest on an Internal Hyper-V switch
- keep the private guest subnet on `192.168.137.0/24`
- make `HOM-LAB-HVH-02` the transit host between the LAN and that guest subnet
- first add a Mac-only route to the guest subnet
- later promote the same route to the router for whole-LAN reachability

What this milestone has already proven:

- the old guest/host DHCP-IP collision on the Wi-Fi-backed External switch path
  is no longer the active blocker
- the guest can boot and obtain a private ICS-subnet IPv4
- the Windows host can see and probe that guest address on the private subnet
- the Mac/controller route can be installed toward that private subnet through
  `HOM-LAB-HVH-02`

What remains in progress:

- whole-LAN reachability as the later router-static-route milestone
- bounded follow-up test:
  - try Secure Boot disabled on the Generation 2 VM if current console evidence
    suggests the guest is not reaching a healthy userspace/SSH state despite
    booting and receiving a private IPv4
- faster iteration improvements now in place:
  - `absent` preserves downloaded installer/source artifacts instead of
    deleting the whole host artifact directory
  - a lighter VM-only control surface exists at
    [server_225_hyperv_ubuntu_vm_lifecycle_only.yaml](/Users/joshc/develop/dotfile-vnext/playbooks/server_225_hyperv_ubuntu_vm_lifecycle_only.yaml)
    for loops where controller identity, networking, and guest-route setup are
    already converged

Reference layout note:

- [hyperv-network-layout--windows--wifi-ics.md](/Users/joshc/develop/dotfile-vnext/docs/diagnostics/hyperv-network-layout--windows--wifi-ics.md)
- [hyperv-network-layout--windows--routed-private-subnet.md](/Users/joshc/develop/dotfile-vnext/docs/diagnostics/hyperv-network-layout--windows--routed-private-subnet.md)

Pinned routed-network evidence:

- Windows host reached guest-private-subnet addresses during the Hyper-V Ubuntu
  runs
- Mac/controller now proves routed reachability to `192.168.137.10`
- Mac/controller now proves `22/tcp` reachability to `192.168.137.10`
- guest-side install is now using a static routed-subnet address:
  - `192.168.137.10/24`
  - gateway `192.168.137.1`
- current remaining blocker:
  - SSH authentication acceptance for `ubuntu@192.168.137.10`

Current verification ladder:

- Windows host:
  - `Test-Connection 192.168.137.10 -Count 1`
  - `Test-NetConnection -ComputerName 192.168.137.10 -Port 22`
  - `Get-NetNeighbor -IPAddress 192.168.137.10`
- Mac/controller:
  - `route -n get 192.168.137.10`
  - `nc -vz -G 2 192.168.137.10 22`
  - `ssh -i ~/.ssh/id_ed25519_ansible -o IdentitiesOnly=yes ubuntu@192.168.137.10`
- Guest console:
  - `ip -br addr`
  - `ip route`
  - `systemctl is-active ssh`
  - `ss -ltnp | grep ':22'`

Current console interpretation note:

- VMConnect may continue to show Subiquity/log output even when the installed
  guest is already up and reachable on the routed subnet
- once host ping and host/controller `22/tcp` probes succeed, treat those as
  stronger truth than stale tty output alone

## Current Cleanup Status

Repo cleanup completed:

- the live `roles/multipass_ubuntu_vm/` implementation has been removed
- stray Multipass troubleshooting artifacts under
  `playbooks/troubleshoot/artifacts/troubleshooting/multipass_bridge_failure/`
  have been removed

Host cleanup blocked:

- `HOM-LAB-HVH-02` is currently unreachable at the network layer, so the
  destructive host-side teardown could - proving stable SSH authentication from the routed guest address
not be completed in this pass

Pinned blocker evidence:

```text
ssh: connect to host DESKTOP-VLLM port 22: Host is down
nc: connectx to DESKTOP-VLLM port 5985 (tcp) failed: Host is down
? (192.168.50.158) at (incomplete) on en0 ifscope [ethernet]
```
