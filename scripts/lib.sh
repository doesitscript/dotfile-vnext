#!/usr/bin/env bash
# Shared bash functions for FuzLang Infrastructure scripts

# Script follows LOGGING_AND_OUTPUT.md contract.
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib"
# shellcheck source=../lib/log.sh
source "${LIB_DIR}/log.sh"
# shellcheck source=../lib/redact.sh
source "${LIB_DIR}/redact.sh"

log_success() { log_ok "$*"; }

# Send macOS notification (optional, doesn't error if not available)
notify() {
  local title="$1"
  local message="$2"
  
  if command -v terminal-notifier &> /dev/null; then
    terminal-notifier -title "${title}" -message "${message}" -sound default 2>/dev/null || true
  fi
}

# Detect repository root
repo_root() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  echo "$(cd "${script_dir}/.." && pwd)"
}

# Get Python interpreter (allow override via FZ_PYTHON)
get_python() {
  echo "${FZ_PYTHON:-python3}"
}

file_sha256() {
  local target_file="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "${target_file}" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "${target_file}" | awk '{print $1}'
  else
    log_error "No SHA-256 tool found (sha256sum/shasum)"
    exit 1
  fi
}

# Require a command to be available
require_cmd() {
  local cmd="$1"
  if ! command -v "${cmd}" &> /dev/null; then
    log_error "Required command not found: ${cmd}"
    exit 1
  fi
}

# Ensure virtual environment exists and has required dependencies
ensure_venv() {
  local repo_root
  repo_root="$(repo_root)"
  local venv_dir="${repo_root}/.venv"
  local requirements_file="${repo_root}/scripts/requirements.txt"
  local mgmt_dir="${repo_root}/.mgmt"
  local bootstrap_stamp="${mgmt_dir}/.fz_bootstrap_complete"
  local requirements_hash_file="${mgmt_dir}/requirements.sha256"
  local python_cmd
  python_cmd="$(get_python)"
  local activate_path="${venv_dir}/bin/activate"
  local force_bootstrap="${FZ_FORCE_BOOTSTRAP:-false}"
  local refresh_deps="${FZ_REFRESH_DEPS:-false}"
  local upgrade_pip_now="${FZ_UPGRADE_PIP_NOW:-false}"
  local venv_created=false
  local full_bootstrap=false

  mkdir -p "${mgmt_dir}"

  create_venv() {
    log_info "Creating virtual environment at ${venv_dir}"
    require_cmd "${python_cmd}"
    if ! "${python_cmd}" -m venv "${venv_dir}"; then
      # On Ubuntu/WSL this typically means python3-venv is missing.
      if command -v apt-get >/dev/null 2>&1; then
        log_warn "python venv support appears missing; attempting to install required packages"
        if sudo apt-get update && sudo apt-get install -y python3-venv python3-pip; then
          log_info "Retrying virtual environment creation after installing venv support"
          "${python_cmd}" -m venv "${venv_dir}"
        else
          log_error "Failed to install python3-venv/python3-pip automatically"
          exit 1
        fi
      else
        log_error "Failed to create virtual environment with ${python_cmd} -m venv ${venv_dir}"
        exit 1
      fi
    fi
    venv_created=true
  }

  if [ ! -d "${venv_dir}" ]; then
    log_info ".venv not found; creating new virtual environment"
    create_venv
  elif [ ! -f "${activate_path}" ]; then
    # Common failure mode in WSL: .venv exists but is incomplete or created from a different platform layout.
    log_warn "Existing virtual environment is invalid for this shell: ${activate_path} missing"
    log_info "Rebuilding virtual environment at ${venv_dir}"
    rm -rf "${venv_dir}"
    create_venv
  else
    log_info "Existing virtual environment detected at ${venv_dir}"
  fi

  # Activate virtual environment
  if [ ! -f "${activate_path}" ]; then
    log_error "Virtual environment activation script not found: ${activate_path}"
    exit 1
  fi
  # shellcheck disable=SC1090
  source "${activate_path}"

  if [ "${force_bootstrap}" = true ] || [ ! -f "${bootstrap_stamp}" ]; then
    full_bootstrap=true
    log_info "Bootstrap cache miss; running full dependency setup"
    setup_git_config
  fi

  # Upgrade pip only during full/bootstrap creation or explicit request.
  if [ "${upgrade_pip_now}" = true ] || [ "${venv_created}" = true ] || [ "${full_bootstrap}" = true ]; then
    log_info "Upgrading pip in virtual environment"
    pip install --quiet --upgrade pip
  fi

  # Install requirements only when changed, on explicit refresh, or full bootstrap.
  local did_install_pip=false
  if [ -f "${requirements_file}" ]; then
    local current_hash
    local previous_hash
    current_hash="$(file_sha256 "${requirements_file}")"
    previous_hash="$(tr -d '\r\n' < "${requirements_hash_file}" 2>/dev/null || true)"

    if [ "${refresh_deps}" = true ] || [ "${full_bootstrap}" = true ] || [ "${current_hash}" != "${previous_hash}" ]; then
      log_info "Installing Python dependencies from ${requirements_file}"
      pip install --quiet --upgrade -r "${requirements_file}"
      printf '%s\n' "${current_hash}" > "${requirements_hash_file}"
      did_install_pip=true
    else
      log_info "Requirements unchanged; skipping dependency install"
    fi
  else
    log_warn "Requirements file not found: ${requirements_file}"
  fi

  # Install Ansible Galaxy collections (for bootstrap_mac, Homebrew roles, etc.) when pip deps were installed or collections file changed.
  local requirements_yml="${repo_root}/requirements.yml"
  local collections_hash_file="${mgmt_dir}/requirements_yml.sha256"
  mkdir -p "${mgmt_dir}"
  if [ -f "${requirements_yml}" ]; then
    local col_hash
    col_hash="$(file_sha256 "${requirements_yml}")"
    local col_prev=""
    [ -f "${collections_hash_file}" ] && col_prev="$(tr -d '\r\n' < "${collections_hash_file}" 2>/dev/null || true)"
    if [ "${refresh_deps}" = true ] || [ "${full_bootstrap}" = true ] || [ "${did_install_pip}" = true ] || [ "${col_hash}" != "${col_prev}" ]; then
      log_info "Installing Ansible Galaxy collections from ${requirements_yml}"
      (cd "${repo_root}" && ansible-galaxy collection install -r requirements.yml)
      printf '%s\n' "${col_hash}" > "${collections_hash_file}"
    fi
  fi

  if [ "${full_bootstrap}" = true ]; then
    : > "${bootstrap_stamp}"
    log_info "Bootstrap cache stamp updated: ${bootstrap_stamp}"
  fi

  log_success "Virtual environment ready"
}

# Setup Ansible environment
setup_ansible_env() {
  local repo_root
  repo_root="$(repo_root)"
  local ansible_cfg="${repo_root}/ansible.cfg"

  # Set ANSIBLE_CONFIG if ansible.cfg exists
  if [ -f "${ansible_cfg}" ]; then
    export ANSIBLE_CONFIG="${ansible_cfg}"
    log_info "Using Ansible config: ${ansible_cfg}"
  else
    log_warn "ansible.cfg not found at ${ansible_cfg}; Ansible defaults will be used"
  fi

  # Ensure we're in repo root (ansible-playbook runs from here)
  cd "${repo_root}"

  # WSL + /mnt/<drive> paths are often world-writable, and Ansible may ignore ansible.cfg there.
  # Export core paths explicitly so role/collection resolution still works when config is skipped.
  export ANSIBLE_ROLES_PATH="${repo_root}/roles:${repo_root}/playbooks/roles:${HOME}/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles"
  export ANSIBLE_COLLECTIONS_PATH="${repo_root}/collections:${HOME}/.ansible/collections:/usr/share/ansible/collections"
  log_info "ANSIBLE_ROLES_PATH=${ANSIBLE_ROLES_PATH}"
  log_info "ANSIBLE_COLLECTIONS_PATH=${ANSIBLE_COLLECTIONS_PATH}"

  # Ansible log_path in ansible.cfg points to .mgmt/ansible.log; ensure .mgmt exists.
  mkdir -p "${repo_root}/.mgmt"
}

# Configure Git globally for push/pull
setup_git_config() {
  local git_email="1589359+doesitscript@users.noreply.github.com"
  
  # Check if Git is available
  if ! command -v git &> /dev/null; then
    log_warn "Git not found, skipping Git configuration"
    return 0
  fi
  
  # Get current email
  local current_email
  current_email="$(git config --global user.email 2>/dev/null || echo "")"
  
  # Set email if not already set to the correct value
  if [ "${current_email}" != "${git_email}" ]; then
    log_info "Configuring Git email: ${git_email}"
    git config --global user.email "${git_email}"
    log_success "Git email configured: ${git_email}"
  else
    log_info "Git email already configured: ${git_email}"
  fi
  
  # Get current name (set if not present)
  local current_name
  current_name="$(git config --global user.name 2>/dev/null || echo "")"
  
  if [ -z "${current_name}" ]; then
    log_info "Setting Git user name: Joshua Castillo"
    git config --global user.name "Joshua Castillo"
  fi
}

# Helper to run ansible-playbook from venv
fz_ansible() {
  local repo_root
  repo_root="$(repo_root)"
  local venv_ansible="${repo_root}/.venv/bin/ansible-playbook"
  local inventory_file="${repo_root}/inventory/inventory.yaml"
  local playbook="$1"
  shift || true

  # Ensure virtual environment exists
  ensure_venv

  # Setup Ansible environment
  setup_ansible_env

  # Check if ansible-playbook exists in venv
  if [ ! -f "${venv_ansible}" ]; then
    log_error "ansible-playbook not found in virtual environment"
    log_info "Run: ./bin/fz verify (to install dependencies)"
    exit 1
  fi

  # Check if playbook exists
  if [ ! -f "${repo_root}/${playbook}" ]; then
    log_error "Playbook not found: ${playbook}"
    exit 1
  fi

  # Check if inventory exists
  if [ ! -f "${inventory_file}" ]; then
    log_error "Inventory file not found: ${inventory_file}"
    exit 1
  fi

  # Build ansible-playbook command
  local ansible_cmd=(
    "${venv_ansible}"
    "${playbook}"
    -i "${inventory_file}"
  )

  # Parse common arguments
  local extra_args=()
  local has_vault_pass=false
  local has_vault_file=false
  local limit_value=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --limit)
        ansible_cmd+=("--limit" "$2")
        limit_value="$2"
        shift 2
        ;;
      --all)
        # --all means don't use --limit (run on all applicable hosts)
        # Just skip this flag, don't forward to ansible-playbook
        shift
        ;;
      --tags)
        ansible_cmd+=("--tags" "$2")
        shift 2
        ;;
      --check)
        ansible_cmd+=("--check")
        shift
        ;;
      --diff)
        ansible_cmd+=("--diff")
        shift
        ;;
      --ask-vault-pass)
        ansible_cmd+=("--ask-vault-pass")
        has_vault_pass=true
        shift
        ;;
      --vault-password-file)
        ansible_cmd+=("--vault-password-file" "$2")
        has_vault_file=true
        shift 2
        ;;
      --skip-tags)
        ansible_cmd+=("--skip-tags" "$2")
        shift 2
        ;;
      --start-at-task)
        ansible_cmd+=("--start-at-task" "$2")
        shift 2
        ;;
      --step)
        ansible_cmd+=("--step")
        shift
        ;;
      --verbose|-v|-vv|-vvv|-vvvv)
        ansible_cmd+=("$1")
        shift
        ;;
      --connection-timeout)
        ansible_cmd+=("--connection-timeout" "$2")
        shift 2
        ;;
      --forks)
        ansible_cmd+=("--forks" "$2")
        shift 2
        ;;
      *)
        # Unknown argument - forward to ansible-playbook
        extra_args+=("$1")
        shift
        ;;
    esac
  done

  # Add extra args if any
  if [ ${#extra_args[@]} -gt 0 ]; then
    ansible_cmd+=("${extra_args[@]}")
  fi

  # WinRM fallback: if limit targets a single Windows host_vars file with win_password
  # but missing ansible_password, inject runtime extra-vars so ntlm auth can proceed.
  if [[ -n "${limit_value}" && "${limit_value}" == *"-win"* ]]; then
    local host_vars_file="${repo_root}/inventory/host_vars/${limit_value}.yaml"
    if [ -f "${host_vars_file}" ]; then
      local ansible_password_value=""
      local win_password_value=""
      ansible_password_value="$(sed -n 's/^[[:space:]]*ansible_password:[[:space:]]*"\{0,1\}\([^"#]*\).*/\1/p' "${host_vars_file}" | head -1)"
      win_password_value="$(sed -n 's/^[[:space:]]*win_password:[[:space:]]*"\{0,1\}\([^"#]*\).*/\1/p' "${host_vars_file}" | head -1)"
      if [[ -z "${ansible_password_value}" && -n "${win_password_value}" ]]; then
        log_info "Using win_password fallback for ansible_password on ${limit_value}"
        ansible_cmd+=("-e" "ansible_password=${win_password_value}")
        ansible_cmd+=("-e" "ansible_winrm_password=${win_password_value}")
      fi
    fi
  fi

  # If no vault method specified, check for vault password file in common locations
  if [ "${has_vault_pass}" = false ] && [ "${has_vault_file}" = false ]; then
    local vault_file="${repo_root}/.vault_pass"
    if [ -f "${vault_file}" ]; then
      log_info "Using vault password file: ${vault_file}"
      ansible_cmd+=("--vault-password-file" "${vault_file}")
    fi
  fi

  log_info "Running: ${ansible_cmd[*]}"
  "${ansible_cmd[@]}"
}

# Run ansible-playbook with proper arguments (uses fz_ansible internally)
run_ansible_playbook() {
  local playbook="$1"
  shift || true

  local repo_root
  repo_root="$(repo_root)"
  local inventory_file="${repo_root}/inventory/inventory.yaml"

  # Ensure we're using the virtual environment
  ensure_venv

  # Setup Ansible environment
  setup_ansible_env

  # Check if playbook exists
  if [ ! -f "${repo_root}/${playbook}" ]; then
    log_error "Playbook not found: ${playbook}"
    exit 1
  fi

  # Check if inventory exists
  if [ ! -f "${inventory_file}" ]; then
    log_error "Inventory file not found: ${inventory_file}"
    exit 1
  fi

  # Build ansible-playbook command
  local venv_ansible="${repo_root}/.venv/bin/ansible-playbook"
  local ansible_cmd=(
    "${venv_ansible}"
    "${playbook}"
    -i "${inventory_file}"
  )

  # Parse common arguments
  local extra_args=()
  local has_vault_pass=false
  local has_vault_file=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --limit)
        ansible_cmd+=("--limit" "$2")
        shift 2
        ;;
      --all)
        # --all means don't use --limit (run on all applicable hosts)
        # Just skip this flag, don't forward to ansible-playbook
        shift
        ;;
      --tags)
        ansible_cmd+=("--tags" "$2")
        shift 2
        ;;
      --check)
        ansible_cmd+=("--check")
        shift
        ;;
      --diff)
        ansible_cmd+=("--diff")
        shift
        ;;
      --ask-vault-pass)
        ansible_cmd+=("--ask-vault-pass")
        has_vault_pass=true
        shift
        ;;
      --vault-password-file)
        ansible_cmd+=("--vault-password-file" "$2")
        has_vault_file=true
        shift 2
        ;;
      --skip-tags)
        ansible_cmd+=("--skip-tags" "$2")
        shift 2
        ;;
      --start-at-task)
        ansible_cmd+=("--start-at-task" "$2")
        shift 2
        ;;
      --step)
        ansible_cmd+=("--step")
        shift
        ;;
      --verbose|-v|-vv|-vvv|-vvvv)
        ansible_cmd+=("$1")
        shift
        ;;
      --connection-timeout)
        ansible_cmd+=("--connection-timeout" "$2")
        shift 2
        ;;
      --forks)
        ansible_cmd+=("--forks" "$2")
        shift 2
        ;;
      *)
        # Unknown argument - forward to ansible-playbook
        extra_args+=("$1")
        shift
        ;;
    esac
  done

  # Add extra args if any
  if [ ${#extra_args[@]} -gt 0 ]; then
    ansible_cmd+=("${extra_args[@]}")
  fi

  # If no vault method specified, check for vault password file in common locations
  if [ "${has_vault_pass}" = false ] && [ "${has_vault_file}" = false ]; then
    local vault_file="${repo_root}/.vault_pass"
    if [ -f "${vault_file}" ]; then
      log_info "Using vault password file: ${vault_file}"
      ansible_cmd+=("--vault-password-file" "${vault_file}")
    fi
  fi

  log_info "Running: ${ansible_cmd[*]}"
  "${ansible_cmd[@]}"
}

# Require vault password setup so local bootstrap can decrypt vaulted vars.
# Prints fix commands and exits if .vault_pass or executable vault_pass.sh is missing.
require_vault_pass_setup() {
  local repo_root
  repo_root="$(repo_root)"
  local vault_file="${repo_root}/.vault_pass"
  local vault_script="${repo_root}/vault_pass.sh"
  if [ -f "${vault_file}" ]; then
    if [ -x "${vault_script}" ]; then
      return 0
    fi
    # Make hands-free: fix execute bit so Ansible can call vault_pass.sh (needed on WSL when repo is on Windows mount).
    if [ -f "${vault_script}" ]; then
      chmod +x "${vault_script}" 2>/dev/null && log_info "Set vault_pass.sh executable for Ansible" && return 0
    fi
    log_error "vault_pass.sh is not executable; Ansible may fail on WSL (execute bit on .vault_pass cannot be cleared on Windows mount)."
    log_error "To fix: chmod +x ${vault_script}"
    log_error "See: ${repo_root}/config/README_vault_pass.md"
    exit 1
  fi
  log_error "Vault password file not found: ${vault_file}"
  log_error "To fix: echo -n 'YOUR_PASSWORD' > ${vault_file}"
  log_error "If vault_pass.sh is not executable: chmod +x ${repo_root}/vault_pass.sh"
  log_error "See: ${repo_root}/config/README_vault_pass.md"
  exit 1
}

# Run local bootstrap playbook from venv using localhost connection.
# Strips --limit and its value from args so only localhost is used (avoids "no hosts to target").
run_local_bootstrap_playbook() {
  local repo_root
  repo_root="$(repo_root)"
  local venv_ansible="${repo_root}/.venv/bin/ansible-playbook"
  local playbook="${repo_root}/playbooks/bootstrap_local.yml"

  ensure_venv
  require_vault_pass_setup
  setup_ansible_env

  if [ ! -f "${venv_ansible}" ]; then
    log_error "ansible-playbook not found in virtual environment"
    exit 1
  fi
  if [ ! -f "${playbook}" ]; then
    log_error "Local bootstrap playbook not found: ${playbook}"
    exit 1
  fi

  local filtered_args=()
  while [[ $# -gt 0 ]]; do
    if [[ "$1" == "--limit" ]]; then shift 2; continue; fi
    filtered_args+=("$1")
    shift
  done

  log_info "Running local bootstrap playbook via localhost connection"
  "${venv_ansible}" -i "localhost," -c local "${playbook}" "${filtered_args[@]}"
}

# Run ansible-vault edit
run_ansible_vault_edit() {
  local vault_file="$1"
  shift || true

  local repo_root
  repo_root="$(repo_root)"

  # Ensure we're using the virtual environment
  ensure_venv

  # Check if vault file exists
  if [ ! -f "${repo_root}/${vault_file}" ]; then
    log_error "Vault file not found: ${vault_file}"
    exit 1
  fi

  # Setup Ansible environment
  setup_ansible_env

  # Build ansible-vault command (use venv version)
  local venv_vault="${repo_root}/.venv/bin/ansible-vault"
  local ansible_cmd=(
    "${venv_vault}"
    edit
    "${vault_file}"
  )

  # Parse vault password arguments
  local has_vault_pass=false
  local has_vault_file=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --ask-vault-pass)
        ansible_cmd+=("--ask-vault-pass")
        has_vault_pass=true
        shift
        ;;
      --vault-password-file)
        ansible_cmd+=("--vault-password-file" "$2")
        has_vault_file=true
        shift 2
        ;;
      *)
        log_warn "Unknown argument for vault edit: $1"
        shift
        ;;
    esac
  done

  # If no vault method specified, check for vault password file in common locations
  if [ "${has_vault_pass}" = false ] && [ "${has_vault_file}" = false ]; then
    local vault_file_pass="${repo_root}/.vault_pass"
    if [ -f "${vault_file_pass}" ]; then
      log_info "Using vault password file: ${vault_file_pass}"
      ansible_cmd+=("--vault-password-file" "${vault_file_pass}")
    else
      log_info "No vault password file found, will prompt for password"
      ansible_cmd+=("--ask-vault-pass")
    fi
  fi

  log_info "Editing vault file: ${vault_file}"
  "${ansible_cmd[@]}"
}

# Run a single role locally on localhost via a temporary playbook.
run_local_role_playbook() {
  local role_name="$1"
  shift || true

  if [ -z "${role_name}" ]; then
    log_error "Role name is required"
    exit 1
  fi

  local repo_root
  repo_root="$(repo_root)"
  local venv_ansible="${repo_root}/.venv/bin/ansible-playbook"
  local tmp_playbook
  tmp_playbook="$(mktemp "${TMPDIR:-/tmp}/fz-role-local.XXXXXX.yml")"
  local dotfiles_home_default="${repo_root}"
  local dotfiles_user_home_default="${HOME}"
  local local_python_interpreter="${repo_root}/.venv/bin/python3"

  ensure_venv
  setup_ansible_env

  if [ ! -f "${venv_ansible}" ]; then
    log_error "ansible-playbook not found in virtual environment"
    exit 1
  fi

  cat > "${tmp_playbook}" <<EOF
- hosts: localhost
  connection: local
  gather_facts: true
  roles:
    - role: ${role_name}
EOF

  log_info "Running local role '${role_name}' using temporary playbook"
  if [ $# -gt 0 ]; then
    "${venv_ansible}" -i "localhost," -c local "${tmp_playbook}" \
      -e "dotfiles_home=${dotfiles_home_default}" \
      -e "dotfiles_user_home=${dotfiles_user_home_default}" \
      -e "ansible_python_interpreter=${local_python_interpreter}" \
      "$@"
  else
    "${venv_ansible}" -i "localhost," -c local "${tmp_playbook}" \
      -e "dotfiles_home=${dotfiles_home_default}" \
      -e "dotfiles_user_home=${dotfiles_user_home_default}" \
      -e "ansible_python_interpreter=${local_python_interpreter}"
  fi
  local rc=$?

  rm -f "${tmp_playbook}"
  return "${rc}"
}

# Print usage information
usage() {
  cat << EOF
FuzLang Infrastructure CLI

Usage: fz <command> [options]

Global Options:
  --force-bootstrap      Force full bootstrap setup and refresh cache stamp
  --refresh-deps         Reinstall Python dependencies regardless of hash
  --upgrade-pip-now      Force pip upgrade in the venv on this run

Commands:
  bootstrap              Full bootstrap (winrm -> verify -> deploy -> verify)
                        Requires --limit or --all
                        Special case: --limit server-225-win runs local bootstrap only
                        Mac control node: --limit mac-dev runs playbooks/bootstrap_mac.yaml only
  bootstrap-winrm        Bootstrap Windows hosts via WinRM
                        Requires --limit or --all
                        Example: fz bootstrap-winrm --limit server-225-win
  bootstrap-ssh          Deploy stacks via SSH (WSL2 operations)
                        Requires --limit or --all
                        Example: fz bootstrap-ssh --limit server-225-wsl
  deploy <target>        Deploy stacks to target node
                        Requires --limit or --all
    main                 Deploy main stacks (server-225)
    network              Deploy network stacks (network-server)
                        Prompts for confirmation unless --yes is provided
    dev                  Deploy dev stacks (dev-3090)
  verify                 Verify entire fabric (no --limit required)
  collect-facts          Write facts for a node to facts/<node>.json
                        Requires --limit (e.g. --limit mac-dev)
                        Windows hosts: run on that machine: .\bin\bootstrap-local.ps1 -FactsOnly
  role-local <role>      Run one role locally on localhost
                        Example: fz role-local git
                        Supports ansible-playbook flags (e.g. --check, --diff)
                        Uses repo venv Python for deterministic local execution
  contract lint          Lint the contract YAML file
  vault edit <scope>     Edit vault file
    shared               Edit shared vault
    network              Edit network vault
    main                 Edit main vault
    dev                  Edit dev vault

Common Options (forwarded to ansible-playbook):
  --limit <pattern>      Limit execution to specific hosts (required for most commands)
  --all                  Run on all applicable hosts
  --yes                  Skip confirmation prompt for deploy network
  --tags <tags>          Run only tasks with these tags
  --skip-tags <tags>     Skip tasks with these tags
  --check                Run in check mode (dry-run)
  --diff                 Show differences when files are changed
  --ask-vault-pass       Prompt for vault password
  --vault-password-file <file>  Use vault password file
  --start-at-task <name> Start execution at specific task
  --step                 One-step-at-a-time execution
  -v, -vv, -vvv, -vvvv   Verbose output
  --connection-timeout <sec>  Connection timeout
  --forks <n>            Number of parallel processes

Examples:
  fz --help                                 Show command help and exit
  fz bootstrap --limit server-225-win      Run local bootstrap path for server-225-win
  fz bootstrap-winrm --limit server-225-win  Run WinRM bootstrap playbook for server-225
  fz bootstrap-ssh --limit server-225-wsl  Run SSH deploy phase for server-225-wsl
  fz bootstrap --limit server-225-wsl      Run full bootstrap flow for one WSL target
  fz bootstrap --all                        Run full bootstrap flow across all target groups
  fz deploy network --limit network-server-win  Deploy network stacks with confirmation prompt
  fz deploy network --limit network-server-win --yes  Deploy network stacks without prompt
  fz deploy main --limit server-225-wsl    Deploy main stacks to a specific host
  fz verify                                 Verify fabric health and connectivity
  fz verify --check                         Dry-run verify playbook without applying changes
  fz role-local git                         Run the git role locally on localhost
  fz role-local git --check --diff          Dry-run local git role and show diffs
  fz vault edit shared --ask-vault-pass     Edit shared vault with interactive password prompt
  fz contract lint                          Validate contract YAML syntax and structure

EOF
}

