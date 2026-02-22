# NVM for bash (same idea as activate_nvm.zsh).
# Source this from ~/.bashrc or from ~/.bashrc.d/ so nvm/node/npm/npx/yarn are available.
#
# Usage in .bashrc:
#   [ -s "/path/to/dotfiles/roles/node/activate_nvm.bash" ] && . "/path/to/dotfiles/roles/node/activate_nvm.bash"
#
# Or with .bashrc.d: put this file (or a symlink) in ~/.bashrc.d/ (e.g. 50-nvm.bash),
# then in .bashrc ensure you source everything in .bashrc.d, e.g.:
#   for f in ~/.bashrc.d/*.bash; do [ -f "$f" ] && . "$f"; done

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

# Lazy load: load nvm.sh on first use of nvm/node/npm/npx/yarn so shell startup stays fast.
# Same idea as group_lazy_load in zsh. After first use, the real commands are on PATH.
_nvm_lazy_load() {
  unset -f nvm node npm npx yarn
  if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    . "$NVM_DIR/nvm.sh"
  fi
  "$@"
}

nvm()  { _nvm_lazy_load nvm "$@"; }
node() { _nvm_lazy_load node "$@"; }
npm()  { _nvm_lazy_load npm "$@"; }
npx()  { _nvm_lazy_load npx "$@"; }
yarn() { _nvm_lazy_load yarn "$@"; }

# Optional: load bash completion for nvm (tab-completion for nvm install, use, etc.)
# Uncomment if you want it:
# [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
