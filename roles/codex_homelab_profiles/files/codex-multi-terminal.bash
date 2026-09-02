# Managed by Ansible role codex_homelab_profiles (multi-terminal).

_codex_mt_set_title() {
  printf '\033]0;%s\007' "$1"
}

_codex_mt_banner() {
  local lane="$1"
  case "$lane" in
    deep)
      cat <<'EOF'

━━ Codex DEEP ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Lane:   qwen2.5-coder-32b@k3s02-vllm
  GPU:    RTX 5090 @ k3s-02 (vLLM)
  Repo:   ~/develop/dotfile-vnext
  Use:    navigation, architecture, hard reasoning
  TUI:    /status  /compact  /model (homelab lanes only)
  Note:   local shell tools not ATDD-approved — use cx-research for tools
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
      _codex_mt_set_title "Codex DEEP — 32B @ 5090"
      ;;
    desktop)
      cat <<'EOF'

━━ Codex DESKTOP ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Lane:   qwen2.5-coder-14b@desktop
  GPU:    RX 9060 XT @ desktop (Ollama)
  Repo:   ~/develop/dotfile-vnext
  Use:    implementation chat, code review
  TUI:    /status  /compact
  Note:   isolated CODEX_HOME — shared ~/.codex skills not loaded here
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
      _codex_mt_set_title "Codex DESKTOP — 14B @ 9060 XT"
      ;;
    skills)
      cat <<'EOF'

━━ Codex SKILLS ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Lane:   qwen2.5-coder-7b@desktop
  GPU:    RX 9060 XT @ desktop (Ollama)
  Repo:   ~/develop/global-skills
  Use:    skill edits, small scoped changes
  TUI:    /status  /compact
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
      _codex_mt_set_title "Codex SKILLS — 7B @ 9060 XT"
      ;;
    hvh01)
      cat <<'EOF'

━━ Codex HVH-01 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Lane:   qwen2.5-coder-1.5b@hvh01
  GPU:    GTX 1060 @ HVH-01 (Ollama)
  Repo:   ~/develop/dotfile-vnext (override: cx-hvh01 /path)
  Use:    micro-tasks, naming, quick utility (tight context)
  TUI:    /status  /compact
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
      _codex_mt_set_title "Codex HVH-01 — 1.5B @ 1060"
      ;;
    research)
      cat <<'EOF'

━━ Codex RESEARCH (cloud) ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Lane:   gpt-5.4 via OpenAI (default ~/.codex)
  Use:    tools, MCP, web, shell — until local ATDD passes
  TUI:    /status  /mcp  /skills
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
      _codex_mt_set_title "Codex RESEARCH — cloud"
      ;;
    *)
      printf 'Unknown codex multi-terminal lane: %s\n' "$lane" >&2
      return 1
      ;;
  esac
}

cx-deep() {
  _codex_mt_banner deep || return
  cd "${HOME}/develop/dotfile-vnext" || return
  codex-homelab deep "$@"
}

cx-desktop() {
  _codex_mt_banner desktop || return
  cd "${HOME}/develop/dotfile-vnext" || return
  codex-homelab desktop "$@"
}

cx-skills() {
  _codex_mt_banner skills || return
  cd "${HOME}/develop/global-skills" || return
  codex-homelab fast "$@"
}

cx-hvh01() {
  local target_dir="${1:-${HOME}/develop/dotfile-vnext}"
  if [[ $# -gt 0 ]]; then
    shift
  fi
  _codex_mt_banner hvh01 || return
  cd "$target_dir" || return
  codex-homelab hvh01 "$@"
}

cx-research() {
  local target_dir="${1:-${HOME}/develop/homelab-reference-library}"
  if [[ $# -gt 0 ]]; then
    shift
  fi
  _codex_mt_banner research || return
  cd "$target_dir" || return
  codex "$@"
}

cx-deep-smoke() {
  _codex_mt_banner deep
  codex-homelab deep exec --ephemeral --skip-git-repo-check -C /tmp \
    'Reply with exactly: pong'
}

cx-hvh01-smoke() {
  _codex_mt_banner hvh01
  codex-homelab hvh01 exec --ephemeral --skip-git-repo-check -C /tmp \
    'Reply with exactly: pong'
}
