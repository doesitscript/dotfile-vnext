# Ansible Docker wrapper functions
# Managed by Ansible role: ansible_dev_tools
#
# Tools that can't compile natively on macOS 12 (onigurumacffi, etc.)
# are wrapped here so they run inside containers instead.
# The current directory is bind-mounted as /workspace; "$@" passes
# all flags/args through so the function behaves like the real CLI.
#
# ansible-lint and ansible-builder install fine via pipx and are NOT
# wrapped here -- a Docker function would shadow the native binary
# with an older version from a stale image.

ansible-navigator() {
  docker run --rm -it \
    -v "$(pwd):/workspace" \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -w /workspace \
    ghcr.io/ansible/community-ansible-dev-tools:latest \
    ansible-navigator "$@"
}
