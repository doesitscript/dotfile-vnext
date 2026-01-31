#!/usr/bin/env bash
# Shared bash functions for FuzLang Infrastructure scripts

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
  echo -e "${BLUE}[INFO]${NC} $*" >&2
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $*" >&2
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $*" >&2
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $*" >&2
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

  if [ ! -d "${venv_dir}" ]; then
    log_info "Creating virtual environment at ${venv_dir}"
    require_cmd "${python_cmd}"
    "${python_cmd}" -m venv "${venv_dir}"
  fi

  # Activate virtual environment
  source "${venv_dir}/bin/activate"

  # Install/upgrade pip
  log_info "Ensuring pip is up to date"
  pip install --quiet --upgrade pip

  # Install requirements if they exist
  if [ -f "${requirements_file}" ]; then
    log_info "Installing Python dependencies from ${requirements_file}"
    pip install --quiet --upgrade -r "${requirements_file}"
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
  fi

  # Ensure we're in repo root (ansible-playbook runs from here)
  cd "${repo_root}"
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

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --limit)
        ansible_cmd+=("--limit" "$2")
        shift 2
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

# Print usage information
usage() {
  cat << EOF
FuzLang Infrastructure CLI

Usage: fz <command> [options]

Commands:
  bootstrap              Bootstrap server-225 (main node)
  bootstrap-winrm        Bootstrap network-server and dev-3090 (Windows nodes)
  bootstrap-ssh          Info about WSL bootstrap (handled automatically)
  deploy <target>        Deploy stacks to target node
    main                 Deploy main stacks (server-225)
    network              Deploy network stacks (network-server)
    dev                  Deploy dev stacks (dev-3090)
  verify                 Verify entire fabric
  contract lint          Lint the contract YAML file
  vault edit <scope>     Edit vault file
    shared               Edit shared vault
    network              Edit network vault
    main                 Edit main vault
    dev                  Edit dev vault

Common Options (forwarded to ansible-playbook):
  --limit <pattern>      Limit execution to specific hosts
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
  fz bootstrap --limit server-225-win
  fz deploy network --tags stacks_network
  fz verify --check
  fz vault edit shared --ask-vault-pass
  fz contract lint

EOF
}

