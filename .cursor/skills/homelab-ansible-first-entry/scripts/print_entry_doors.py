#!/usr/bin/env python3
"""Print the Ansible-first entry doors for dotfile-vnext agents.

Run at the start of install/download/configure/remove work so the agent does
not invent a custom approach. Light by design — routing only.
"""

from __future__ import annotations

DOORS = [
    (
        "Windows tool/package, Chocolatey, Setup.exe, HVH, AMD desktop",
        "windows-tool-capability-intake",
    ),
    (
        "macOS CLI / Homebrew vs release binary",
        "macos-tool-install-decider-and-scaffold → tool-capability-intake",
    ),
    (
        "Hugging Face model weights on the share",
        "hf-model-weight-lifecycle",
    ),
    (
        "Generic / unclear-OS tool capability",
        "tool-capability-intake",
    ),
    (
        "Ansible role/playbook design already in scope",
        "ansible-knowledge-gate (module matrix required)",
    ),
    (
        "Broad project maturity / best practices",
        "project-maturity-router",
    ),
]

PROHIBITED = [
    "playbooks/troubleshoot/_tmp_* install playbooks",
    "New role files/*.ps1 curl/BITS download+install when win_get_url+win_package apply",
    "Ad-hoc choco/pip/scp install as the primary install path",
    "Skipping module discovery (ansible-doc / Context7) before shell",
    "Invented ssh user@ip/-i/-p — use ssh <inventory_hostname> (homelab-ssh-alias-connect)",
]

SSH = [
    "Resolve: bin/codex-env python .cursor/skills/homelab-ssh-alias-connect/scripts/resolve_ssh_alias.py --host <inventory_hostname>",
    "Connect: ssh <inventory_hostname>   # Host alias from Ansible-managed ~/.ssh/config",
    "Do not rebuild HostName/User/IdentityFile by hand from ansible_host",
]

WINDOWS_EXE = [
    "1) chocolatey.chocolatey.win_chocolatey when healthy",
    "2) ansible.windows.win_get_url (checksum + long timeout)",
    "3) ansible.windows.win_package (silent args + creates_path)",
    "4) Owning role + inventory install_method — never a temp playbook",
]


def main() -> None:
    print("=== homelab-ansible-first-entry ===")
    print("Do not invent an approach. Pick a door, then open that skill.\n")
    print("DOORS:")
    for shape, skill in DOORS:
        print(f"  - If: {shape}")
        print(f"    → {skill}")
    print("\nPROHIBITED as primary install:")
    for item in PROHIBITED:
        print(f"  - {item}")
    print("\nInteractive SSH (nested skill homelab-ssh-alias-connect):")
    for step in SSH:
        print(f"  {step}")
    print("\nWindows upstream Setup.exe preferred path:")
    for step in WINDOWS_EXE:
        print(f"  {step}")
    print(
        "\nMinimal receipt before mutate:\n"
        "  Entry door: <skill>\n"
        "  Owner role/playbook: <path or needs intake>\n"
        "  Install family candidates: <modules>\n"
        "  One-off exception?: no | user-explicit oneoffs\n"
        "  Next skill: <handoff>"
    )


if __name__ == "__main__":
    main()
