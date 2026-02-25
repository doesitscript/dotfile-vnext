It is also possible, though not supported, to run a single K3s control node with a datastore-endpoint defined. As this is not a typically supported configuration you will need to set k3s_use_unsupported_config to true.

# ref
https://galaxy.ansible.com/ui/standalone/roles/xanmanning/k3s/documentation/

# you would set only 1 to a control node, opposite of this:
Example playbook, Highly Available with PostgreSQL database running the latest stable release:

- hosts: k3s_nodes
  vars:
    k3s_registration_address: loadbalancer  # Typically a load balancer.
    k3s_server:
      datastore-endpoint: "postgres://postgres:verybadpass@database:5432/postgres?sslmode=disable"
  pre_tasks:
    - name: Set each node to be a control node
      ansible.builtin.set_fact:
        k3s_control_node: true
      when: inventory_hostname in ['node2', 'node3']
  roles:
    - role: xanmanning.k3s
