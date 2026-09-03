# multiagents / Bun PATH — Ansible-managed by roles/multiagents
# Adds ~/.bun/bin so `bun` and `multiagents` resolve in interactive shells.
if [ -d "${HOME}/.bun/bin" ]; then
  case ":${PATH}:" in
    *":${HOME}/.bun/bin:"*) ;;
    *) PATH="${HOME}/.bun/bin:${PATH}" ;;
  esac
  export PATH
fi
