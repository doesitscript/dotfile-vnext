#!/usr/bin/env bash
# ONE-OFF TRIAL — remove Mac artifacts installed by install_one_off_tasks.sh

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
  "${HOME}/.bashrc.d/python-fzf-tab-completion_one_off_tasks.bash" \
  "${HOME}/.bashrc.d/shell-completion_one_off_tasks.bash" \
  "${HOME}/bin/codex-homelab_one_off_tasks" \
  "${HOME}/bin/render_local_model_catalog_one_off_tasks" \
  "${HOME}/bin/rl_custom_complete"

rm -rf \
  "${HOME}/.local/share/dotfile-vnext-one-off-tasks/pythonpath" \
  "${HOME}/.codex-homelab/desktop_one_off_tasks"

printf '%s\n' 'Removed Codex multi-terminal one-off trial artifacts.'
printf '%s\n' 'Open a new shell to drop cx-* functions.'
