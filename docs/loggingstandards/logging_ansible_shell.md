```text
Cursor instructions (repo-wide logging/output improvements)

1) Create a single logging helper for bash, and make every shell script source it
- Add: lib/log.sh
  - Provide functions: log_info, log_warn, log_error, die, run, section
  - Support LOG_LEVEL (error|warn|info|debug), NO_COLOR=1, and timestamps
  - Write all logs to stderr; command output passthrough but prefix lines in debug mode
  - Exit codes must propagate (run should return command exit code)
- Update every *.sh entry script (bootstrap-local.sh, bin_bootstrap-local.sh, any scripts in bin/) to:
  <!-- - set -euo pipefail (only where safe; if not safe, use set -e and add TODO) -->
  - source lib/log.sh at the top
  - replace echo with log_* calls
  - wrap external commands with run "description" <cmd...>

2) Standardize Ansible output & logs (controller-side)
- Update ansible.cfg:
  - Set stdout_callback = yaml (or community.general.yaml if present)
  - Set bin_ansible_callbacks = True
  - Set display_skipped_hosts = False
  - Set display_ok_hosts = True
  - Set timeout = 60
  - Set forks = 10 (or 5 if you want conservative)
  - Set retry_files_enabled = False
  - Set log_path = ./logs/ansible.log
- Create logs/.gitkeep and ensure logs/ is gitignored except .gitkeep

3) Add a run wrapper script so every playbook run is consistently logged
- Add: bin/run-playbook.sh
  - Usage: bin/run-playbook.sh <playbook.yaml> [--limit ...] [--extra-vars ...]
  - Creates a timestamped run dir: logs/runs/YYYYMMDD_HHMMSS_<playbook>/
  - Captures:
    - full stdout/stderr to run.log
    - ansible.log copied into the run dir after execution
    - a copy of inventory.yaml and host_vars used (tar/zip)
  - Exits with the playbook’s exit code

4) Make bootstrap scripts write structured “facts” consistently (json + text)
- Add: facts/README.md explaining contents and lifecycle
- Ensure every bootstrap script writes:
  - facts/<physical_node>.json (machine-readable)
  - facts/<physical_node>.log (human-readable)
- For bash: write json via jq if present; if not present, write minimal key/value text and keep json optional
- For PowerShell: keep as you already have (don’t change PS)

5) Add a repo-wide “logging contract” doc that Cursor follows
- Add: LOGGING_AND_OUTPUT.md (or update existing LOGGING_AND_ERRORS.md) to include:
  - severity levels, formatting, where logs go, what never to print (secrets)
  - required fields for facts json (hostname, ip, surface types, ports, thumbprints)
  - how to run playbooks via bin/run-playbook.sh
- Ensure scripts reference this doc in header comments

6) Add secret-redaction and “no secrets in logs” guardrails
- Add: lib/redact.sh
  - function redact_stream that masks common patterns:
    - password=, token=, secret=, key=
    - WinRM passwords in inventory/host_vars
  - In bin/run-playbook.sh, pipe output through redact_stream when writing run.log
- Ensure Ansible tasks that print variables never print vault contents; remove debug tasks printing vars

7) Make failures actionable (single-line summary at end)
- In bin/run-playbook.sh, if exit non-zero:
  - print a short summary:
    - playbook name, exit code, run dir
    - “open logs/runs/.../run.log”
- In lib/log.sh die(): always print the command that failed and its exit code if available

8) Normalize line endings + prevent CRLF surprises for logs/scripts
- Ensure .gitattributes enforces:
  - *.sh, *.yaml, *.yml, *.ps1, *.cmd, *.bat  => LF
  - and all files globally use LF
- Add a pre-commit optional script (do not require) at bin/hooks/pre-commit-example that checks line endings and blocks mixed EOL

9) Update existing scripts to use the new helpers (minimum set)
- Must update at least:
  - bootstrap-local.sh
  - bin_bootstrap-local.sh
  - any script referenced in README.md / operator_runbook.md
- Leave deeper scripts for later, but add TODO markers.

Deliverables checklist
- lib/log.sh
- lib/redact.sh
- bin/run-playbook.sh
- logs/.gitkeep + gitignore update
- ansible.cfg updated
- facts/README.md
- LOGGING_AND_OUTPUT.md (or update LOGGING_AND_ERRORS.md)
- Updated scripts to source lib/log.sh and use run/log_* 
```
