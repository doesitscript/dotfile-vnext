# tmux shell aliases
# Sourced via ~/.bashrc.d/ (common/shell_config)

alias ta='tmux attach -t'
alias tl='tmux list-sessions'
alias tn='tmux new-session -s'
alias tk='tmux kill-session -t'


# Start a new tmux session
tmux new -s dev

# Run your development server
npm run dev

# Detach from session: Ctrl+B, then D

# Disconnect SSH - processes keep running

# Later, reconnect and reattach
ssh dev-server
tmux attach -t dev