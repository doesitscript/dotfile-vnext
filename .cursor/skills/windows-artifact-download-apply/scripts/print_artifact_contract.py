#!/usr/bin/env python3
"""Print the windows_artifact contract checklist for agents.

Run before wiring roles/windows_artifact_download so the contract is complete
and temp curl playbooks are not invented.
"""

from __future__ import annotations

REQUIRED = [
    ("id", "Stable artifact id for logs/receipts"),
    ("url", "Pinned HTTPS URL (versioned release asset)"),
    ("destination", r"Final path under C:\ProgramData\Ansible\artifacts\..."),
    ("checksum.algorithm", "Usually sha256"),
    ("checksum.value", "Exact digest of the published file"),
]

DEFAULTS = [
    "resume: true",
    "force: false",
    "async.enabled: true",
    "async.timeout_seconds: 28800",
    "async.poll_interval_seconds: 30",
    "stalled_transfer.minimum_bytes_per_second: 1024",
    "stalled_transfer.timeout_seconds: 120",
    "preserve_partial_on_failure: true",
]

PROHIBITED = [
    "playbooks/troubleshoot/_tmp_* download/install playbooks",
    "New role files/*.ps1 curl/BITS download+install",
    "Ad-hoc scp/interactive curl as the primary download path",
    "Skipping checksum / floating latest without pin",
    "Using this role for ollama pull / HF weight trees",
]

NEXT = [
    "Wire include_role: windows_artifact_download in the owning product role",
    "Install with win_package (or extract) in that same product role",
    "Apply via product playbook + single-host-ansible-rollout",
    "On stall: keep .partial; triage hop/CDN; resume same contract",
]


def main() -> None:
    print("=== windows-artifact-download-apply ===")
    print("Role: roles/windows_artifact_download")
    print("Do not invent curl/_tmp downloaders.\n")
    print("REQUIRED contract keys:")
    for key, meaning in REQUIRED:
        print(f"  - {key}: {meaning}")
    print("\nRecommended large-file defaults:")
    for item in DEFAULTS:
        print(f"  - {item}")
    print("\nPROHIBITED:")
    for item in PROHIBITED:
        print(f"  - {item}")
    print("\nNext steps:")
    for item in NEXT:
        print(f"  - {item}")
    print(
        "\nMinimal receipt:\n"
        "  Owner role/playbook: <path>\n"
        "  Artifact id/url: <id> <url>\n"
        "  Checksum: sha256:<value>\n"
        "  Destination: <path>\n"
        "  Partial preserved?: yes|no\n"
        "  Install next?: win_package | extract | deferred"
    )


if __name__ == "__main__":
    main()
