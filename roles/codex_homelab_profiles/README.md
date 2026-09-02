# codex_homelab_profiles

Manages the macOS user-scoped, isolated Codex home for explicit homelab
LiteLLM routes. It does not manage the gateway secret: the launcher fetches a
short-lived value only when it starts a local Codex session.

## Current Managed Lane

`codex-homelab desktop` uses `qwen2.5-coder-14b@desktop` with the measured
12K context window. It is a concise coding-chat lane, not an autocomplete or
autonomous shell-agent claim.

## Multi-terminal (`codex_homelab_profiles_multi_terminal_state: present`)

When enabled on `mac-dev`:

- `files/bashrc.d/codex-multi-terminal.bash` — `cx-deep`, `cx-desktop`, `cx-skills`, `cx-hvh01`, `cx-research`
- Shared `~/.codex/local-{deep,fast,hvh01}.config.toml` and lane instructions
- `~/bin/render_local_model_catalog` and `codex-homelab` launcher (`deep|fast|desktop|hvh01`)

Promotion plan: `docs/plans/2026-09-02--codex-multi-terminal-promotion/`

## Apply / Verify / Undo

| | Contract |
| --- | --- |
| Apply | `ansible-playbook playbooks/deploy_codex_homelab_profiles.yaml --limit mac-dev` |
| Verify | `codex-homelab desktop exec --ephemeral --skip-git-repo-check -C /tmp 'Reply with exactly: desktop-managed-profile-ok'` |
| Undo | Set `codex_homelab_profiles_state: absent`, then rerun the playbook |
