# Windows OpenSSH Legacy Cleanup Exception

## Purpose

This note documents a very specific exception:

using direct remote commands to remove or unwind legacy Windows OpenSSH / WSL SSH state when the original setup was not written idempotently enough to reverse cleanly through the existing Ansible roles.

## Scope

This is only for:
- legacy cleanup on Windows hosts
- teardown or rollback work that is clearly one-off
- situations where the current Ansible code cannot honestly or safely express the uninstall path

This is not for:
- routine configuration
- normal install paths
- introducing new state
- replacing Ansible roles with ad-hoc remote commands

## Current intent

If this exception is used, the pattern should be:

1. User explicitly approves the cleanup.
2. Remote commands remove the broken or legacy pieces.
3. The stripped-down state is verified.
4. Ansible is used again to converge the desired final state.

## Why this exists

Some older Windows/WSL/OpenSSH experiments in this repo were exploratory and not fully reversible through clean idempotent code. In those cases, pretending the teardown is already modeled well in Ansible is less honest than documenting a one-off cleanup exception.

## Future-agent boundary

Future agents should not treat this file as blanket permission to run remote cleanup commands.

The correct interpretation is:
- this is a narrow exception
- it requires user confirmation
- it should be documented before or while it is used
- it should not silently become the new default automation path

## Preferred steady-state direction

After cleanup, the repo should return to:
- Ansible-managed installs
- idempotent verification where practical
- bootstrap/semi-manual work isolated from normal operations
