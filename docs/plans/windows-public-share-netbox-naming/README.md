# Windows Public Share Capability Plan With NetBox Naming And Required Diagrams

## Summary

- Add a reusable Windows public-share capability for `HOM-LAB-HVH-02` and `home-lab-auth-hvh-01`.
- Replace the weak NetBox-facing `primary-hvh-01` and `exec-hvh-01` names with the current context baseline names `home-lab-auth-hvh-01` and `home-lab-auth-hvh-02`.
- Keep historical/control names as aliases and push rich context into NetBox native fields, tags, and context metadata.
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
        nbtenant[tenant: home]
        nbdev1[device: home-lab-auth-hvh-01<br/>legacy_aliases: network-server, primary-hvh-01]
        nbdev2[device: home-lab-auth-hvh-02<br/>legacy_aliases: HOM-LAB-HVH-02, exec-hvh-01]
        nbrole[device_role: hyperv-host]
        nbplatform[platform: Windows Server 2025]
        nbtags[tags: ansible-managed, home, lab, auth, infra, hyperv, primary or execution]
    end

    subgraph windows [Windows Hosts]
        nsw[home-lab-auth-hvh-01<br/>F:\\shares\\public]
        s225[HOM-LAB-HVH-02<br/>F:\\shares\\public]
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
    netbox --> nbtenant
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

    preview -->|yes| nb_preview[Preview NetBox model<br/>home-lab-auth-hvh-01, home-lab-auth-hvh-02]
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
    alias1[current Ansible inventory name<br/>home-lab-auth-hvh-01] --> name1[NetBox device<br/>home-lab-auth-hvh-01]
    legacy1[retired Windows control alias] --> name1
    old1[legacy NetBox name<br/>primary-hvh-01] --> name1
    alias2[Ansible/control alias<br/>HOM-LAB-HVH-02] --> name2[NetBox device<br/>home-lab-auth-hvh-02]
    old2[legacy NetBox name<br/>exec-hvh-01] --> name2
    role[role segment hvh] --> fullrole[device_role<br/>hyperv-host]
    name1 --> tags1[tags<br/>ansible-managed, home, lab, auth, infra, hyperv, primary]
    name2 --> tags2[tags<br/>ansible-managed, home, lab, auth, infra, hyperv, execution]
    netbox --> tags1
    netbox --> tags2
```

## Key Changes Implemented

- Active inventory now uses `home-lab-auth-hvh-01` for the former network-server Windows control host.
- NetBox device names are `home-lab-auth-hvh-01` and `home-lab-auth-hvh-02`.
- NetBox-facing changes follow repo seed/config first, repo consistency gate second, NetBox apply third.
- Legacy names `network-server`, `primary-hvh-01`, and `exec-hvh-01` remain migration aliases only; the retired Windows control alias is migration context only.
- `castle` remains namespace/context, not tenant.
- `home` is modeled as the NetBox tenant.
- `homelab` remains NetBox site for now; `lab` is carried as a context tag until the site naming model is intentionally revised.
- `auth` is carried as a context/stage tag.
- `windows_file_shares` owns the Windows SMB capability with `windows_file_shares_state: present|absent`.
- The managed Windows share is `F:\shares\public` exposed as `public`.
- Access is credentialed: local group `share_users`, user `mikec`, NTFS `Modify`, SMB `Change`.
- Anonymous access and `Everyone` share grants are intentionally omitted.
- `docs/plans/README.md` now requires stored plans to include required diagram sections or explicit `N/A` reasons.

## Apply / Verify / Undo

Apply:

```bash
ansible-playbook playbooks/deploy_ipam_netbox.yaml -i inventory/inventory.yaml --tags ipam_netbox_repo_consistency
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
  - NetBox contains `home-lab-auth-hvh-01` for the former network-server Windows control host
  - NetBox contains `home-lab-auth-hvh-02` for `HOM-LAB-HVH-02`
