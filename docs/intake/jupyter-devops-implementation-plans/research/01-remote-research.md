# Research: Remote JupyterLab Workbench

**Research Date:** 2026-05-19  
**Purpose:** Document deployment patterns for remote JupyterLab on Ubuntu VM with Ansible automation

---

## 1. JupyterLab Installation Documentation

### Production Installation Pattern (Non-Docker)

**Official Approach:**
- Create dedicated `jupyter` user for isolation
- Use Python 3 virtual environment (`python3 -m venv`)
- Install JupyterLab via pip in isolated environment
- Configure password-based authentication
- Deploy as systemd service

**Key Sources:**
- [Install JupyterLab on Ubuntu 24.04 - Makson Lee](https://www.maksonlee.com/install-jupyterlab-on-ubuntu-24-04/)
- [DigitalOcean Tutorial - Ubuntu 18.04](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-jupyterlab-environment-on-ubuntu-18-04)

### Installation Steps (Baseline)

```bash
# 1. Create dedicated user
sudo adduser --disabled-password --gecos "" jupyter

# 2. Install prerequisites
sudo apt update && sudo apt install -y python3 python3-pip python3-venv

# 3. Create virtual environment (as jupyter user)
sudo su - jupyter
python3 -m venv ~/jupyterlab-venv
source ~/jupyterlab-venv/bin/activate
pip install --upgrade pip
pip install jupyterlab

# 4. Generate config and set password
jupyter lab --generate-config
jupyter lab password
```

### Configuration File Pattern

`~/.jupyter/jupyter_lab_config.py`:
```python
c.PasswordIdentityProvider.hashed_password = 'argon2:...'
c.ServerApp.ip = '0.0.0.0'  # Listen on all interfaces (for SSH tunnel)
c.ServerApp.port = 8888
c.ServerApp.open_browser = False
c.ServerApp.allow_remote_access = True
```

**Security Note:** The `0.0.0.0` binding is acceptable when behind SSH tunnel or reverse proxy, not for direct internet exposure.

---

## 2. Ansible Role Examples

### Available Roles (2024-2026)

#### ansible/jupyter (Codeberg)
- **URL:** https://codeberg.org/ansible/jupyter
- **Target:** Ubuntu 22.04
- **Features:**
  - Installs JupyterLab behind JupyterHub
  - Python virtualenv setup
  - Node.js dependency handling
  - Julia kernel support (optional)
  - Notebook directory management

#### DODAS-TS/ansible-role-jupyterhub-env (GitHub)
- **URL:** https://github.com/DODAS-TS/ansible-role-jupyterhub-env
- **Latest:** v2.5.0 (March 2024)
- **Features:**
  - JupyterHub spawning JupyterLab
  - GPU support (optional)
  - Docker integration
  - NVIDIA driver installation
  - Monitoring service integration
  - Collaborative JupyterLab features

#### marvel-nccr/ansible-role-aiida (GitHub)
- **URL:** https://github.com/marvel-nccr/ansible-role-aiida
- **Features:**
  - Separate 'jupyter' Python virtual environment
  - Jupyter + JupyterLab as kernel
  - Scientific workflow integration (AiiDA)
  - Docker container support

#### ISTI-ansible-roles/ansible-role-jupyter (Gitea)
- **URL:** https://gitea-s2i2s.isti.cnr.it/ISTI-ansible-roles/ansible-role-jupyter
- **Features:**
  - Jupyter and JupyterHub installation
  - LDAP authentication with SSL
  - Group filters support

### Key Ansible Pattern Observations

1. **Virtual environment isolation** is universal across all roles
2. **Systemd service management** is standard approach
3. **Node.js** is common dependency (JupyterLab frontend)
4. Most roles target **Ubuntu/Debian** platforms
5. **JupyterHub** is common for multi-user scenarios (not our use case)

---

## 3. SSH Tunnel Best Practices

### Why SSH Tunneling

SSH tunneling is the **recommended secure method** for remote Jupyter access:
- Encrypts all traffic
- No need to expose Jupyter port to internet
- Works with existing SSH infrastructure
- Supports token/password authentication

**Source:** [ML Journey - Remote Jupyter](https://mljourney.com/how-to-use-jupyter-notebook-remotely/)

### SSH Tunnel Setup Pattern

**From local machine (Mac):**
```bash
ssh -L 8888:localhost:8888 your_username@your_server_ip
```

Then access at `http://localhost:8888` in local browser.

**Advanced pattern with background persistence:**
```bash
ssh -N -f -L 8888:localhost:8888 your_username@your_server_ip
```
- `-N`: No remote commands
- `-f`: Background mode
- `-L`: Local port forwarding

### Port Management Best Practices

1. **Check for port conflicts:**
   ```bash
   lsof -i :8888
   ```

2. **Use terminal multiplexers (tmux/screen)** to keep Jupyter running when SSH disconnects

3. **VPN for off-campus access** rather than exposing ports directly

4. **Avoid X11 forwarding** - SSH port forwarding is much more performant for browser-based tools

**Sources:**
- [Yale Research Computing - Jupyter SSH](https://docs.ycrc.yale.edu/clusters-at-yale/guides/jupyter_ssh/)
- [UW-Madison - SSH Port Forwarding](https://kb.wisc.edu/data/154458)

---

## 4. Python Virtual Environment Management in Ansible

### Ansible's pip Module

**Primary tool:** `ansible.builtin.pip` module
- **Documentation:** https://docs.ansible.com/ansible/latest/collections/ansible/builtin/pip_module.html
- Supports virtual environments via `virtualenv` parameter
- Can use Python 3's built-in venv: `virtualenv_command: python3 -m venv`
- Manages requirements files, version pinning, PyPI packages

### Pattern: pip with venv

```yaml
- name: Create virtual environment
  ansible.builtin.pip:
    name: pip
    state: latest
    virtualenv: /home/jupyter/jupyterlab-venv
    virtualenv_command: python3 -m venv

- name: Install JupyterLab in venv
  ansible.builtin.pip:
    name:
      - jupyterlab
      - ipykernel
      - langfuse
      - anthropic
      - openai
      - python-dotenv
    virtualenv: /home/jupyter/jupyterlab-venv
    state: present
```

### Poetry Alternative

**When to use Poetry:**
- Modern dependency management needs
- Automatic virtual environment management
- Faster, more reliable dependency resolution (SAT-based solver)
- PEP 621 compliance

**Ansible pattern with Poetry:**
```yaml
- name: Install Poetry
  ansible.builtin.pip:
    name: poetry
    state: present

- name: Install project dependencies with Poetry
  ansible.builtin.command:
    cmd: poetry install --no-root
    chdir: /home/jupyter/notebooks
  become_user: jupyter
```

**Sources:**
- [Ansible Pilot - Poetry Virtual Environments](https://ansiblepilot.com/articles/leveraging-poetry-for-efficient-virtual-environment-management)
- [Red Hat - Python Dependencies in EE](https://developers.redhat.com/articles/2025/01/27/how-manage-python-dependencies-ansible-execution-environments)

### Recommendation for This Project

**Use pip + venv** for simplicity:
- Aligns with official JupyterLab docs
- Ansible pip module is mature and well-documented
- Sufficient for SDK package management (langfuse, anthropic, openai)
- No additional tooling dependency

**Consider Poetry if:**
- Complex dependency graphs emerge
- Lock file reproducibility is critical
- Team grows and needs standardized tooling

---

## 5. Systemd Service Patterns for JupyterLab

### Service Unit File Template

**Location:** `/etc/systemd/system/jupyterlab.service`

```ini
[Unit]
Description=JupyterLab Server
After=network.target

[Service]
Type=simple
User=jupyter
Group=jupyter
WorkingDirectory=/home/jupyter
Environment="PATH=/home/jupyter/jupyterlab-venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ExecStart=/home/jupyter/jupyterlab-venv/bin/jupyter lab --config=/home/jupyter/.jupyter/jupyter_lab_config.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### Key Configuration Elements

1. **Type=simple:** Standard for long-running processes
2. **User/Group:** Non-root execution (security)
3. **WorkingDirectory:** Notebooks directory or home
4. **Environment:** Include venv bin in PATH
5. **ExecStart:** Full path to venv's jupyter binary
6. **Restart policies:** `always` + `RestartSec=10` for resilience

### Service Management Commands

```bash
# Enable and start
sudo systemctl daemon-reload
sudo systemctl enable jupyterlab
sudo systemctl start jupyterlab

# Check status
sudo systemctl status jupyterlab

# View logs
sudo journalctl -u jupyterlab -f
```

### Ansible Systemd Module Pattern

```yaml
- name: Create JupyterLab systemd service
  ansible.builtin.template:
    src: jupyterlab.service.j2
    dest: /etc/systemd/system/jupyterlab.service
    mode: '0644'
  notify: Reload systemd

- name: Enable and start JupyterLab service
  ansible.builtin.systemd:
    name: jupyterlab
    enabled: true
    state: started
    daemon_reload: true
```

**Sources:**
- [Vultr - JupyterLab Ubuntu 22.04](https://docs.vultr.com/how-to-set-up-a-jupyterlab-environment-on-ubuntu-22-04)
- [DatabaseMart - JupyterLab Deployment Guide](https://www.databasemart.com/kb/jupyterlab-deployment-guide)

---

## 6. Security Considerations

### Architecture Security Model

**JupyterLab is designed for single-user access only.**  
**For multi-user production environments, use JupyterHub instead.**

**Source:** [Jupyter Server - Public Server Docs](https://jupyter-server.readthedocs.io/en/latest/operators/public-server.html)

### Authentication Best Practices

#### Password-Based Authentication (Recommended)

1. Generate password hash with Argon2:
   ```bash
   jupyter lab password
   ```

2. Configure in `jupyter_lab_config.py`:
   ```python
   c.PasswordIdentityProvider.hashed_password = 'argon2:...'
   ```

#### Token Authentication (Default)

- Jupyter auto-generates unique tokens
- **Security limitation:** Tokens can leak through XML HTTP requests
- Shared token allows arbitrary requests
- Not suitable for multi-user scenarios

### Network Security

#### Binding Configuration

**For SSH tunnel access (recommended):**
```python
c.ServerApp.ip = '127.0.0.1'  # Localhost only
c.ServerApp.port = 8888
c.ServerApp.allow_remote_access = False  # Explicit
```

Access via: `ssh -L 8888:localhost:8888 user@server`

**For reverse proxy setup:**
```python
c.ServerApp.ip = '127.0.0.1'  # Still localhost
c.ServerApp.port = 8888
```
Then configure Nginx/HAProxy to proxy to localhost:8888 with SSL termination.

**Never expose directly to internet:**
```python
# DANGEROUS - only for trusted networks behind firewall
c.ServerApp.ip = '0.0.0.0'
c.ServerApp.allow_remote_access = True
```

### SSL/TLS Configuration

**For production with reverse proxy:**
- Use Nginx for SSL termination
- Obtain certificates from Let's Encrypt
- Configure HTTPS redirect
- Set appropriate headers (HSTS, X-Frame-Options)

**For direct SSL (not recommended):**
```python
c.ServerApp.certfile = '/path/to/cert.pem'
c.ServerApp.keyfile = '/path/to/key.pem'
```

### Hardening Checklist

- [ ] Run as dedicated non-root user
- [ ] Use password authentication (not just tokens)
- [ ] Bind to localhost when using SSH tunnel
- [ ] Use reverse proxy with SSL for public access
- [ ] Configure firewall to restrict port access
- [ ] Enable systemd service (not user session)
- [ ] Set restrictive file permissions on config
- [ ] Regular security updates (apt, pip)
- [ ] Disable unused kernels
- [ ] Monitor logs (`journalctl -u jupyterlab`)

### Known Security Limitations

1. **Single-user design:** Commands from concurrent users can collide
2. **Token leakage:** Authentication tokens exposed in requests
3. **No built-in RBAC:** Limited access control mechanisms
4. **Code execution risk:** Users can run arbitrary system commands via notebooks

**Mitigation:** Use JupyterHub for multi-user scenarios, strict network isolation, and proper authentication.

**Sources:**
- [JupyterLab Security Best Practices](https://jupyterlab.readthedocs.io/en/latest/developer/security.html)
- [Running Public Jupyter Server](https://jupyter-server.readthedocs.io/en/latest/operators/public-server.html)
- [HAProxy Basic Auth Setup](https://www.tspi.at/2023/01/27/jupyterlabhaproxyauth.html)

---

## Summary: Recommended Pattern for This Project

### Architecture

```
Mac (local)
  └─ SSH tunnel (port 8888)
       └─ Ubuntu VM
            └─ JupyterLab (systemd service)
                 └─ Python venv with SDKs
                      ├─ langfuse
                      ├─ anthropic
                      ├─ openai
                      └─ python-dotenv
```

### Implementation Approach

1. **User:** Dedicated `jupyter` user
2. **Python env:** venv at `/home/jupyter/jupyterlab-venv`
3. **Installation:** Ansible pip module
4. **Service:** systemd unit
5. **Access:** SSH tunnel (localhost binding)
6. **Auth:** Password-based
7. **Packages:** pip requirements file

### Why This Pattern

- **Simple:** Fewest moving parts
- **Secure:** SSH tunnel + localhost binding
- **Ansible-native:** Uses built-in pip module
- **Maintainable:** Standard systemd service
- **Scalable:** Can add reverse proxy later if needed
- **Documented:** Aligns with official JupyterLab docs

### Next Steps

1. Create Ansible role structure (`roles/jupyterlab_workbench/`)
2. Define role variables (Python version, packages, user)
3. Implement tasks for user, venv, config, service
4. Create systemd service template
5. Add handlers for service restart
6. Document SSH tunnel setup in role README
7. Test deployment on Ubuntu VM

---

## Research Sources

### Primary Documentation
- [JupyterLab Official Installation Guides](https://www.maksonlee.com/install-jupyterlab-on-ubuntu-24-04/)
- [DigitalOcean JupyterLab Tutorial](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-jupyterlab-environment-on-ubuntu-18-04)
- [Ansible pip Module Docs](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/pip_module.html)

### Ansible Roles
- [ansible/jupyter (Codeberg)](https://codeberg.org/ansible/jupyter)
- [DODAS-TS/ansible-role-jupyterhub-env (GitHub)](https://github.com/DODAS-TS/ansible-role-jupyterhub-env)
- [marvel-nccr/ansible-role-aiida (GitHub)](https://github.com/marvel-nccr/ansible-role-aiida)

### Security & Operations
- [JupyterLab Security Best Practices](https://jupyterlab.readthedocs.io/en/latest/developer/security.html)
- [Running Public Jupyter Server](https://jupyter-server.readthedocs.io/en/latest/operators/public-server.html)
- [Yale Research Computing - SSH Tunnel Guide](https://docs.ycrc.yale.edu/clusters-at-yale/guides/jupyter_ssh/)

### Python Environment Management
- [Ansible Pilot - Poetry for Virtual Environments](https://ansiblepilot.com/articles/leveraging-poetry-for-efficient-virtual-environment-management)
- [Red Hat - Python Dependencies in Execution Environments](https://developers.redhat.com/articles/2025/01/27/how-manage-python-dependencies-ansible-execution-environments)

### Systemd & Production Deployment
- [Vultr - JupyterLab on Ubuntu 22.04](https://docs.vultr.com/how-to-set-up-a-jupyterlab-environment-on-ubuntu-22-04)
- [DatabaseMart - JupyterLab Deployment Guide](https://www.databasemart.com/kb/jupyterlab-deployment-guide)
- [GuidoV - JupyterLab Server Setup](https://guidov.github.io/2024/09/15/jupyterlab-server/)
