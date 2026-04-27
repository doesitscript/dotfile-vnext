# server_225/gpu_driver_validation

Legacy compatibility wrapper for Server-225 GPU driver validation.

This role delegates to `common/gpu_driver_validation` and uses the `gpu`
value from `inventory/group_vars/server_225/main.yml` for expected model reporting.

The capability-oriented entry point is now:

```bash
ansible-playbook playbooks/validate_windows_gpu_hosts.yaml -i inventory/inventory.yaml
```

Purpose:
- validate that NVIDIA driver tooling is present
- report driver and GPU status when available
- fail clearly when `nvidia-smi` is not available

This role validates only. It does not install or update GPU drivers.
