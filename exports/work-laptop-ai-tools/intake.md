# Intake (processed)

Inbound from the work-laptop sibling. Processed by
`work-laptop-improvement-review` + parent role updates.

## Delivered (this cycle)

| Ask | Where |
| --- | --- |
| Aider must create/edit files (not only suggest shell) | `roles/aider` → `dirty-commits: true`, `suggest-shell-commands: false`, `yes-always: true`, `.aiderignore` |
| Aider 0.86+ key conversion (`yes` → `yes-always`) + map + fail probe | `roles/aider` + deviation `aider-write-edit-workflow` |
| Homebrew Python 3.12 for pipx | `aider_pipx_python` (optional `--python`) |
| Cline skip JSONC VS Code settings merge | `roles/cline_ide` jq gate |
| Firecrawl respect `npm prefix -g` | `roles/mcp_servers/firecrawl` mac tasks |
| Kilo/Cline managed config must merge/convert (not blind overwrite) | `kilo_ide_apply_mode: merge`, `cline_ide_providers_merge`, deviation `managed-ide-config-merge` |
| Stable HVH-01 SMB mount (Finder `/Volumes` collision) | `helpers/work-mac-local-models/setup_shares.sh` + deviation `smb-stable-mount-hvh01` (legacy share path) |
| Bootstrap OpenSSL-skip preflight via task content | `bootstrap/bootstrap-macos-ansible.sh` + deviation `bootstrap-openssl-content-gate` |
| Prefer DMR over share/rsync for local models | `DOCKER-MODEL-RUNNER.md`; automation `disabled` until commissioned |
| Continue MCP NVM+npmrc prefix abort (Context7/Firebase) | `bin/work-laptop-nvm-exec` resolves Node without `nvm.sh`; deviation `npm-global-prefix` |
| Continue Jan autocomplete + LiteLLM edit/apply | superseded by DMR 3B local models from `inbox/config.yaml`; keep `7b@desktop` edit/apply |
| Continue corrected config (`inbox/config.yaml`) | DMR **1.5B** default autocomplete; LM Studio embed; no Jan/Ollama on packet; fix AWS IaC `uvx` |
| Jan/Ollama Continue recipes | Parent only: `docs/lessons-learned/continue/jan-and-ollama-local-autocomplete.md` |
| AWS MCP OAuth / AWS IaC profile interactive | deviation `continue-mcp-oauth-aws-profile`; optional `aws_iac_mcp_aws_profile` |

See `deviations/register.yaml` for accepted long-term accommodations.

## Aider new-file habit

Before asking Aider to inspect or write a path: `/add <file>` so it is in the
chat. For a read-only planning pass, launch it with `aider --read <file>`.
Paths in chat are relative to the Git worktree root, even when Aider starts in
a nested directory. Aider can map a repository but does not automatically
expose every file's full contents to the model.

## Ignore guidance

Repo-root `.aiderignore` is deployed by the aider role from the intake ignore
list (tfstate, venvs, node_modules, IDE noise, etc.). Untracked local
`.aider*` runtime files stay gitignored; managed `.aiderignore` remains
tracked.
