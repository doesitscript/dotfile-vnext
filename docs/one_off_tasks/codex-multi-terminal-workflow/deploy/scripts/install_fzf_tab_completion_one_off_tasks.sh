#!/usr/bin/env bash
# ONE-OFF TRIAL — install deps + clone for lincheney/fzf-tab-completion
# Upstream: https://github.com/lincheney/fzf-tab-completion#bash

set -euo pipefail

FZF_TAB_DIR="${FZF_TAB_COMPLETION_DIR:-${HOME}/.local/share/fzf-tab-completion}"
FZF_TAB_REPO="https://github.com/lincheney/fzf-tab-completion.git"
BREW_FORMULAE=(fzf gawk grep gnu-sed coreutils)

printf '%s\n' '=== fzf-tab-completion one-off install ==='

missing=0

if command -v brew >/dev/null 2>&1; then
  for formula in "${BREW_FORMULAE[@]}"; do
    if brew list "$formula" >/dev/null 2>&1; then
      printf '  ok  brew %s\n' "$formula"
    else
      printf '  install  brew %s\n' "$formula"
      brew install "$formula"
    fi
  done
else
  printf '  warn  Homebrew not found — install manually: %s\n' "${BREW_FORMULAE[*]}"
  missing=1
fi

for cmd in fzf gawk; do
  if command -v "$cmd" >/dev/null 2>&1; then
    printf '  ok  %s (%s)\n' "$cmd" "$(command -v "$cmd")"
  else
    printf '  missing  %s — required by fzf-tab-completion\n' "$cmd" >&2
    missing=1
  fi
done

for cmd in gsed ggrep; do
  if command -v "$cmd" >/dev/null 2>&1; then
    printf '  ok  %s (%s)\n' "$cmd" "$(command -v "$cmd")"
  else
    printf '  warn  %s not on PATH — brew gnu-sed / grep provide gsed / ggrep on macOS\n' "$cmd" >&2
  fi
done

if [[ ! -f "${FZF_TAB_DIR}/bash/fzf-bash-completion.sh" ]]; then
  mkdir -p "$(dirname "${FZF_TAB_DIR}")"
  printf '  clone  %s\n' "$FZF_TAB_DIR"
  git clone --depth 1 "$FZF_TAB_REPO" "${FZF_TAB_DIR}"
else
  printf '  ok  clone present at %s\n' "$FZF_TAB_DIR"
fi

if ! bash -c 'shopt -s progcomp; [[ $(shopt -p progcomp) == *-s* ]]'; then
  printf '  warn  programmable completion (progcomp) unavailable in this bash\n' >&2
  missing=1
fi

if [[ -f "${HOME}/.bashrc.d/bash_completion.bash" ]]; then
  printf '  ok  bash_completion.bash loads before shell-completion (alphabetical .bashrc.d)\n'
else
  printf '  warn  ~/.bashrc.d/bash_completion.bash missing — fzf-tab-completion needs bash-completion\n' >&2
fi

if bash --noprofile --norc -c '
  shopt -s progcomp
  FZF_TAB='"${FZF_TAB_DIR}"'
  source "${FZF_TAB}/bash/fzf-bash-completion.sh"
  declare -F fzf_bash_completion >/dev/null
'; then
  printf '  ok  fzf_bash_completion loads in clean bash\n'
else
  printf '  fail  could not source fzf-bash-completion.sh\n' >&2
  missing=1
fi

if (( missing )); then
  printf '\n%s\n' 'Install finished with warnings — fix missing items above.' >&2
  exit 1
fi

printf '\n%s\n' 'fzf-tab-completion ready. Reload:'
printf '  source ~/.bashrc.d/shell-completion_one_off_tasks.bash\n'
