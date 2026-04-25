# role_template

Generic Ansible role scaffold. Copy this directory to create a new role.

## Usage

```bash
cp -r roles/common/role_template roles/<new_role_name>
```

Then customise:

1. **README.md** – Describe what the role installs / configures.
2. **defaults/main.yml** – Add role-specific default variables.
3. **tasks/main.yml** – Cross-platform dispatcher (already wired).
4. **tasks/mac.yml / ubuntu.yml / windows.yml** – Platform-specific tasks.
5. **templates/** – Jinja2 config-file templates.
6. **files/** – Static files to link or copy.
7. **handlers/main.yml** – Service restarts or other handler actions.
8. **<role_name>.bash** – Shell aliases / env vars (sourced via `~/.bashrc.d/`).

## Naming Reminder

Name new roles by capability, not by operating system. Keep the OS split inside
`tasks/main.yml` unless the role is an explicit narrow exception already
accepted by the repo.

## Composition Reminder

If the work really spans multiple distinct capabilities, prefer composing
multiple roles in a playbook with meaningful tags instead of turning a new role
into a wrapper for other roles by default.

## Structure

```
role_template/
├── README.md
├── defaults/
│   └── main.yml
├── files/
├── handlers/
│   └── main.yml
├── tasks/
│   ├── main.yml
│   ├── mac.yml
│   ├── ubuntu.yml
│   └── windows.yml
└── templates/
```
