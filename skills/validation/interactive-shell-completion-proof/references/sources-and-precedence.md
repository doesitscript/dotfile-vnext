# Sources And Precedence

For interactive shell completion proof, prefer:

1. Real PTY transcript from the managed helper script
2. Direct shell-truth commands such as `echo "$SHELL"`, `command -v bash`, and `bash --version`
3. Visible completion bindings such as `complete -p <tool>`
4. Installed completion files under managed loader directories
5. Repo-owned shell/completion roles and playbooks

Synthetic completion-function invocation is a debugging hint only. It does not
outrank a real PTY transcript.
