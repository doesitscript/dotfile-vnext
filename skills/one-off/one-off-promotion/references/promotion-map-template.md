# Promotion disposition ledger template

Copy into the promotion plan `README.md`. **Do not** use a two-row shortcut map.

Statuses (use exactly one per row):

- `Promoted`
- `Promoted with reshape`
- `Retired and replaced`
- `Retired with no managed replacement`
- `Open gap`

| One-off artifact | Status | Managed destination / note |
| --- | --- | --- |
| `deploy/bashrc.d/*_one_off_tasks.bash` | Promoted with reshape | `roles/<owner>/files/bashrc.d/<name>.bash` |
| `deploy/bin/*_one_off_tasks` | Promoted with reshape | `roles/<owner>/templates/<name>.sh.j2` |
| `deploy/scripts/install_*.sh` | Retired and replaced | `roles/<owner>/tasks/present.yml` |
| `deploy/scripts/verify_*.sh` | Open gap or Retired with no managed replacement | document receipt/test surface or rationale |
| `deploy/uninstall_*.sh` | Retired and replaced | see **Undo** section — not automatically `tasks/absent.yml` |

## Undo / removal (plan contract)

For each **owned artifact class**, document the real removal path:

| Artifact class | False assumption | Required truth |
| --- | --- | --- |
| Static `bashrc.d/*.bash` via `common/shell_config` | role `absent` removes file | `shell_config` copies unconditionally — need state-aware deploy or explicit delete tasks |
| Templates / `~/bin` | absent alone | owner role `absent` tasks must list paths |
| Legacy `*_one_off_tasks` on host | playbook only | `scripts/uninstall_<slug>_one_off_legacy.sh` + verified converge |

Reference audit: `docs/plans/2026-09-02--codex-multi-terminal-promotion/AI-CORRECTION-EVALUATION.md` (P1).
