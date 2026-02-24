# Docker Wrapper Functions for Ansible CLI Tools

## Why

On macOS 12 (Monterey), certain Ansible tools fail to install natively because
the `onigurumacffi` C extension cannot compile (`oniguruma.h` not found).
Affected packages: `ansible-navigator` and `ansible-dev-tools`.

Tools that **do** install fine via pipx (`ansible`, `ansible-lint`,
`ansible-builder`) are left as native binaries -- wrapping them in Docker would
shadow the up-to-date pipx binary with a potentially stale image version.

## Which tools are wrapped

Only tools that cannot compile on macOS 12 get Docker wrappers. Currently:

- **`ansible-navigator`** -- uses `ghcr.io/ansible/community-ansible-dev-tools:latest`
  (official Ansible image, mounts Docker socket so navigator can launch EEs).

## How the function acts like a native command

The wrapper lives in `roles/ansible_dev_tools/files/ansible-functions.bash`:

```bash
ansible-navigator() {
  docker run --rm -it \
    -v "$(pwd):/workspace" \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -w /workspace \
    ghcr.io/ansible/community-ansible-dev-tools:latest \
    ansible-navigator "$@"
}
```

Key points:

- **`"$@"`** forwards every argument the caller passes (`--help`, `--version`,
  file paths, flags) directly to the container, so it behaves identically to a
  locally installed binary.
- **`-v "$(pwd):/workspace"` + `-w /workspace`** bind-mounts the current
  directory so the tool sees the same files it would on the host.
- **`-v /var/run/docker.sock:...`** gives navigator access to Docker so it can
  launch execution environments from inside the container.
- **`--rm`** removes the container after exit so nothing accumulates.
- **`-it`** allocates a TTY for colored output and allows Ctrl-C.
- **Bash functions take precedence over binaries in `$PATH`**, so the function
  wins even if a native binary exists.

## How the function gets sourced into every terminal

The `common/shell_config` role sets up a modular `~/.bashrc.d/` directory:

1. `.bash_profile` sources `.bashrc` (so login shells get everything).
2. `.bashrc` loops over `~/.bashrc.d/*.bash` and sources each file.
3. The `ansible_dev_tools` role symlinks
   `roles/ansible_dev_tools/files/ansible-functions.bash` into
   `~/.bashrc.d/ansible-functions.bash`.

After a shell restart (or Cursor relaunch), the function is automatically
available.

## macOS only

The symlink task is gated with `when: ansible_facts['system'] == "Darwin"`.
Linux and WSL can install all tools natively via pipx or apt without the
compilation issues that forced this workaround on macOS 12.

## Lesson learned: don't wrap what pipx can handle

An earlier iteration also wrapped `ansible-lint` in Docker using
`cytopia/ansible-lint`. That image was stuck at 6.11.0 while the pipx-installed
version was 26.1.1 -- the function silently downgraded the tool. Only wrap
tools that genuinely cannot install natively.
