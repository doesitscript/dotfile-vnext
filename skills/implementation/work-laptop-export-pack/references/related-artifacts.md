# Related Artifacts

Packet source of truth:

- `exports/work-laptop-ai-tools/export-manifest.yml`
- `exports/work-laptop-ai-tools/playbook.yaml`
- `exports/work-laptop-ai-tools/inventory.yaml`
- `exports/work-laptop-ai-tools/host_vars/work-laptop.yaml`
- `exports/work-laptop-ai-tools/README.md` (includes Associated skills quick-find)
- `exports/work-laptop-ai-tools/bootstrap/bootstrap-contract.sh`
- `exports/work-laptop-ai-tools/bootstrap/bootstrap-tooling.yaml`
- `exports/work-laptop-ai-tools/bootstrap/bootstrap-macos-ansible.sh`
- `exports/work-laptop-ai-tools/scripts/requirements.txt`

Associated skills (operator quick-find; mirrored in packet README):

- `work-laptop-export-pack` — this skill (sync / validate / smoke)
- `project-skill-runtime-bridge` — Cursor discoverability for this skill
- Plan loop (optional): `paired-agent-plan-implementer`,
  `paired-agent-plan-evaluator` against
  `docs/plans/2026-09-02--work-laptop-export-pilot/`

Skill-owned helpers:

- `skills/implementation/work-laptop-export-pack/scripts/packet_manifest.py`
- `skills/implementation/work-laptop-export-pack/scripts/sync_sibling_repo.py`
- `skills/implementation/work-laptop-export-pack/scripts/build_export_archive.py`
- `skills/implementation/work-laptop-export-pack/scripts/validate_export_contract.py`
- `skills/implementation/work-laptop-export-pack/scripts/roundtrip_smoke.py`

Runtime discovery bridge:

- `skills/implementation/project-skill-runtime-bridge/SKILL.md`
- `skills/implementation/project-skill-runtime-bridge/scripts/link_project_skills_to_cursor.py`

Zed on the work-laptop packet:

- `roles/zed_ide/` with packet host_vars `zed_ide_install_cask: false`
  (config + launcher only; do not install/upgrade the Zed app)
