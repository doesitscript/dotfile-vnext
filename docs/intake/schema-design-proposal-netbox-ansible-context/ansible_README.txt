# cas.lab Ansible Collection

Manages all infrastructure in the CAS Lab environment using the compressed naming schema.

## Naming Schema

```
{tenant}-{env}-{site}-{role}-{seq##}
```

| Field  | Current Value | Example |
|--------|--------------|---------|
| tenant | `cas`        | cas     |
| env    | `lab`        | lab     |
| site   | `hom`        | hom     |
| role   | see table    | csw     |
| seq    | 2-digit zero-padded | 01 |

**Example hostname:** `cas-lab-hom-csw-01`

## Installation

```bash
ansible-galaxy collection install cas.lab
# or from source:
ansible-galaxy collection install git+https://git.lab.cas.local/ansible/cas-lab-collection.git
```

## Usage

```yaml
- hosts: cas-lab-hom-web-01
  collections:
    - cas.lab
  roles:
    - web
```

## Roles

See `roles/` directory for all 37 role implementations.
