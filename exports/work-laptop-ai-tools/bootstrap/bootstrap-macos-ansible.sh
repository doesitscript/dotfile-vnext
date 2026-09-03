#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKET_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# shellcheck source=bootstrap-contract.sh
source "${SCRIPT_DIR}/bootstrap-contract.sh"

DRY_RUN=false
NONINTERACTIVE_HOMEBREW=false
RUN_MAIN_PLAYBOOK=true
SKIP_COLLECTIONS=false
FORCE_UPGRADE_HOMEBREW=false
FORCE_REFRESH_PACKET_VENV=false
FORCE_UPGRADE_COLLECTIONS=false
FORCE_UPGRADE_PACKET_TOOLCHAIN=false
HOMEBREW_UPDATED=false
PLAYBOOK_ARGS=()

PACKET_VENV_DIR="${PACKET_ROOT}/${PACKET_VENV_RELATIVE}"
PACKET_REQUIREMENTS_FILE="${PACKET_ROOT}/${PACKET_REQUIREMENTS_RELATIVE}"
PACKET_COLLECTIONS_DIR="${PACKET_ROOT}/${PACKET_COLLECTIONS_DIR_RELATIVE}"
PACKET_COLLECTIONS_REQUIREMENTS_FILE="${PACKET_ROOT}/${PACKET_COLLECTIONS_REQUIREMENTS_RELATIVE}"
PACKET_INVENTORY_FILE="${PACKET_ROOT}/${PACKET_INVENTORY_RELATIVE}"
PACKET_VENV_PYTHON="${PACKET_VENV_DIR}/bin/python3"
PACKET_ANSIBLE_PLAYBOOK_BIN="${PACKET_VENV_DIR}/bin/ansible-playbook"
PACKET_ANSIBLE_GALAXY_BIN="${PACKET_VENV_DIR}/bin/ansible-galaxy"
PACKET_PUBLIC_ANSIBLE_PLAYBOOK="${HOME}/${PACKET_PUBLIC_BIN_RELATIVE}/ansible-playbook"

log() {
  printf '%s\n' "$*"
}

fail() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

usage() {
  cat <<'EOF'
Usage:
  ./bootstrap/bootstrap-macos-ansible.sh [options] [-- <ansible-playbook args>]

Purpose:
  Bootstrap a fresh macOS machine so this exported packet can run locally.
  The script installs only the missing first-touch pieces directly, then hands
  off to the packet-contained roles for the handpicked work-laptop tool set:
    packet .venv -> ~/.local/bin/ansible-playbook symlink

Options:
  --dry-run                          Print the actions that would run.
  --noninteractive-homebrew         Use NONINTERACTIVE=1 for the Homebrew installer.
  --bootstrap-only                  Stop after the packet tooling bootstrap playbook.
  --skip-collections                Skip packet-local ansible-galaxy collection install.
  --force-upgrade-homebrew          Run Homebrew update and allow bootstrap playbook package refresh.
  --force-refresh-packet-venv       Upgrade packet .venv pip dependencies from scripts/requirements.txt.
  --force-upgrade-collections       Reinstall packet-local collections with --force.
  --force-upgrade-packet-toolchain  Upgrade packet .venv Ansible tooling through the bootstrap playbook.
  --force-upgrade-pipx              Compatibility alias for --force-upgrade-packet-toolchain.
  --force-upgrade-ansible           Compatibility alias for packet .venv plus packet-tooling refresh.
  --force-upgrade-all               Enable all force-upgrade flags above.
  --help                            Show this help text.

Examples:
  ./bootstrap/bootstrap-macos-ansible.sh -- -K
  ./bootstrap/bootstrap-macos-ansible.sh --bootstrap-only
  ./bootstrap/bootstrap-macos-ansible.sh --force-upgrade-all -- -K
EOF
}

print_command() {
  printf '$'
  for part in "$@"; do
    printf ' %q' "${part}"
  done
  printf '\n'
}

run_cmd() {
  print_command "$@"
  if [ "${DRY_RUN}" = true ]; then
    return 0
  fi
  "$@"
}

append_unique_line() {
  local target="$1"
  local line="$2"

  if [ -f "${target}" ] && grep -Fqx "${line}" "${target}"; then
    return 0
  fi

  if [ "${DRY_RUN}" = true ]; then
    log "Would append to ${target}: ${line}"
    return 0
  fi

  mkdir -p "$(dirname "${target}")"
  touch "${target}"
  printf '\n%s\n' "${line}" >> "${target}"
}

detect_shell_profile() {
  case "${SHELL:-}" in
    */zsh) printf '%s\n' "${HOME}/.zprofile" ;;
    */bash) printf '%s\n' "${HOME}/.bash_profile" ;;
    *) printf '%s\n' "${HOME}/.profile" ;;
  esac
}

find_brew_bin() {
  if [ -x /opt/homebrew/bin/brew ]; then
    printf '%s\n' /opt/homebrew/bin/brew
    return 0
  fi
  if [ -x /usr/local/bin/brew ]; then
    printf '%s\n' /usr/local/bin/brew
    return 0
  fi
  if command -v brew >/dev/null 2>&1; then
    command -v brew
    return 0
  fi
  return 1
}

load_homebrew_env() {
  local brew_bin
  brew_bin="$(find_brew_bin)" || return 1
  eval "$("${brew_bin}" shellenv)"
}

ensure_homebrew_path_for_session() {
  case ":${PATH}:" in
    *":${HOME}/.local/bin:"*) ;;
    *) export PATH="${HOME}/.local/bin:${PATH}" ;;
  esac
}

ensure_xcode_clt_for_homebrew_install() {
  if xcode-select -p >/dev/null 2>&1; then
    return 0
  fi
  fail "Xcode Command Line Tools are required before first-time Homebrew install. Run 'xcode-select --install' on the target Mac and re-run this bootstrap."
}

run_homebrew_update_once() {
  local brew_bin="$1"
  if [ "${HOMEBREW_UPDATED}" = true ]; then
    return 0
  fi
  run_cmd "${brew_bin}" update
  HOMEBREW_UPDATED=true
}

ensure_homebrew() {
  local brew_bin installer_tmp profile_path shellenv_line

  if brew_bin="$(find_brew_bin)"; then
    log "Homebrew already present: ${brew_bin}"
    load_homebrew_env
    if [ "${FORCE_UPGRADE_HOMEBREW}" = true ]; then
      run_homebrew_update_once "${brew_bin}"
    fi
    return 0
  fi

  ensure_xcode_clt_for_homebrew_install
  installer_tmp="$(mktemp "${TMPDIR:-/tmp}/homebrew-install.XXXXXX.sh")"
  trap 'rm -f "${installer_tmp}"' EXIT
  run_cmd curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "${installer_tmp}"
  if [ "${NONINTERACTIVE_HOMEBREW}" = true ]; then
    print_command env NONINTERACTIVE=1 /bin/bash "${installer_tmp}"
    if [ "${DRY_RUN}" = false ]; then
      env NONINTERACTIVE=1 /bin/bash "${installer_tmp}"
    fi
  else
    run_cmd /bin/bash "${installer_tmp}"
  fi

  if [ "${DRY_RUN}" = true ]; then
    trap - EXIT
    rm -f "${installer_tmp}"
    log "Dry run: assuming Homebrew would be installed successfully."
    return 0
  fi

  trap - EXIT
  rm -f "${installer_tmp}"

  brew_bin="$(find_brew_bin)" || fail "Homebrew install completed but brew was not found on PATH or in the default prefixes."
  load_homebrew_env
  ensure_homebrew_path_for_session

  profile_path="$(detect_shell_profile)"
  shellenv_line="eval \"\$(${brew_bin} shellenv)\""
  append_unique_line "${profile_path}" "${shellenv_line}"
  log "Persisted Homebrew shellenv in ${profile_path}"
}

ensure_packet_venv() {
  local base_python

  [ -f "${PACKET_REQUIREMENTS_FILE}" ] || fail "Missing packet requirements file: ${PACKET_REQUIREMENTS_FILE}"

  if [ -x "${PACKET_SYSTEM_PYTHON}" ]; then
    base_python="${PACKET_SYSTEM_PYTHON}"
  else
    base_python="$(command -v python3 || true)"
  fi
  [ -n "${base_python}" ] || fail "Python 3 is required to create the packet virtual environment."

  if [ ! -x "${PACKET_VENV_PYTHON}" ]; then
    run_cmd "${base_python}" -m venv "${PACKET_VENV_DIR}"
    run_cmd "${PACKET_VENV_PYTHON}" -m pip install --upgrade pip
    run_cmd "${PACKET_VENV_PYTHON}" -m pip install -r "${PACKET_REQUIREMENTS_FILE}"
    return 0
  fi

  log "Packet virtual environment already present: ${PACKET_VENV_DIR}"
  if [ "${FORCE_REFRESH_PACKET_VENV}" = true ]; then
    run_cmd "${PACKET_VENV_PYTHON}" -m pip install --upgrade pip
    run_cmd "${PACKET_VENV_PYTHON}" -m pip install --upgrade -r "${PACKET_REQUIREMENTS_FILE}"
  fi
}

collection_installed() {
  if [ ! -x "${PACKET_ANSIBLE_GALAXY_BIN}" ]; then
    return 1
  fi
  "${PACKET_ANSIBLE_GALAXY_BIN}" collection list -p "${PACKET_COLLECTIONS_DIR}" community.general 2>/dev/null | grep -Fq "community.general"
}

ensure_packet_collections() {
  [ -f "${PACKET_COLLECTIONS_REQUIREMENTS_FILE}" ] || fail "Missing packet collection requirements file: ${PACKET_COLLECTIONS_REQUIREMENTS_FILE}"

  if [ "${SKIP_COLLECTIONS}" = true ]; then
    log "Skipping packet-local collection install by request."
    return 0
  fi

  if [ "${DRY_RUN}" = true ]; then
    if [ "${FORCE_UPGRADE_COLLECTIONS}" = true ]; then
      run_cmd "${PACKET_ANSIBLE_GALAXY_BIN}" collection install --force -r "${PACKET_COLLECTIONS_REQUIREMENTS_FILE}" -p "${PACKET_COLLECTIONS_DIR}"
    else
      run_cmd "${PACKET_ANSIBLE_GALAXY_BIN}" collection install -r "${PACKET_COLLECTIONS_REQUIREMENTS_FILE}" -p "${PACKET_COLLECTIONS_DIR}"
    fi
    return 0
  fi

  mkdir -p "${PACKET_COLLECTIONS_DIR}"
  if collection_installed; then
    log "Packet-local collection community.general already present."
    if [ "${FORCE_UPGRADE_COLLECTIONS}" = true ]; then
      run_cmd "${PACKET_ANSIBLE_GALAXY_BIN}" collection install --force -r "${PACKET_COLLECTIONS_REQUIREMENTS_FILE}" -p "${PACKET_COLLECTIONS_DIR}"
    fi
    return 0
  fi

  run_cmd "${PACKET_ANSIBLE_GALAXY_BIN}" collection install -r "${PACKET_COLLECTIONS_REQUIREMENTS_FILE}" -p "${PACKET_COLLECTIONS_DIR}"
}

run_packet_tooling_bootstrap_playbook() {
  local cmd=(
    "${PACKET_ANSIBLE_PLAYBOOK_BIN}"
    "${PACKET_ROOT}/${PACKET_BOOTSTRAP_PLAYBOOK_RELATIVE}"
    -i "${PACKET_INVENTORY_FILE}"
  )

  if [ "${FORCE_UPGRADE_HOMEBREW}" = true ]; then
    cmd+=(-e work_laptop_bootstrap_force_homebrew_upgrade=true)
  fi
  if [ "${FORCE_UPGRADE_PACKET_TOOLCHAIN}" = true ]; then
    cmd+=(-e work_laptop_bootstrap_force_packet_toolchain_upgrade=true)
  fi

  run_cmd "${cmd[@]}"
}

run_main_packet_playbook() {
  local cmd=(
    "${PACKET_ANSIBLE_PLAYBOOK_BIN}"
    "${PACKET_ROOT}/${PACKET_MAIN_PLAYBOOK_RELATIVE}"
    -i "${PACKET_INVENTORY_FILE}"
  )
  if [ "${#PLAYBOOK_ARGS[@]}" -gt 0 ]; then
    cmd+=("${PLAYBOOK_ARGS[@]}")
  fi
  run_cmd "${cmd[@]}"
}

parse_args() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --dry-run)
        DRY_RUN=true
        ;;
      --noninteractive-homebrew)
        NONINTERACTIVE_HOMEBREW=true
        ;;
      --bootstrap-only)
        RUN_MAIN_PLAYBOOK=false
        ;;
      --skip-collections)
        SKIP_COLLECTIONS=true
        ;;
      --force-upgrade-homebrew)
        FORCE_UPGRADE_HOMEBREW=true
        ;;
      --force-refresh-packet-venv)
        FORCE_REFRESH_PACKET_VENV=true
        ;;
      --force-upgrade-collections)
        FORCE_UPGRADE_COLLECTIONS=true
        ;;
      --force-upgrade-packet-toolchain|--force-upgrade-pipx)
        FORCE_UPGRADE_PACKET_TOOLCHAIN=true
        ;;
      --force-upgrade-ansible)
        FORCE_REFRESH_PACKET_VENV=true
        FORCE_UPGRADE_CONTROLLER_TOOLCHAIN=true
        ;;
      --force-upgrade-all)
        FORCE_UPGRADE_HOMEBREW=true
        FORCE_REFRESH_PACKET_VENV=true
        FORCE_UPGRADE_COLLECTIONS=true
        FORCE_UPGRADE_PACKET_TOOLCHAIN=true
        ;;
      --help|-h)
        usage
        exit 0
        ;;
      --)
        shift
        PLAYBOOK_ARGS=("$@")
        break
        ;;
      *)
        fail "Unknown argument: $1"
        ;;
    esac
    shift
  done
}

configure_homebrew_tap_trust_compat() {
  # Work laptops often already have third-party taps. Homebrew 6+ refuses some
  # brew operations while untrusted taps are present, which breaks Ansible
  # community.general.homebrew installs of official formulae (openssl, pyenv,
  # etc.). Prefer trusting taps you keep long-term with `brew trust <tap>`.
  # This session opt-out keeps packet automation unblocked until then.
  if [ -z "${HOMEBREW_NO_REQUIRE_TAP_TRUST:-}" ]; then
    export HOMEBREW_NO_REQUIRE_TAP_TRUST=1
    log "Enabled HOMEBREW_NO_REQUIRE_TAP_TRUST=1 for this bootstrap/Ansible session (Homebrew 6 tap-trust compat)."
  else
    log "Using existing HOMEBREW_NO_REQUIRE_TAP_TRUST=${HOMEBREW_NO_REQUIRE_TAP_TRUST}"
  fi
}

require_current_python_brew_tasks() {
  local python_mac_tasks="${PACKET_ROOT}/roles/python/tasks/mac.yml"
  local revision_file="${PACKET_ROOT}/${PACKET_REVISION_RELATIVE}"
  local head_sha=""
  local revision_value=""

  [ -f "${python_mac_tasks}" ] || fail "Missing ${python_mac_tasks}"
  [ -f "${revision_file}" ] || fail "Missing ${revision_file}. Run git pull on master (need commit >= 745ecce)."

  revision_value="$(grep -E '^python_mac_revision=' "${revision_file}" | head -1 | cut -d= -f2- | tr -d '[:space:]')"
  if [ "${revision_value}" != "${PACKET_PYTHON_MAC_REVISION}" ]; then
    fail "Stale ${revision_file}: got python_mac_revision=${revision_value:-<missing>}, need ${PACKET_PYTHON_MAC_REVISION}. Run: git fetch origin && git pull --ff-only origin master"
  fi
  log "Packet revision OK: python_mac_revision=${revision_value}"

  if [ -d "${PACKET_ROOT}/.git" ] && command -v git >/dev/null 2>&1; then
    head_sha="$(git -C "${PACKET_ROOT}" rev-parse --short HEAD 2>/dev/null || true)"
    if [ -n "${head_sha}" ]; then
      log "Packet git HEAD: ${head_sha} (need >= 745ecce for OpenSSL-skip fix)"
    fi
  fi

  if grep -Fq 'Ensure Python tooling dependencies are installed on macOS' "${python_mac_tasks}"; then
    fail "Stale python brew installer still on disk in ${python_mac_tasks}. Run: git fetch origin && git restore --source=origin/master -- roles/python/tasks/mac.yml roles/python/defaults/main.yml bootstrap/bootstrap-macos-ansible.sh .packet-revision && git pull --ff-only origin master"
  fi

  if ! grep -Fq "PACKET_PYTHON_MAC_REVISION=${PACKET_PYTHON_MAC_REVISION}" "${python_mac_tasks}"; then
    fail "python mac tasks missing revision marker ${PACKET_PYTHON_MAC_REVISION}. Run git pull on master."
  fi

  if ! grep -Fq 'Report existing OpenSSL instead of reinstalling' "${python_mac_tasks}"; then
    fail "Packet checkout is missing the OpenSSL-skip python tasks. Run git pull on master."
  fi

  log "Python brew task preflight OK (OpenSSL install/upgrade skipped by design)."
}

main() {
  [ "$(uname -s)" = "Darwin" ] || fail "This bootstrap currently supports macOS only."
  parse_args "$@"
  ensure_homebrew_path_for_session
  export ANSIBLE_CONFIG="${PACKET_ROOT}/ansible.cfg"
  configure_homebrew_tap_trust_compat
  require_current_python_brew_tasks

  ensure_homebrew
  ensure_packet_venv
  ensure_packet_collections
  run_cmd "${PACKET_ANSIBLE_PLAYBOOK_BIN}" --version
  run_packet_tooling_bootstrap_playbook

  if [ "${RUN_MAIN_PLAYBOOK}" = true ]; then
    run_main_packet_playbook
  else
    log "Bootstrap complete. Packet Ansible toolchain is ready at ${PACKET_VENV_DIR}."
    log "Public Ansible entrypoint should converge to ${PACKET_PUBLIC_ANSIBLE_PLAYBOOK} after the bootstrap role run."
  fi
}

main "$@"
