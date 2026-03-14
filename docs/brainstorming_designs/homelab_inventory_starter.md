2. Create a Dynamic Inventory File
Create:

Code
inventory/netbox.yml
With:

yaml
plugin: netbox.netbox.nb_inventory
api_endpoint: "http://<netbox-url>/api/"
token: "<your-api-token>"
validate_certs: false

group_by:
  - device_roles
  - platforms
  - tags
  - sites
  - tenants

compose:
  ansible_host: primary_ip4.address
This means:

Every VM in NetBox becomes an Ansible host

Groups are created automatically

IPs come from NetBox

Hostnames come from NetBox

Tags become inventory groups

This is the backbone of your automation.