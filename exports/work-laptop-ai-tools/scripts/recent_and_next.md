cd ~/Documents/develop/work-laptop-ai-tools
git pull --ff-only
ANSIBLE_VAULT_PASSWORD_FILE=/path/to/parent/.vault_pass \
ansible-playbook playbook.yaml -i inventory.yaml --skip-tags hosts_file --tags ai_tools
