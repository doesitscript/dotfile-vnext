#!/usr/bin/env bash
# ONE-OFF TRIAL — install staged artifacts from docs/one_off_tasks/codex-multi-terminal-workflow/
# Deploys *_one_off_tasks files to the Mac. Safe to re-run.

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
package_root="$(cd "${script_dir}/.." && pwd)"
deploy_root="${script_dir}"

printf '%s\n' "Installing Codex multi-terminal one-off trial from:"
printf '  %s\n' "$package_root"

mkdir -p "${HOME}/.codex" "${HOME}/.codex-homelab/desktop_one_off_tasks" "${HOME}/bin" "${HOME}/.bashrc.d"

install -m 0600 "${deploy_root}/codex/local-deep_one_off_tasks.config.toml" \
  "${HOME}/.codex/local-deep_one_off_tasks.config.toml"
install -m 0600 "${deploy_root}/codex/local-fast_one_off_tasks.config.toml" \
  "${HOME}/.codex/local-fast_one_off_tasks.config.toml"
install -m 0600 "${deploy_root}/codex/local-hvh01_one_off_tasks.config.toml" \
  "${HOME}/.codex/local-hvh01_one_off_tasks.config.toml"

install -m 0644 "${deploy_root}/codex/instructions-navigation_one_off_tasks.md" \
  "${HOME}/.codex/instructions-navigation_one_off_tasks.md"
install -m 0644 "${deploy_root}/codex/instructions-implement_one_off_tasks.md" \
  "${HOME}/.codex/instructions-implement_one_off_tasks.md"
install -m 0644 "${deploy_root}/codex/instructions-skills_one_off_tasks.md" \
  "${HOME}/.codex/instructions-skills_one_off_tasks.md"
install -m 0644 "${deploy_root}/codex/instructions-hvh01_one_off_tasks.md" \
  "${HOME}/.codex/instructions-hvh01_one_off_tasks.md"

install -m 0600 "${deploy_root}/codex-homelab/desktop_one_off_tasks/config.toml" \
  "${HOME}/.codex-homelab/desktop_one_off_tasks/config.toml"

install -m 0700 "${deploy_root}/bin/codex-homelab_one_off_tasks.sh" \
  "${HOME}/bin/codex-homelab_one_off_tasks"

install -m 0644 "${deploy_root}/bashrc.d/codex-multi-terminal_one_off_tasks.bash" \
  "${HOME}/.bashrc.d/codex-multi-terminal_one_off_tasks.bash"

install -m 0644 "${deploy_root}/bashrc.d/shell-completion_one_off_tasks.bash" \
  "${HOME}/.bashrc.d/shell-completion_one_off_tasks.bash"

install -m 0755 "${deploy_root}/scripts/render_local_model_catalog_one_off_tasks.sh" \
  "${HOME}/bin/render_local_model_catalog_one_off_tasks"

"${HOME}/bin/render_local_model_catalog_one_off_tasks"

# --- Tab completion: fzf + lincheney/fzf-tab-completion (upstream installer) ---
chmod +x "${deploy_root}/scripts/install_fzf_tab_completion_one_off_tasks.sh"
chmod +x "${deploy_root}/scripts/verify_fzf_tab_completion_one_off_tasks.sh"
"${deploy_root}/scripts/install_fzf_tab_completion_one_off_tasks.sh"

# --- Python REPL tab completion (optional upstream python3 path) --------------
chmod +x "${deploy_root}/scripts/install_python_repl_fzf_tab_completion_one_off_tasks.sh"
chmod +x "${deploy_root}/scripts/verify_python_repl_fzf_tab_completion_one_off_tasks.sh"
"${deploy_root}/scripts/install_python_repl_fzf_tab_completion_one_off_tasks.sh"

printf '\n%s\n' 'Installed. Open a new shell or run:'
printf '  source ~/.bashrc.d/codex-multi-terminal_one_off_tasks.bash\n'
printf '  source ~/.bashrc.d/shell-completion_one_off_tasks.bash\n\n'
printf '%s\n' 'Tab completion (fzf-tab-completion):'
printf '%s\n' '  • Tab completes longest common prefix when possible'
printf '%s\n' '  • Tab again opens fzf with remaining matches'
printf '%s\n' '  • cx-de<Tab> → cx-deep; Tab → fzf with cx-deep-smoke, cx-desktop, …'
printf '%s\n\n' '  • paths/flags use the same fzf picker'
printf '%s\n' 'Python REPL:'
printf '%s\n' '  • source ~/.bashrc.d/python-fzf-tab-completion_one_off_tasks.bash'
printf '%s\n' '  • python3 — Tab uses fzf in the interactive REPL'
printf '%s\n' 'Try:'
printf '  cx-deep       # 32B @ 5090 — dotfile-vnext\n'
printf '  cx-desktop    # 14B @ desktop — dotfile-vnext\n'
printf '  cx-skills     # 7B @ desktop — global-skills\n'
printf '  cx-hvh01      # 1.5B @ 1060 — utility lane\n'
printf '  cx-research   # cloud — homelab-reference-library\n'
printf '\nSmoke: cx-deep-smoke | cx-hvh01-smoke\n'
printf 'Undo:  %s/uninstall_one_off_tasks.sh\n' "$deploy_root"
