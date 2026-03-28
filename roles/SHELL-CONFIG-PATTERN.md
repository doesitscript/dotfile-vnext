# Shell Config Pattern

## Origin

This pattern is adapted from [Zach Holman's dotfiles](https://github.com/holman/dotfiles).
The original used zsh: a single loader in `~/.zshrc` globbed `$ZSH/**/*.zsh` and sourced
every `.zsh` file it found — one per topic, no manual imports.

This project translates that to bash with Ansible managing the deployment.

---

## The contract

Any role that needs to add something to the shell environment does one thing:

> Place a static `*.bash` file at `roles/<rolename>/files/bashrc.d/<name>.bash`

That is the entire interface. No deploy task needed in the role. The `shell_config`
role discovers and deploys all such files centrally.

---

## How it works

Three pieces, all managed by `roles/common/shell_config`:

### 1. The directory

`~/.bashrc.d/` — all shell config files land here.

### 2. The loader (in `~/.bashrc`)

```bash
# Source modular shell configs from .bashrc.d
if [ -d ~/.bashrc.d ]; then
  for file in ~/.bashrc.d/*.bash; do
    [ -f "$file" ] && source "$file"
  done
fi
```

Files are sourced in filename-sorted order. Name files accordingly — `path.bash` sorts
before `python-env.bash`, so PATH is set before anything that depends on it.

### 3. The login shell chain (in `~/.bash_profile`)

```bash
if [ -f ~/.bashrc ]; then
  source ~/.bashrc
fi
```

This means login shells (including new terminal windows and shells spawned by tools like
Cursor and MCP servers at launch) source `.bashrc.d` automatically.

### 4. The central deploy (in `shell_config/tasks/unix.yml`)

```yaml
- name: Find bashrc.d files contributed by roles
  ansible.builtin.find:
    paths: "{{ playbook_dir }}/roles"
    patterns: "*.bash"
    recurse: true
    file_type: file
  register: _shell_config_bashrc_contributions
  delegate_to: localhost
  become: false

- name: Deploy contributed bashrc.d files to ~/.bashrc.d/
  ansible.builtin.copy:
    src: "{{ item.path }}"
    dest: "{{ ansible_env.HOME }}/.bashrc.d/{{ item.path | basename }}"
    mode: "0644"
  loop: "{{ _shell_config_bashrc_contributions.files }}"
  when: "'files/bashrc.d' in item.path"
```

`delegate_to: localhost` is required — the `find` runs on the control machine (where the
role files live), and `copy` then pushes each file to the target host.

---

## How to add shell config in a new role

1. Create `roles/<your-role>/files/bashrc.d/<name>.bash`
2. Put your exports, aliases, or functions in it
3. Done — `shell_config` deploys it on next run

Example — `roles/my_tool/files/bashrc.d/my_tool.bash`:

```bash
export MY_TOOL_HOME=/usr/local/my_tool
export PATH="$MY_TOOL_HOME/bin:$PATH"
```

No task file changes. No `templates/`. No `meta/` updates. Just the file.

---

## Current consumers

| File | Role | Purpose |
|---|---|---|
| `path.bash` | `common/shell_config` | PATH configuration (templated — deployed directly by role) |
| `aliases.bash` | `common/shell_config` | Common shell aliases (templated — deployed directly by role) |
| `winrm_env.bash` | `ansible_dev_tools` | WinRM macOS env vars — first consumer of the central convention |

---

## Known gaps — not yet migrated

The following `.bash` files exist in role directories but predate this convention and are
NOT yet deployed. They sit in role roots rather than `files/bashrc.d/`. They are
documented here as a known gap; no attempt is being made to migrate them now.

| File | Location |
|---|---|
| `functions.bash`, `env.bash`, `aliases.bash` | `roles/python/` |
| `tmux.bash` | `roles/common/tmux/`, `roles/tmux/` |
| `activate_nvm.bash` | `roles/common/node/` |
| `git.bash`, `aliases.bash` | `roles/git/` |

To migrate any of these: move the file to `roles/<rolename>/files/bashrc.d/<name>.bash`
and remove any existing per-role deploy task for it.

---

## Relationship to `.envrc`

`.envrc` (direnv) only activates when the shell's working directory is inside the project.
Variables that need to be available globally — to GUI-launched editors, MCP servers, or
shells opened outside the project — belong in `~/.bashrc.d/`, not `.envrc`.

Once a variable has been moved into a `files/bashrc.d/` file and the role has been run,
remove the corresponding line from `.envrc`.
