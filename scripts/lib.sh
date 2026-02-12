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
  local python_cmd
  python_cmd="$(get_python)"
  local activate_path="${venv_dir}/bin/activate"

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

  # Install/upgrade pip
  log_info "Ensuring pip is up to date"
  pip install --quiet --upgrade pip

  # Install requirements if they exist
  if [ -f "${requirements_file}" ]; then
    log_info "Installing Python dependencies from ${requirements_file}"
    pip install --quiet --upgrade -r "${requirements_file}"
  else
    log_warn "Requirements file not found: ${requirements_file}"
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

  # Ensure standard per-user log directory exists.
  local ansible_log_dir="${HOME}/logs"
  mkdir -p "${ansible_log_dir}"
  log_info "Ansible log directory ready: ${ansible_log_dir}"
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

# Run local bootstrap playbook from venv using localhost connection.
run_local_bootstrap_playbook() {
  local repo_root
  repo_root="$(repo_root)"
  local venv_ansible="${repo_root}/.venv/bin/ansible-playbook"
  local playbook="${repo_root}/bootstrap/local/local_bootstrap.yml"

  ensure_venv
  setup_ansible_env

  if [ ! -f "${venv_ansible}" ]; then
    log_error "ansible-playbook not found in virtual environment"
    exit 1
  fi
  if [ ! -f "${playbook}" ]; then
    log_error "Local bootstrap playbook not found: ${playbook}"
    exit 1
  fi

  log_info "Running local bootstrap playbook via localhost connection"
  "${venv_ansible}" -i "localhost," -c local "${playbook}"
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
    "${venv_ansible}" -i "localhost," -c local "${tmp_playbook}" "$@"
  else
    "${venv_ansible}" -i "localhost," -c local "${tmp_playbook}"
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

Commands:
  bootstrap              Full bootstrap (winrm -> verify -> deploy -> verify)
                        Requires --limit or --all
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
    dev                  Deploy dev stacks (dev-3090)
  verify                 Verify entire fabric (no --limit required)
  role-local <role>      Run one role locally on localhost
                        Example: fz role-local git
                        Supports ansible-playbook flags (e.g. --check, --diff)
  contract lint          Lint the contract YAML file
  vault edit <scope>     Edit vault file
    shared               Edit shared vault
    network              Edit network vault
    main                 Edit main vault
    dev                  Edit dev vault

Common Options (forwarded to ansible-playbook):
  --limit <pattern>      Limit execution to specific hosts (required for most commands)
  --all                  Run on all applicable hosts
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
  fz bootstrap-winrm --limit server-225-win
  fz bootstrap-ssh --limit server-225-wsl
  fz bootstrap --limit server-225-win --all
  fz deploy network --limit network-server-win
  fz deploy main --limit server-225-wsl
  fz verify
  fz verify --check
  fz vault edit shared --ask-vault-pass
  fz contract lint

EOF
}

