# Ansible Semaphore Setup Guide

This guide explains how to set up and use Ansible Semaphore UI for managing your FuzLang infrastructure.

## Overview

Ansible Semaphore provides a web-based UI for:
- Running Ansible playbooks
- Managing job templates and schedules
- Viewing job history and logs
- Managing inventories and credentials
- Managing Ansible Vault passwords

## Prerequisites

- Docker and Docker Compose installed on mac-dev
- Ansible installed on mac-dev
- Access to the dotfile-vnext repository

## Deployment

### 1. Configure Semaphore Admin Password (Optional but Recommended)

Edit the vault file to set a secure admin password:

```bash
./bin/fz vault edit connection --ask-vault-pass
```

Add or update:
```yaml
vault_semaphore_admin_password: "your-secure-password-here"
```

If you don't set this, the default password will be `CHANGE_ME_ON_FIRST_LOGIN` and you **must** change it immediately after first login.

### 2. Deploy Semaphore

Run the deployment playbook:

```bash
./bin/fz deploy semaphore
```

Or manually:

```bash
ansible-playbook -i inventory/inventory.yaml playbooks/deploy_semaphore.yaml --ask-vault-pass
```

### 3. Access Semaphore UI

After deployment, access Semaphore at:
- **URL**: `http://localhost:3000`
- **Username**: `admin`
- **Password**: The password you set in the vault (or `CHANGE_ME_ON_FIRST_LOGIN` if not set)

## Initial Configuration in Semaphore UI

### Step 1: Change Admin Password

1. Log in with the default credentials
2. Go to **Settings** → **Users**
3. Click on the `admin` user
4. Change the password to something secure
5. Save changes

### Step 2: Create a Project

1. Go to **Projects** → **New Project**
2. Name: `FuzLang Infrastructure`
3. Description: `FuzLang multi-node AI infrastructure`
4. Click **Create**

### Step 3: Add Git Repository (Optional)

If you want Semaphore to pull playbooks from Git:

1. Go to **Projects** → **FuzLang Infrastructure** → **Repositories**
2. Click **Add Repository**
3. Configure:
   - **Name**: `dotfile-vnext`
   - **Git URL**: Path to your repository (local path or Git URL)
   - **Git Branch**: `main` (or your default branch)
   - **SSH Key**: If using SSH, add an access key first

### Step 4: Add Inventory

1. Go to **Projects** → **FuzLang Infrastructure** → **Inventory**
2. Click **Add Inventory**
3. Choose **File** or **Static**
4. For **File**:
   - **Name**: `FuzLang Inventory`
   - **Inventory File**: `/data/inventory/inventory.yaml`
5. Click **Save**

### Step 5: Add Access Keys

#### SSH Keys (for WSL and mac-dev access)

1. Go to **Projects** → **FuzLang Infrastructure** → **Access Keys**
2. Click **Add Key**
3. Configure:
   - **Name**: `SSH Key - WSL`
   - **Type**: `SSH`
   - **SSH Private Key**: Paste your SSH private key
   - **SSH User**: `josh` (or your WSL username)
4. Click **Save**

#### WinRM Credentials (for Windows hosts)

1. Go to **Access Keys** → **Add Key**
2. Configure:
   - **Name**: `WinRM - Server-225`
   - **Type**: `Login Password`
   - **Username**: `josh` (or your Windows admin username)
   - **Password**: Your Windows admin password (or reference vault)
3. Click **Save**

Repeat for other Windows hosts (network-server, dev-3090).

#### Ansible Vault Password

1. Go to **Access Keys** → **Add Key**
2. Configure:
   - **Name**: `Ansible Vault Password`
   - **Type**: `Ansible Vault`
   - **Vault Password**: Your Ansible Vault password
3. Click **Save**

**Security Note**: The vault password is encrypted in Semaphore's database, but ensure Semaphore itself is secured.

### Step 6: Create Job Templates

#### Bootstrap Templates

**Bootstrap Server-225**:
1. Go to **Projects** → **FuzLang Infrastructure** → **Templates**
2. Click **Add Template**
3. Configure:
   - **Name**: `Bootstrap Server-225`
   - **Playbook**: `/data/playbooks/bootstrap_server_225.yaml`
   - **Inventory**: `FuzLang Inventory`
   - **Limit**: `server-225-win`
   - **Vault Password**: `Ansible Vault Password` (select from dropdown)
   - **SSH Key**: `SSH Key - WSL` (if needed)
4. Click **Save**

**Bootstrap Network Server**:
- Similar to above, but:
  - **Name**: `Bootstrap Network Server`
  - **Playbook**: `/data/playbooks/bootstrap_network_server.yaml`
  - **Limit**: `network-server-win`

**Bootstrap Dev-3090**:
- Similar to above, but:
  - **Name**: `Bootstrap Dev-3090`
  - **Playbook**: `/data/playbooks/bootstrap_dev_3090.yaml`
  - **Limit**: `dev-3090-win`

#### Deploy Templates

**Deploy Network Stacks**:
1. Create template:
   - **Name**: `Deploy Network Stacks`
   - **Playbook**: `/data/playbooks/deploy_network_stacks.yaml`
   - **Inventory**: `FuzLang Inventory`
   - **Limit**: `network_node`
   - **Vault Password**: `Ansible Vault Password`
2. Click **Save**

**Deploy Main Stacks**:
- Similar, but:
  - **Name**: `Deploy Main Stacks`
  - **Playbook**: `/data/playbooks/deploy_main_stacks.yaml`
  - **Limit**: `main_node`

**Deploy Dev Stacks**:
- Similar, but:
  - **Name**: `Deploy Dev Stacks`
  - **Playbook**: `/data/playbooks/deploy_dev_stacks.yaml`
  - **Limit**: `dev_node`

#### Verify Template

**Verify Fabric**:
1. Create template:
   - **Name**: `Verify Fabric`
   - **Playbook**: `/data/playbooks/verify_fabric.yaml`
   - **Inventory**: `FuzLang Inventory`
   - **Vault Password**: `Ansible Vault Password`
2. Click **Save**

### Step 7: Run Jobs

1. Go to **Projects** → **FuzLang Infrastructure** → **Templates**
2. Click on a template (e.g., `Verify Fabric`)
3. Click **Run**
4. Monitor the job execution in real-time
5. View logs and output

## Managing Semaphore

### Start/Stop Semaphore

```bash
# Start
cd ~/.semaphore/semaphore
docker compose up -d

# Stop
docker compose down

# View logs
docker compose logs -f

# Restart
docker compose restart
```

### Update Semaphore

1. Pull latest image:
   ```bash
   cd ~/.semaphore/semaphore
   docker compose pull
   docker compose up -d
   ```

### Backup Semaphore Data

Semaphore data is stored in `~/.semaphore/semaphore`. To backup:

```bash
# Backup the entire directory
tar -czf semaphore-backup-$(date +%Y%m%d).tar.gz ~/.semaphore/semaphore
```

### Reset Semaphore (if needed)

If you need to reset Semaphore:

```bash
# Stop and remove
cd ~/.semaphore/semaphore
docker compose down -v

# Remove data (WARNING: This deletes all configuration!)
rm -rf ~/.semaphore/semaphore

# Redeploy
./bin/fz deploy semaphore
```

## Troubleshooting

### Semaphore won't start

1. Check Docker is running:
   ```bash
   docker ps
   ```

2. Check logs:
   ```bash
   cd ~/.semaphore/semaphore
   docker compose logs
   ```

3. Verify port 3000 is available:
   ```bash
   lsof -i :3000
   ```

### Can't access playbooks/inventory

1. Verify mount paths in `inventory/group_vars/mac_dev.yaml`
2. Ensure paths are absolute (use `playbook_dir` variable)
3. Check Docker volume mounts:
   ```bash
   docker inspect semaphore | grep -A 10 Mounts
   ```

### Jobs fail with "inventory not found"

1. Verify inventory file path in Semaphore UI
2. Check that inventory is mounted correctly
3. Ensure inventory file is readable

### Vault password not working

1. Verify vault password access key is correct
2. Check that vault files are mounted and readable
3. Test vault password manually:
   ```bash
   ansible-vault view vault/shared.vault.yml --ask-vault-pass
   ```

## Security Best Practices

1. **Change default admin password immediately**
2. **Use strong passwords for all access keys**
3. **Limit Semaphore access** (only accessible from localhost or trusted network)
4. **Regularly update Semaphore** to latest version
5. **Backup Semaphore data** regularly
6. **Monitor job logs** for security issues
7. **Use SSH keys** instead of passwords where possible
8. **Rotate vault passwords** periodically

## Integration with Existing Workflow

Semaphore complements your existing `./bin/fz` workflow:

- **Use `./bin/fz`** for: Quick CLI operations, local development, scripts
- **Use Semaphore** for: Web UI access, scheduled jobs, team collaboration, audit logs

Both can coexist and use the same playbooks, inventory, and vault files.

## Next Steps

1. Set up scheduled jobs for regular verification
2. Configure email notifications for job failures
3. Set up multiple users with appropriate permissions
4. Integrate with Git for playbook versioning
5. Set up backup automation for Semaphore data



