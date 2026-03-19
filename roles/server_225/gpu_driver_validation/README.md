# server_225/gpu_driver_validation

Node-specific GPU driver validation for Server-225.

This role delegates to `common/gpu_driver_validation` and uses the `gpu`
value from `inventory/group_vars/server_225.yaml` for expected model reporting.

Purpose:
- validate that NVIDIA driver tooling is present
- report driver and GPU status when available
- fail clearly when `nvidia-smi` is not available

This role validates only. It does not install or update GPU drivers.
