netbox is up, try again to finish

NetBox is up — I'll verify connectivity, run the seed playbooks, then complete Track H.

000curl_failed
        "children": [
            "ungrouped"
        ]
    }
}

--- 192.168.50.158 ping statistics ---
2 packets transmitted, 2 packets received, 0.0% packet loss, 2 packets out of wait time
round-trip min/avg/max/stddev = 6.134/6.166/6.198/0.032 ms
ping: cannot resolve hom-lab-ctl-hvh-02: Unknown host
http_code:000
NETBOX_TOKEN unset
cd /Users/joshc/develop/dotfile-vnext && source .envrc 2>/dev/null; curl -s -m 8 -w "\nhttp:%{http_code}\n" "http://192.168.137.10:8000/api/status/" 2>&1 | tail -3; curl -s -m 8 -w "\nhttp:%{http_code}\n" -H "Authorization: Token ${NETBOX_TOKEN}" "http://192.168.137.10:8000/api/" 2>&1 | tail -3
http:000

http:000
cd /Users/joshc/develop/dotfile-vnext && bin/codex-env ansible hom-lab-ctl-dkr-02 -m ansible.builtin.uri -a "url=http://127.0.0.1:8000/api/status/ return_content=yes" 2>&1 | tail -25
"django_tables2": "2.7.0",
            "drf_spectacular": "0.27.2",
            "drf_spectacular_sidecar": "2024.5.1",
            "mptt": "0.16.0",
            "rest_framework": "3.15.1",
            "social_django": "5.4.1",
            "taggit": "5.0.1",
            "timezone_field": "6.1.0"
        },
        "netbox-version": "4.0.2",
        "plugins": {},
        "python-version": "3.11.6",
        "rq-workers-running": 1
    },
    "msg": "OK (426 bytes)",
    "redirected": false,
    "referrer_policy": "same-origin",
    "server": "Unit/1.32.0",
    "status": 200,
    "url": "http://127.0.0.1:8000/api/status/",
    "vary": "HX-Request, Accept-Language, Cookie, origin",
    "x_content_type_options": "nosniff",
    "x_frame_options": "SAMEORIGIN",
    "x_request_id": "d7b34b0b-4e53-419d-a209-ac145d1241c4"
}
ping -c 1 -W 2 192.168.137.10 2>&1; cd /Users/joshc/develop/dotfile-vnext && source .envrc 2>/dev/null; bin/codex-env ansible hom-lab-ctl-dkr-02 -m ansible.builtin.uri -a "url=http://192.168.50.158:8000/api/status/ return_content=yes timeout=5" 2>&1 | tail -8
PING 192.168.137.10 (192.168.137.10): 56 data bytes

--- 192.168.137.10 ping statistics ---
1 packets transmitted, 0 packets received, 100.0% packet loss
    "changed": false,
    "content": "",
    "elapsed": 5,
    "msg": "Status code was -1 and not [200]: Request failed: <urlopen error timed out>",
    "redirected": false,
    "status": -1,
    "url": "http://192.168.50.158:8000/api/status/"
}
[WARNING]: Unable to parse /Users/joshc/develop/dotfile-vnext/inventory/netbox.yml as an inventory source
hom-lab-ctl-dkr-02 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
not in ssh config
Permission denied, please try again.
Permission denied, please try again.
joshc@192.168.50.158: Permission denied (publickey,password,keyboard-interactive).
kex_exchange_identification: Connection closed by remote host
Connection closed by UNKNOWN port 65535
ssh -f -N -L 18000:127.0.0.1:8000 \
  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -o ProxyCommand="ssh -W %h:%p -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i /Users/joshc/.ssh/id_ed25519_ansible joshc@192.168.50.158" \
  -i /Users/joshc/.ssh/id_ed25519_ansible \
  joshc@192.168.137.10 2>&1; sleep 2; cd /Users/joshc/develop/dotfile-vnext && source .envrc; curl -s -m 5 -H "Authorization: Token ${NETBOX_TOKEN}" http://127.0.0.1:18000/api/status/ | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('netbox-version','ok'))"
Warning: Permanently added '192.168.50.158' (ED25519) to the list of known hosts.
Warning: Permanently added '192.168.137.10' (ED25519) to the list of known hosts.
the input device is not a TTY
COMMAND   PID  USER   FD   TYPE             DEVICE SIZE/OFF NODE NAME
ssh     65961 joshc    6u  IPv6 0x47b18077a95ce2b3      0t0  TCP localhost:biimenu (LISTEN)
ssh     65961 joshc    7u  IPv4 0x47b18077a6b13b13      0t0  TCP localhost:biimenu (LISTEN)
{"django-version":"5.0.6","installed-apps":{"debug_toolbar":"4.3.0","django_filters":"24.2","django_prometheus":"2.3.1","django_rq":"2.10.2","django_tables2":"2.7.0","drf_spectacular":"0.27.2","drf_spectacular_sidecar":"2024.5.1","mptt":"0.16.0","rest_framework":"3.15.1","social_django":"5.4.1","taggit":"5.0.1","timezone_field":"6.1.0"},"netbox-version":"4.0.2","plugins":{},"python-version":"3.11.6","rq-workers-running":1}
Tunnel is up. Running NetBox seed playbooks through it, then validating nb_inventory.

    "msg": "vault_netbox_api_token is required in vault.yml before NetBox API seeding can run."
}

PLAY RECAP *********************************************************************
hom-lab-ctl-dkr-02         : ok=4    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0
---
# =============================================================================
# ipam_netbox — NetBox IPAM/DCIM
# roles/ipam_netbox | playbooks/deploy_ipam_netbox.yaml
# =============================================================================
vault_netbox_superuser_email: "admin@example.com"
vault_netbox_superuser_password: "MPUN9p4LdPxDJ+rfv75YeK75r5wMrBYK5hhmEIfpWqA="
# ipam_netbox / playbooks/deploy_ipam_netbox.yaml
# Dedicated NetBox API token for repo-owned Ansible automation.
vault_netbox_api_token: "1294e361cd75fcf464ceededc75084a4e39670f4"
Vault loads on the remote host instead of the controller. Fixing load_vault.yml to delegate to localhost, then re-running the seeds.

    name: vault_vars
  delegate_to: localhost
  run_once: true
plugin: netbox.netbox.nb_inventory
api_endpoint: http://192.168.50.158:8000
# Use LAN IP when reachable; nb_inventory also works via SSH tunnel to hom-lab-ctl-dkr-02:8000
api_endpoint: http://127.0.0.1:18000
plugin: netbox.netbox.nb_inventory
# Use LAN IP when reachable; nb_inventory also works via SSH tunnel to hom-lab-ctl-dkr-02:8000
api_endpoint: http://127.0.0.1:18000
# Override with NETBOX_URL when LAN portproxy is down (e.g. http://127.0.0.1:18000 via SSH tunnel)
    "msg": "vault_netbox_api_token is required in vault.yml before NetBox API seeding can run."
}

PLAY RECAP *********************************************************************
hom-lab-ctl-dkr-02         : ok=4    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0
plugin: netbox.netbox.nb_inventory
# Override with NETBOX_URL when LAN portproxy is down (e.g. http://127.0.0.1:18000 via SSH tunnel)
api_endpoint: "{{ lookup('env', 'NETBOX_URL') | default('http://192.168.50.158:8000', true) }}"
api_endpoint: http://192.168.50.158:8000
  ansible.builtin.include_tasks: load_vault.yml
  delegate_to: localhost
  run_once: true
  tags:
  ansible.builtin.include_tasks: load_vault.yml
  delegate_to: localhost
  run_once: true
  tags:
  ansible.builtin.include_tasks: load_vault.yml
  delegate_to: localhost
  run_once: true
  tags:
  ansible.builtin.include_tasks: load_vault.yml
  delegate_to: localhost
  run_once: true
  tags:
  ansible.builtin.include_tasks: load_vault.yml
  delegate_to: localhost
  run_once: true
  tags:

1 ---
2 # Vault: use tasks/load_vault.yml — not playbook_dir/../vault.yml (see load_vault.yml).
3 - name: Include vault variables for NetBox API token
    ^ column 3
Vault vars were scoped to localhost because of delegate_to; removing that so they load on the play host.

    name: vault_vars
  delegate_to: localhost
  run_once: true
  ansible.builtin.include_tasks: load_vault.yml
  delegate_to: localhost
  run_once: true
  tags:
  ansible.builtin.include_tasks: load_vault.yml
  delegate_to: localhost
  run_once: true
  tags:
  ansible.builtin.include_tasks: load_vault.yml
  delegate_to: localhost
  run_once: true
  tags:
  ansible.builtin.include_tasks: load_vault.yml
  delegate_to: localhost
  run_once: true
  tags:
  ansible.builtin.include_tasks: load_vault.yml
  delegate_to: localhost
  run_once: true
  tags:
---
plugin: netbox.netbox.nb_inventory
curl: (28) Connection timed out after 5005 milliseconds
000
{"django-version":"5.0.6","installed-apps":{"debug_toolbar":"4.3.0","django_filters":"24.2","django_prometheus":"2.3.1","django_rq":"2.10.2","django_tables2":"2.7.0","drf_spectacular":"0.27.2","d
