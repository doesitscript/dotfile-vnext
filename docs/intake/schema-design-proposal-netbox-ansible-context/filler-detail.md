Here's everything that was built for cas-lab-hom:

🌐 Documentation Site
The interactive site is live above with six fully navigable sections:

Section	What's inside
Overview	Schema formula, segment breakdown, naming rules, 8 example hostnames
Role Reference	Searchable/filterable table of all 37 roles with category badges and expandable details
Hostname Validator	Real-time regex validation, segment-color parsing, unknown-role warnings, and hostname generator
Environments & Sites	Token tables for all envs and sites — lab/hom highlighted as active
NetBox Integration	YAML webhook definition, Python handler snippet, custom field definitions
Ansible Collections	Collection tree view, role list, sample playbook


🔗 NetBox Webhook Files (9 files attached above)
File	Purpose
netbox_webhook_handler.txt	FastAPI service — HMAC-verified, validates device/VM names on create/update, returns parsed segments + errors
netbox_webhooks.txt	3 webhook definitions (device create, device update, VM create/update) + custom field + tag definitions
netbox_docker_compose.txt	Docker Compose to run the handler alongside NetBox
netbox_requirements.txt	fastapi + uvicorn pinned deps


Schema regex enforced: ^[a-z]{2,3}-[a-z]{2,3}-[a-z]{2,3}-[a-z]{2,3}-\d{2}$

⚙️ Ansible Collection — cas.lab (270 files)
File	Purpose
ansible_galaxy.txt → galaxy.yml	Collection manifest, namespace cas.lab, version 1.0.0
ansible_inventory.txt → hosts.yml	Full inventory with all 37 host stubs across 7 group categories
ansible_provision_all.yml	Master playbook — schema pre-flight assert, then per-group role dispatch
ansible_validate_schema.yml	Standalone validation playbook with per-segment assertions
ansible_cfg.txt → ansible.cfg	Tuned config with fact caching, pipelining, YAML callback
ansible_README.txt	Collection docs


Each of the 37 roles gets: defaults/main.yml, vars/main.yml, meta/main.yml, handlers/main.yml, tasks/main.yml, tasks/<category>.yml, templates/<role>.conf.j2, and an empty files/ dir.

A natural next step would be scaffolding a Gitea/GitLab CI pipeline (cas-lab-hom-git-01) that runs ansible-playbook validate_schema.yml on every PR as a gating check — want me to generate that workflow definition?


Infra Naming Schema — Documentation Site
Open app
Open
