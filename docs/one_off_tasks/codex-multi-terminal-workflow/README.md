# Codex multi-terminal workflow (one-off trial)

**Scope:** try-before-commit package for four distributed local Codex terminals plus a
cloud research lane. All Mac-deployed artifacts use the `_one_off_tasks` suffix.

**Evolution / next steps:** [evolution.md](./evolution.md)

## Quick start

```bash
# From repo root — deploy to Mac (idempotent)
chmod +x docs/one_off_tasks/codex-multi-terminal-workflow/deploy/*.sh
docs/one_off_tasks/codex-multi-terminal-workflow/deploy/install_one_off_tasks.sh

# Load aliases in current shell
source ~/.bashrc.d/codex-multi-terminal_one_off_tasks.bash

# Open four terminals and run one command each:
cx-deep
cx-desktop
cx-skills
cx-hvh01      # optional 4th local GPU
cx-research   # cloud when you need tools/MCP
```

Each `cx-*` command **prints a banner** (lane, GPU, repo, tips) and **sets the terminal
window title** before starting Codex.

Smoke tests (non-interactive):

```bash
cx-deep-smoke
cx-hvh01-smoke
```

Undo:

```bash
docs/one_off_tasks/codex-multi-terminal-workflow/deploy/uninstall_one_off_tasks.sh
```

---

## Mental model

Your homelab is a **distributed inference mesh**. LiteLLM routes each Codex profile to a
different `model@host` on different hardware. Four terminals = four lanes, not four
clients fighting over one GPU.

```text
  cx-deep      → qwen2.5-coder-32b@k3s02-vllm  → RTX 5090 @ k3s-02
  cx-desktop   → qwen2.5-coder-14b@desktop     → RX 9060 XT @ desktop
  cx-skills    → qwen2.5-coder-7b@desktop      → RX 9060 XT @ desktop
  cx-hvh01     → qwen2.5-coder-1.5b@hvh01    → GTX 1060 @ HVH-01
  cx-research  → gpt-5.4 (cloud)               → OpenAI default ~/.codex
```

`/model` inside a session switches models **within the same provider** only. Pick
provider at terminal launch (`cx-*`), not mid-session.

---

## Aliases and what they do

| Command | Default cwd | Launcher | Profile / home |
| --- | --- | --- | --- |
| `cx-deep` | `~/develop/dotfile-vnext` | `codex-homelab_one_off_tasks deep` | `local-deep_one_off_tasks` |
| `cx-desktop` | `~/develop/dotfile-vnext` | `codex-homelab_one_off_tasks desktop` | `~/.codex-homelab/desktop_one_off_tasks` |
| `cx-skills` | `~/develop/global-skills` | `codex-homelab_one_off_tasks fast` | `local-fast_one_off_tasks` |
| `cx-hvh01` | `~/develop/dotfile-vnext` | `codex-homelab_one_off_tasks hvh01` | `local-hvh01_one_off_tasks` |
| `cx-hvh01 /other/path` | custom | same | same |
| `cx-research` | `~/develop/homelab-reference-library` | `codex` (cloud) | `~/.codex` default |
| `cx-research /other/path` | custom | same | same |

**Banner contents** (printed before every interactive launch):

- Lane name and `model@host`
- Physical GPU / host
- Default repo
- Intended task type
- TUI reminders (`/status`, `/compact`, `/mcp` on cloud)
- Local tool-loop caveat

**Terminal titles** (set via OSC sequence):

- `Codex DEEP — 32B @ 5090`
- `Codex DESKTOP — 14B @ 9060 XT`
- `Codex SKILLS — 7B @ 9060 XT`
- `Codex HVH-01 — 1.5B @ 1060`
- `Codex RESEARCH — cloud`

---

## Deployed Mac artifacts (`*_one_off_tasks`)

| Staged source (repo) | Deployed path (Mac) |
| --- | --- |
| `deploy/codex/local-deep_one_off_tasks.config.toml` | `~/.codex/local-deep_one_off_tasks.config.toml` |
| `deploy/codex/local-fast_one_off_tasks.config.toml` | `~/.codex/local-fast_one_off_tasks.config.toml` |
| `deploy/codex/local-hvh01_one_off_tasks.config.toml` | `~/.codex/local-hvh01_one_off_tasks.config.toml` |
| `deploy/codex-homelab/desktop_one_off_tasks/config.toml` | `~/.codex-homelab/desktop_one_off_tasks/config.toml` |
| `deploy/codex/instructions-*_one_off_tasks.md` | `~/.codex/instructions-*_one_off_tasks.md` |
| `deploy/scripts/render_local_model_catalog_one_off_tasks.sh` | `~/bin/render_local_model_catalog_one_off_tasks` |
| (render output) | `~/.codex/local-model-catalog_one_off_tasks.json` |
| `deploy/bin/codex-homelab_one_off_tasks.sh` | `~/bin/codex-homelab_one_off_tasks` |
| `deploy/bashrc.d/codex-multi-terminal_one_off_tasks.bash` | `~/.bashrc.d/codex-multi-terminal_one_off_tasks.bash` |
| `deploy/bashrc.d/shell-completion_one_off_tasks.bash` | `~/.bashrc.d/shell-completion_one_off_tasks.bash` |

Mode `0600` on profile configs; launcher mode `0700`.

### Shell integration

`~/.bashrc` is Ansible-managed and already sources `~/.bashrc.d/*.bash`. The one-off
snippet is dropped in as `codex-multi-terminal_one_off_tasks.bash` — **no edit to
`.bashrc` required**. The file header marks it non-permanent and points here.

If you ever need a manual hook (not expected on mac-dev):

```bash
# ONE-OFF non-permanent — docs/one_off_tasks/codex-multi-terminal-workflow/
source ~/.bashrc.d/codex-multi-terminal_one_off_tasks.bash
```

---

## Role-specific model instructions

| File | Lane | Role |
| --- | --- | --- |
| `instructions-navigation_one_off_tasks.md` | deep | Architecture, repo maps, read-heavy |
| `instructions-implement_one_off_tasks.md` | desktop | Implementation, code review |
| `instructions-skills_one_off_tasks.md` | fast/skills | global-skills edits |
| `instructions-hvh01_one_off_tasks.md` | hvh01 | Micro-tasks, tight context |

Referenced from each profile via `model_instructions_file`.

---

## In-session TUI tips

| Command | When |
| --- | --- |
| `/status` | Confirm model + provider after launch |
| `/compact` | Free context on local lanes (12k–28k windows) |
| `/model` | Switch homelab lane on local terminals only |
| `/mcp` | Cloud research terminal |
| `/new` | Fresh thread, same profile |
| `codex resume --last` | Resume prior session in this cwd |

---

## Verification

After `cx-deep` opens, type `/status` — expect `homelab-litellm` and
`qwen2.5-coder-32b@k3s02-vllm`.

Non-interactive:

```bash
codex-homelab_one_off_tasks deep exec --ephemeral --skip-git-repo-check -C /tmp \
  'Reply with exactly: pong'
```

---

## Lane maturity (honest)

From `model-lane-acceptance/codex/` and the Codex execution receipt:

| Lane | Status | Notes |
| --- | --- | --- |
| deep | Approved (chat) | Shell tool loop pending ATDD |
| desktop | Experimental | Chat/review OK; tools unexecuted |
| fast | Experimental | Not dependable for unattended work |
| hvh01 | New (one-off) | Run `cx-hvh01-smoke` before trusting |
| cloud | Production | Use for tools until local ATDD green |

---

## Package layout

```text
docs/one_off_tasks/codex-multi-terminal-workflow/
  README.md                 ← this file
  evolution.md              ← where we are / next steps
  deploy/
    install_one_off_tasks.sh
    uninstall_one_off_tasks.sh
    bin/codex-homelab_one_off_tasks.sh
    bashrc.d/codex-multi-terminal_one_off_tasks.bash
    codex/*.config.toml, instructions-*.md
    codex-homelab/desktop_one_off_tasks/config.toml
    scripts/render_local_model_catalog_one_off_tasks.sh
```

---

## Related repo docs

- [Codex local clients plan](../../plans/2026-09-01--homelab-local-ai-clients-codex/README.md)
- [Limitations and follow-up](../../plans/2026-09-01--homelab-local-ai-clients-codex/limitations-and-follow-up.md)
- [Client map](../../../model-lane-acceptance/client-map.yml)
- [Profile map](../../../model-lane-acceptance/codex/profile-map.yml)

---

## Tab completion (fzf-tab-completion)

**Upstream:** [lincheney/fzf-tab-completion](https://github.com/lincheney/fzf-tab-completion) — Tab
completion using fzf **with** bash’s existing completion mechanisms (not a separate `**` trigger).
Distinct from [junegunn/fzf](https://github.com/junegunn/fzf) `eval "$(fzf --bash)"`, which only adds
`**<Tab>` fuzzy path completion.

### Context7 / upstream install order

Per [installation](https://github.com/lincheney/fzf-tab-completion#installation) and
[bash setup](https://github.com/lincheney/fzf-tab-completion#bash):

1. **fzf** — `brew install fzf` ([junegunn/fzf](https://github.com/junegunn/fzf))
2. **macOS GNU tools** — `brew install gawk grep gnu-sed coreutils` (script uses `gawk`, `gsed`, `ggrep`)
3. **Clone** — `git clone https://github.com/lincheney/fzf-tab-completion.git ~/.local/share/fzf-tab-completion`
4. **bash-completion / progcomp** — already loaded via Ansible `bash_completion.bash` in `~/.bashrc.d/`
5. **Source + bind** (in `shell-completion_one_off_tasks.bash`):

```bash
source ~/.local/share/fzf-tab-completion/bash/fzf-bash-completion.sh
bind -x '"\t": fzf_bash_completion'
```

6. **Optional `**` trigger** — add `eval "$(fzf --bash)"` to `~/.bashrc` separately if wanted
7. **Optional Python REPL** — see [python3](https://github.com/lincheney/fzf-tab-completion#python3) and
   `deploy/python/usercustomize_one_off_tasks.py.example`

### One-off installers

```bash
docs/one_off_tasks/codex-multi-terminal-workflow/deploy/scripts/install_fzf_tab_completion_one_off_tasks.sh
docs/one_off_tasks/codex-multi-terminal-workflow/deploy/scripts/verify_fzf_tab_completion_one_off_tasks.sh
```

`install_one_off_tasks.sh` calls the fzf-tab-completion installer automatically.

### Env vars (trial defaults)

| Variable | Value | Effect |
| --- | --- | --- |
| `FZF_COMPLETION_AUTO_COMMON_PREFIX` | `true` | complete longest shared prefix before fzf |
| `FZF_COMPLETION_AUTO_COMMON_PREFIX_PART` | `true` | also complete partial common prefixes |
| `FZF_TAB_COMPLETION_PROMPT` | `'> '` | fzf picker prompt (upstream default) |
| `FZF_COMPLETION_OPTS` | `--layout=reverse --border --height=40% --bind tab:down,…` | Tab cycles in fzf; Enter accepts |

### Behavior examples

| Input | Result |
| --- | --- |
| `ls <Tab>` | fzf lists all files |
| `ls a<Tab>` | completes to `ls abc`; Tab again → fzf with remaining `a*` matches |
| `ls abcd<Tab>` | fzf or auto-prefix to `abcdef-` when `_PART=true` |
| `cx-de<Tab>` | completes toward `cx-deep`; Tab again → fzf with other `cx-*` aliases |

Reload:

```bash
source ~/.bashrc.d/shell-completion_one_off_tasks.bash
```

**Promote permanently:** fold into `roles/common/shell_config/files/bashrc.d/` after trial.

---

When the trial sticks:

1. Fold profiles into `docs/plans/…/templates/` without `_one_off_tasks` suffix.
2. Extend `codex_homelab.sh` with `hvh01` and role-specific instructions.
3. Add `roles/.../files/bashrc.d/codex-multi-terminal.bash` via Ansible.
4. Run `uninstall_one_off_tasks.sh` and remove this folder or mark it archived.
