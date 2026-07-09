These are the plugins in the community.clickhouse collection:

Modules
clickhouse_cfg_info module – Retrieves ClickHouse config file content and returns it as JSON

clickhouse_client module – Execute queries in a ClickHouse database using the clickhouse-driver Client interface

clickhouse_db module – Creates or removes a ClickHouse database using the clickhouse-driver Client interface

clickhouse_grants module – Manage grants for ClickHouse users and roles

clickhouse_info module – Gather ClickHouse server information using the clickhouse-driver Client interface

clickhouse_named_collection module – Creates, removes or modify a ClickHouse named collection using the clickhouse-driver Client interface

clickhouse_quota module – Creates or removes a ClickHouse quota

clickhouse_role module – Creates or removes a ClickHouse role.

clickhouse_row_policy module – Creates, removes or modify a ClickHouse row policy using the clickhouse-driver Client interface

clickhouse_script module – Run SQL queries from a file

clickhouse_user module – Creates or removes a ClickHouse user using the clickhouse-driver Client interface

-------------


These are the plugins in the netbox.netbox collection:

Modules
netbox_aggregate module – Creates or removes aggregates from NetBox

netbox_asn module – Create, update or delete ASNs within NetBox

netbox_cable module – Create, update or delete cables within NetBox

netbox_circuit module – Create, update or delete circuits within NetBox

netbox_circuit_termination module – Create, update or delete circuit terminations within NetBox

netbox_circuit_type module – Create, update or delete circuit types within NetBox

netbox_cluster module – Create, update or delete clusters within NetBox

netbox_cluster_group module – Create, update or delete cluster groups within NetBox

netbox_cluster_type module – Create, update or delete cluster types within NetBox

netbox_config_context module – Creates, updates or deletes configuration contexts within NetBox

netbox_config_template module – Creates or removes config templates from NetBox

netbox_console_port module – Create, update or delete console ports within NetBox

netbox_console_port_template module – Create, update or delete console port templates within NetBox

netbox_console_server_port module – Create, update or delete console server ports within NetBox

netbox_console_server_port_template module – Create, update or delete console server port templates within NetBox

netbox_contact module – Creates or removes contacts from NetBox

netbox_contact_assignment module – Creates or removes contact assignments from NetBox

netbox_contact_group module – Creates or removes contact groups from NetBox

netbox_contact_role module – Creates or removes contact roles from NetBox

netbox_custom_field module – Creates, updates or deletes custom fields within NetBox

netbox_custom_field_choice_set module – Creates, updates or deletes custom field choice sets within Netbox

netbox_custom_link module – Creates, updates or deletes custom links within NetBox

netbox_data_source module – Creates or removes data sources from NetBox

netbox_device module – Create, update or delete devices within NetBox

netbox_device_bay module – Create, update or delete device bays within NetBox

netbox_device_bay_template module – Create, update or delete device bay templates within NetBox

netbox_device_interface module – Creates or removes interfaces on devices from NetBox

netbox_device_interface_template module – Creates or removes interfaces on devices from NetBox

netbox_device_role module – Create, update or delete devices roles within NetBox

netbox_device_type module – Create, update or delete device types within NetBox

netbox_export_template module – Creates, updates or deletes export templates within NetBox

netbox_fhrp_group module – Create, update or delete FHRP groups within NetBox

netbox_fhrp_group_assignment module – Create, update or delete FHRP group assignments within NetBox

netbox_front_port module – Create, update or delete front ports within NetBox

netbox_front_port_template module – Create, update or delete front port templates within NetBox

netbox_inventory_item module – Creates or removes inventory items from NetBox

netbox_inventory_item_role module – Create, update or delete devices roles within NetBox

netbox_ip_address module – Creates or removes IP addresses from NetBox

netbox_ipam_role module – Creates or removes ipam roles from NetBox

netbox_journal_entry module – Creates a journal entry

netbox_l2vpn module – Create, update or delete L2VPNs within NetBox

netbox_l2vpn_termination module – Create, update or delete L2VPNs terminations within NetBox

netbox_location module – Create, update or delete locations within NetBox

netbox_mac_address module – Create, update or delete MAC addresses within NetBox

netbox_manufacturer module – Create or delete manufacturers within NetBox

netbox_module module – Create, update or delete module within NetBox

netbox_module_bay module – Create, update or delete module bay within NetBox

netbox_module_type module – Create, update or delete module types within NetBox

netbox_permission module – Creates or removes permissions from NetBox

netbox_platform module – Create or delete platforms within NetBox

netbox_power_feed module – Create, update or delete power feeds within NetBox

netbox_power_outlet module – Create, update or delete power outlets within NetBox

netbox_power_outlet_template module – Create, update or delete power outlet templates within NetBox

netbox_power_panel module – Create, update or delete power panels within NetBox

netbox_power_port module – Create, update or delete power ports within NetBox

netbox_power_port_template module – Create, update or delete power port templates within NetBox

netbox_prefix module – Creates or removes prefixes from NetBox

netbox_provider module – Create, update or delete providers within NetBox

netbox_provider_network module – Create, update or delete provider networks within NetBox

netbox_rack module – Create, update or delete racks within NetBox

netbox_rack_group module – Create, update or delete racks groups within NetBox

netbox_rack_role module – Create, update or delete racks roles within NetBox

netbox_rear_port module – Create, update or delete rear ports within NetBox

netbox_rear_port_template module – Create, update or delete rear port templates within NetBox

netbox_region module – Creates or removes regions from NetBox

netbox_rir module – Create, update or delete RIRs within NetBox

netbox_route_target module – Creates or removes route targets from NetBox

netbox_service module – Creates or removes service from NetBox

netbox_service_template module – Create, update or delete service templates within NetBox

netbox_site module – Creates or removes sites from NetBox

netbox_site_group module – Create, update, or delete site groups within NetBox

netbox_tag module – Creates or removes tags from NetBox

netbox_tenant module – Creates or removes tenants from NetBox

netbox_tenant_group module – Creates or removes tenant groups from NetBox

netbox_token module – Creates or removes tokens from NetBox

netbox_tunnel module – Create, update or delete tunnels within NetBox

netbox_tunnel_group module – Create, update or delete tunnel groups within NetBox

netbox_user module – Creates or removes users from NetBox

netbox_user_group module – Creates or removes user groups from NetBox

netbox_virtual_chassis module – Create, update or delete virtual chassis within NetBox

netbox_virtual_disk module – Creates or removes disks from virtual machines in NetBox

netbox_virtual_machine module – Create, update or delete virtual_machines within NetBox

netbox_vlan module – Create, update or delete vlans within NetBox

netbox_vlan_group module – Create, update or delete vlans groups within NetBox

netbox_vm_interface module – Creates or removes interfaces from virtual machines in NetBox

netbox_vrf module – Create, update or delete vrfs within NetBox

netbox_webhook module – Creates, updates or deletes webhook configuration within NetBox

netbox_wireless_lan module – Creates or removes Wireless LANs from NetBox

netbox_wireless_lan_group module – Creates or removes Wireless LAN Groups from NetBox

netbox_wireless_link module – Creates or removes Wireless links from NetBox

Inventory Plugins
nb_inventory inventory – NetBox inventory source

Lookup Plugins
nb_lookup lookup – Queries and returns elements from NetBox

See also



---------------



- name: "Test NetBox modules"
  connection: local
  hosts: localhost
  gather_facts: false
  tasks:
    - name: Create virtual machine within NetBox with only required information
      netbox_virtual_machine:
        netbox_url: http://netbox.local
        netbox_token: thisIsMyToken
        data:
          name: Test Virtual Machine
          cluster: test cluster
        state: present

    - name: Delete virtual machine within netbox
      netbox_virtual_machine:
        netbox_url: http://netbox.local
        netbox_token: thisIsMyToken
        data:
          name: Test Virtual Machine
        state: absent

    - name: Create virtual machine with tags
      netbox_virtual_machine:
        netbox_url: http://netbox.local
        netbox_token: thisIsMyToken
        data:
          name: Another Test Virtual Machine
          cluster: test cluster
          site: Test Site
          tags:
            - Schnozzberry
        state: present

    - name: Update vcpus, memory and disk of an existing virtual machine
      netbox_virtual_machine:
        netbox_url: http://netbox.local
        netbox_token: thisIsMyToken
        data:
          name: Test Virtual Machine
          cluster: test cluster
          vcpus: 8
          memory: 8
          disk: 8
        state: present

    - name: Update virtual machine within NetBox with serial number
      netbox_virtual_machine:
        netbox_url: http://netbox.local
        netbox_token: thisIsMyToken
        data:
          name: Test Virtual Machine
          cluster: test cluster
          serial: 1234abc
        state: present
