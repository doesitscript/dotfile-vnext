# K3s-02 Storage Upgrade Plan

**Created**: 2026-09-10  
**Status**: Immediate cleanup done, upgrade pending  
**Priority**: High - recurring issue without disk expansion

## Problem Statement

K3s node `hom-lab-ctl-k3s-02` hit disk pressure during Qwen3-Coder-30B-A3B AWQ deployment, causing pod evictions and preventing new deployments.

### Symptoms
- Pod evicted with "low on resource: ephemeral-storage"
- Node tainted with `node.kubernetes.io/disk-pressure`
- Image filesystem at 87% (threshold: 85%)
- vLLM pod stuck in Pending state

### Root Cause
**VM disk undersized for current + planned model workloads:**
- **Current disk**: 77GB total, 41GB used (54%)
- **Problem area**: `/var/lib/rancher` = 28GB
- **HF cache PVC**: 120Gi allocated (will grow with each model)
- **4 planned models**: ~82GB cached storage needed

## Immediate Fix (Completed 2026-09-10)

```bash
# Clean up old pods
kubectl delete pods -n vllm-runtime <old-pods>

# Prune unused images
sudo crictl rmi --prune

# Clean logs
sudo journalctl --vacuum-size=100M
```

**Result**: Freed enough space to deploy Qwen3-Coder-30B-A3B AWQ.

## Recommended Long-Term Solution

### Option C: Dedicated Data Disk (Recommended)

**Why**: Separates OS from data, easier to expand, matches K8s best practices.

#### Steps:
1. **Create new VHDX on HOM-LAB-HVH-02**
   - Size: 300-500GB
   - Type: Dynamic VHDX
   - Attach to `hom-lab-ctl-k3s-02` VM

2. **Partition and mount**
   ```bash
   # On k3s-02 VM
   sudo fdisk /dev/sdX  # Create partition
   sudo mkfs.ext4 /dev/sdX1
   sudo mkdir -p /mnt/k3s-data
   sudo mount /dev/sdX1 /mnt/k3s-data
   echo '/dev/sdX1 /mnt/k3s-data ext4 defaults 0 0' | sudo tee -a /etc/fstab
   ```

3. **Migrate K3s local-path storage**
   ```bash
   # Stop K3s
   sudo systemctl stop k3s
   
   # Move existing storage
   sudo mv /var/lib/rancher/k3s/storage /mnt/k3s-data/
   sudo ln -s /mnt/k3s-data/storage /var/lib/rancher/k3s/storage
   
   # Restart K3s
   sudo systemctl start k3s
   ```

4. **Update local-path provisioner config**
   - Edit ConfigMap to use `/mnt/k3s-data/storage` as base path
   - Restart provisioner deployment

### Alternative: Expand Root Disk

If adding a disk is complex, expand root to **200GB minimum**:

1. Expand VHDX in Hyper-V Manager
2. On VM: `sudo growpart /dev/sda 1`
3. Resize filesystem: `sudo resize2fs /dev/sda1`

## Storage Capacity Planning

### Current Model Footprint
| Model | Format | Size | Location |
|-------|--------|------|----------|
| Qwen3-Coder-30B-A3B | AWQ-4bit | 17GB | K3s PVC |
| Qwen3.6-35B-A3B | NVFP4 | 23GB | Planned |
| Devstral Small 2 | GGUF Q4 | 14GB | Planned |
| GLM-4.6 | GGUF Q4 | 28GB | Planned |
| **Total** | | **82GB** | |

### Headroom Requirements
- Container images (vLLM): ~8-10GB per version
- K3s system: ~5-10GB
- Logs and temp: ~10GB
- Growth buffer: 50-100GB

**Minimum recommended**: 200GB  
**Comfortable sizing**: 300-500GB

## Monitoring & Alerts

### Key Metrics to Watch
```bash
# Check node disk pressure
kubectl get nodes -o jsonpath='{.items[0].status.conditions[?(@.type=="DiskPressure")]}'

# Monitor storage usage
df -h /var/lib/rancher

# Check PVC usage
kubectl get pvc -A
```

### Recommended Alerts
- Alert when `/var/lib/rancher` > 75%
- Alert when K3s node shows DiskPressure=True
- Alert when PVC usage > 80%

## Related Documentation
- Model catalog: `inventory/group_vars/model_catalog/manifest.yml`
- vLLM role: `roles/k3s_vllm_runtime/`
- Model selection reasoning: `docs/brainstorming_designs/2026-09-10--5090-model-lane-evaluation/model-selection-reasoning.md`

## Next Actions
- [ ] Schedule disk expansion (this week per user)
- [ ] Update monitoring/alerting for disk usage
- [ ] Document final disk configuration in inventory
- [ ] Test deployment of remaining 3 models after expansion
