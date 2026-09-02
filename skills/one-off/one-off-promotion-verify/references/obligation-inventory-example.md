# Obligation inventory example (codex multi-terminal promotion)

| ID | Source | Obligation | In scope? | Status | Evidence |
| --- | --- | --- | --- | --- | --- |
| O-01 | Apply | `deploy_development_nodes.yaml` tags on `mac-dev` | yes | pass | PLAY RECAP failed=0 |
| O-02 | Verify | `bash -lc 'type cx-deep'` | yes | pass | function defined |
| O-03 | Verify | `cx-hvh01-smoke` | yes | pass | pong from hvh01 lane |
| O-04 | Verify | `cx-deep-smoke` | yes | pass | pong from k3s02 lane |
| O-05 | Legacy | `uninstall_*_one_off_legacy.sh` | yes | pass | `*_one_off_tasks` paths gone |
| O-06 | Verify | Interactive Tab completion | yes | pending | requires TTY |
