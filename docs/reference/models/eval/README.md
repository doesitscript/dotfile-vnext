# EVAL landing

Date: 2026-09-02
Purpose: keep the most current model-to-hardware evaluation method, active
matrices, and live troubleshooting notes in one place.

## What belongs here

- the current evaluation framework
- the reusable note template
- dated model-fit notes
- scored comparison matrices
- live troubleshooting notes that affect evaluation confidence

## Authority order

Use evidence in this order:

1. Live host probe on the real target machine
2. Runtime/package facts for the exact served artifact
3. Official model/vendor docs
4. Repo deployment surfaces and older internal notes

Repo truth matters for deployment ownership, but not by itself for model fit.

## Current working set

| Item | Doc | Status |
| --- | --- | --- |
| Evaluation framework | [EVAL-model-note-fit-framework.md](./EVAL-model-note-fit-framework.md) | Current method |
| Evaluation template | [EVAL-model-note-fit-template.md](./EVAL-model-note-fit-template.md) | Reusable note shape |
| Windows desktop fit note | [EVAL-model-note-fit--dev-workstation-win-gpt-oss-20b.md](./EVAL-model-note-fit--dev-workstation-win-gpt-oss-20b.md) | Current 16GB desktop decision |
| Windows desktop matrix | [dev-workstation-win-2026-09-02-matrix.md](./dev-workstation-win-2026-09-02-matrix.md) | First scored comparison |

## Current live boundary

Two different controller contexts produced different results on 2026-09-02:

- This execution environment could not open sockets to the host:
  - SSH to `192.168.50.133:22` failed with `Operation not permitted`
  - WinRM to `192.168.50.133:5985/wsman` failed with `Operation not permitted`
- A user-local terminal on `mac-dev` did reach the host:
  - `ping 192.168.50.133` succeeded
  - `ssh 192.168.50.133` reached OpenSSH and prompted for `joshc`'s password

Interpretation:

- the Windows host is up
- the LAN path is up from the user's real terminal
- `sshd` is listening on the host
- the remaining likely issue is repo-managed key authentication or controller-path
  mismatch, not total host outage

That means current EVAL output for this host is based on:

- confirmed repo deployment surfaces
- current upstream model/runtime docs
- user-supplied live network evidence
- a failed transport attempt from this execution environment

It still does not include a successful repo-managed remote session from this
session.

## Current troubleshooting hypothesis

Most likely causes, in order:

1. the host accepts password SSH, but the repo-managed public key is missing or
   stale in Windows `authorized_keys`
2. the reachable user terminal and this execution environment do not share the
   same network egress permissions
3. WinRM is disabled or blocked even though OpenSSH is up

Next validation from a reachable terminal:

```bash
ssh -i ~/.ssh/id_ed25519_ansible joshc@192.168.50.133
ssh dev-workstation-win
```

If those still fall back to a password prompt, repair should focus on the
Windows `authorized_keys` / `administrators_authorized_keys` surfaces managed by
`roles/access_identity_windows`.

## Repeatable troubleshooting path

Controller-side best effort:

```bash
cd /Users/joshc/develop/dotfile-vnext
export NO_PROXY='*'
ANSIBLE_CONFIG=ansible.cfg bin/codex-env ansible-playbook \
  playbooks/access_windows_best_effort.yaml \
  -i inventory/inventory.yaml \
  -e access_windows_best_effort_target=dev-workstation-win \
  --tags collect_windows_remote_access
```

On-host local collection when both remote transports fail:

```powershell
powershell -ExecutionPolicy Bypass -File .\bin\troubleshoot-windows-remote-access-local.ps1
```

Model deployment after transport is restored:

```bash
cd /Users/joshc/develop/dotfile-vnext
ANSIBLE_CONFIG=ansible.cfg bin/codex-env ansible-playbook \
  playbooks/deploy_dev_workstation_ollama_runtime.yaml \
  -i inventory/inventory.yaml \
  --limit dev-workstation-win
```

## Improvement rules

When adding or updating work here:

1. Separate host fit from client-lane fit.
2. Record what is proven versus inferred.
3. Prefer a scored matrix over a loose opinion.
4. Keep old notes, but supersede them explicitly.
5. Add the next missing live probe rather than widening speculation.
