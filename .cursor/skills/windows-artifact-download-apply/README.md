# windows-artifact-download-apply

Project skill for pinned large Windows downloads through
`roles/windows_artifact_download`.

## Quick start

```bash
bin/codex-env python .cursor/skills/windows-artifact-download-apply/scripts/print_artifact_contract.py
```

Then wire `include_role: windows_artifact_download` in the owning product role
and apply with the product playbook (not a `_tmp_` playbook).

## Related

- Role: `roles/windows_artifact_download/`
- Example caller: `roles/windows_ollama_runtime/tasks/install_setup_exe.yml`
- Lesson: `docs/lessons-learned/windows-desktop-wifi-github-download/README.md`
