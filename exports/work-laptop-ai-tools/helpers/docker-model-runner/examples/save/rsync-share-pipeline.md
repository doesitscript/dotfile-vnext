# Saved — rsync / public-share pipeline findings

**Status:** legacy. Prefer Docker Model Runner.

## Pipeline (deprecated)

```text
controller hf download → \\HOM-LAB-HVH-01\public\models\...
  → work laptop setup_shares.sh → ~/mnt/hvh-01-public
  → rsync -aP listed folders → ~/models
  → ollama create / lms import
```

## Lessons to keep

1. **macOS rsync:** bundled rsync rejects `--info=progress2`; use `rsync -aP`.
2. **Paste hygiene:** red `#` comment and command are two lines; do not join.
3. **Stable mount:** Finder `/Volumes` mount blocks `~/mnt/hvh-01-public`;
   `setup_shares.sh` unmounts then remounts (deviation `smb-stable-mount-hvh01`).
4. **HVH-01 only** for `models/`; HVH-02 public has no models tree.
5. **Manifest vs share:** missing share folder ≠ remove from working set; it
   means controller download still needed (legacy path).
6. **Username:** SMB user must be `$USER` / `a805120`, never home-Mac `joshc`.

## Helpers (legacy location)

`helpers/work-mac-local-models/` — echo-only scripts and `models-to-copy.list`.
