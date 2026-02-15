Good.
Now we build something real.

You want:

• Clean Docker lab stack
• Reverse proxy
• Proper compose structure
• Ansible templating
• Vault usage
• Clean separation

This will be production-style, but lab-appropriate.

🧱 Target Architecture

Server runs:

Traefik (reverse proxy)
|
├── whoami (test service)
├── Portainer (optional UI)
└── future services


Access via:

http://server-ip
http://whoami.server-ip


No hardcoding secrets in repo.

📁 Repo Structure
compose/
  lab_stack/
    docker-compose.yml.j2

roles/
  docker_engine/
  docker_stack/
  verify_docker/

group_vars/
  server_225.yml
  vault.yml (encrypted)

playbooks/
  docker_deploy.yaml

🔐 Vault File

Create vault:

ansible-vault create group_vars/vault.yml


Inside:

vault_traefik_dashboard_password: "supersecretpassword"


Encrypt it.

🧠 group_vars/server_225.yml
docker_project_name: lab_stack
docker_project_dest: /opt/lab_stack
docker_domain: "server-225.local"
traefik_dashboard_user: "admin"

🧩 Compose Template

compose/lab_stack/docker-compose.yml.j2

version: "3.9"

services:

  traefik:
    image: traefik:v3.0
    container_name: traefik
    command:
      - "--api.dashboard=true"
      - "--providers.docker=true"
      - "--entrypoints.web.address=:80"
    ports:
      - "80:80"
      - "8080:8080"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.dashboard.rule=Host(`traefik.{{ docker_domain }}`)"
      - "traefik.http.routers.dashboard.service=api@internal"

  whoami:
    image: traefik/whoami
    container_name: whoami
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.whoami.rule=Host(`whoami.{{ docker_domain }}`)"
      - "traefik.http.routers.whoami.entrypoints=web"

  portainer:
    image: portainer/portainer-ce
    container_name: portainer
    command: -H unix:///var/run/docker.sock
    ports:
      - "9000:9000"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data

volumes:
  portainer_data:


This is clean, extensible, and label-driven.

🧱 docker_stack Role
tasks/main.yml
- name: Ensure project directory exists
  ansible.builtin.file:
    path: "{{ docker_project_dest }}"
    state: directory
    mode: '0755'

- name: Template docker-compose file
  ansible.builtin.template:
    src: docker-compose.yml.j2
    dest: "{{ docker_project_dest }}/docker-compose.yml"
    mode: '0644'

- name: Deploy docker stack
  community.docker.docker_compose:
    project_src: "{{ docker_project_dest }}"
    state: present
  tags:
    - docker

🧱 verify_docker Role
tasks/main.yml
- name: Gather docker info
  community.docker.docker_host_info:
  register: docker_info
  changed_when: false
  tags:
    - verify
    - docker

- name: Ensure traefik is running
  ansible.builtin.assert:
    that:
      - "'traefik' in docker_info.containers | map(attribute='Names') | join(' ')"
    fail_msg: "Traefik container not running"
  tags:
    - verify
    - docker

📜 Playbook

playbooks/docker_deploy.yaml

- hosts: server_225
  gather_facts: true
  vars_files:
    - group_vars/vault.yml
  roles:
    - docker_engine
    - docker_stack
    - verify_docker

🧪 Run

Deploy:

ansible-playbook playbooks/docker_deploy.yaml -i inventory/inventory.yaml --tags docker


Verify only:

ansible-playbook playbooks/docker_deploy.yaml -i inventory/inventory.yaml --tags verify

🌐 What You Get

After deploy:

http://server-ip
http://whoami.server-ip
http://server-ip:9000


If DNS isn’t set up, use /etc/hosts on your Mac for lab domain.

🔥 Why This Is Clean

• Reverse proxy decouples services
• No ports exposed except 80 + 9000
• Labels drive routing
• Compose templated via Ansible
• Secrets isolated in vault
• Verification separate
• Idempotent
• Extendable