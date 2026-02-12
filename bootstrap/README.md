# Bootstrap

Bootstrap prepares Windows nodes (facts, host_vars, WSL, Ansible) and runs the local bootstrap playbook. The default is a **hands-free chain**: run the first script and it calls the next until the full setup is done.

## Commands (with options)

| Command | Explanation |
|---------|-------------|
| `.\bin\bootstrap-local.cmd` | **Entry point.** Runs bootstrap-local.ps1 (full chain). No options; use the .ps1 directly to control chaining. |
| `.\bin\bootstrap-local.ps1` | Full bootstrap: facts, host_vars, then chains to bootstrap-ansible-local.ps1. |
| `.\bin\bootstrap-local.ps1 -FactsOnly` | Facts only: write `facts\<node>.json` and exit. No host_vars, no next script. |
| `.\bin\bootstrap-local.ps1 -RunAll:$false` | Facts + host_vars only; do not call bootstrap-ansible-local.ps1. |
| `.\bin\bootstrap-ansible-local.ps1` | WSL distro setup, then runs bootstrap-local.sh in WSL, then runs `./bin/fz bootstrap --limit server-225-win`. |
| `.\bin\bootstrap-ansible-local.ps1 -RunWslBootstrap:$false` | Skip running bootstrap-local.sh in WSL; only run the final fz bootstrap step. |
| `.\bin\bootstrap-ansible-local.ps1 -RunFzBootstrap:$false` | Run bootstrap-local.sh in WSL but do not run fz; stop after SSH/sudoers. |
| `./bin/bootstrap-local.sh` | WSL: SSH + sudoers; then by default runs `./bin/fz bootstrap --limit server-225-win`. |
| `./bin/bootstrap-local.sh --skip-fz-bootstrap` | WSL: SSH + sudoers only; do not run fz. Use to re-run just this step. |
| `./bin/fz bootstrap --limit server-225-win` | Local playbook from WSL (controller key, vault, etc.). Use when already in WSL. |

See repo root `README.md` for full command reference and vault setup.