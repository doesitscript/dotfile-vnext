ansible-playbook playbooks/access_windows.yaml \
  -i inventory/inventory.yaml \
  --limit 'server-225-win,network_server' \
  --tags wsl-reset,wsl