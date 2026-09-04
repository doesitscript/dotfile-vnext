---
id: documents-develop-paths
status: promoted
behavior_group: repo-layout-paths
title: Repos under ~/Documents/develop on work laptop
---

## Trigger

```text
-bash: cd: /Users/a805120/develop/dotfile-vnext: No such file or directory
```

Home Mac uses `~/develop/...`; work laptop uses `~/Documents/develop/...`.

## Accommodation

- `codex_homelab_profiles_develop_root` / `repo_primary|skills|research` in host_vars.
- Templated `cx-*` bash drop-in (not hardcoded `~/develop/dotfile-vnext`).

## Re-apply

```bash
grep _CODEX_MT_REPO_ ~/.bashrc.d/codex-multi-terminal.bash
# Expect Documents/develop/work-laptop-ai-tools etc.
```

## Generalize

| Peer | Same risk? | Action |
| --- | --- | --- |
| Skills/scripts with `~/develop/` | yes | parameterize or Documents override |
| Kickoff / session paths | yes | check register before hardcoding |
| New cx-* lanes | yes | use repo_* vars only |
