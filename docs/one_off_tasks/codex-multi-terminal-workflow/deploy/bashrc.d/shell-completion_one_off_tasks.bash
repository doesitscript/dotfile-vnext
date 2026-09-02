# ONE-OFF TRIAL (non-permanent) — source: docs/one_off_tasks/codex-multi-terminal-workflow/deploy/bashrc.d/
# Auto-sourced by ~/.bashrc.d loop (Ansible common/shell_config). Remove via uninstall_one_off_tasks.sh.
#
# Target UX (GNU Bash / readline via Context7):
#   1st Tab  → insert first match on the prompt line immediately
#   below   → show all matches horizontally (AWS CLI style)
#   Tab     → cycle forward through matches on the same prompt line
#   Shift+Tab → cycle backward
#
# Keys:
#   menu-complete on Tab — replace word with one match per Tab
#   print-completions-horizontally on — space-separated row under prompt
#   show-all-if-ambiguous off — avoid list-only first Tab (no inline insert)
#   complete -I — command-name completion for cx-* at line start

if [[ -n "${BASH_VERSION:-}" ]]; then
  bind 'set show-all-if-ambiguous off' 2>/dev/null || true
  bind 'set show-all-if-unmodified off' 2>/dev/null || true
  bind 'set print-completions-horizontally on' 2>/dev/null || true
  bind 'set menu-complete-display-prefix on' 2>/dev/null || true
  bind 'set colored-completion-prefix on' 2>/dev/null || true
  bind 'set colored-stats on' 2>/dev/null || true
  bind 'set bell-style none' 2>/dev/null || true

  bind '"\t": menu-complete' 2>/dev/null || true
  bind '"\e[Z": menu-complete-backward' 2>/dev/null || true
fi

# Command-name completion (initial word on the line): cx-deep, cx-desktop, …
_cx_one_off_tasks_command_completion() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  mapfile -t COMPREPLY < <(
    {
      compgen -A function -- "$cur"
      compgen -c -- "$cur"
    } | awk 'NF && !seen[$0]++'
  )
}

# Argument completion for codex-homelab_one_off_tasks subcommands.
_cx_one_off_tasks_launcher_completion() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  if ((COMP_CWORD == 1)); then
    mapfile -t COMPREPLY < <(compgen -W 'deep desktop fast hvh01 tools' -- "$cur")
    return 0
  fi
  compopt -o filenames 2>/dev/null || true
  mapfile -t COMPREPLY < <(compgen -f -- "$cur")
}

if [[ -n "${BASH_VERSION:-}" ]]; then
  complete -I -o bashdefault -o default -F _cx_one_off_tasks_command_completion 2>/dev/null || true
  complete -o bashdefault -o default -F _cx_one_off_tasks_launcher_completion \
    codex-homelab_one_off_tasks 2>/dev/null || true
fi
