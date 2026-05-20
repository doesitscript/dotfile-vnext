# Plan: Remote JupyterLab Workbench

## Overview

This plan outlines the implementation of a remote JupyterLab workbench on an Ubuntu virtual machine, managed by Ansible automation. The primary goal is to provide a secure and robust environment for data science and AI/ML development, accessible via SSH tunneling from a local machine (e.g., macOS). The setup emphasizes single-user isolation, password-based authentication, and systemd service management for resilience.

## Recommended Architecture

```mermaid
graph TD
    subgraph Local_Machine [Local Machine (macOS)]
        User[User Interface] -- SSH Tunnel (port 8888) --> Remote_VM
    end

    subgraph Remote_VM [Ubuntu VM]
        JupyterLab_Service[JupyterLab Systemd Service]
        Python_Venv[Python Virtual Environment]
        Jupyter_Config[JupyterLab Config File<br/>(`jupyter_lab_config.py`)]
        Jupyter_User[Dedicated `jupyter` User]
    end

    subgraph Repository [dotfile-vnext Repository]
        subgraph Roles [Roles]
            JupyterLab_Role[roles/jupyterlab_workbench/]
            JCommon_Node_Role[roles/common/node]
        end
        subgraph Inventory [Inventory]
            Host_Vars[inventory/host_vars/<host>/]
            Group_Vars[inventory/group_vars/all.yaml]
            Version_Contract[Version Contract (for Python packages)]
        end
        subgraph Playbooks [Playbooks]
            Deploy_Playbook[playbooks/deploy_development_nodes.yaml]
        end
        subgraph Templates [Templates]
            JupyterLab_Service_Template[roles/jupyterlab_workbench/templates/jupyterlab.service.j2]
            JupyterLab_Config_Template[roles/jupyterlab_workbench/templates/jupyter_lab_config.py.j2]
        end
    end

    Python_Venv -->|"installs"| SDKs[Python SDKs<br/>(langfuse, anthropic, openai, python-dotenv)]
    JupyterLab_Service -->|"runs"| Python_Venv
    JupyterLab_Service -->|"uses config"| Jupyter_Config
    Jupyter_User -->|"owns"| Python_Venv
    Jupyter_User -->|"owns"| Jupyter_Config

    JupyterLab_Role -->|"deploys"| JupyterLab_Service
    JupyterLab_Role -->|"creates"| Python_Venv
    JupyterLab_Role -->|"configures"| Jupyter_Config
    JupyterLab_Role -->|"manages"| Jupyter_User
    JupyterLab_Role -->|"depends on"| JCommon_Node_Role
    JupyterLab_Role -- "uses" --> JupyterLab_Service_Template
    JupyterLab_Role -- "uses" --> JupyterLab_Config_Template

    Host_Vars -->|"provides host-specific vars"| JupyterLab_Role
    Group_Vars -->|"provides global vars"| JupyterLab_Role
    Version_Contract -->|"defines pinned package versions"| JupyterLab_Role
    Deploy_Playbook -->|"includes"| JupyterLab_Role

    Remote_VM -- SSH Access --> Jupyter_User

    classDef default fill:#DDEBF7,stroke:#6680A6,stroke-width:2px;
    class JupyterLab_Service fill:#FCE4D6,stroke:#D3781F;
    class Python_Venv fill:#E2F0D9,stroke:#6B9E5A;
    class Jupyter_Config fill:#FFF2CC,stroke:#FFC000;
    class Jupyter_User fill:#D9EAD3,stroke:#93C47D;
    class SDKs fill:#E9EFF9,stroke:#A1B2D9;
    class JupyterLab_Role fill:#D0E0E3,stroke:#7EA0A9;
    class Host_Vars fill:#F8ECC2,stroke:#D4AC0D;
    class Group_Vars fill:#F8ECC2,stroke:#D4AC0D;
    class Version_Contract fill:#F8ECC2,stroke:#D4AC0D;
    class Deploy_Playbook fill:#F2F2F2,stroke:#A6A6A6;
    class JupyterLab_Service_Template fill:#F0F0F0,stroke:#B0B0B0;
    class JupyterLab_Config_Template fill:#F0F0F0,stroke:#B0B0B0;
    class JCommon_Node_Role fill:#D0E0E3,stroke:#7EA0A9;

```

## Implementation Approach

The implementation will focus on creating a new Ansible role `jupyterlab_workbench` that handles the installation and configuration of JupyterLab on an Ubuntu VM. This role will ensure a secure and maintainable setup, accessible through SSH tunneling.

### 1. Create `jupyterlab_workbench` Role Structure
- Use `ansible-galaxy init jupyterlab_workbench` to scaffold the role.

### 2. Define Role Variables (`defaults/main.yml`)
- `jupyterlab_workbench_user`: Dedicated user for JupyterLab (default: `jupyter`).
- `jupyterlab_workbench_venv_path`: Path to the Python virtual environment (default: `/home/{{ jupyterlab_workbench_user }}/jupyterlab-venv`).
- `jupyterlab_workbench_port`: Port for JupyterLab server (default: `8888`).
- `jupyterlab_workbench_packages`: List of Python packages to install (default: `jupyterlab`, `ipykernel`, `langfuse`, `anthropic`, `openai`, `python-dotenv`).
- `jupyterlab_workbench_password_hash`: Hashed password for JupyterLab, to be sourced from vault.
- `jupyterlab_workbench_bind_ip`: IP address to bind JupyterLab to (default: `127.0.0.1` for SSH tunneling).

### 3. Implement Tasks (`tasks/main.yml`)
- **Prerequisites**: Ensure `roles/common/node` is a dependency if Node.js is required for JupyterLab extensions (research suggests it often is).
- **User Creation**: Create the dedicated `jupyterlab_workbench_user` with `ansible.builtin.user` and ensure proper home directory setup.
- **Python Virtual Environment**:
    - Use `ansible.builtin.pip` to create the virtual environment at `jupyterlab_workbench_venv_path` using `python3 -m venv`.
    - Upgrade `pip` within the new venv.
- **Install JupyterLab and Packages**:
    - Use `ansible.builtin.pip` to install `jupyterlab` and `jupyterlab_workbench_packages` into the virtual environment.
- **JupyterLab Configuration**:
    - Create `~/.jupyter/` directory for the user.
    - Template `jupyter_lab_config.py.j2` to `{{ jupyterlab_workbench_user_home }}/.jupyter/jupyter_lab_config.py`.
    - The template will set `c.PasswordIdentityProvider.hashed_password`, `c.ServerApp.ip`, `c.ServerApp.port`, `c.ServerApp.open_browser=False`, and `c.ServerApp.allow_remote_access=False`.
- **Systemd Service**:
    - Template `jupyterlab.service.j2` to `/etc/systemd/system/jupyterlab.service` with appropriate permissions (`0644`).
    - The template will define `User`, `Group`, `WorkingDirectory`, `Environment` (including venv bin path), and `ExecStart` with the config file path.
    - Use `ansible.builtin.systemd` to `daemon-reload`, `enable`, and `start` the `jupyterlab` service.
    - Set up a handler to reload systemd and restart the service on config changes.

### 4. Integrate into Playbook (`playbooks/deploy_development_nodes.yaml`)
- Add the `jupyterlab_workbench` role to `playbooks/deploy_development_nodes.yaml`.
- Apply a tag, e.g., `jupyterlab`, to the role inclusion for selective execution.

### 5. Documentation
- Update `roles/jupyterlab_workbench/README.md` with usage instructions, including how to set the password hash and how to establish the SSH tunnel.

## Apply / Verify / Undo / Change Class

### Apply
- **Action**: Run the `deploy_development_nodes.yaml` playbook with the `jupyterlab` tag.
- **Command**: `ansible-playbook playbooks/deploy_development_nodes.yaml --tags jupyterlab -l <target_host>`
- **Prerequisites**: Target Ubuntu VM must be reachable via Ansible and have Python 3 installed.

### Verify
- **Method 1 (Service Status)**: Check if the `jupyterlab` systemd service is running on the remote VM.
    - **Command**: `ssh <target_host> "systemctl status jupyterlab"`
- **Method 2 (Port Listen)**: Verify JupyterLab is listening on `127.0.0.1:8888` on the remote VM.
    - **Command**: `ssh <target_host> "sudo lsof -i :8888"`
- **Method 3 (SSH Tunnel Access)**: Establish an SSH tunnel and access JupyterLab from the local browser.
    - **Command**: `ssh -L 8888:localhost:8888 <target_host>`
    - **Browser**: Navigate to `http://localhost:8888` and log in with the configured password.

### Undo
- **Action**: Stop and disable the systemd service, remove the user and its home directory, and remove the configuration files.
- **Ansible Tasks**: Add `state: absent` tasks to the `jupyterlab_workbench` role for user, venv, and service.
- **Command**: `ansible-playbook playbooks/deploy_development_nodes.yaml --tags jupyterlab --extra-vars "jupyterlab_workbench_state=absent" -l <target_host>` (Assuming the role is designed with a `state` variable).

### Change Class
- **Idempotent Configuration**: The core installation and configuration tasks will be idempotent, meaning re-running them will not cause unintended changes if the system is already in the desired state.
- **Bootstrap/Semi-manual**: Initial password hash generation requires a manual step to run `jupyter lab password` on a local machine and copy the hash to a vault.
- **Destructive**: The `undo` operation is destructive as it removes users and files.

## Naming Standards

- **Role Naming**: `jupyterlab_workbench` (capability-focused, snake_case).
- **Variable Naming**: All role variables will be prefixed with `jupyterlab_workbench_` (e.g., `jupyterlab_workbench_user`). Vault variables will follow `vault_jupyterlab_workbench_password_hash`.
- **Task Naming**: Descriptive and imperative (e.g., "Create dedicated jupyter user").
- **File Naming**: Templates `jupyterlab.service.j2`, `jupyter_lab_config.py.j2`.

## Dependencies

- **Ansible Collections**: `ansible.builtin` (for user, pip, systemd, template modules).
- **Python**: Python 3 and `python3-venv` on the target Ubuntu VM.
- **Systemd**: On the target Ubuntu VM.
- **OpenSSH Server**: On the target Ubuntu VM for SSH access and tunneling.

## Diagram Inventory

### Diagrams Included
- **Architecture/Structure Diagram**: Shows repository organization, naming schemes, and integration points

### Additional Diagrams Available On Request
- **Deployment Flow**: Sequential deployment steps across environments
- **State Transition Diagram**: Object lifecycle and state changes
- **Integration Sequence**: Detailed API/service interaction timeline
- **Network Topology**: Host/cluster/network relationships (when infrastructure is in scope)
