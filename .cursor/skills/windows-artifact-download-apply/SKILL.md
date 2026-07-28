---
name: windows-artifact-download-apply
description: >-
  Use when a Windows host needs a pinned large HTTP(S) download in Ansible —
  Setup.exe, MSI, ZIP, driver, firmware — with resume, stall limits, checksum,
  and atomic publish via roles/windows_artifact_download. Use for multi-GB
  GitHub assets, hung Chocolatey replaced by Setup.exe, or when tempted to
  invent curl/BITS/_tmp playbooks. Do not use for ollama pull / app-native
  model layers (owning product role) or healthy Chocolatey packages.
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: "homelab-ansible-first-entry, windows-tool-capability-intake, single-host-ansible-rollout, homelab-ssh-alias-connect"
requires_summary: "roles/windows_artifact_download; AGENTS.md §32; no _tmp install playbooks"
title: Windows Artifact Download Apply
technology: ansible
document_type: skill
status: reviewed
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-07-24"
applies_to:
  - ansible
  - windows
  - tooling
related:
  - roles/windows_artifact_download/
  - roles/windows_ollama_runtime/
  - docs/lessons-learned/windows-desktop-wifi-github-download/README.md
  - AGENTS.md
tags:
  - skill
  - ansible
  - windows
  - download
  - artifact
---

# Skill: Windows Artifact Download Apply

Route large Windows HTTP(S) artifacts through
`roles/windows_artifact_download` instead of inventing curl/BITS/temp
playbooks. This skill owns the **download contract + apply/verify path**;
the product role still owns install (`win_package`) and app-native pulls.

## When to use / not use

**Use when:**

- Pinning a multi‑MB/GB installer or archive (GitHub release Setup.exe, MSI, ZIP)
- Chocolatey is wrong/hung for a large Setup.exe and the durable path is
  artifact download + `win_package`
- Extending an existing Windows product role to download before install
- Resuming a paused `.partial` under `C:\ProgramData\Ansible\artifacts\...`

**Do not use when:**

- Healthy Chocolatey package is the chosen install authority
- App-native download (`ollama pull`, HF Hub client weight trees) — owning
  product / `hf-model-weight-lifecycle`
- One-off `oneoffs` exception explicitly requested by the user

## Nested skill scope

1. Enter via `homelab-ansible-first-entry` when the wider task is install/mutate.
2. For new Windows capabilities, complete intake in `windows-tool-capability-intake`
   first; then return here for the download slice.
3. Interactive SSH → `homelab-ssh-alias-connect` (`ssh <inventory_hostname>`).
4. Live apply → nest `single-host-ansible-rollout` (list-hosts → check → apply → verify).

## Hard stop — PROHIBITED

- `playbooks/troubleshoot/_tmp_*` download/install playbooks
- New role `files/*.ps1` curl/BITS download+install when this role applies
- Ad-hoc `scp` of installers or interactive one-liner curl as the primary path
- Dropping checksum / pinning “latest” without a recorded sha256

## Contract (required)

Print checklist:

```bash
bin/codex-env python .cursor/skills/windows-artifact-download-apply/scripts/print_artifact_contract.py
```

Minimum `windows_artifact` keys:

| Key | Meaning |
| --- | --- |
| `id` | Stable artifact id (logs / receipts) |
| `url` | Pinned HTTPS URL (versioned release asset) |
| `destination` | Final path under `C:\ProgramData\Ansible\artifacts\...` |
| `checksum.algorithm` | Usually `sha256` |
| `checksum.value` | Exact digest of the published file |

Defaults already favor large transfers: `resume: true`, async enabled,
stall min bps + timeout, `preserve_partial_on_failure: true`.

Caller pattern:

```yaml
- name: Download pinned upstream installer
  ansible.builtin.include_role:
    name: windows_artifact_download
  vars:
    windows_artifact:
      id: "tool-1.2.3"
      url: "https://example.com/releases/download/v1.2.3/Setup.exe"
      destination: 'C:\ProgramData\Ansible\artifacts\tool\Setup-1.2.3.exe'
      checksum:
        algorithm: sha256
        value: "<pinned sha256>"
      async:
        enabled: true
        timeout_seconds: 28800
        poll_interval_seconds: 30
```

Then install with `ansible.windows.win_package` (or extract) in the **owning**
product role — keep download and install separate.

## Workflow

1. Confirm owner role/playbook (extend existing; do not invent `_tmp_`).
2. Pin version URL + sha256 from upstream (GitHub release / vendor).
3. Wire `include_role: windows_artifact_download` with the contract above.
4. Preview: `--list-hosts` then `--check` when useful (incomplete partials can
   fail checksum in check mode — expect that).
5. Apply via owning playbook; monitor `.partial` growth if multi‑GB.
6. Verify: destination exists, checksum matches, then product install path.
7. If download stalls: check first-hop loss / CDN (see lesson below); pause and
   keep partial; resume with same contract (`resume: true`).

## Network triage (when slow)

Lesson: `docs/lessons-learned/windows-desktop-wifi-github-download/README.md`

- Ping/pathping to LAN gateway before blaming Ansible flags
- Compare Cloudflare vs GitHub ranged curl on the same host
- Do not treat low curl CPU as a hang — watch partial byte growth

## Apply / Verify / Undo / Change class

- **Apply:** include role with complete contract; async curl resume
- **Verify:** `win_stat` checksum == contract; published path exists
- **Undo:** remove destination / `.partial` (product uninstall is separate)
- **Change class:** idempotent config (safe re-run; resumes partials)

## Minimal receipt

```text
Owner role/playbook: <path>
Artifact id/url: <id> <url>
Checksum: sha256:<value>
Destination: <path>
Partial preserved?: yes|no
Install next?: win_package | extract | deferred
```

## Handoffs

| Next need | Skill / surface |
| --- | --- |
| New Windows capability scaffold | `windows-tool-capability-intake` |
| Single-host preview/apply | `single-host-ansible-rollout` |
| Desktop Ollama product path | `deploy-dev-workstation-ollama-runtime` |
| App-native model layers | product role `/api/pull` or `hf-model-weight-lifecycle` |

## References

- `references/contract.md`
- `references/related-artifacts.md`
- `roles/windows_artifact_download/README.md`
