# Scheduled Task Verification Role

Verifies scheduled task exists on server-225 and brings stacks up after reboot.

## Purpose

- Checks if scheduled task exists (autostart-ai-stack)
- Verifies task is enabled
- Verifies task has boot trigger configured
- Ensures reboot survivability for server-225 stacks

## Usage

This role is automatically included in `verify_fabric.yaml` playbook for server-225 Windows host.

