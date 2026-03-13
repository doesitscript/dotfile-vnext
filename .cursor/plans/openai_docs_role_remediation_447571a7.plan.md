---
name: OpenAI docs role remediation
overview: Replace command/shell usage and stdout-based change detection in roles/mcp_servers/openai_docs with idempotent modules, correct nvm context, brew --prefix for macOS path, and task timeouts.
todos: []
isProject: false
---

# openai_docs Role Remediation

## Researched

- **community.general.npm**: Idempotent; `name`, `global: true`, `state: present`; reports `changed` natively; accepts `executable` parameter for nvm-managed npm.
- **community.general.homebrew**: Idempotent; `state: present`; reports `changed` natively. Already used correctly.
- **brew --prefix `<formula>`**: Returns the formula installation prefix (e.g. `/opt/homebrew/opt/codex`); binary is at `<prefix>/bin/codex`. This is the documented, supported way to get a Homebrew formula path. No Ansible module wraps it, so `ansible.builtin.command` with `changed_when: false` is the correct and only option.
- **Ansible task timeout**: `timeout:` keyword on any task (seconds); task is killed and failed if exceeded.
- **101-ansible--canonical-coding.md**: "Use specific modules instead of generic command or shell"; "Prefer Ansible built-in modules to leverage idempotency"; "Always use changed_when with command and shell".
- **Project nvm**: `roles/common/node` installs nvm and Node `node_default_version: "20"`. npm global packages live at `~/.nvm/versions/node/20/bin/`.

---

## Problems in Current Code

1. **Ubuntu install**: `ansible.builtin.command: npm i -g @openai/codex` — not idempotent; change detection via stdout parsing (`'added' in ...`) is fragile.
2. **Ubuntu nvm context missing**: `community.general.npm` without `executable` invokes system npm — which may not exist, or installs into the wrong node version.
3. **Both OS — path resolution**: `ansible.builtin.command: which codex` with `failed_when: false` — `which` is not a module; `failed_when: false` silently masks failure; if the binary isn't found, `set_fact` is silently skipped and the MCP entry ends up with an empty `command`.
4. **Both OS — no timeout**: Long installs can hang the play indefinitely.
5. **Mac install**: `community.general.homebrew` is correct but has no timeout.

---

## Rules for command/shell Use in This Role

- **Prohibited**: `ansible.builtin.command` or `shell` for package installs (module exists: `community.general.npm`).
- **Prohibited**: `which` or any equivalent for path resolution; it is not a module and masks failure with `failed_when: false`.
- **Prohibited**: `changed_when` based on stdout/stderr content for installs.
- **Acceptable**: `ansible.builtin.command: brew --prefix codex` for macOS path resolution. `brew --prefix` is a deterministic, single-line config query; no Ansible module provides this. Requires `changed_when: false`. Stdout is used as a value (path string), not for change inference.
- **Acceptable**: `failed_when: false` is **never** used. If the path query fails, the task must fail.

---

## Implementation

### mac.yml

**Install** (no change needed except timeout):

```yaml
- name: Install Codex app via Homebrew (macOS)
  community.general.homebrew:
    name: codex
    state: present
  timeout: 120
```

**Path resolution** — use `brew --prefix codex`:

```yaml
- name: Get Codex install prefix from Homebrew (macOS)
  ansible.builtin.command: brew --prefix codex
  register: _codex_brew_prefix
  changed_when: false

- name: Set Codex command path for mcp.json (macOS)
  ansible.builtin.set_fact:
    openai_docs_codex_command: "{{ _codex_brew_prefix.stdout | trim }}/bin/codex"
```

- No `failed_when: false`. If codex is not installed, `brew --prefix codex` exits non-zero and the task fails visibly.
- `changed_when: false` because this is a read-only config query.
- No stat needed — `brew --prefix` is the authoritative path source for Homebrew installs.

---

### ubuntu.yml

**Install** — replace `command` with `community.general.npm` + nvm `executable`:

```yaml
- name: Install Codex app via npm (Ubuntu)
  community.general.npm:
    name: "@openai/codex"
    global: true
    state: present
    executable: "{{ dotfiles_user_home }}/.nvm/versions/node/{{ node_default_version }}/bin/npm"
  timeout: 300
```

- `executable` points to the nvm-managed npm; without it the module uses system npm (wrong or absent).
- `node_default_version` must be available on the host; it is set in `roles/common/node/defaults/main.yml` as `"20"`. Document in openai_docs README that common/node must run first.
- Module handles idempotency; no `changed_when` needed.

**Path resolution** — stat on nvm bin path (primary) with fallback to system locations:

```yaml
- name: Stat Codex binary candidates (Ubuntu)
  ansible.builtin.stat:
    path: "{{ item }}"
  loop: "{{ openai_docs_codex_bin_candidates }}"
  register: _codex_stat_results

- name: Set Codex command path for mcp.json (Ubuntu)
  ansible.builtin.set_fact:
    openai_docs_codex_command: "{{ (_codex_stat_results.results | selectattr('stat.exists') | first).item }}"
```

- `openai_docs_codex_bin_candidates` defined in `defaults/main.yml` (see below).
- `selectattr('stat.exists') | first` picks the first path that actually exists.
- If nothing exists, `first` raises an error — task fails visibly (no silent masking).

---

### defaults/main.yml additions

```yaml
# Ordered list of candidate Codex binary paths (Ubuntu). First existing path wins.
# Primary: nvm-managed node. Fallbacks: system npm global bin.
openai_docs_codex_bin_candidates:
  - "{{ dotfiles_user_home }}/.nvm/versions/node/{{ node_default_version }}/bin/codex"
  - "/usr/local/bin/codex"
  - "/usr/bin/codex"

# node_default_version is inherited from roles/common/node; document as dependency.
node_default_version: "20"
```

---

## Files to Change


| File                                                    | Change                                                                                                                                                                |
| ------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `roles/mcp_servers/openai_docs/tasks/mac.yml`           | Add `timeout: 120` to homebrew task; replace `which`/set_fact with `brew --prefix codex` + `changed_when: false` + set_fact                                           |
| `roles/mcp_servers/openai_docs/tasks/ubuntu.yml`        | Replace `command: npm i -g` with `community.general.npm` + `executable` + `timeout: 300`; replace `which`/set_fact with stat loop on candidates + selectattr set_fact |
| `roles/mcp_servers/openai_docs/defaults/main.yml`       | Add `openai_docs_codex_bin_candidates` list; add `node_default_version: "20"` with comment                                                                            |
| `roles/mcp_servers/openai_docs/README.md`               | Document: common/node must run first (provides nvm + Node); macOS path via `brew --prefix`; Ubuntu path via stat on candidate list                                    |
| `roles/mcp_servers/openai_docs/meta/argument_specs.yml` | Add `openai_docs_codex_bin_candidates` and `node_default_version` options                                                                                             |


Lint and validate after every file edit.
