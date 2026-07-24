# docker_pyenv_functions

Opt-in shell wrappers that run `pyenv` / `python` / `pip` inside a Docker
image (`pyenv-env:latest`), with versions persisted under `~/.pyenv-docker`.

## Lifecycle

| Control | Default |
|---|---|
| `docker_pyenv_functions_state` | `absent` |

This role is **not** wired into `deploy_development_nodes.yaml`. Native
Python tooling stays in `roles/python` (Homebrew pyenv, pipx, helpers).

## Apply / Verify / Undo

- **Apply:** set `docker_pyenv_functions_state: present` on a host, include
  this role from a playbook, run it. Symlinks
  `~/.bashrc.d/docker-pyenv-functions.bash` → this role's `functions.bash`.
- **Verify:** `ls -la ~/.bashrc.d/docker-pyenv-functions.bash` and open a
  new bash shell; `type python` should show a function.
- **Undo:** set `docker_pyenv_functions_state: absent` and re-run, or remove
  the symlink manually.
- **Change class:** idempotent config (symlink only). Does not build the
  `pyenv-env` image.

## Conflict warning

When present, these functions **shadow** bare `python` / `python3` / `pip` /
`pyenv` in interactive bash. Prefer project `.venv` + `bin/codex-env` for
repo work. Do not enable this role alongside an expectation that bare
`python3` means native pyenv.
