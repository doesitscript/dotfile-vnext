# Codex multi-terminal workflow — evolution

**Origin:** `docs/one_off_tasks/codex-multi-terminal-workflow/`  
**Status:** one-off trial (`*_one_off_tasks` suffix on deployed Mac artifacts)

## Where we are

- Four **local** Codex lanes map to **different homelab hardware** via LiteLLM
  (`litellm.hom.lab/v1`), not one GPU shared across terminals.
- One **cloud** lane (`cx-research`) for tool/MCP-heavy work until local shell-tool
  ATDD passes.
- Shell entrypoints: `cx-deep`, `cx-desktop`, `cx-skills`, `cx-hvh01`, `cx-research`
  (each prints a banner, sets a terminal title, then starts Codex).
- Role-specific `model_instructions_file` copies are deployed with the `_one_off_tasks`
  suffix for navigation, implement, skills, and hvh01 lanes.
- `local-hvh01_one_off_tasks` profile targets `qwen2.5-coder-1.5b@hvh01` on the GTX
  1060 — a fourth **physical** GPU lane not previously wired for Codex.

| Terminal | Alias | Lane | Hardware |
| --- | --- | --- | --- |
| Navigate | `cx-deep` | `qwen2.5-coder-32b@k3s02-vllm` | RTX 5090 @ k3s-02 |
| Implement | `cx-desktop` | `qwen2.5-coder-14b@desktop` | RX 9060 XT @ desktop |
| Skills / quick | `cx-skills` | `qwen2.5-coder-7b@desktop` | RX 9060 XT @ desktop |
| Utility / fast | `cx-hvh01` | `qwen2.5-coder-1.5b@hvh01` | GTX 1060 @ HVH-01 |
| Research / tools | `cx-research` | `gpt-5.4` (cloud) | OpenAI |

## Now

- Run the 4-terminal local layout plus `cx-research` when you need tools, MCP, or web.
- Use `/status` in each TUI to confirm model + provider before trusting a lane.
- Use `/compact` early on local lanes (12k–28k context windows).
- Treat local lanes as **chat / review / planning** until tool-loop ATDD is green.

## Soon

- Promote role-specific `instructions-*_one_off_tasks.md` content after you like the
  tone; fold into Ansible-managed Codex templates under
  `docs/plans/2026-09-01--homelab-local-ai-clients-codex/templates/`.
- Add `cx-tools` (Ministral @ desktop) if you want a dedicated experimental lane.
- Run acceptance probes from `model-lane-acceptance/codex/` for any lane you rely on
  daily.

## When tool loop is green

- Move implementation work from cloud `cx-research` → `cx-desktop` or `cx-deep`.
- Re-run `model-lane-acceptance/codex/pending/tool-loop.yml` scenarios with receipts.
- Drop the “use cloud for tools” banner text from the shell helpers.

## Later

- Add `~/.codex/gemini-research_one_off_tasks.config.toml` (or Ansible template) once
  Gemini credentials and a LiteLLM Responses route exist — see
  `docs/plans/2026-09-01--homelab-local-ai-clients-codex/templates/gemini-via-litellm.config.toml.example`.
- Promote `*_one_off_tasks` artifacts into normal repo automation (`roles/…`,
  `codex-homelab` without suffix) and remove the one-off install.
- Optional: iTerm2 window layout / tmux session script for persistent 4-pane layout.

## Undo

```bash
docs/one_off_tasks/codex-multi-terminal-workflow/deploy/uninstall_one_off_tasks.sh
```
