# windows_artifact_cache

Reusable Windows role for **hot ↔ cold/shared** large-file ladders.

Callers supply artifact contracts (`id`, `hot_path`, `cold_paths`). This role
hydrates the hot path from the first existing cold candidate, optionally seeds
cold from hot after a download/build, or offloads hot → cold and removes hot.

**`cold_paths` order (shared with reclaim):** when
`hyperv_ubuntu_vm_cold_data_root` is set, list COLD-DATA-HOST first, then shared
UNC. Seed and offload write to `cold_paths[0]`; hydrate tries each until one
exists.

## Use for

- Cloud image archives (`.tar.gz`) and unpacked reusable bases (`.vhd`)
- Vendor ISOs and remastered installer ISOs on a shared Hyper-V cache
- Any durable multi-GB file that should live on cheaper storage until `present`

## Do not use for

- HTTP(S) download itself — use `windows_artifact_download` or `win_get_url`
- Live guest disks that must stay hot (running VM VHDX)
- VM `absent` teardown — offload is a separate operator action

## Lifecycle

```yaml
windows_artifact_cache_state: present | absent
```

| State | Behavior |
| --- | --- |
| `present` | If hot missing → copy from first existing `cold_paths` entry. If `seed_cold` and hot exists → copy to `cold_paths[0]` when missing (or always when `seed_overwrite`) |
| `absent` | Copy hot → `cold_paths[0]`, verify size, remove hot when `remove_hot_on_absent` |

Results land in `windows_artifact_cache_results[<id>]` with `source`
(`hot_already` \| `cold` \| `missing`), `hot_exists`, `seeded`, etc.

## Example — hydrate before download

```yaml
- name: Hydrate cloud image archive from shared/cold cache
  ansible.builtin.include_role:
    name: windows_artifact_cache
  vars:
    windows_artifact_cache_state: present
    windows_artifact_cache_items:
      - id: ubuntu-24.04-azure-archive
        hot_path: 'C:\ProgramData\Ansible\hyperv_ubuntu_vm\vm\ubuntu-….tar.gz'
        cold_paths:
          - 'H:\COLD-DATA-HOST\hyperv-cache\ubuntu-cloud-images\ubuntu-….tar.gz'
          - '\\HOM-LAB-HVH-02\public\hyperv-cache\ubuntu-cloud-images\ubuntu-….tar.gz'
        seed_cold: true

- name: Download only when cache miss
  ansible.windows.win_get_url:
    url: "{{ cloud_image_url }}"
    dest: "{{ hot_archive_path }}"
    force: false
  when: >-
    not (
      (windows_artifact_cache_results['ubuntu-24.04-azure-archive'].hot_exists
       | default(false))
    )
```

## Example — offload playbook

```yaml
- name: Offload large rebuild bases to cold storage
  hosts: windows_hyperv_hosts
  roles:
    - role: windows_artifact_cache
      vars:
        windows_artifact_cache_state: absent
        windows_artifact_cache_items: "{{ windows_artifact_cache_offload_items }}"
```

## Occasional reclaim job

To regain hot disk without tearing down VMs, run the reclaim playbook. It
discovers the same rebuild-base classes that `present` hydrates, then either
previews or offloads them:

```bash
# Preview candidates + sizes (no deletes)
ansible-playbook playbooks/windows_artifact_cache_reclaim.yaml \
  -i inventory/inventory.yaml --limit HOM-LAB-HVH-02

# Apply: copy to cold (COLD-DATA-HOST when set, else shared UNC), remove hot
ansible-playbook playbooks/windows_artifact_cache_reclaim.yaml \
  -i inventory/inventory.yaml --limit HOM-LAB-HVH-02 \
  -e windows_artifact_cache_reclaim_mode=apply
```

Non-lifecycle verify (explicit item list only — never VM present):

```bash
ansible-playbook playbooks/windows_artifact_cache_verify.yaml \
  -i inventory/inventory.yaml --limit HOM-LAB-HVH-02 \
  -e windows_artifact_cache_verify_mode=hydrate \
  -e @roles/hyperv_ubuntu_vm/files/examples/windows_artifact_cache_offload_items.example.yml
```

Profiles (default): `hyperv_ubuntu_rebuild_bases` only.
Opt in to `windows_pinned_installers` or `hyperv_gpu_p_payload` only after those
product roles hydrate via this cache. Live guest `.vhdx` and `.VMRS` are never
targeted. Remastered ISO reclaim requires `{vm_dir}-autoinstall.iso` naming
(legacy scrap names are skipped). Product hydrate may still list a legacy
basename via `hyperv_ubuntu_vm_legacy_hyperv_name` for mid-migration cold objects.

## Apply / Verify / Undo / Change class

- **Apply:** `include_role` with `present` before product create; `absent` via
  companion offload playbook when reclaiming hot disk
- **Verify:** `windows_artifact_cache_results[<id>].hot_exists` / `offloaded`
- **Undo:** re-run `present` to hydrate; downloads remain last resort
- **Change class:** idempotent config (safe re-run)

## Related

- Sibling download role: `windows_artifact_download`
- First consumers: `hyperv_ubuntu_vm` (Azure archive + unpacked VHD + remastered ISO)
- HRL: `q-and-a/ansible/hyperv-cloud-image-hot-cold-cache-ladder.md`
