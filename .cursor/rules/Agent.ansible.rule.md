Phase 0 — Identify the Resource or System

Before touching code:

Write this sentence:

I am managing a <resource or system> to ensure it is <desired state>.

Examples:

Kubernetes Node taint → resource

Windows firewall rule → resource

Install K3s cluster → system

Configure WireGuard router → system

This determines whether you search for a module or a role.

Phase 1 — Galaxy Search (System-Level Problems)

If the problem is a system (multi-resource orchestration):

Run:

ansible-galaxy search <keyword>
ansible-galaxy collection search <keyword>

Examples:

ansible-galaxy search k3s
ansible-galaxy collection search nvidia
ansible-galaxy search wireguard

Then inspect:

ansible-doc -l -t role <namespace>.<collection>
ansible-doc -l -t module <namespace>.<collection>

Then inspect examples:

~/.ansible/roles/<namespace>.<role>/examples/
~/.ansible/collections/ansible_collections/<ns>/<collection>/playbooks/

Only if no suitable role exists do you write your own orchestration.

This prevents re-implementing K3s install logic when a maintained role exists.

Phase 2 — Module Namespace Search (Resource-Level Problems)

If the problem is manipulating a specific resource:

Search built-ins and installed collections first.

Core search:

ansible-doc -l | grep <keyword>

Collection search:

ansible-doc -l -t module <namespace>.<collection>

Examples:

Kubernetes:

ansible-doc -l | grep k8s

Windows:

ansible-doc -l | grep win_

Docker:

ansible-doc -l | grep docker

Linux:

ansible-doc -l | grep file
ansible-doc -l | grep service
ansible-doc -l | grep mount

If a module exists → use it.

No scripting allowed.

Phase 3 — Installed Collection Inspection

If kubernetes.core is installed:

ansible-doc -l -t module kubernetes.core

If community.windows is installed:

ansible-doc -l -t module community.windows

This forces awareness of what you already have before inventing commands.

Phase 4 — Idempotent Expression

All tasks must be expressed as:

state: present

state: absent

ensure: exists

ensure: configured

ensure: ready

Never:

run

execute

call

invoke

That language shift matters.

Phase 5 — Scripted Fallback (Last Resort)

Only if:

No module exists

No maintained role exists

Then:

Must include justification

Must include changed_when

Must include creates/removes if possible

Must include comment explaining why no module exists

If any of those are missing → violation.

Updated Hard Rule

For Kubernetes specifically:

If kubernetes.core is installed:

kubectl usage is disallowed in production roles.

Only allowed for debugging tasks.

This would have prevented your k3s_node_config mess entirely.

Why This Time It Works

Previously the rule was:

“Search for modules.”

That was incomplete.

Now the rule is layered:

Identify resource vs system

Galaxy search (system)

Namespace search (resource)

Inspect installed collections

Express desired state declaratively

Only then script

There is no ambiguity left.