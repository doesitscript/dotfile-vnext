# windows_desktop_gaming_firewall

Explicit Windows Firewall program-path rules for interactive Windows gaming
desktops.

- Apply: set `windows_desktop_gaming_firewall_state: present` on the target host and
  declare one or more entries in `windows_desktop_gaming_firewall_rules`.
- Verify: rerun the owning playbook and confirm the declared rule names are present in
  Windows Firewall for the declared program paths.
- Undo: set `windows_desktop_gaming_firewall_state: absent` and rerun the same playbook.
- Change class: idempotent config.

Current first use:

- `dev-workstation-win` Dead by Daylight shipping-binary inbound TCP/UDP rules
