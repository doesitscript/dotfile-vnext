# Bootstrap

Bootstrap prepares each node so Ansible can manage it (and, for the Mac, so it can run Ansible against others).

## Entrypoints by node

| Node | Where to run | Command |
|------|----------------|--------|
| **Server-225** (Windows + WSL) | On the Windows host (Administrator) | `.\bin\bootstrap-local.cmd` |
| **Mac (control node)** | On the Mac | `./bin/fz bootstrap --limit mac-dev` (see main [README](../../README.md#bootstrap-mac-control-node) for full steps) |
| **Network server** | On the network server Windows host | `.\bin\bootstrap-local.cmd` (same as server-225) |
| **Dev-3090** | On the dev-3090 Windows host | `.\bin\bootstrap-local.cmd` |

## Order

1. Server-225: run `bootstrap-local.cmd` on that machine.
2. Mac: clone repo on Mac, add `.vault_pass`, install collections, run `./bin/fz bootstrap --limit mac-dev`.
3. Network server (and dev-3090 if used): run `bootstrap-local.cmd` on each, then push or sync repo so the Mac has their host_vars.

After that, from the Mac: `./bin/fz deploy main --limit server-225-wsl`, `./bin/fz deploy network --limit network-server-win`, etc.

## Local bootstrap (Windows nodes)

- `bin/bootstrap-local.cmd` → `bin/bootstrap-local.ps1` → `bin/bootstrap-ansible-local.ps1` → WSL `bin/bootstrap-local.sh` → `./bin/fz bootstrap --limit server-225-win`.
- See main README and `source_of_truth_bootstrap.md` for details.
