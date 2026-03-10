# common/firewall

Universal Windows base firewall rules. Applies to all managed Windows hosts
via `playbooks/windows_base.yml`.

## What it manages

| Rule | Protocol | Type | Purpose |
|---|---|---|---|
| ICMP Allow incoming V4 echo request | icmpv4 | 8:* | Enables ping (IPv4) |
| ICMP Allow incoming V6 echo request | icmpv6 | 128:* | Enables ping (IPv6) |

All three Windows firewall profiles (domain, private, public) are covered.

## What it does NOT manage

SSH port rules live in `roles/access_identity_windows/tasks/firewall.yml`
because they depend on identity-role variables (`win_ssh_port`, etc.).

## Configuration

All rules are opt-out. Override in `host_vars` or `group_vars`:

```yaml
firewall_rules_config:
  icmp_v4_echo: true   # set false to disable ping on a specific host
  icmp_v6_echo: true
```

## Tags

| Tag | Scope |
|---|---|
| `firewall` | All firewall tasks |
| `firewall_icmp` | ICMP rules only |

## Targeted run

```bash
ansible-playbook playbooks/windows_base.yml --tags firewall_icmp
```
