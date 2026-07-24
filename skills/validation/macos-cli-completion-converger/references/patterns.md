# Completion Patterns

## Primary failure classes

1. Generated completion file missing
2. Shared loader too narrow
3. Homebrew Bash completion runtime mismatch
4. Wrapper tool with optional direct completion
5. User-local shell drift outside repo ownership

## Repo-backed lessons

- `kubectl` completion may need explicit generation when the binary is installed directly instead of through Homebrew.
- `gonzo`, `dstl8`, `kubectx`, `kubens`, `k9s`, and `stern` all benefit from consistent treatment by the shared loader.
- Source-building can appear during small Homebrew runtime changes on older macOS hosts; plan verification time accordingly.
