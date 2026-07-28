# Mental model — policy vs inventory vs classify

```text
policy/execution_roles.yml     = “what ai-client-ui means + how to match”
inventory host_vars            = “facts about this host” (classes, planes, state)
classify_host                  = computes labels/roles at runtime
open_webui_state: present      = “commission this capability here”
```

## Implications

- Lots of designators live in **policy** (`policy/*.yml`).
- Inventory stays **relatively thin**: host truth + commission flags.
- Do **not** stamp `ai-client-ui` onto every host_vars file — classify derives it.
- Do **not** invent `hosts: HOM-LAB-HVH-02`; commission with `*_state` on a host
  that already matches the execution role (or adjust policy match rules).

## Related

- `policy/README.md`
- `policy/execution_roles.yml`
- `policy/process_order.yml`
- `contracts/open-webui.yaml`
