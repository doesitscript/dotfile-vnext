# You can periodically run the following script to automatically clean up sessions without active processes:
# just a script btw
#This script checks all sessions starting with vsct, and automatically cleans them up if they have no attached clients and no running programs inside.
# Prune detached vsct* tmux sessions without active foreground jobs (zsh)
prune_vsct_tmux() {
  if ! command -v tmux >/dev/null 2>&1; then
    echo "tmux command not found" >&2
    return 1
  fi
 
  local sessions
  sessions=$(tmux list-sessions -F "#{session_name}::#{session_attached}" 2>/dev/null) || return 0
 
  local -a idle=(fish bash zsh sh)
  local killed=0
 
  local line name attached panes pane_cmd lower has_active in_idle
  setopt localoptions shwordsplit
 
  for line in ${(f)sessions}; do
    name=${line%%::*}
    attached=${line##*::}
 
    [[ $name == vsct* ]] || continue
    [[ -n "$attached" && $attached -gt 0 ]] && continue
 
    panes=$(tmux list-panes -t "$name" -F "#{pane_current_command}" 2>/dev/null) || continue
    has_active=0
 
    for pane_cmd in ${(f)panes}; do
      [[ -z "$pane_cmd" ]] && continue
      lower=${pane_cmd:l}
 
      in_idle=0
      for _c in $idle; do
        [[ "$lower" == "$_c" ]] && in_idle=1 && break
      done
 
      if [[ $in_idle -eq 0 ]]; then
        has_active=1
        break
      fi
    done
 
    if [[ $has_active -eq 0 ]]; then
      tmux kill-session -t "$name" && ((killed++))
    fi
  done
}