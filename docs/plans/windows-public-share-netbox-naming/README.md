# Windows Public Share Capability Plan With NetBox Naming And Required Diagrams

## Summary

- Add a reusable Windows public-share capability for `server-225-win` and `network-server-win`.
- Replace the NetBox-facing `network-server-win` alias concept with `primary-hvh-01`.
- Use short NetBox names and push rich context into NetBox native fields, tags, and context metadata.
- Fix the planning gap by adding a plan-authoring checklist under `docs/plans/`.

## Architecture/Structure Diagram

```mermaid
graph TB
    subgraph repo [dotfile-vnext]
        subgraph docs [Planning And Naming Docs]
            plan[docs/plans/windows-public-share-netbox-naming/README.md]
            template[docs/plans/README.md<br/>diagram checklist]
            naming[docs/reference/naming-standards/*]
        end

        subgraph inventory [Inventory Layer]
            inv[inventory/inventory.yaml<br/>windows_file_share_hosts]
            gv[inventory/group_vars/windows_file_share_hosts/main.yml<br/>windows_file_shares_*]
            vault[inventory/group_vars/windows_file_share_hosts/vault.yml<br/>vault_windows_file_shares_mikec_password]
            hostvars[inventory/host_vars/*<br/>legacy aliases remain]
        end

        subgraph roles [Role Layer]
            shares[roles/windows_file_shares<br/>state: present or absent]
            netbox[roles/ipam_netbox<br/>seed Windows share-host model]
        end

        subgraph playbooks [Playbook Layer]
            sharepb[playbooks/windows_file_shares.yml<br/>preview, apply, verify]
            nbpb[playbooks/deploy_ipam_netbox.yaml<br/>NetBox seed tags]
            site[playbooks/site.yaml<br/>imports share capability]
        end
    end

    subgraph netbox_live [NetBox Source Of Truth]
        nbsite[site: homelab]
        nbdev1[device: primary-hvh-01<br/>legacy_alias: network-server-win]
        nbdev2[device: exec-hvh-01<br/>legacy_alias: server-225-win]
        nbrole[device_role: hyperv-host]
        nbplatform[platform: Windows Server 2025]
        nbtags[tags: ansible-managed, infra, hyperv, primary or execution]
    end

    subgraph windows [Windows Hosts]
        nsw[network-server-win<br/>F:\\shares\\public]
        s225[server-225-win<br/>F:\\shares\\public]
        smb[SMB share: public<br/>group: share_users]
    end

    naming --> plan
    template --> plan
    inv --> sharepb
    gv --> shares
    vault --> shares
    hostvars --> sharepb
    nbpb --> netbox
    sharepb --> shares
    site --> sharepb

    netbox --> nbsite
    netbox --> nbdev1
    netbox --> nbdev2
    nbdev1 --> nbrole
    nbdev2 --> nbrole
    nbdev1 --> nbplatform
    nbdev2 --> nbplatform
    nbdev1 --> nbtags
    nbdev2 --> nbtags

    shares --> nsw
    shares --> s225
    nsw --> smb
    s225 --> smb
```

## Capability Routing Diagram

```mermaid
graph TB
    start[Operator runs preview or apply] --> preview{Preview only?}

    preview -->|yes| nb_preview[Preview NetBox model<br/>primary-hvh-01, exec-hvh-01]
    preview -->|yes| share_preview[Preview Windows share state<br/>F: label, user, group, share]
    nb_preview --> stop_preview[Stop before mutation]
    share_preview --> stop_preview

    preview -->|no| netbox_token{NetBox token available?}
    netbox_token -->|no| fail_token[Fail before NetBox mutation<br/>vault_netbox_api_token required]
    netbox_token -->|yes| seed_netbox[Seed or update NetBox objects<br/>site, tags, platform, role, devices, interfaces, IPs]

    seed_netbox --> share_state{windows_file_shares_state}
    share_state -->|present| ensure_volume[Ensure F: label is data]
    ensure_volume --> ensure_identity[Ensure mikec and share_users]
    ensure_identity --> ensure_folder[Ensure F:\\shares\\public]
    ensure_folder --> ensure_acl[Ensure NTFS and SMB permissions]
    ensure_acl --> verify[Verify local and UNC access]

    share_state -->|absent| remove_share[Remove managed public share and managed ACL entries]
    remove_share --> verify_absent[Verify share removed<br/>identity cleanup is explicit future policy]

    verify --> idempotence[Rerun apply for idempotence]
    verify_absent --> idempotence
```

## Naming/Modeling Diagram

```mermaid
graph LR
    context[Context metadata<br/>namespace: castle<br/>site: homelab<br/>environment labels: home, lab] --> netbox[NetBox native fields and tags]
    alias1[Ansible/control alias<br/>network-server-win] --> name1[NetBox device<br/>primary-hvh-01]
    alias2[Ansible/control alias<br/>server-225-win] --> name2[NetBox device<br/>exec-hvh-01]
    role[role segment hvh] --> fullrole[device_role<br/>hyperv-host]
    name1 --> tags1[tags<br/>ansible-managed, infra, hyperv, primary]
    name2 --> tags2[tags<br/>ansible-managed, infra, hyperv, execution]
    netbox --> tags1
    netbox --> tags2
```

## Key Changes Implemented

- NetBox naming keeps `network-server-win` and `server-225-win` as Ansible/control aliases.
- NetBox device names are `primary-hvh-01` and `exec-hvh-01`.
- `castle` remains namespace/context, not tenant.
- `homelab` remains NetBox site; `home` and `lab` remain context labels unless later promoted.
- `windows_file_shares` owns the Windows SMB capability with `windows_file_shares_state: present|absent`.
- The managed Windows share is `F:\shares\public` exposed as `public`.
- Access is credentialed: local group `share_users`, user `mikec`, NTFS `Modify`, SMB `Change`.
- Anonymous access and `Everyone` share grants are intentionally omitted.
- `docs/plans/README.md` now requires stored plans to include required diagram sections or explicit `N/A` reasons.

## Apply / Verify / Undo

Apply:

```bash
ansible-playbook playbooks/windows_file_shares.yml -i inventory/inventory.yaml
ansible-playbook playbooks/deploy_ipam_netbox.yaml -i inventory/inventory.yaml --tags ipam_netbox_seed_windows_share_hosts_model
```

Verify:

```bash
ansible-playbook playbooks/windows_file_shares.yml -i inventory/inventory.yaml --tags windows_file_shares_verify
ansible-playbook playbooks/deploy_ipam_netbox.yaml -i inventory/inventory.yaml --tags ipam_netbox_seed_windows_share_hosts_model_preview
```

Undo:

```bash
ansible-playbook playbooks/windows_file_shares.yml -i inventory/inventory.yaml -e windows_file_shares_state=absent
```

NetBox cleanup remains explicit/manual unless an `absent` source-of-truth seed path is added later.

Change class: idempotent Windows configuration plus NetBox source-of-truth modeling.

## Validation Plan

- `ansible-playbook playbooks/windows_file_shares.yml -i inventory/inventory.yaml --syntax-check`
- `ansible-lint playbooks/windows_file_shares.yml`
- `ansible-playbook playbooks/deploy_ipam_netbox.yaml -i inventory/inventory.yaml --syntax-check`
- Preview `windows_file_share_hosts` before applying share mutations.
- Preview NetBox naming model before applying NetBox mutations.
- Apply and verify that:
  - `Get-Volume -DriveLetter F` returns label `data`
  - `F:\shares\public` exists
  - `mikec` exists and belongs to `share_users`
  - SMB share `public` exists with `share_users` Change access
  - `\\localhost\public` works with the vaulted credential
  - second apply is idempotent
