Good.

Systemd is already working. That means we skip all WSL boot configuration. No need to touch that again.

You are not inside a Docker container.
You are inside WSL Ubuntu.
Docker simply is not installed yet.

From your earlier output:

```
Command 'docker' not found
```

That confirms it.

So we move straight to installing Docker properly via Ansible.

---

# Clean, Correct Docker Installation (Ubuntu 24.04 in WSL)

We are not using snap.
We are not using random Galaxy roles.
We are installing the official Docker CE packages.

Create a role:

```
roles/docker_engine/tasks/main.yml
```

Put this inside:

```yaml
---
- name: Install prerequisite packages
  ansible.builtin.apt:
    name:
      - ca-certificates
      - curl
      - gnupg
      - lsb-release
    state: present
    update_cache: yes
  become: true

- name: Create Docker keyring directory
  ansible.builtin.file:
    path: /etc/apt/keyrings
    state: directory
    mode: '0755'
  become: true

- name: Add Docker GPG key
  ansible.builtin.get_url:
    url: https://download.docker.com/linux/ubuntu/gpg
    dest: /etc/apt/keyrings/docker.asc
    mode: '0644'
  become: true

- name: Add Docker apt repository
  ansible.builtin.apt_repository:
    repo: >
      deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc]
      https://download.docker.com/linux/ubuntu
      {{ ansible_distribution_release }} stable
    state: present
  become: true

- name: Install Docker Engine and Compose plugin
  ansible.builtin.apt:
    name:
      - docker-ce
      - docker-ce-cli
      - containerd.io
      - docker-buildx-plugin
      - docker-compose-plugin
    state: present
    update_cache: yes
  become: true

- name: Ensure docker group exists
  ansible.builtin.group:
    name: docker
    state: present
  become: true

- name: Add user to docker group
  ansible.builtin.user:
    name: "{{ ansible_user_id }}"
    groups: docker
    append: yes
  become: true

- name: Enable docker service
  ansible.builtin.systemd:
    name: docker
    enabled: true
  become: true

- name: Start docker service
  ansible.builtin.systemd:
    name: docker
    state: started
  become: true
```

---

# Playbook

```
playbooks/docker_engine.yaml
```

```yaml
---
- name: Install Docker on WSL
  hosts: wsl_hosts
  gather_facts: true

  roles:
    - docker_engine
```

---

# Run It

From your Mac:

```
ansible-playbook playbooks/docker_engine.yaml -i inventory/inventory.yaml
```

After it completes:

Log out of WSL completely.

Reconnect.

Then:

```
docker version
docker compose version
```

If those work, you're done.

---

# Why this is the correct approach

• Uses official Docker CE repo
• Uses apt (not snap)
• Enables systemd service
• Idempotent
• Works cleanly inside WSL 24
• Compatible with community.docker modules

---

If something fails, show me the exact error and we’ll fix that layer only.
