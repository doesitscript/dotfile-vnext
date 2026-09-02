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

## Tab completion (no more beep)

**Problem:** `cx-de` + Tab beeped because readline had `show-all-if-ambiguous off`
(default).

**Fix deployed:** `~/.bashrc.d/shell-completion_one_off_tasks.bash`

| Setting | Effect |
| --- | --- |
| `show-all-if-ambiguous off` | With `menu-complete`, first Tab inserts inline instead of list-only |
| `print-completions-horizontally on` | Space-separated options under prompt (AWS CLI style) |
| `menu-complete` on Tab | First Tab inserts first match; repeat Tab cycles on same line |
| `complete -I` | Command-name completion for `cx-*` at line start |

**Try it** (new shell, or `source ~/.bashrc.d/shell-completion_one_off_tasks.bash`):

```text
cx-de<Tab>        → prompt becomes cx-deep; options shown horizontally below
<Tab>             → cx-deep-smoke, then cx-desktop, … (same prompt line)
<Shift-Tab>       → cycle backward
codex-homelab_one_off_tasks <Tab>  → deep desktop fast hvh01 tools
```

### Optional: fzf (paths and fuzzy pick)

fzf is **not required** for cx-* command cycling. For fuzzy **path** completion
(history, files, `cd` trees), install fzf and add to shell startup (from fzf
README via Context7):

```bash
brew install fzf
# In ~/.bashrc.d after bash-completion loads:
eval "$(fzf --bash)"
```

fzf uses `**` as the default completion trigger for fuzzy file/command search —
separate from plain Tab menu-complete above.

**Promote permanently:** fold `shell-completion_one_off_tasks.bash` into Ansible
`roles/common/shell_config/files/bashrc.d/` after trial.

---

When the trial sticks:

1. Fold profiles into `docs/plans/…/templates/` without `_one_off_tasks` suffix.
2. Extend `codex_homelab.sh` with `hvh01` and role-specific instructions.
3. Add `roles/.../files/bashrc.d/codex-multi-terminal.bash` via Ansible.
4. Run `uninstall_one_off_tasks.sh` and remove this folder or mark it archived.
