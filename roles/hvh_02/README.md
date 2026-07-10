ansible-playbook playbooks/access.yaml \
  -i inventory/inventory.yaml \
  --limit 'execution_nodes,HOM-LAB-HVH-02'
