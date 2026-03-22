# Tunnelblick Local Staging

This folder is the ignored local landing zone for raw Tunnelblick/OpenVPN client
exports while they are being inspected or translated into vaulted repo data.

Use it for temporary local files such as:
- `router-openvpn.ovpn`
- `router-openvpn.tblk`
- a router-exported zip archive containing the client config

This folder is ignored by Git except for this README and `.gitkeep`.

Preferred long-term shape:
- non-secret profile metadata in `inventory/host_vars/mac-dev.yaml`
- secret values and optional `.ovpn` text content in `vault/mac_dev.vault.yml`

Current staged filename to use when the router export is found:
- `private/tunnelblick/router-openvpn.ovpn`
