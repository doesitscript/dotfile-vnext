# Work Laptop AI Tools Build Target

This packet is intentionally isolated from the repo's normal shared playbooks
and development-node automation. It exists to export a minimal, explicit,
local-run Ansible slice for a work MacBook.

Primary delivery model:

- `dotfile-vnext` remains the source of truth
- `../work-laptop-ai-tools` is the generated sibling build target repo
- the zip archive is optional and secondary
- the sibling repo is replaceable and should never become the design authority

## Associated skills (quick find)

These skills live in `dotfile-vnext` (not in this generated sibling). Use them
from that repo so you can re-sync or validate this packet without hunting.

| Skill | Path in `dotfile-vnext` | Use for |
| --- | --- | --- |
| `work-laptop-export-pack` | `skills/implementation/work-laptop-export-pack/SKILL.md` | Sync this sibling repo, validate the export contract, run external smoke preview |
| `project-skill-runtime-bridge` | `skills/implementation/project-skill-runtime-bridge/SKILL.md` | Keep `work-laptop-export-pack` discoverable under `.cursor/skills` |

Governing plan packet (paired-agent pilot history):

- `docs/plans/2026-09-02--work-laptop-export-pilot/README.md`
- related paired-agent skills when re-running that plan loop:
  `paired-agent-plan-implementer`, `paired-agent-plan-evaluator`

Copy-paste from `dotfile-vnext`:

```bash
# Use skill work-laptop-export-pack
bin/codex-env python \
  skills/implementation/work-laptop-export-pack/scripts/validate_export_contract.py
bin/codex-env python \
  skills/implementation/work-laptop-export-pack/scripts/sync_sibling_repo.py
bin/codex-env python \
  skills/implementation/work-laptop-export-pack/scripts/roundtrip_smoke.py \
  --packet-dir /Users/joshc/develop/work-laptop-ai-tools \
  --ansible-command "$PWD/bin/codex-env ansible-playbook"
```

Current scope:

- target-local execution on the exported work laptop only
- guarded `ansible_connection: local`
- Codex CLI install through `nvm` + npm
- baseline `~/.codex/config.toml` creation for Codex CLI on the work laptop
- Codex local profile/config export for the current homelab model lanes
- `/private/etc/hosts` entries for current homelab names
- VS Code install + `Continue.continue`, `redhat.ansible`, `redhat.vscode-yaml`,
  and `hashicorp.terraform`
- VS Code `.vscode/mcp.json` entries for HashiCorp Terraform MCP and the
  official AWS MCP Server plus AWS IaC MCP
- `~/.continue/config.yaml` with the existing LiteLLM chat/edit lanes plus
  Terraform MCP, AWS MCP, and AWS IaC MCP server entries
- Zed configuration only (`zed_ide_install_cask: false`) — deploys
  `~/.config/zed/settings.json` for Zed Agent model routing, inline assistant,
  commit messages, thread summaries, and Zed `context_servers` for Terraform
  MCP, AWS MCP, and AWS IaC MCP; does **not** install or upgrade the Zed app
- local HashiCorp Terraform CLI and Terraform MCP server install
- Homebrew `uv` install as needed for `awslabs.aws-iac-mcp-server@latest`
- minimal shared bash startup scaffolding required by the Node/Codex path

Safety posture:

- no main inventory host entry
- no SSH / remote-management path
- no participation in `playbooks/deploy_development_nodes.yaml`
- explicit `work_laptop_export_mode=true` gate
- explicit local hostname match gate
- remote autocomplete and remote edit-prediction lanes stay disabled by default

Primary files:

- `ansible.cfg`
- `bootstrap/bootstrap-contract.sh`
- `bootstrap/bootstrap-tooling.yaml`
- `bootstrap/bootstrap-macos-ansible.sh`
- `collections/requirements.yml`
- `scripts/requirements.txt`
- `playbook.yaml`
- `inventory.yaml`
- `host_vars/work-laptop.yaml`
- `roles/work_laptop_codex_cli/tasks/main.yml`
- `roles/work_laptop_packet_receipt/tasks/main.yml`
- `export-manifest.yml`

Canonical run on the generated sibling repo checkout on the work laptop:

Fresh-machine bootstrap:

- Xcode Command Line Tools if Homebrew is not already installed
- sudo rights for the `/private/etc/hosts` update

```bash
./bootstrap/bootstrap-macos-ansible.sh
```

That script is the intended first-touch handoff into the packet-contained
tooling bootstrap and then the packet playbook. Pass normal
`ansible-playbook` args after `--`:

```bash
./bootstrap/bootstrap-macos-ansible.sh -- -K
```

Force-upgrade path when you explicitly want to refresh existing tooling:

```bash
./bootstrap/bootstrap-macos-ansible.sh --force-upgrade-all -- -K
```

Bootstrap only, without handing off into the packet playbook:

```bash
./bootstrap/bootstrap-macos-ansible.sh --bootstrap-only
```

## After a source fix (work laptop recovery)

When a bootstrap/playbook failure is fixed upstream and pushed to this sibling
repo, run these on the work laptop. Prefer this path over one-off editor edits
in the checkout — local patches get overwritten on the next sync/pull.

Branch policy: stay on `master` (this sibling) / `main` (`dotfile-vnext`). Do
not create feature branches for normal fix → sync → pull loops unless a
special reason is called out.

1. Pull the latest sibling checkout (stay on `master`):

```bash
cd ~/Documents/develop/work-laptop-ai-tools
git status
git branch --show-current   # expect: master
git pull
```

2. Only if you (or a local editor agent) changed files in this checkout while
   waiting for the upstream fix, discard those local edits so the pulled fix
   wins. Skip this step when `git status` is clean after `git pull`.

```bash
# discard edits to one file (NOT a branch switch):
git restore roles/python/tasks/mac.yml

# or discard all tracked local edits:
# git restore .
```

`git restore <file>` / `git checkout -- <file>` only resets working-tree files.
It does not create or switch branches.

3. Re-run bootstrap + packet playbook (asks for sudo password when hosts-file
   or other become tasks need it):

```bash
./bootstrap/bootstrap-macos-ansible.sh -- -K
```

4. Confirm this OpenSSL skip fix is present before re-running (expect the
   probe/report tasks, not `community.general.homebrew` installing openssl):

```bash
rg -n "Report existing OpenSSL|Install missing required Python|openssl@3" roles/python/tasks/mac.yml roles/python/defaults/main.yml
# expect: no openssl@3 in python_macos_brew_packages
# expect: task names include "Report existing OpenSSL instead of reinstalling"
ls -ld "$(brew --prefix)/opt/openssl@3"
```

5. Optional probes when Homebrew / OpenSSL was the failure:

```bash
which openssl
openssl version
brew list --versions openssl@3
brew --prefix openssl@3
```

6. Optional longer-term Homebrew tap trust (instead of relying forever on the
   bootstrap `HOMEBREW_NO_REQUIRE_TAP_TRUST=1` session opt-out). Trust only taps
   you intentionally keep:

```bash
brew tap-info --installed
brew trust <user>/<tap>
```

7. If `ansible-playbook` is not on your shell `PATH`, use the packet venv
   binary (bootstrap already does this):

```bash
./.venv/bin/ansible-playbook --version
./.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml --list-tasks
```

Paste the full failing task output back to the agent when something still
stops the run; fixes belong in `dotfile-vnext` source on `main`, then sync →
sibling `master` push → you `git pull` on `master` → re-run the commands above.

Direct playbook previews still work when you want them separately:

```bash
ansible-playbook \
  playbook.yaml \
  -i inventory.yaml \
  --list-hosts
```

```bash
ansible-playbook \
  playbook.yaml \
  -i inventory.yaml \
  --list-tasks
```

Project skill helpers:

```bash
bin/codex-env python \
  skills/implementation/work-laptop-export-pack/scripts/sync_sibling_repo.py
```

```bash
bin/codex-env python \
  skills/implementation/work-laptop-export-pack/scripts/roundtrip_smoke.py \
  --packet-dir /Users/joshc/develop/work-laptop-ai-tools \
  --ansible-command "$PWD/bin/codex-env ansible-playbook"
```

Default workflow stops there. Do not rebuild or validate the archive branch
unless you explicitly want zip output or zip-based proof.

Explicit opt-in archive helper:

```bash
bin/codex-env python \
  skills/implementation/work-laptop-export-pack/scripts/build_export_archive.py \
  --overwrite
```

The round-trip helper is for build-target proof only and supports both paths:

- sibling repo proof with `--packet-dir <external checkout>`
- zip proof only when `--archive-path <zip>` is supplied explicitly

Preview mode runs bootstrap `--help`, bootstrap `--dry-run --bootstrap-only`,
playbook `--syntax-check`, `--list-hosts`, and `--list-tasks`. Add `--apply`
only when the external checkout or extracted packet is running on the real work
laptop and a mutating apply is intended.

Remote autocomplete policy:

- Continue autocomplete is intentionally disabled in this packet
- Zed edit predictions are intentionally disabled in this packet
- do not point editor autocomplete-style features at remote LiteLLM, vLLM, or
  remote Ollama infrastructure from this laptop
- only revisit this with a deliberately local-only small model running on the
  Mac itself after validation

Secret and access boundaries:

- `continue_ide` ships `REPLACE_WITH_LITELLM_KEY` by design; supply the real gateway key on the work laptop before relying on Continue.
- `continue_ide` intentionally renders no autocomplete lane unless
  `continue_ide_autocomplete_enabled=true` is set for a local-only future path.
- `zed_ide` ships `REPLACE_WITH_LITELLM_KEY` in `~/.config/zed/openai.env`;
  use `zed-homelab` or save the key in Zed's provider UI before relying on
  Zed Agent model access.
- `zed_ide` intentionally leaves `edit_predictions` disabled unless
  `zed_ide_edit_predictions_enabled=true` is set for a local-only future path.
- AWS MCP uses OAuth against the official managed AWS endpoint on first use; no
  AWS secrets are exported in this packet.
- `codex-homelab` fetches the LiteLLM gateway key from `hom-lab-ctl-k3s-02` at launch time, so the work laptop still needs the expected SSH access path.
- AWS IaC MCP uses the local AWS CLI/profile context on the work laptop; no
  AWS secrets are exported in this packet.

Bootstrap behavior:

- default behavior is bootstrap packet `.venv`, bootstrap packet-local collections, run the packet-contained tooling bootstrap playbook, then hand off into `playbook.yaml`
- default install behavior is install-if-missing only
- the packet bootstrap playbook reuses existing repo role logic for `ansible_dev_tools`, `python`, and optional `package_manager` refreshes
- packet Ansible lives at `.venv/bin/ansible-playbook` and the repo-style public entrypoint is `~/.local/bin/ansible-playbook`
- existing Homebrew, packet `.venv`, packet collections, and packet tooling are left alone unless a `--force-*` flag is passed
- a newly installed Homebrew gets its `shellenv` line appended once to the active login-shell profile
- bootstrap and both packet playbooks set `HOMEBREW_NO_REQUIRE_TAP_TRUST=1` so Homebrew 6 tap-trust on pre-existing third-party taps does not abort official formula installs (`openssl@3`, `pyenv`, etc.); prefer long-term `brew trust <tap>` for taps you keep
- Python macOS brew deps skip installing/upgrading `openssl@3` and
  `ca-certificates` when a usable Homebrew OpenSSL already exists; those
  re-fetches were failing mid-bottle on the work laptop
- remaining brew deps (`readline`, `sqlite`, `xz`, `zlib`, `pyenv`, `pipx`) are
  installed only when their `$(brew --prefix)/opt/<formula>` path is missing
- Windows-only role paths (Chocolatey, PowerShell profile, WinRM bash drop-in) are not executed on this macOS packet; platform dispatch uses dynamic `include_tasks` so those files do not spam skipped task noise
- the packet carries a local contract file so the export skill can validate path and method drift before sibling-repo sync or zipping
- the Terraform MCP role installs Homebrew `go` if needed, then publishes
  `terraform-mcp-server` to `~/.local/bin`
- the AWS IaC MCP role installs Homebrew `uv` if needed, then configures
  `uvx awslabs.aws-iac-mcp-server@latest`

Safeguards:

- the target repo must live outside this repo
- the sync helper requires a real git checkout by default
- the playbook still fails closed unless `work_laptop_export_mode=true`,
  `ansible_connection=local`, and the short hostname matches
- the sibling repo is generated from the manifest include list only
- the sync helper tracks managed files in `.build-target-sync-state.json` so
  later refreshes can remove stale generated files without touching `.git/`

Current target facts:

- short hostname: `MLLXLJJ2XVFJ`
- username: `a805120`
- model: `MacBook Pro 14-inch (November 2023)`
- chip: `Apple M3 Pro`
- macOS: `Tahoe 26.6.1`
