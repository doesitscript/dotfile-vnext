# k3s Storage Role

Sets up persistent volume infrastructure for the k3s cluster.

This role:

- Creates local storage mount points (D:\ai\data on Windows, /mnt/d/ai/data in WSL)
- Sets correct permissions for container runtimes
- Applies StorageClass manifests
- Applies PersistentVolume definitions
- Waits for storage controller readiness

## Variables

- `persistent_volume_path` – Host path for local volumes (default: /mnt/d/ai/data/k3s-volumes)
- `storageclass_name` – Name of StorageClass (default: local-storage)

## Tasks

1. `main.yml` – Full setup (create mounts, apply manifests)
2. `storage_class.yml` – Apply StorageClass and PV manifests

## Usage

```yaml
- include_role:
    name: k3s_storage
  vars:
    persistent_volume_path: "/mnt/d/ai/data/k3s-volumes"
```
