# Research — Hyper-V Ubuntu VM Replacement

## Sources Checked

- Repo intake:
  - `docs/intake/hyperv-ubuntu-docker-vm--replacing-multipass.md`
- Existing repo roles:
  - `roles/hyperv_networking/`
  - `roles/multipass_ubuntu_vm/`
  - `roles/access_identity_controller/`
- Microsoft Learn:
  - Hyper-V generation guidance
  - Ubuntu support on Hyper-V
  - Hyper-V generation 2 security settings
- cloud-init documentation:
  - NoCloud datasource
- Local controller tooling:
  - `hdiutil makehybrid`
  - `community.general.iso_create`

## What Already Exists

- `hyperv_networking` already owns Hyper-V feature enablement and External
  switch management on `hom-lab-ctl-hvh-02`.
- `server-225-ubuntu` already exists as the reserved inventory identity for the
  replacement VM.
- `multipass_ubuntu_vm` already contains the reusable bootstrap patterns we
  want to carry forward:
  - controller public key loading
  - cloud-init user-data templating
  - SSH fact publication

## Original Phase-1 Implementation Direction

- New role: `hyperv_ubuntu_vm`
- Dedicated control surface: `playbooks/server_225_hyperv_ubuntu_vm.yaml`
- Keep `provision_server_225.yaml` unchanged until the new role is runtime
  proven
- Use Hyper-V Generation 2
- Use Ubuntu cloud image
- Use NoCloud `CIDATA` seed ISO with:
  - `user-data`
  - `meta-data`
- Generate the seed ISO on the controller with `hdiutil makehybrid`
- Install `qemu-img` on the Windows host via Chocolatey
- Convert the Ubuntu `.img` to a VM-owned `.vhdx` on `hom-lab-ctl-hvh-02`
- Publish the guest back to `server-225-ubuntu` through host facts and the
  controller SSH config refresh

## Decisions Applied In Phase 1

- Controller-side ISO creation is preferred over bootstrapping a Windows ISO
  authoring tool because:
  - the controller already has `hdiutil makehybrid`
  - `community.general.iso_create` rejected the required cloud-init filenames
    (`user-data`, `meta-data`) under ISO9660 restrictions
  - it keeps the Windows host dependency surface smaller
- Windows-side image conversion still needs `qemu-img`, so the role owns that
  bootstrap dependency on `hom-lab-ctl-hvh-02`
- Secure Boot should use the Linux-compatible template:
  - `MicrosoftUEFICertificateAuthority`

## Risks / Open Edges

- Hyper-V IP discovery after first boot depends on integration services and may
  take time; the role should wait rather than assuming immediate IP visibility
- Cloud-init input is effectively bootstrap input; if it changes later, that
  should be treated as recreate-worthy rather than silently reconciled in place
- `qemu-img` successfully converts the Ubuntu cloud image, but the resulting
  `.vhdx` is still rejected by Hyper-V at boot time with:
  - `Virtual hard disk files must be uncompressed and unencrypted and must not be sparse`
- Runtime evidence so far shows:
  - the Hyper-V External Switch creation path works after increasing the WinRM
    connection timeout in `hyperv_networking`
  - controller-side seed ISO generation now works with `hdiutil`
  - `qemu-img.exe` is installed at `C:\Program Files\qemu\qemu-img.exe`
  - the converted disk file can report `VhdType=Fixed` while still failing
    Hyper-V boot with the sparse-file limitation
- a direct troubleshooting probe also shows the same file currently carries:
    - `fsutil sparse queryflag -> This file is set as sparse`
    - `compact /q -> 1 are compressed and 0 are not compressed`
    - `Get-Item.Attributes -> Archive, SparseFile, NotContentIndexed`
  - the contradiction is therefore not theoretical: the current `qemu-img -> vhdx`
    artifact strategy is producing a boot disk that looks fixed to `Get-VHD`
    while still remaining sparse/compressed at the filesystem layer
  - replacement-resource testing later proved a more viable route:
    - Canonical Azure VHD tarball
    - extract published VHD on `hom-lab-ctl-hvh-02`
    - clear sparse flag and compression on the source artifact
    - native `Convert-VHD` to the final fixed VHDX
    - attach and boot successfully in Hyper-V

## Runtime Findings To Carry Forward

- The first end-to-end playbook proof now gets through:
  - Hyper-V feature and switch prerequisites
  - controller cloud-init rendering and seed ISO creation
  - Windows cloud-image download
  - `qemu-img` installation and disk conversion
  - Hyper-V VM object creation
- The remaining blocker is the disk artifact strategy, not the orchestration.
- The raw `.img -> qemu-img -> vhdx` path should no longer be treated as the
  primary candidate.
- The first viable replacement path is now proven:
  - use Canonical's Azure VHD as the source artifact
  - normalize the extracted source on the Windows host
  - use native `Convert-VHD`
  - probe both source and destination before Hyper-V attach/start

## Current Recommendation

- Adopt this as the new primary path:
  - download Canonical Azure VHD tarball
  - extract the published VHD
  - clear sparse flag on the source artifact
  - clear compression on the source artifact
  - run native `Convert-VHD` to the final fixed VHDX
  - probe source and destination with `fsutil`, `compact`, `Get-Item`, and
    `Get-VHD` before Hyper-V attach/start
- Keep the raw `.img -> qemu-img -> vhdx` path only as fallback or legacy
  experiment material.
- Treat any future implementation that skips the source- and destination-probe
  gates as incomplete for this host class.

## Recommended Verification

1. Syntax-check the dedicated playbook
2. Lint the new role
3. Run the dedicated playbook against `hom-lab-ctl-hvh-02`
4. Confirm:
   - VM exists in Hyper-V
   - guest obtains an IPv4 address on the External Switch
   - SSH works from `mac-dev`
   - `server-225-ubuntu` gets published into controller SSH config
