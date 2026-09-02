# codex_homelab_profiles

Manages the macOS user-scoped, isolated Codex home for explicit homelab
LiteLLM routes. It does not manage the gateway secret: the launcher fetches a
short-lived value only when it starts a local Codex session.

## Current Managed Lane

`codex-homelab desktop` follows `codex_homelab_profiles_model`. On `mac-dev`
the host override now points that isolated desktop lane at
`ministral-3-8b@desktop` with a 24K context contract because the prior
`qwen2.5-coder-14b@desktop` path formed JSON-like tool requests without
executing them in Codex. Keep the lane experimental; this change removes the
known parser mismatch from the default laptop path.

## Multi-terminal (`codex_homelab_profiles_multi_terminal_state: present`)

When enabled on `mac-dev`:

- `~/.bashrc.d/codex-multi-terminal.bash` — role-owned deploy (`multi_terminal.yml`)
- Shared `~/.codex/local-{deep,fast,hvh01,tools}.config.toml` and lane instructions
- `~/bin/render_local_model_catalog` and `codex-homelab` launcher (`deep|fast|desktop|hvh01`)

Promotion plan: `docs/plans/2026-09-02--codex-multi-terminal-promotion/`

## Apply / Verify / Undo

| | Contract |
| --- | --- |
| Apply | `ansible-playbook playbooks/deploy_development_nodes.yaml --tags shell_config,bash_completion,codex_homelab_profiles --limit mac-dev` |
| Verify | `codex-homelab desktop exec --ephemeral --skip-git-repo-check -C /tmp 'Reply with exactly: desktop-managed-profile-ok'` |
| Undo (multi-terminal only) | `codex_homelab_profiles_multi_terminal_state: absent` + same Apply command — runs `multi_terminal_absent.yml` |
| Undo (full role) | `codex_homelab_profiles_state: absent` + same Apply command |
