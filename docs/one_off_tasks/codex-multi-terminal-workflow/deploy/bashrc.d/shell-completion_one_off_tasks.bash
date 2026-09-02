# ONE-OFF TRIAL (non-permanent) — source: docs/one_off_tasks/codex-multi-terminal-workflow/deploy/bashrc.d/
# Auto-sourced by ~/.bashrc.d loop (Ansible common/shell_config). Remove via uninstall_one_off_tasks.sh.
#
# Tab UX trial:
#   - command menu on ONE line ABOVE the prompt (width-bounded; no wrap spill)
#   - 1st Tab on a query inserts first match + highlights first option
#   - repeat Tab on same query cycles; typing more chars resets to first match
#   - optional blank line before each new prompt (PROMPT_COMMAND breathe)
#
# Paths/flags: lincheney/fzf-tab-completion when fzf is installed.

if [[ -z "${BASH_VERSION:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi

# --- fzf-tab-completion (paths, flags, kubectl, git, …) ---------------------
_FZF_TAB_COMPLETION_DIR="${FZF_TAB_COMPLETION_DIR:-${HOME}/.local/share/fzf-tab-completion}"
if [[ -f "${_FZF_TAB_COMPLETION_DIR}/bash/fzf-bash-completion.sh" ]]; then
  # shellcheck disable=SC1090
  source "${_FZF_TAB_COMPLETION_DIR}/bash/fzf-bash-completion.sh"
fi

export FZF_COMPLETION_OPTS="${FZF_COMPLETION_OPTS:---layout=reverse --border --height=40% --bind tab:accept}"
export FZF_TAB_COMPLETION_PROMPT="${FZF_TAB_COMPLETION_PROMPT:-> }"
export FZF_COMPLETION_AUTO_COMMON_PREFIX="${FZF_COMPLETION_AUTO_COMMON_PREFIX:-true}"

# --- Optional: blank line before each new prompt (trial spacing) ----------------
_one_off_prompt_breathe() {
  printf '\n'
}
if [[ -z "${_ONE_OFF_PROMPT_BREATHE_LOADED:-}" ]]; then
  _ONE_OFF_PROMPT_BREATHE_LOADED=1
  PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }_one_off_prompt_breathe"
fi

# --- Inline horizontal command menu -----------------------------------------
declare -g _ONE_OFF_TAB_MENU_ACTIVE=0
declare -g _ONE_OFF_TAB_MENU_QUERY=""
declare -g _ONE_OFF_TAB_MENU_INDEX=0
declare -g _ONE_OFF_TAB_MENU_DRAWN=0
declare -ga _ONE_OFF_TAB_MENU_MATCHES=()

_one_off_tab_term_width() {
  if (( COLUMNS > 0 )); then
    printf '%s' "$COLUMNS"
  elif command -v tput >/dev/null 2>&1; then
    tput cols 2>/dev/null || printf '80'
  else
    printf '80'
  fi
}

_one_off_tab_clear_menu_line() {
  if (( _ONE_OFF_TAB_MENU_DRAWN )); then
    printf '\033[?7l\033[s\033[1A\033[2K\r\033[u\033[?7h'
    _ONE_OFF_TAB_MENU_DRAWN=0
  fi
}

_one_off_tab_menu_reset() {
  _one_off_tab_clear_menu_line
  _ONE_OFF_TAB_MENU_ACTIVE=0
  _ONE_OFF_TAB_MENU_QUERY=""
  _ONE_OFF_TAB_MENU_INDEX=0
  _ONE_OFF_TAB_MENU_MATCHES=()
}

_one_off_tab_collect_matches() {
  local query="$1"
  mapfile -t _ONE_OFF_TAB_MENU_MATCHES < <(
    {
      compgen -A alias -- "$query"
      compgen -A function -- "$query"
      compgen -c -- "$query"
    } | awk 'NF && !seen[$0]++' | LC_ALL=C sort -u
  )
}

_one_off_tab_print_horizontal_menu() {
  local cols width item index total start end
  local used=0 plain_len piece
  local left_ellipsis=0 right_ellipsis=0

  width="$(_one_off_tab_term_width)"
  (( width < 20 )) && width=80
  total=${#_ONE_OFF_TAB_MENU_MATCHES[@]}
  (( total == 0 )) && return 0

  # Window around the active selection so the row never wraps onto the prompt line.
  start=${_ONE_OFF_TAB_MENU_INDEX}
  end=$(( start + 1 ))
  used=$(( ${#_ONE_OFF_TAB_MENU_MATCHES[start]} + 2 ))

  while (( start > 0 || end < total )); do
    if (( start > 0 )); then
      plain_len=$(( ${#_ONE_OFF_TAB_MENU_MATCHES[start - 1]} + 2 ))
      if (( used + plain_len + 2 > width )); then
        left_ellipsis=1
        break
      fi
      start=$(( start - 1 ))
      used=$(( used + plain_len ))
    fi
    if (( end < total )); then
      plain_len=$(( ${#_ONE_OFF_TAB_MENU_MATCHES[end]} + 2 ))
      if (( used + plain_len + 2 > width )); then
        right_ellipsis=1
        break
      fi
      end=$(( end + 1 ))
      used=$(( used + plain_len ))
    fi
    if (( start == 0 && end == total )); then
      break
    fi
  done

  printf '\033[?7l'
  printf '\033[s'
  printf '\033[1A\033[2K\r'

  (( left_ellipsis )) && printf '…  '

  for (( index = start; index < end; index++ )); do
    item="${_ONE_OFF_TAB_MENU_MATCHES[index]}"
    if (( index == _ONE_OFF_TAB_MENU_INDEX )); then
      printf '\033[7m%s\033[27m  ' "$item"
    else
      printf '%s  ' "$item"
    fi
  done

  (( right_ellipsis )) && printf '…'
  printf '\033[u\033[?7h'
  _ONE_OFF_TAB_MENU_DRAWN=1
}

_one_off_tab_first_word() {
  local line="$1" point="$2"
  if [[ "$line" != *" "* ]]; then
    printf '%s' "$line"
    return 0
  fi
  if (( point <= ${#line%% *} )); then
    printf '%s' "${line%% *}"
  else
    printf ''
  fi
}

_one_off_tab_in_command_position() {
  local line="$1" point="$2"
  [[ "$line" != *" "* ]] && return 0
  (( point <= ${#line%% *} )) && return 0
  return 1
}

_one_off_tab_inline_command_menu() {
  local line="${READLINE_LINE}" point="${READLINE_POINT}"
  local query suffix choice direction="${1:-forward}"

  if ! _one_off_tab_in_command_position "$line" "$point"; then
    return 1
  fi

  query="$(_one_off_tab_first_word "$line" "$point")"
  [[ -n "$query" ]] || return 1

  # Cycle only when Tab is pressed again on the *same* query. Prefix overlap from a
  # prior session (e.g. stored "cx" while typing "cx-de") must reset to first match.
  if (( _ONE_OFF_TAB_MENU_ACTIVE )) && [[ "$query" == "$_ONE_OFF_TAB_MENU_QUERY" ]]; then
    if ((${#_ONE_OFF_TAB_MENU_MATCHES[@]} > 1)); then
      if [[ "$direction" == backward ]]; then
        _ONE_OFF_TAB_MENU_INDEX=$(( (_ONE_OFF_TAB_MENU_INDEX - 1 + ${#_ONE_OFF_TAB_MENU_MATCHES[@]}) % ${#_ONE_OFF_TAB_MENU_MATCHES[@]} ))
      else
        _ONE_OFF_TAB_MENU_INDEX=$(( (_ONE_OFF_TAB_MENU_INDEX + 1) % ${#_ONE_OFF_TAB_MENU_MATCHES[@]} ))
      fi
    fi
  else
    _one_off_tab_clear_menu_line
    _ONE_OFF_TAB_MENU_QUERY="$query"
    _one_off_tab_collect_matches "$query"
    _ONE_OFF_TAB_MENU_INDEX=0
    _ONE_OFF_TAB_MENU_ACTIVE=1
  fi

  if ((${#_ONE_OFF_TAB_MENU_MATCHES[@]} == 0)); then
    _one_off_tab_menu_reset
    return 1
  fi

  choice="${_ONE_OFF_TAB_MENU_MATCHES[_ONE_OFF_TAB_MENU_INDEX]}"
  if [[ "$line" == *" "* ]]; then
    suffix="${line#"$query"}"
    READLINE_LINE="${choice}${suffix}"
  else
    READLINE_LINE="$choice"
  fi
  READLINE_POINT="${#READLINE_LINE}"

  if ((${#_ONE_OFF_TAB_MENU_MATCHES[@]} > 1)); then
    _one_off_tab_print_horizontal_menu
  else
    _one_off_tab_clear_menu_line
  fi
  return 0
}

_one_off_tab_complete() {
  if _one_off_tab_inline_command_menu forward; then
    return 0
  fi
  _one_off_tab_menu_reset
  if declare -F fzf_bash_completion >/dev/null 2>&1; then
    fzf_bash_completion
    return 0
  fi
  return 0
}

_one_off_tab_complete_backward() {
  if _one_off_tab_inline_command_menu backward; then
    return 0
  fi
  _one_off_tab_menu_reset
  if declare -F fzf_bash_completion >/dev/null 2>&1; then
    fzf_bash_completion
    return 0
  fi
  return 0
}

bind 'set bell-style none' 2>/dev/null || true
bind -x '"\t": _one_off_tab_complete' 2>/dev/null || true
bind -x '"\e[Z": _one_off_tab_complete_backward' 2>/dev/null || true
