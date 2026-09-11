---
name: work-laptop-remediation-return
description: "Use when a work-laptop packet apply or managed client configuration fails and the correction, evidence, validation, and source-packet handoff must be captured. Do not use for a routine successful day-2 apply or a source-only design change without laptop evidence."
---

# Work-Laptop Remediation Return

Repair a demonstrated work-laptop configuration failure while preserving the
parent packet as design authority.

## Inputs

- Failing command and relevant error output
- Affected managed path, role, or client
- Whether `dotfile-vnext/exports/work-laptop-ai-tools/` is available

## Workflow

1. Read the error and identify the controlling packet role, template, or
   `host_vars/work-laptop.yaml` value. Do not patch a generated user-home file.
2. Read `deviations/register.yaml` and relevant dated inbox notes. Classify the
   problem as a source defect, an accepted laptop deviation, or an unverified
   environment issue.
3. When the parent packet is available, edit it first and sync through
   `work-laptop-packet-ops`. When unavailable, make only the smallest sibling
   correction required to recover and mark it `upstream-backport-needed` in the
   inbox receipt.
4. Add or update a dated inbox item with the observed error, root cause, changed
   source paths, exact validation, and any remaining boundary. Never record
   secret values.
5. Run the normal day-2 apply:

   ```bash
   .venv/bin/ansible-playbook playbook.yaml -i inventory.yaml --skip-tags hosts_file
   ```

6. Run a focused check for the rendered artifact or repaired command. Do not
   claim success from a changed task alone.
7. Commit and push only reviewed, non-secret files. Never commit vault files,
   API keys, generated user-home configs, or temporary logs.

## Authority Rule

Source-packet configuration wins over laptop-only behavior. Deprecate a
laptop-only deviation unless it is explicitly accepted in
`deviations/register.yaml`.

## Outputs

- Validated source correction or an explicit `upstream-backport-needed` receipt
- Dated inbox evidence and next owner
- Commit and push result when requested

## Failure Boundaries

- Do not force-pull, reset, or overwrite generated user-home config.
- Do not treat sibling-only changes as the final source of truth.
- Stop and report when credentials, vault access, or a parent-source conflict
  blocks validation.

## Handoffs

- `work-laptop-day2-apply` for normal laptop convergence
- `work-laptop-inbox-evaluate-fix` for upstream process of inbox receipts
- `work-laptop-improvement-review` for deviation intake and broader debt review
- `work-laptop-packet-ops` for parent-to-sibling validation and sync
- `work-laptop-ide-clients` for Continue, Cline, Zed, or `cx-*` configuration