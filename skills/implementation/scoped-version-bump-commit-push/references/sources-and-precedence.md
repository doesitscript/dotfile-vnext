# Sources And Precedence

For scoped version-bump and closeout work in `dotfile-vnext`, prefer:

1. The user's requested scope
2. Current git worktree truth
3. Canonical version surfaces such as `VERSION`
4. README or other mirrored version mentions
5. Real push output

If the worktree contains unrelated dirty files, scoped intent outranks blanket
commit convenience.
