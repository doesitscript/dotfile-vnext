# Docker Runtime Verification Role

Verifies Docker runtime location matches contract (Linux VM vs Windows).

## Purpose

- Checks if Docker is running in the Linux VM when contract specifies the Linux VM path
- Checks if Docker is running on Windows when contract specifies Windows Docker Engine
- Verifies Windows Docker Engine is disabled when the Linux VM path is chosen
- Ensures runtime matches contract expectations

## Usage

This role is automatically included in `verify_fabric.yaml` playbook for all hosts.
