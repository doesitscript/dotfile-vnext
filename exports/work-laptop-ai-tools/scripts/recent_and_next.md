cd ~/Documents/develop/work-laptop-ai-tools
git pull --ff-only
ANSIBLE_VAULT_PASSWORD_FILE=/path/to/parent/.vault_pass \
ansible-playbook playbook.yaml -i inventory.yaml --tags ai_cli_apps
