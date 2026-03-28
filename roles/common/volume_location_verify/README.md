# Volume Location Verification Role

Best-effort checks that volumes are not on OS disk.

## Purpose

- Verifies data volumes are on non-OS disk (Windows: checks drive letters)
- Best-effort check for Linux (checks mount points)
- Ensures persistent data is not on OS disk per contract

## Usage

This role is automatically included in `verify_fabric.yaml` playbook for all hosts.
