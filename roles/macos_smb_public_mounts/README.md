# macos_smb_public_mounts

Permanent macOS mounts for Windows `public` SMB shares on `HOM-LAB-HVH-01`
and `HOM-LAB-HVH-02`.

## Methods (`macos_smb_public_mounts_method`)

| Method | Mechanism | Mount points |
| --- | --- | --- |
| `automount` | `/etc/auto_master` + `/etc/auto_homelab_smb` | `~/mnt/hvh-01-public`, `~/mnt/hvh-02-public` |
| `finder_login` | LaunchAgent + `mount_smbfs` (Finder SMB client, no GUI) | `~/HomelabSMB/hvh-01-public`, `~/HomelabSMB/hvh-02-public` |

Volume names stay **`hvh-01-public` / `hvh-02-public`** under `~/HomelabSMB`
so they do not collide with a Finder favorite that shows as `public`.

Switching methods tears down the other backend first (unmount, remove
automount map / LaunchAgent), then applies the selected one.

## Shared behavior

- Keychain internet passwords for `joshc` (IP + hostname)
- Password from `vault_windows_house_remoting_password` (URL-encoded; house
  password contains `@`)
- Servers use inventory `host_ip`

## Lifecycle

| State | Effect |
| --- | --- |
| `present` | Keychain + selected method + verified mounts |
| `absent` | Unmount, remove both backends, delete Keychain entries |

## Apply / Verify / Undo / Change class

```bash
# finder_login (try Finder SMB path)
ansible-playbook playbooks/deploy_development_nodes.yaml \
  --tags macos_smb_public_mounts --limit mac-dev \
  -e macos_smb_public_mounts_method=finder_login

# back to automount
ansible-playbook playbooks/deploy_development_nodes.yaml \
  --tags macos_smb_public_mounts --limit mac-dev \
  -e macos_smb_public_mounts_method=automount

# undo
ansible-playbook playbooks/deploy_development_nodes.yaml \
  --tags macos_smb_public_mounts --limit mac-dev \
  -e macos_smb_public_mounts_state=absent
```

- **Verify:** `mount | grep smbfs` and `ls` the mount points above
- **Change class:** idempotent config
