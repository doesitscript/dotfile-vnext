# Shell contract for the work-laptop export packet bootstrap flow.
# The bootstrap script sources this file, and the project skill validates that
# these values still match the repo's work-laptop packet conventions.

PACKET_REFERENCE_HOST="mac-dev"
PACKET_SYSTEM_PYTHON="/usr/bin/python3"
PACKET_VENV_RELATIVE=".venv"
PACKET_REQUIREMENTS_RELATIVE="scripts/requirements.txt"
PACKET_COLLECTIONS_DIR_RELATIVE="collections"
PACKET_COLLECTIONS_REQUIREMENTS_RELATIVE="collections/requirements.yml"
PACKET_BOOTSTRAP_PLAYBOOK_RELATIVE="bootstrap/bootstrap-tooling.yaml"
PACKET_MAIN_PLAYBOOK_RELATIVE="playbook.yaml"
PACKET_INVENTORY_RELATIVE="inventory.yaml"
PACKET_PUBLIC_BIN_RELATIVE=".local/bin"
