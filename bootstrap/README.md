# Bootstrap

Bootstrap prepares Windows nodes (facts, host_vars, WSL, Ansible) and runs the local bootstrap playbook.

## Commands

| Command | Explanation |
|---------|-------------|
| `.\bin\bootstrap-local.ps1` | Full bootstrap from Windows (Admin): detect node, collect facts, write host_vars, chain to Ansible. |
| `.\bin\bootstrap-local.ps1 -FactsOnly` | Refresh `facts\<node>.json` only; no host_vars or Ansible. |
| `./bin/fz bootstrap --limit server-225-win` | Local bootstrap from WSL: runs the local playbook (SSH, controller key, vault). Use when already in WSL on the target. |
| `./bin/bootstrap-local.sh` | WSL-side script (SSH, sudoers). Usually run by bootstrap-ansible-local.ps1; or run after host_vars exist. |

See repo root `README.md` for full command reference and vault setup.