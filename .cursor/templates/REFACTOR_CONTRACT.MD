Good.
You’re getting both.

No fluff. No commentary. Just artifacts you can use.

---

# 📄 1️⃣ REFACTOR_CONTRACT.md

*(Drop this in your repo root.)*

---

# SSH / Access Refactor Contract

## Purpose

Convert ad-hoc transport playbooks into structured, reusable roles while preserving:

* Working SSH on controller (Mac)
* Working OpenSSH on Windows hosts
* Inventory-driven configuration
* Idempotent behavior
* Explicit verification separation

This contract defines what is allowed and what is not.

---

## Architectural Model

### 1. Roles represent configuration state.

They:

* Are idempotent.
* Use Ansible modules whenever possible.
* Do not contain verification logic.
* Do not hardcode users.
* Consume inventory variables.

### 2. Verification is separate.

Verification:

* Lives in `roles/verify_ssh/`.
* Is tagged `verify`.
* Uses `changed_when: false`.
* Can be skipped with `--skip-tags verify`.

### 3. Playbooks are entrypoints only.

Playbooks:

* Target host groups.
* Include roles.
* Contain no implementation logic.

---

## Required Final Structure

```
roles/
  access_identity_controller/
    defaults/main.yml
    tasks/main.yml

  access_identity_windows/
    defaults/main.yml
    tasks/main.yml

  verify_ssh/
    tasks/
      main.yml
      connectivity.yml
      key_auth.yml
```

```
playbooks/
  access_controller.yaml
  access_windows.yaml
```

No `transport_*` playbooks may exist.

---

## Controller Role Requirements

Must:

* Ensure SSH key exists.
* Publish:

  * execution_node_private_key_path
  * execution_node_public_key_path
* Tag fact publishing with:

  * facts
  * transport

Must not:

* Hardcode usernames.
* Embed verification logic.

---

## Windows Role Requirements

Must:

* Install OpenSSH capability.
* Ensure sshd running.
* Ensure firewall rule.
* Ensure administrators_authorized_keys exists.
* Disable ACL inheritance.
* Grant:

  * SYSTEM FullControl
  * Administrators FullControl
* Install controller public key.

Must use:

* ansible.windows.win_acl
* ansible.windows.win_file
* ansible.windows.win_acl_inheritance

Must consume:

* ansible_user from inventory

---

## Verification Role Requirements

### connectivity.yml

* Use wait_for on port 22.

### key_auth.yml

* SSH from controller.
* BatchMode=yes.
* StrictHostKeyChecking=no (lab).
* changed_when: false.

### Must fail clearly if:

stdout != ssh_ok.

---

## Inventory Discipline

Inventory defines:

* ansible_user
* ansible_host
* ansible_connection

Roles never define login users.

---

## Success Criteria

Running:

```
ansible-playbook playbooks/access_controller.yaml -i inventory/inventory.yaml
ansible-playbook playbooks/access_windows.yaml -i inventory/inventory.yaml --limit server-225-win
```

Must result in:

* SSH key exists on controller.
* OpenSSH enabled on Windows.
* Controller key installed.
* SSH login works.
* Verification passes.
* No transport breakage.

---

## Forbidden

* Reintroducing transport playbooks.
* Hardcoded Administrator.
* Mixing configuration and verification.
* Shell usage where module exists.
* Duplicated SSH logic.

---

End of Contract.

---

---

# 🧠 2️⃣ EXECUTION_CHECKLIST.md

*(Operational checklist to avoid another spiral.)*

---

# SSH Refactor Execution Checklist

## Phase 1 – Controller

☐ access_identity_controller role exists
☐ SSH key created idempotently
☐ execution_node_private_key_path fact published
☐ execution_node_public_key_path fact published
☐ No hardcoded user

Test:

```
ansible-playbook playbooks/access_controller.yaml -i inventory/inventory.yaml
```

---

## Phase 2 – Windows

☐ OpenSSH capability installed
☐ sshd running
☐ Firewall rule present
☐ administrators_authorized_keys exists
☐ ACL inheritance disabled
☐ SYSTEM FullControl
☐ Administrators FullControl
☐ Controller public key installed

Test:

```
ansible-playbook playbooks/access_windows.yaml -i inventory/inventory.yaml --limit server-225-win
```

---

## Phase 3 – Verification Separation

☐ verify_ssh role exists
☐ connectivity.yml created
☐ key_auth.yml created
☐ All tasks tagged verify
☐ All verification tasks changed_when: false

Test:

```
ansible-playbook playbooks/access_windows.yaml -i inventory/inventory.yaml --limit server-225-win --tags verify
```

---

## Phase 4 – Skip Verification Test

```
ansible-playbook playbooks/access_windows.yaml -i inventory/inventory.yaml --limit server-225-win --skip-tags verify
```

Must still configure successfully.

---

## Phase 5 – Transport Integrity

☐ Can SSH from Mac to Windows
☐ Ansible can connect via SSH (if switching transport later)
☐ WinRM not broken

---

## Phase 6 – Fact Discipline

☐ Facts tagged with "facts"
☐ No random runtime values set as facts
☐ No duplication across roles

---

## Phase 7 – Clean State

☐ No transport_* playbooks remain
☐ No Administrator hardcoding
☐ No verification embedded inside config roles

---

End Checklist.

---

These two documents together give you:

* Constraint contract (for AI)
* Execution discipline (for you)

Use the contract when delegating to AI.
Use the checklist when validating output.

That’s how you stop babysitting.
