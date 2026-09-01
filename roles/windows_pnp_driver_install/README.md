# windows_pnp_driver_install

Stage and install a Windows PnP driver package with `pnputil`.

## TP-Link Wi-Fi 6 on Windows Server

TP-Link publishes **Win10/Win11 x64 only** for Archer TX3000E. There is **no**
official Windows Server driver package.

Observed on `HOM-LAB-HVH-01` (Windows Server 2025, build 26100):

- **Signed vendor `mtkwl6ex.inf` installs** via `pnputil /add-driver` without INF
  edits (`NTAMD64.10.0...16299` matches build 26100).
- **Server INF patch** (duplicate decorations, disable `CatalogFile`) is
  implemented but **cannot be installed** on Server 2025 — even `pnputil /force`
  returns *"does not contain digital signature information"*.
- Use `windows_pnp_driver_install_patch_inf_for_windows_server: false` (default).
- Use the **complete** `Windows_11_64bit` folder (`.inf`, `.sys`, `.dll`, `.dat`,
  `.cat`) — not a partial copy. Staging SSOT:
  `F:\shares\public\driver-staging\tplink-wifi6-mediatek`. Operator copy under
  `C:\Temp\Windows_11_64bit` is equivalent when all five files are present.
- **Admin share path** (from another Windows PC on the LAN):
  `\\HOM-LAB-HVH-01\C$\Temp\Windows_11_64bit`. macOS controller: prefer SSH +
  `run_remote_command.py`; SMB `C$` requires explicit mount/credentials.
- **2026-09-01 live evidence:** driver store contains signed `oem2.inf`
  (mtkwl6ex 0.34.2.886), but PCIe `VEN_14C3&DEV_7922` reports
  `IsPresent=false` / PnP problem **45** (phantom). Device Manager “cannot load
  drivers” in that state is a **hardware-not-detected** symptom, not missing
  Win11 files. Reseat PCIe card and reboot before re-running install.

`host_export` remains available as a fallback but is **not recommended** for
Server targets because it copies whatever is already in another host's driver
store without vendor packaging or Server decoration fixes.

## Apply / Verify / Undo / Change class

| | |
| --- | --- |
| Apply | `ansible-playbook playbooks/install_tplink_wifi6_driver_hvh01.yml --tags driver_install_apply` |
| Verify | Playbook reports OS detection, patch actions, adapter/PnP status |
| Undo | Remove driver via Device Manager / `pnputil /delete-driver` (manual) |
| Change class | Idempotent vendor download + optional INF patch + install |
