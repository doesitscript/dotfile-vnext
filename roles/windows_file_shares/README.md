# windows_file_shares

Manages local Windows SMB shares for hosts in `windows_file_share_hosts`.

The public interface is `windows_file_shares_state: present|absent`.
`present` ensures expected volume labels, local groups, local users, folders,
NTFS permissions, SMB shares, the SMB server service, and the SMB firewall rule
group. `absent` removes managed SMB shares and managed NTFS ACL entries; it
keeps folders, users, and groups unless a future explicit cleanup contract is
added.

Use `windows_file_shares_extra_directories` for host-specific subdirectories
inside managed shares, such as model catalog storage roots. These directories
are created and verified, but they are not exposed as separate SMB shares.

Sensitive user passwords belong in group or host vault files using `vault_`
prefixed variables.

## Apply

```bash
ansible-playbook playbooks/windows_file_shares.yml -i inventory/inventory.yaml
```

## Preview

```bash
ansible-playbook playbooks/windows_file_shares.yml -i inventory/inventory.yaml --tags windows_file_shares_preview
```

## Verify

```bash
ansible-playbook playbooks/windows_file_shares.yml -i inventory/inventory.yaml --tags windows_file_shares_verify
```
