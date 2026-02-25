Using these tools will allow you to avoid "scripting everything" (reinventing the wheel) and instead use verified, parameterized roles.

1. Search for Roles (The "Research" Phase)
Use the search command to find popular or specialized roles, such as those by Jeff Geerling, or community-driven ones. 
bash
ansible-galaxy role search <keyword>
Example: ansible-galaxy role search nginx
Best Practice: Look for roles with high download counts and good ratings. 
OneUptime
OneUptime
 +1

 2. Get Role Details (Understanding Parameters)
Before using a role, you need to know its input parameters (variables). The info command shows the documentation, author, and default variables. 
bash
ansible-galaxy role info <username.role_name>
Example: ansible-galaxy role info geerlingguy.nginx
Tip: This command is crucial for identifying which parameters in defaults/main.yml you need to override in your playbook to customize the behavior. 
Ansible Community Documentation
Ansible Community Documentation
 +4

what mcp tools can help me to find capabilties and roles and colections to solve a problem. what other things can our mcp servers more generically help us whnwe are about to design a solution to a problem in ansible

/Users/joshc/.local/pipx/venvs/ansible/lib/python3.14/site-packages/ansible/_internal/ansible_collections

ansible-galaxy role search <service>
ansible-galaxy role search *K3*
Inspect: ansible-galaxy role info <best_match>

 collection   Manage an Ansible Galaxy collection.
    role         Manage an Ansible Galaxy role.

options:
  --version      show program's version number, config file location, configured
                 module search path, module location, executable location and
                 exit