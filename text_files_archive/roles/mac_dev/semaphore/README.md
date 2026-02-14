# Semaphore UI Role

Deploys Ansible Semaphore web UI on mac-dev node.

## Purpose

Provides a web-based interface for:
- Running Ansible playbooks
- Managing job templates
- Viewing job history and logs
- Managing inventories
- Managing credentials (including Ansible Vault passwords)

## Configuration

### Required Variables

- `semaphore_data_root`: Base directory for Semaphore data (default: `~/semaphore` or `/opt/semaphore`)
- `semaphore_playbooks_mount`: Path to playbooks directory (should mount to repo playbooks)
- `semaphore_inventory_mount`: Path to inventory directory (should mount to repo inventory)
- `semaphore_roles_mount`: Path to roles directory (should mount to repo roles)
- `semaphore_vault_mount`: Path to vault directory (should mount to repo vault)
- `semaphore_ansible_cfg_mount`: Path to ansible.cfg (should mount to repo ansible.cfg)

### Optional Variables

- `semaphore_port`: Port for Semaphore UI (default: `3000`)
- `semaphore_image`: Docker image (default: `ansiblesemaphore/semaphore:latest`)
- `semaphore_admin`: Admin username (default: `admin`)
- `semaphore_admin_password`: Admin password (default: `admin` - **CHANGE THIS!**)
- `semaphore_admin_name`: Admin display name (default: `Admin`)
- `semaphore_admin_email`: Admin email (default: `admin@localhost`)

## Usage

After deployment, access Semaphore at:
- URL: `http://localhost:3000` (or configured port)
- Username: `admin` (or configured admin user)
- Password: `admin` (or configured password - **CHANGE IMMEDIATELY!**)

## Initial Setup in Semaphore UI

1. **Change admin password** (Security → Users → Edit admin user)
2. **Add Git Repository** (Projects → Add Repository):
   - Point to your dotfile-vnext repository
   - Configure access credentials if needed
3. **Add Inventory** (Inventory → Add):
   - Upload or point to `inventory/inventory.yaml`
4. **Add Access Keys** (Access Keys):
   - For SSH access to hosts
   - For WinRM access (if needed)
5. **Add Vault Password** (Access Keys → Type: Ansible Vault):
   - Add your vault password as an access key
6. **Create Templates** (Templates):
   - Create job templates for your playbooks
   - Configure inventory, vault password, and other settings

## Security Notes

- **Always change the default admin password**
- Vault passwords are stored encrypted in Semaphore's database
- Consider using environment variables for sensitive configuration
- The vault directory is mounted read-only for security



