# GPU Verification Role

Verifies GPU validation checks pass on GPU nodes.

## Purpose

- Checks if nvidia-smi is available
- Retrieves GPU information (name, memory, driver version)
- Gets GPU temperature and utilization
- Verifies GPU driver is installed and working
- Validates GPU matches contract expectations

## Usage

This role is automatically included in `verify_fabric.yaml` playbook for GPU nodes (server-225, dev-3090).

