# Reorganization ideas: Mac / SSH setup and playbook layout

**Purpose:** Record plans for making the Mac-as-executor + OpenSSH-on-Windows flow more future-proof and easier to run. No implementation yet—ideas only.

---

## Current state (summary)

- **bootstrap_execution_node.yaml** – Mac: ensures `~/.ssh`, creates `id_ed25519_ansible` (and `.pub`). Central executor; most mature SSH side.
- **boostrap_windows_ssh_via_winrm.yaml** – Windows: OpenSSH via WinRM, key from execution node → `administrators_authorized_keys`. Pair to the above; almost ready for all Windows servers.
- **deploy_shell_config.yaml** – Shell envs for Linux-based dev.
- **bootstrap_server_225.yaml** – Next-stage infra (not tested).
- Bootstrap scripts: done; only touch for new PC/Mac.
- Roles: mix of single-app, multi-OS, and early org (network_server, server_225) not yet used.

---

## Plan A: Group the SSH pair under a subdir (minimal move)

**Idea:** Put the two SSH-related playbooks in one place so “both sides” are obvious and you have room to add more later.

- **playbooks/ssh/** (or **playbooks/execution_plane/**)
  - `bootstrap_execution_node.yaml`   → e.g. `ssh/bootstrap_execution_node.yaml`
  - `boostrap_windows_ssh_via_winrm.yaml` → e.g. `ssh/bootstrap_windows_openssh_via_winrm.yaml` (and fix typo: boostrap → bootstrap)

**Pros:** Clear that these two go together; one place for “SSH / execution plane” playbooks; easy to add a small README or a wrapper playbook later.  
**Cons:** Slightly longer paths; any scripts/docs that call these playbooks need path updates.

**Run order (unchanged):**  
1. `playbooks/ssh/bootstrap_execution_node.yaml`  
2. `playbooks/ssh/bootstrap_windows_openssh_via_winrm.yaml` (with `--limit` as needed)

---

## Plan B: Single “SSH setup” playbook that runs both sides (orchestrator)

**Idea:** One entrypoint that runs execution node first, then Windows OpenSSH, so you don’t have to remember order or two invocations.

- **playbooks/ssh/setup_openssh.yaml** (or `playbooks/ssh/run_ssh_bootstrap.yaml`)
  - Play 1: `hosts: execution_nodes` – import or include the tasks from current bootstrap_execution_node (or call a role).
  - Play 2: `hosts: windows_hosts` – import or include the tasks from current boostrap_windows_ssh_via_winrm (or call a role).

**Pros:** One command: “run the SSH setup”; good for “new machine” or “refresh everything.”  
**Cons:** Two plays in one file can get long; you might still want to run “only Mac” or “only Windows” sometimes, so keep the two playbooks (or roles) as separate, callable units.

**Variant:** Orchestrator only *includes* the two playbooks (e.g. `import_playbook`), so logic stays in bootstrap_execution_node and bootstrap_windows_openssh_via_winrm; orchestrator is just ordering + a single entrypoint.

---

## Plan C: Extract shared “SSH / key” logic into a role (or roles)

**Idea:** The “execution node” side is: create dir, create key, maybe one or two more tasks. The “Windows OpenSSH” side is: capability, service, firewall, file, ACL, key line. Move those into roles so playbooks are thin and reusable.

- **roles/execution_node_ssh/** (or **roles/ssh_execution_node/**)
  - tasks: ensure `.ssh`, ensure `id_ed25519_ansible` key (using same vars as today).
- **roles/windows_openssh/** (or **roles/openssh_windows/**)
  - tasks: capability, sshd service, firewall rule, `administrators_authorized_keys` file + ACL, install key line, restart when needed.

Then:
- **bootstrap_execution_node.yaml** → one play, `roles: [ execution_node_ssh ]` (plus vars).
- **bootstrap_windows_openssh_via_winrm.yaml** → one play, `roles: [ windows_openssh ]` (plus vars).

**Pros:** Reusable from other playbooks (e.g. bootstrap_server_225, or a future “full bootstrap”); aligns with “roles for structure” from Ansible docs; single place to fix key path or ACL logic.  
**Cons:** More files; need to pass execution_node_pub_key_path (or equivalent) via group_vars/execution_nodes or play vars so the Windows role stays decoupled.

---

## Plan D: Naming and typo fix (do regardless)

- Rename **boostrap_windows_ssh_via_winrm.yaml** → **bootstrap_windows_openssh_via_winrm.yaml** (fix “boostrap”, add “openssh” for clarity).
- Optionally standardize on **bootstrap_*_openssh** or **bootstrap_*_ssh** so “SSH” vs “OpenSSH” is consistent across playbooks.

---

## Recommendation (for later)

1. **Do Plan D** (typo + naming) when you touch these files next.
2. **Do Plan A** if you want a low-friction move: create `playbooks/ssh/`, move the two playbooks there, fix the name, update any docs/scripts that reference them.
3. **Consider Plan B** if you want a single “run both sides” command; implement it as an orchestrator that `import_playbook`s the two existing playbooks so you don’t duplicate logic.
4. **Consider Plan C** when you’re ready to reuse this logic from bootstrap_server_225 or other playbooks, or when you want roles to be the main unit of organization.

---

## Execution-node-specific “Mac” naming

You described the Mac as “execution point / central point.” The playbooks already use **execution_nodes** (inventory group) and “execution node” in comments, which is future-proof if you ever add another executor. No change required for that; only consider whether you want a **group_vars** or **docs** note that “today, execution_nodes = mac-dev” so it’s explicit for future you.

---

*Recorded for later; revise as you reorganize.*
