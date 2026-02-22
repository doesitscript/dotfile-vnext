# Docker-based pyenv proxy — transparent wrappers that send commands
# to the pyenv-env container. Installed Python versions persist in
# ~/.pyenv-docker across container runs.
#
# Managed by Ansible role: python

_PYENV_DOCKER_IMAGE="pyenv-env:latest"
_PYENV_DOCKER_VOLUME="$HOME/.pyenv-docker"

_pyenv_docker_run() {
  local tty_flag=""
  [ -t 0 ] && tty_flag="-it"

  docker run --rm $tty_flag \
    -v "${_PYENV_DOCKER_VOLUME}:/root/.pyenv" \
    -v "$(pwd):/workspace" \
    -w /workspace \
    "${_PYENV_DOCKER_IMAGE}" \
    "$*"
}

pyenv() {
  _pyenv_docker_run "pyenv $*"
}

python() {
  _pyenv_docker_run "eval \"\$(pyenv init -)\" && python $*"
}

python3() {
  _pyenv_docker_run "eval \"\$(pyenv init -)\" && python3 $*"
}

pip() {
  _pyenv_docker_run "eval \"\$(pyenv init -)\" && pip $*"
}

pip3() {
  _pyenv_docker_run "eval \"\$(pyenv init -)\" && pip3 $*"
}
