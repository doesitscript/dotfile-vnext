ansible-playbook playbooks/access.yaml \
  -i inventory/inventory.yaml \
  --limit 'execution_nodes,server-225-win'
