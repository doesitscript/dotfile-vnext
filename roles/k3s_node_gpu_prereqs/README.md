# k3s_node_gpu_prereqs

Validates that a K3s node is ready to schedule NVIDIA GPU workloads.

This role is intentionally a gate, not a driver installer. It checks
`nvidia-smi` and Kubernetes node capacity for `nvidia.com/gpu` before later AI
runtime roles attempt to schedule pods.

## Apply

```bash
ansible-playbook playbooks/deploy_gpu_infrastructure.yaml -i inventory/inventory.yaml
```

## Verify

The role fails with probe output if the node does not expose NVIDIA userspace or
Kubernetes GPU capacity.
