# Useful commands

Paste-ready agent prompts for this slice. Skills live under `.agents/skills/`.

**Design authority** is the source packet
`dotfile-vnext/exports/work-laptop-ai-tools/`. The sibling checkout
`work-laptop-ai-tools` is generated — do not treat it as the source of truth.

| Section | Who runs it | Typical machine |
| --- | --- | --- |
| [Upstream (source packet)](#upstream-source-packet) | Controller / home Mac with `dotfile-vnext` | Sync, inbox evaluate-fix, packet edits |
| [Work laptop (sibling apply)](#work-laptop-sibling-apply) | Corporate work Mac | `git pull` + day-2 apply |

---

## Upstream (source packet)

Use these from a session that can edit the packet under `dotfile-vnext` and
sync into the sibling. Prefer the **export packet** over unregistered
laptop-only drift (`AGENTS.md`).

### U1. Inbox evaluate-and-fix (implement)

Use skill `work-laptop-inbox-evaluate-fix` to git pull the sibling, process
active `inbox/` notes, fix durable items in the source packet (prefer packet
over unregistered laptop drift), register deviations, then sync and push the
sibling. Do not treat the sibling as design authority.

### U2. Inbound laptop feedback review (audit only)

Use skill `work-laptop-improvement-review` to pull the latest sibling, ingest
inbound laptop feedback, and register accepted deviations. Audit only unless
asked to implement. For implement mode, use U1 instead.

### U3. Sync source to sibling

Use skill `work-laptop-packet-ops` to sync the work-laptop-ai-tools source
packet to the sibling. Validate the export contract, then copy every manifest
path from `dotfile-vnext/exports/work-laptop-ai-tools/` into the sibling
checkout so the sibling matches the packet. Do not treat the sibling as design
authority. Do not commit or push.

### U4. Sync source to sibling, then git push the sibling

Use skill `work-laptop-packet-ops` to sync the work-laptop-ai-tools source
packet to the sibling. Validate the export contract, then copy every manifest
path from `dotfile-vnext/exports/work-laptop-ai-tools/` into the sibling
checkout so the sibling matches the packet. Then do the git work in the sibling
subproject only: status, diff, commit the synced packet files, and push that
sibling branch to its remote. Do not force-push. Do not commit vault secrets.
Leave unrelated dirty files unstaged.

### U5. Enable an MCP on this slice

Use skill `work-laptop-mcp-commission` to enable <mcp> for Continue, Cline, and
Codex on this packet. Do not enable VS Code native `mcp.json`. Do not apply live
on the laptop unless asked. After packet edits, use skill
`work-laptop-packet-ops` to sync the sibling.

### U6. Vault status, names only

Use skill `work-laptop-vault-status` to check whether the packet vault exists,
is ciphertext, and which mapped keys are nonempty. Names only. Do not print
secret values.

### U7. Docker Model Runner (preferred; automation disabled)

Follow `DOCKER-MODEL-RUNNER.md` and
`helpers/docker-model-runner/examples/redeploy-checklist.md`. Do not implement
an Ansible DMR role until `work_laptop_docker_model_runner_automation` is
commissioned. Do not extend the legacy public-share rsync helpers for new model
work.

### U8. Add a controller download (legacy share path)

Use skill `work-laptop-model-public-download` to add <repo> <file.gguf> to
`helpers/work-mac-local-models/models-to-copy.list`. The controller helper only
echoes the download command. Do not run the download unless asked. Prefer DMR
for new work.

### U9. Pin Qwen3-4B for Jan RAG, then sync and push

Use skill `work-laptop-model-runtime-import` to pin Qwen3-4B as the Jan RAG
chat model, then `work-laptop-packet-ops` to sync and push the packet and
sibling.

---

## Work laptop (sibling apply)

Use these **on the work Mac** after pulling the sibling repo. Do not invent
SSH/scp apply paths from the controller unless the user explicitly asks for a
one-off.

### L1. Apply on the work laptop

Use skill `work-laptop-day2-apply` on the work Mac after `git pull`. Full apply
is `--skip-tags hosts_file`. If the change is only in the sequential tail of
`playbook.yaml` roles, use the quick window instead: `--tags recent_10` for the
last 10 role entries, or `--tags recent_15` for the last 15. Still pass
`--skip-tags hosts_file`. Then verify Continue, Cline, and `cx-*`. Do not invent
an ad-hoc SSH or scp apply. Do not use a recent window for a change outside that
tail.

### L2. Work-laptop recorded facts

Use skill `work-laptop-recorded-facts` for the work laptop model, chip, macOS
version, hostname, and username. Read `host_vars/work-laptop.yaml` first. Do
not search the tree or guess.

### L3. Add a work-laptop import (legacy share path)

Use skill `work-laptop-model-runtime-import` so the work-laptop helper echoes
the copy and Ollama import commands for models already in `models-to-copy.list`.
Point at `~/models`, not the share. Do not run those commands. Prefer DMR for
new work.

### L4. Drop inbox feedback for upstream

When the laptop differs from pulled packet behavior, add a dated note under
`inbox/` describing the failure and the fix that worked. Upstream then runs
**U1** (`work-laptop-inbox-evaluate-fix`) so durable items land in the source
packet and `deviations/`. Do not keep accepted accommodations only in inbox
prose.

### L5. Remediation return (repair → evidence → source)

Use skill `work-laptop-remediation-return` when a day-2 apply or managed client
config fails on the work Mac. Capture the error, make the smallest correction
(prefer source packet when available; otherwise mark
`upstream-backport-needed`), write a dated `inbox/` receipt, validate with
playbook + focused check, then commit/push non-secret files. Prefer source
packet over unregistered laptop drift.
