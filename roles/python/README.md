python
======

Installs pyenv, pyenv-virtualenv, pipx, python2, python3, and poetry. Also adds a number of helpful aliases and functions for developing in python.

Use the `mkvenv` script for bootstrapping new virtualenvs.

On macOS, the role installs the requested `pyenv_global_versions` and then sets
`pyenv global` to match the inventory order. `mac-dev` currently pins only
`3.14.6`.

## Python Tooling Patterns

This role is authoritative for Python tooling decisions in this repository.

### When to Use Each Tool

| Tool | Use For | Managed By |
|---|---|---|
| **pip + venv** | Project-specific dependencies (MCP servers, local tools) | Individual roles |
| **pipx** | Global CLI tools (poetry, virtualenv) | This role (`pipx_packages`) |
| **poetry** | Python packaging projects (when needed) | Installed via pipx |

### Tools Evaluated but NOT Adopted

- **uv**: Evaluated for NetBox MCP server but rejected to maintain pattern consistency with existing `pip/venv` approach and avoid redundancy with `poetry`. See [`docs/python-dependency-patterns.md`](../../docs/python-dependency-patterns.md) for full rationale and decision framework.

### Pattern Examples

- **pip/venv pattern**: [`roles/mcp_servers/ansible-mcp/tasks/mac.yml`](../mcp_servers/ansible-mcp/tasks/mac.yml)
- **pipx global tools**: [`roles/python/defaults/main.yml`](defaults/main.yml) - see `pipx_packages`

### See Also

For comprehensive Python dependency management guidance, decision framework, and historical context, see [`docs/python-dependency-patterns.md`](../../docs/python-dependency-patterns.md).

## Notes

* Bash shell init should set up `pyenv` and `pyenv-virtualenv` in your profile.

# installs to $(brew --prefix)/opt/python

# Optional python 3 
https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#from-source

Confirming your installation
Whatever method of installing Ansible you chose, you can test that it is installed correctly with a ping command:

$ ansible all -m ping --ask-pass

# See installed versions 

❯ echo $(pyenv root)/versions
/Users/joshuacastillo/.pyenv/versions

# or 

❯ pyenv version
system (set by /Users/joshuacastillo/.pyenv/version)
3.9.6 (set by /Users/joshuacastillo/.pyenv/version)
3.9.5 (set by /Users/joshuacastillo/.pyenv/version)
3.9.0 (set by /Users/joshuacastillo/.pyenv/version)

# install a new venv 
```
pyenv virtualenv 2.7.10 my-virtual-env-2.7.10
```


# Activate virtualenv
Some external tools (e.g. jedi) might require you to activate the virtualenv and conda environments.

If eval "$(pyenv virtualenv-init -)" is configured in your shell, pyenv-virtualenv will automatically activate/deactivate virtualenvs on entering/leaving directories which contain a .python-version file that contains the name of a valid virtual environment as shown in the output of pyenv virtualenvs (e.g., venv34 or 3.4.3/envs/venv34 in example above) . .python-version files are used by pyenv to denote local Python versions and can be created and deleted with the pyenv local command.

You can also activate and deactivate a pyenv virtualenv manually:

pyenv activate <name>
pyenv deactivate

Special environment variables
You can set certain environment variables to control pyenv-virtualenv.

PYENV_VIRTUALENV_CACHE_PATH, if set, specifies a directory to use for caching downloaded package files.
VIRTUALENV_VERSION, if set, forces pyenv-virtualenv to install the desired version of virtualenv. If virtualenv has not been installed, pyenv-virtualenv will try to install the given version of virtualenv.
GET_PIP, if set and venv is preferred over virtualenv, use get_pip.py from the specified location.
GET_PIP_URL, if set and venv is preferred over virtualenv, download get_pip.py from the specified URL.
PIP_VERSION, if set and venv is preferred over virtualenv, install the specified version of pip.
PYENV_VIRTUALENV_VERBOSE_ACTIVATE, if set, shows some verbose outputs on activation and deactivation

# Removing a python version manually
rm -rf "~/.pyenv/versions/X.Y.Z"
Where "X.Y.Z" is the version that you want to remove. To list installed versions:

pyenv versions

# Setup global
pyenv global 3.4.0
