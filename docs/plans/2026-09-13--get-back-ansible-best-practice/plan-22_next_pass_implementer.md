# Plan 22 next-pass implementer report

To: The Plan 22 evaluator

## Blocking item 1 — vault-env fidelity

Updated `/Users/joshc/develop/homelab-model-lane-pytest/scripts/sync_env_from_vault.py` to load `vault-env.toml` with `tomllib` and drive the vault root, vault file, wrapper command, output file, sample files, defaults, and secret mappings.

The configured mapping is:

```text
vault_k3s_litellm_gateway_master_key -> LITELLM_API_KEY
```

The script validates the configured mapping, decrypts through the configured
dotfile-vnext wrapper, writes only ignored `.env` with mode `0600`, and writes
placeholder values to `.env.example`. It does not print secret values.

Changed paths:

- `/Users/joshc/develop/homelab-model-lane-pytest/vault-env.toml`
- `/Users/joshc/develop/homelab-model-lane-pytest/scripts/sync_env_from_vault.py`
- `/Users/joshc/develop/homelab-model-lane-pytest/justfile`
- `/Users/joshc/develop/homelab-model-lane-pytest/README.md`

Fresh command:

```text
DOTFILE_VNEXT=/Users/joshc/develop/dotfile-vnext just sync-env
sync-env: wrote .env (0600) and refreshed .env.example
600 .env
644 .env.example
secret-file-check: pass
```

## Blocking item 2 — thin SHIM

Updated:

`/Users/joshc/develop/dotfile-vnext/.cursor/skills/homelab-litellm-model-lane-pytest-draft/SKILL.md`

The SHIM now documents:

```text
DOTFILE_VNEXT=/Users/joshc/develop/dotfile-vnext just sync-env
just unit
just live -m smoke -k qwen3-coder-30b-a3b
```

It explains that the package loads ignored `.env` on direct launch and no
skill is required after hydration. The stale statement that vault wrappers
remain outside the package was removed. The skill remains `-draft` and owns
only operator discovery, evidence rules, and launch documentation.

## Blocking item 3 — gpt-oss-20b tools honesty

Updated `manifests/default.yml` so `gpt-oss-20b` advertises `chat` only while
retaining the tools scenario as an explicitly omitted manifest case. The
manifest comment records the observed behavior: HTTP 200 with empty content
instead of a tool call. This prevents a false tools pass and keeps chat
coverage active. The SHIM documents the same gating decision.

Fresh full-suite verification proves the default story is green without
claiming unsupported tools behavior:

```text
just test
======================== 21 passed in 90.32s (0:01:30) =========================
```

The prior evaluator-captured smoke receipt in `plan-22_execution_note.md` was
not refreshed because the receipt format did not change.

## Fresh verification

```text
just unit
============================== 5 passed in 0.10s ===============================

just lint
All checks passed!
19 files already formatted

just test
======================== 21 passed in 90.32s (0:01:30) =========================
```

No secret values were placed in source, TOML, plan artifacts, command output,
or chat. `.env` remains ignored and was verified at mode `0600`.

## Remaining risks

- `gpt-oss-20b` tools are intentionally not in the live matrix until a future
  commissioning run proves tool-call behavior and follow-up citation.
- The package SSOT invariant remains a checked-in commissioned-ID subset,
  rather than importing Ansible at pytest import time.
- Live latency is gateway/model dependent; the full run took 90.32 seconds.

ready for evaluator re-review: yes
