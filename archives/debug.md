./bin/fz bootstrap --limit mac-dev

2026-02-12 17:26:45 [INFO] fz invoked from /Users/joshc/develop/dotfile-vnext
2026-02-12 17:26:45 [INFO] Command=bootstrap Args=--limit mac-dev
2026-02-12 17:26:45 [CHECK] Dispatching command handler
2026-02-12 17:26:45 [INFO] bootstrap args captured: --limit mac-dev
2026-02-12 17:26:45 [STEP] Phase 1: Bootstrap WinRM
2026-02-12 17:26:45 [CHECK] bootstrap mode: --limit mac-dev
2026-02-12 17:26:45 [INFO] Existing virtual environment detected at /Users/joshc/develop/dotfile-vnext/.venv                                                                            
2026-02-12 17:26:45 [INFO] Requirements unchanged; skipping dependency install
/Users/joshc/develop/dotfile-vnext/scripts/lib.sh: line 159: /Users/joshc/develop/dotfile-vnext/.mgmt/requirements_yml.sha256: No such file or directory                                
2026-02-12 17:26:45 [INFO] Installing Ansible Galaxy collections from /Users/joshc/develop/dotfile-vnext/requirements.yml                                                               
Starting galaxy collection install process
Nothing to do. All requested collections are already installed. If you want to reinstall them, consider using `--force`.                                                                
2026-02-12 17:26:46 [OK] Virtual environment ready
2026-02-12 17:26:46 [INFO] Using Ansible config: /Users/joshc/develop/dotfile-vnext/ansible.cfg                                                                                         
2026-02-12 17:26:46 [INFO] ANSIBLE_ROLES_PATH=/Users/joshc/develop/dotfile-vnext/roles:/Users/joshc/develop/dotfile-vnext/playbooks/roles:/Users/joshc/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles                                                                   
2026-02-12 17:26:46 [INFO] ANSIBLE_COLLECTIONS_PATH=/Users/joshc/develop/dotfile-vnext/collections:/Users/joshc/.ansible/collections:/usr/share/ansible/collections                     
2026-02-12 17:26:46 [INFO] Ansible log directory ready: /Users/joshc/logs
2026-02-12 17:26:46 [INFO] Running: /Users/joshc/develop/dotfile-vnext/.venv/bin/ansible-playbook playbooks/bootstrap_dev_3090.yaml -i /Users/joshc/develop/dotfile-vnext/inventory/inventory.yaml --limit mac-dev                                                                  
[WARNING]: Deprecation warnings can be disabled by setting `deprecation_warnings=False` in ansible.cfg.                                                                                 
[DEPRECATION WARNING]: community.windows.win_timezone has been deprecated. win_timezone will be removed in a future release of this collection. Use ansible.windows.win_timezone instead. This feature will be removed from collection 'community.windows' version 4.0.0.           
[ERROR]: couldn't resolve module/action 'ansible.windows.win_firewall_rule'. This often indicates a misspelling, missing collection, or incorrect module path.                          
Origin: /Users/joshc/develop/dotfile-vnext/playbooks/bootstrap_dev_3090.yaml:21:7

19         }
20
21     - name: Open WinRM HTTPS firewall rule
         ^ column 7
