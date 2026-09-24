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
active `inbox/` notes **and** sibling working-tree diffs that change packet
behavior, fix durable items in the source packet (prefer packet over
unregistered laptop drift), register deviations, then sync and push the
sibling. Do not treat the sibling as design authority. This is the upstream
half of the feedback loop in `DEPENDENCY-MAP.md` § Feedback loop.

### U2. Inbound laptop feedback review (audit only)

Use skill `work-laptop-improvement-review` to pull the latest sibling, ingest
inbound laptop feedback, and register accepted deviations. Audit only unless
asked to implement. For implement mode, use U1 instead.

### U3. Sync source to sibling

Use skill `work-laptop-packet-ops` to sync the work-laptop-ai-tools source
packet to the sibling. Validate the export contract, then copy every manifest
path from `dotfile-vnext/exports/work-laptop-ai-tools/` into the sibling
checkout so the sibling matches the packet. Sync **always refreshes**
`scripts/recent_and_next.md` (full + grouped + recent apply commands). Do not
treat the sibling as design authority. Do not commit or push.

### U3b. Update AI tools and client configuration by capability tag

The stable capability catalog is `group_vars/all/work_laptop_capabilities.yml`.
Use these commands on the work laptop after pulling the sibling packet. Start
with the preview, then apply the smallest capability that covers the change.

```bash
# First target: all AI tools and their managed configuration.
.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml \
  --skip-tags hosts_file --tags ai_tools --check --diff
.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml \
  --skip-tags hosts_file --tags ai_tools

# Narrower AI client/configuration refresh.
.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml \
  --skip-tags hosts_file --tags ai_clients

# Jan local runtime/RAG configuration only; no model download.
.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml \
  --skip-tags hosts_file --tags model_runtime

# AI MCP integrations only.
.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml \
  --skip-tags hosts_file --tags mcp
```

`model_download` is metadata-only for now. Use the documented model arrival
or Docker Model Runner helpers for model acquisition; do not assume that
`--tags model_download` downloads weights.

### U3c. Deploy all AI CLI apps (model catalogs)

After editing commissioned models in parent
`inventory/group_vars/all/ai_cli_apps.yml` and client role/host_vars lists,
sync the packet, then on the laptop. `ai_tools` is the broader first target;
`ai_cli_apps` remains the legacy narrow alias for the client role set:

```bash
ansible-playbook playbook.yaml --tags ai_cli_apps
```

Parity check from `dotfile-vnext`:

```bash
bin/codex-env python model-lane-acceptance/scripts/check-ai-cli-model-parity.py
```

### U3d. Terratest quickstart (Go + Terraform testing)

Context7: Terratest is a Go library (Go >= 1.26 cited; packet floor 1.22).
Packet roles: `golang_cli`, `terraform_cli`, `terratest_quickstart`.

Sync, push sibling, then on the work Mac:

```bash
.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml \
  --skip-tags hosts_file --tags terratest
cd ~/Documents/develop/terratest-quickstart/test
go test -v -timeout 30m
```

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

**Default apply card:** `scripts/recent_and_next.md` (refreshed on every
upstream → sibling sync). Prefer that file over reconstructing commands here.

### L1. Apply on the work laptop

Use skill `work-laptop-day2-apply` on the work Mac after `git pull`. Open
`scripts/recent_and_next.md` and run either:

- **full update** (`--skip-tags hosts_file`), or
- **grouped update** (`--tags ai_tools` default; or `ai_clients` /
  `model_runtime` / `mcp`), or
- **recent-change window** (`recent_10` / `recent_15`) when only the playbook
  role-list tail changed.

Then verify Continue, Cline, and `cx-*`. Do not invent an ad-hoc SSH or scp
apply.

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
packet over unregistered laptop drift. Upstream then runs **U1** so the fix
becomes packet + `deviations/` permanence — that closed loop is how we stop
regressing the same laptop failure.
