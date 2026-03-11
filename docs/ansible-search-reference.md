# Ansible Search Reference

How to find answers using Ansible tooling before writing code or asking the internet.

---

## 1. Search your own project first

```bash
# Find any keyword across all roles and playbooks
rg "keyword" roles/ playbooks/ --type yaml

# Just filenames that contain a match (less noise)
rg "keyword" roles/ --type yaml -l

# Examples
rg "networkingMode" roles/ playbooks/
rg "win_powershell" roles/ --type yaml -l
rg "keepwsl" roles/ playbooks/ --type yaml
```

`rg` (ripgrep) is already installed. Faster than `grep`, respects `.gitignore`, shows file + line number.

---

## 2. Check if a module already exists for what you're trying to do

```bash
# List all available modules and filter by keyword
ansible-doc -l | grep -i "wsl"
ansible-doc -l | grep -i "firewall"
ansible-doc -l | grep -i "registry"
ansible-doc -l | grep -i "win_"

# Read a module's full docs + examples
ansible-doc ansible.windows.win_powershell
ansible-doc community.windows.win_scheduled_task
ansible-doc ansible.builtin.wait_for_connection
```

**Rule:** Before writing a `win_powershell` script to do something, run `ansible-doc -l | grep -i <thing>` first.
If a module exists, use it — it handles idempotency, check mode, and error reporting for you.

---

## 3. Search Galaxy for community roles and collections

```bash
# Search community roles by keyword
ansible-galaxy role search "wsl"
ansible-galaxy role search "openssh"
ansible-galaxy role search "docker" --author geerlingguy

# See what collections are installed locally
ansible-galaxy collection list

# Install a collection
ansible-galaxy collection install community.windows
```

Galaxy search hits galaxy.ansible.com directly. Useful for "does a maintained role for this exist."
Always check the author and star count — signal-to-noise varies widely.

---

## 4. Search online documentation

No great single CLI tool for this. Use a targeted browser search:

```
site:docs.ansible.com <keyword>
site:docs.ansible.com win_powershell
site:docs.ansible.com wait_for_connection
```

Or open the search page directly:

```bash
open "https://docs.ansible.com/ansible/latest/search.html?q=wsl"
```

Key doc URLs to bookmark:
- Core modules: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/
- Windows collection: https://docs.ansible.com/ansible/latest/collections/ansible/windows/
- Community Windows: https://docs.ansible.com/ansible/latest/collections/community/windows/

---

## The recommended order

1. `rg` in your own project — you may have already solved this
2. `ansible-doc -l | grep` — a module may exist and save you writing code
3. `ansible-galaxy role search` — a maintained role may cover it completely
4. `site:docs.ansible.com` web search — for module parameters and examples
5. Write custom code — only after the above come up empty
