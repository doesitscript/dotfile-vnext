#!/usr/bin/env bash
# Remove legacy *_one_off_tasks artifacts after promotion to Ansible.
# Safe to re-run. Source: docs/plans/2026-09-02--codex-multi-terminal-promotion/

set -euo pipefail

rm -f \
  "${HOME}/.codex/local-deep_one_off_tasks.config.toml" \
  "${HOME}/.codex/local-fast_one_off_tasks.config.toml" \
  "${HOME}/.codex/local-hvh01_one_off_tasks.config.toml" \
  "${HOME}/.codex/local-model-catalog_one_off_tasks.json" \
  "${HOME}/.codex/instructions-navigation_one_off_tasks.md" \
  "${HOME}/.codex/instructions-implement_one_off_tasks.md" \
  "${HOME}/.codex/instructions-skills_one_off_tasks.md" \
  "${HOME}/.codex/instructions-hvh01_one_off_tasks.md" \
  "${HOME}/.bashrc.d/codex-multi-terminal_one_off_tasks.bash" \
  "${HOME}/.bashrc.d/shell-completion_one_off_tasks.bash" \
  "${HOME}/.bashrc.d/python-fzf-tab-completion_one_off_tasks.bash" \
  "${HOME}/bin/codex-homelab_one_off_tasks" \
  "${HOME}/bin/render_local_model_catalog_one_off_tasks"

rm -rf \
  "${HOME}/.codex-homelab/desktop_one_off_tasks" \
  "${HOME}/.local/share/dotfile-vnext-one-off-tasks"

printf '%s\n' 'Removed legacy codex multi-terminal one-off artifacts from the host.'
printf '%s\n' 'Converge managed state: ansible-playbook playbooks/deploy_development_nodes.yaml --tags fzf_tab_completion,codex_homelab_profiles --limit mac-dev'
