# Ansible Naming Conventions

## Source

- Collections Structure: https://docs.ansible.com/ansible/latest/dev_guide/developing_collections_structure.html
- Inventory Guide: https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html
- This project's ansible-coding-standards.mdc

## Hard Requirements (MUST)

### Role Names

- **Valid characters**: lowercase alphanumeric + underscore (`_`)
- **Must start with**: alphabetic character
- **No hyphens**: Roles cannot contain hyphens (causes issues with collections)
- **No numbers at start**: Must begin with a letter

**Examples:**
- ✅ `docker`, `ipam_netbox`, `common_node`, `hyperv_ubuntu_vm`
- ❌ `docker-role`, `ipam-netbox`, `1_role`, `_hidden`

### Variable Names

- **Valid characters**: lowercase alphanumeric + underscore
- **Must start with**: alphabetic or underscore character
- **No special characters**: No hyphens, dots, or other punctuation
- **ASCII only**: Variable names must be ASCII strings
- **Not Python keywords**: Cannot be `for`, `if`, `class`, etc.
- **No Jinja2 templating**: Variable names cannot contain `{{` or `{%`

**Role variable prefix requirement:**
- All role variables MUST be prefixed with `<role_name>_`
- Example: Role `ipam_netbox` → variables: `ipam_netbox_state`, `ipam_netbox_version`

**Internal variables:**
- Use double underscore prefix: `__internal_var`
- Signals "do not depend on this externally"

**Examples:**
- ✅ `my_var`, `user_name`, `db_password`, `ipam_netbox_api_url`
- ❌ `my-var`, `user.name`, `123var`, `class`, `{{var}}`

### Vault Variable Names

- **Prefix**: All vault variables must use `vault_` prefix
- **Role ownership**: Vault variables owned by a role follow `vault_<role_name>_<field>`
- **Examples:**
  - `vault_ipam_netbox_db_password`
  - `vault_ansible_ui_semaphore_admin_password`
  - `vault_server_225_win_password`

### Collection Names

**Namespace:**
- Lowercase letters, digits, underscores
- No hyphens

**Collection name:**
- Lowercase letters, digits, underscores
- No hyphens

**FQCN format:**
```
<namespace>.<collection>.<plugin_type>.<plugin_name>
```

**Examples:**
- `ansible.builtin.copy`
- `community.general.docker_container`
- `netbox.netbox.netbox_device`

### File Extensions

- **YAML files**: Must use `.yml` extension, NOT `.yaml`
- **Python files**: `.py`
- **Jinja2 templates**: `.j2` appended to target filename (e.g., `nginx.conf.j2`)

## Recommendations (SHOULD)

### Task Naming

- **All tasks must have names**: Use the `name` parameter
- **Start with uppercase**: Task names should start with capital letter
- **Imperative form**: "Install package", "Create user", "Start service"
- **Descriptive and specific**: Name should indicate what the task does
- **No loop variables in names**: They don't expand properly
- **Prefix with file identifier**: In sub-task files, prefix with file name for easier debugging

**Examples:**
```yaml
- name: Install Docker engine
  ansible.builtin.package:
    name: docker
    state: present

- name: Create application user
  ansible.builtin.user:
    name: appuser
    state: present
```

### Play Naming

- All plays must have names
- Do not use variables in play names (they don't expand properly)

### Playbook Naming

**Pattern:**
```
<action>_<resource>_<target>.yml
```

**Examples:**
- `deploy_ipam_netbox.yml`
- `deploy_development_nodes.yml`
- `troubleshoot_windows_remote_access.yml`
- `backup_databases.yml`

### Role Naming Patterns

**Capability-focused (preferred):**
```
<capability>
```

Examples:
- `docker` — Docker capability
- `speech_central` — Speech synthesis capability
- `ipam_netbox` — NetBox IPAM capability

**Avoid OS-specific suffixes:**
- ❌ `speech_central_mac`, `docker_ubuntu`
- ✅ `speech_central` with OS dispatch inside `tasks/main.yml`

**Component pattern:**
```
<component>_<subcomponent>
```

Examples:
- `hyperv_networking`
- `ipam_netbox`
- `automation_awx`

### Inventory Naming

**Group names:**
- Lowercase
- Underscores for multi-word names
- Descriptive of function or environment

**Examples:**
- `web_servers`
- `database_servers`
- `production`
- `staging`
- `k3s_cluster`

**Host names:**
- Lowercase
- Hyphens preferred for readability
- Should match actual hostnames when possible

**Examples:**
- `server-225-win`
- `server-225-ubuntu`
- `s225-dkr-01`

### Tag Naming

**Pattern:**
```
<role_name>
<role_name>_<sub_operation>
```

**Rules:**
- Prefix with role name
- Use underscores (not hyphens — tags are Python identifiers)
- Every tag must be usable standalone
- Never create destructive tags without state variables

**Examples:**
- `ipam_netbox` — entire role
- `ipam_netbox_present` — deploy path
- `ipam_netbox_absent` — remove path
- `ipam_netbox_smoke_test` — health check
- `ipam_netbox_seed_tags` — seed NetBox tags

### Variable Naming Patterns

**State variables:**
```
<role_name>_state
```

Values: `present`, `absent`

**Version variables:**
```
<role_name>_<package>_version
```

**Configuration paths:**
```
<role_name>_<config>_path
```

**Boolean flags:**
```
<role_name>_enable_<feature>
```

**Lists:**
```
<role_name>_<items>
```

(Plural form for lists)

## Common Patterns

### Role Structure Naming

```
roles/
└── my_role/
    ├── defaults/
    │   └── main.yml           # Default variables
    ├── tasks/
    │   ├── main.yml           # Main entry point
    │   ├── present.yml        # Install/configure tasks
    │   ├── absent.yml         # Removal tasks
    │   ├── mac.yml            # OS-specific tasks
    │   ├── ubuntu.yml
    │   └── windows.yml
    ├── templates/
    │   └── config.yml.j2      # Jinja2 templates
    ├── vars/
    │   └── main.yml           # Role constants
    ├── meta/
    │   ├── main.yml           # Dependencies
    │   └── argument_specs.yml # Role interface
    └── README.md
```

### Collection Structure Naming

```
ansible_collections/
└── my_namespace/
    └── my_collection/
        ├── galaxy.yml
        ├── plugins/
        │   ├── modules/
        │   │   └── my_module.py
        │   ├── inventory/
        │   └── module_utils/
        │       └── helper.py
        ├── roles/
        │   └── my_role/
        └── playbooks/
```

### Playbook Project Structure

```
project/
├── inventory/
│   ├── inventory.yml          # Static inventory
│   ├── netbox.yml             # Dynamic inventory
│   ├── group_vars/
│   │   ├── all.yml
│   │   └── web_servers.yml
│   └── host_vars/
│       └── server-225-win.yml
├── playbooks/
│   ├── deploy_ipam_netbox.yml
│   └── deploy_development_nodes.yml
├── roles/
│   └── (roles)
├── requirements.yml           # Galaxy dependencies
└── ansible.cfg
```

## Constraints

| Element | Max Length | Valid Characters | Must Start With | Must End With | Case |
|---|---|---|---|---|---|
| Role name | No limit (practical: < 50) | `[a-z0-9_]` | `[a-z]` | `[a-z0-9]` | lowercase |
| Variable name | No limit (practical: < 100) | `[a-z0-9_]` | `[a-z_]` | `[a-z0-9_]` | lowercase |
| Collection namespace | No limit | `[a-z0-9_]` | `[a-z]` | `[a-z0-9]` | lowercase |
| Group name | No limit | `[a-z0-9_]` | `[a-z]` | `[a-z0-9_]` | lowercase |
| Tag name | No limit | `[a-z0-9_]` | `[a-z]` | `[a-z0-9_]` | lowercase |

## Rationale

### Why Underscores for Roles (Not Hyphens)

- Role names become Python module names when packaged in collections
- Python imports don't support hyphens: `from my-role import` fails
- Collections enforce this: Galaxy import will fail if role name has hyphens
- Hyphens work for standalone roles but break when migrating to collections

### Why Role Name Prefix for Variables

- Prevents namespace collisions when multiple roles are used
- Makes variable ownership obvious
- Supports role reusability
- Example collision without prefix: Two roles both define `port` variable

### Why FQCN Required

- Explicit about which collection provides the module
- Prevents ambiguity when multiple collections have same module name
- Better performance (Ansible doesn't search multiple paths)
- Required for collections, best practice everywhere

### Why `.yml` Not `.yaml`

- Consistency across Ansible ecosystem
- Shorter
- Universal convention in Ansible documentation and examples
- Tooling assumes `.yml`

### Why Imperative Task Names

- Describes action being taken: "Install package" not "Package installation"
- Clearer in logs and output
- Matches Ansible's declarative-but-imperative nature
- More readable when scanning playbook output

## Anti-Patterns to Avoid

- ❌ Role names with hyphens: `my-role` → Use `my_role`
- ❌ Variables without role prefix: `port` → Use `my_role_port`
- ❌ Uppercase in names: `MyRole` → Use `my_role`
- ❌ Special characters: `my.role`, `my-var` → Use `my_role`, `my_var`
- ❌ Using `set_fact` to override role defaults
- ❌ Bare module names without FQCN: `copy` → Use `ansible.builtin.copy`
- ❌ Mixing `.yml` and `.yaml` extensions
- ❌ Unnamed tasks
- ❌ Playbook tags without role prefix
- ❌ Variables starting with numbers
- ❌ Python keywords as variable names

## Project-Specific Patterns (This Repo)

### Capability-Focused Naming

- Prefer naming roles for the capability they manage, not the OS
- Use OS selection inside `tasks/main.yml` with `mac.yml`, `ubuntu.yml`, `windows.yml` dispatch
- Example: `speech_central` instead of `speech_central_mac`

### Lifecycle State Variables

- Every capability should expose: `<role_name>_state: present|absent`
- Present/absent task files: `tasks/present.yml`, `tasks/absent.yml`
- Playbooks preserve both states (don't wrapper-filter to only one)

### Version Contract Variables

- Version pins stored in inventory: `<component>_version_contract`
- Role reads from contract: `<role_name>_version: "{{ <component>_version_contract.<package> }}"`
- Example: `langfuse_tooling_version_contract.cli: "0.0.10"`

### NetBox-Ansible Integration

- NetBox object slugs use hyphens: `ansible-managed`
- Ansible tags use underscores: `ipam_netbox_seed_tags`
- Never reuse same string as both Ansible tag and NetBox slug

## References

- Ansible Best Practices: https://docs.ansible.com/ansible/latest/tips_tricks/ansible_tips_tricks.html
- Ansible Content Best Practices: `guidelines://ansible-content-best-practices` (FetchMcpResource)
- Zen of Ansible: `ansible.zen_of_ansible` (ansible MCP)
- This project: `.cursor/rules/ansible-coding-standards.mdc`
