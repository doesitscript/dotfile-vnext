# windows_rdp_certificate_export

Exports the public leaf certificate from `Cert:\LocalMachine\Remote Desktop`
so a Mac Microsoft Remote Desktop client can trust LAN RDP hosts without the
"certificate couldn't be verified back to a root certificate" prompt.

## Apply / Verify / Undo / Change class

- **Apply:** `state: present` — export DER/PEM + CN sidecar, fetch to controller cache
- **Verify:** fetched `.cer` exists under `.cache/rdp-certs/<inventory_hostname>/`
- **Undo:** `state: absent` — remove remote export files (cache cleanup optional)
- **Change class:** idempotent config (public cert only; no private key)

## Usage

```bash
ansible-playbook playbooks/remote_desktop_mac_lan.yaml \
  -i inventory/inventory.yaml \
  --tags windows_rdp_certificate_export
```

## Module matrix

| Surface | FQCN | Fit |
| --- | --- | --- |
| Export RDP TLS leaf | `ansible.windows.win_certificate_store` (`state=exported`, store `Remote Desktop`) | yes |
| Discover thumbprint/CN | `ansible.windows.win_powershell` (custom store listing) | yes (narrow) |
| Stage remote dir | `ansible.windows.win_file` | yes |
| Pull to controller | `ansible.builtin.fetch` | yes |
