Option 1: Using the run-playbook wrapper (recommended)
./bin/run-playbook.sh playbooks/deploy_shell_config.yaml --limit mac-dev

# Deploy to your Mac./bin/run-playbook.sh playbooks/deploy_shell_config.yaml --limit mac-dev# Deploy to the Ubuntu guest on server-225./bin/run-playbook.sh playbooks/deploy_shell_config.yaml --limit server-225-ubuntu
Option 2: Direct ansible-playbook
# Deploy to your Macansible-playbook playbooks/deploy_shell_config.yaml \  -i inventory/inventory.yaml \  --limit mac-dev \  --vault-password-file vault_pass.sh# Deploy to the Ubuntu guestansible-playbook playbooks/deploy_shell_config.yaml \  -i inventory/inventory.yaml \  --limit server-225-ubuntu \  --vault-password-file vault_pass.sh
Option 3: Using fz (if you add it to fz later)
# This would require adding a command to bin/fz, but for now use Option 1 or 2
After running
# Reload your shell to activate direnvsource ~/.bashrc# Or just open a new terminal
