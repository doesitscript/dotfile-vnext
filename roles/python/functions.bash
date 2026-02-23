# Docker-based pyenv — runs pyenv/python/pip inside a container.
# Installed versions persist in ~/.pyenv-docker across runs.
pyenv() {
	docker run --rm -it \
		-v "${HOME}/.pyenv-docker:/root/.pyenv" \
		-v "$(pwd):/workspace" \
		-w /workspace \
		pyenv-env:latest \
		"pyenv $*"
}

python() {
	docker run --rm -it \
		-v "${HOME}/.pyenv-docker:/root/.pyenv" \
		-v "$(pwd):/workspace" \
		-w /workspace \
		pyenv-env:latest \
		"eval \"\$(pyenv init --path)\" && eval \"\$(pyenv init -)\" && python $*"
}

python3() { python "$@"; }

pip() {
	docker run --rm -it \
		-v "${HOME}/.pyenv-docker:/root/.pyenv" \
		-v "$(pwd):/workspace" \
		-w /workspace \
		pyenv-env:latest \
		"eval \"\$(pyenv init --path)\" && eval \"\$(pyenv init -)\" && pip $*"
}

pip3() { pip "$@"; }

# Remove python compiled byte-code in either current directory or in a
# list of specified directories.
pyclean() {
	PYCLEAN_PLACES=${*:-'.'}
	find ${PYCLEAN_PLACES} -type f -name "*.py[co]" -delete
	find ${PYCLEAN_PLACES} -type d -name "__pycache__" -delete
}

# Build docs in watch mode.
sphinxwatch() {
	sphinx-autobuild --open-browser docs docs/_build
}

# Generate fake data, e.g. `fake name`, `fake url`, `fake email`
fake() {
	result=$(PYTHONIOENCODING=UTF-8 faker -s="" $1)
	echo "$result"
	echo "$result" | pbcopy
}

pyup() {
	if [[ -f setup.py ]]; then
		printf "Found setup.py...\n"
		pip install -U -e '.[dev]'
	fi
	if [[ -f requirements-dev.txt ]]; then
		printf "Found requirements-dev.txt...\n"
		pip install -U -r requirements-dev.txt
	elif [[ -f requirements.txt ]]; then
		printf "Found requirements.txt...\n"
		pip install -U -r requirements.txt
	fi
}
