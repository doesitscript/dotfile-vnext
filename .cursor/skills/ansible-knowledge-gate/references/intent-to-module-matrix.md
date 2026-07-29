# Intent → module matrix

Use this before any Windows/Linux shell task for install, runtime, firewall,
env, or service work when the FQCN is not already proven in-repo for that
exact surface.

## Passes

1. **Pass A — surfaces:** list plain-language operational needs (no FQCN).
2. **Pass B — Context7 intent search:** `resolve-library-id` + `query-docs`
   with intent phrases. Record library ids and which queries ran.
3. **Pass C (optional) — parameter deepen:** query the chosen FQCN for
   required args, defaults, and footguns (e.g. scheduled-task time limit).

Report which passes ran in the knowledge receipt.

## Matrix template

```md
| Surface (plain) | Candidate FQCN | Evidence | Fit (yes/partial/no) | Notes |
| --- | --- | --- | --- | --- |
| Boot background serve | community.windows.win_scheduled_task | Context7 … | partial | needs PT0S |
| SCM service | ansible.windows.win_service | … | yes | needs binary that behaves as service |
| NSSM wrap | community.windows.win_nssm | … | yes | install nssm first |
```

## Anti-patterns (from live misses)

- Jumping to `win_shell` / custom `.ps1` because the module name was unknown
- Assuming the existing role pattern is correct without vendor + Context7
  evidence
- Treating Galaxy role folklore as module docs
- Skipping Pass B when Context7 MCP is available
