# Docker-based pyenv — runs pyenv/python/pip inside a container.
# Installed versions persist in ~/.pyenv-docker across runs.
#
# Opt-in only: roles/docker_pyenv_functions (default state: absent).
# When enabled, this file is symlinked to ~/.bashrc.d/docker-pyenv-functions.bash.
#
# Uses -i when stdin is not a TTY (pipes/scripts); -it when interactive.

pyenv() {
	local flags=(-i)
	[[ -t 0 ]] && flags=(-it)
	docker run --rm "${flags[@]}" \
		-v "${HOME}/.pyenv-docker:/root/.pyenv" \
		-v "$(pwd):/workspace" \
		-w /workspace \
		pyenv-env:latest \
		bash -lc 'pyenv "$@"' _ "$@"
}

python() {
	local flags=(-i)
	[[ -t 0 ]] && flags=(-it)
	docker run --rm "${flags[@]}" \
		-v "${HOME}/.pyenv-docker:/root/.pyenv" \
		-v "$(pwd):/workspace" \
		-w /workspace \
		pyenv-env:latest \
		bash -lc 'eval "$(pyenv init --path)"; eval "$(pyenv init -)"; python "$@"' _ "$@"
}

python3() { python "$@"; }

pip() {
	local flags=(-i)
	[[ -t 0 ]] && flags=(-it)
	docker run --rm "${flags[@]}" \
		-v "${HOME}/.pyenv-docker:/root/.pyenv" \
		-v "$(pwd):/workspace" \
		-w /workspace \
		pyenv-env:latest \
		bash -lc 'eval "$(pyenv init --path)"; eval "$(pyenv init -)"; pip "$@"' _ "$@"
}

pip3() { pip "$@"; }
