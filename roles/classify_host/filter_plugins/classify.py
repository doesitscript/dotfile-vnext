"""Resolve homelab capability policy against inventory host fields."""

from __future__ import annotations

from typing import Any


def _as_list(value: Any) -> list[Any]:
    if value is None:
        return []
    if isinstance(value, list):
        return value
    return [value]


def _enabled_planes(runtime_planes: Any) -> list[str]:
    if not isinstance(runtime_planes, dict):
        return []
    out: list[str] = []
    for key, cfg in runtime_planes.items():
        if isinstance(cfg, dict) and cfg.get("enabled") is True:
            out.append(str(key))
        elif cfg is True:
            out.append(str(key))
    return out


def _match_list_rule(host_values: list[Any], rule: Any, mode: str) -> bool:
    wanted = [str(x) for x in _as_list(rule)]
    have = {str(x) for x in host_values}
    if mode == "any":
        return any(w in have for w in wanted)
    if mode == "all":
        return all(w in have for w in wanted)
    if mode == "none":
        return not any(w in have for w in wanted)
    raise ValueError(f"unknown list match mode: {mode}")


def host_matches_execution_role(host: dict[str, Any], match: dict[str, Any] | None) -> bool:
    """Return True if host inventory fields satisfy an execution_role match block."""
    if not match:
        return False

    surface = host.get("inventory_surface_role")
    node_classes = _as_list(host.get("node_classes"))
    hardware_classes = _as_list(host.get("hardware_classes"))
    policy_classes = _as_list(host.get("policy_classes"))
    enabled_planes = _enabled_planes(host.get("runtime_planes"))

    for key, rule in match.items():
        if key == "classification_status":
            if str(host.get("classification_status") or "") != str(rule):
                return False
            continue
        if key == "classification_status_empty":
            empty = not bool(host.get("classification_status"))
            if bool(rule) != empty:
                return False
            continue
        if key == "surface_type":
            if str(host.get("surface_type") or "") != str(rule):
                return False
            continue
        if key == "inventory_surface_role":
            if str(surface or "") != str(rule):
                return False
            continue
        if key == "node_classes_any":
            if not _match_list_rule(node_classes, rule, "any"):
                return False
            continue
        if key == "node_classes_all":
            if not _match_list_rule(node_classes, rule, "all"):
                return False
            continue
        if key == "node_classes_none":
            if not _match_list_rule(node_classes, rule, "none"):
                return False
            continue
        if key == "hardware_classes_any":
            if not _match_list_rule(hardware_classes, rule, "any"):
                return False
            continue
        if key == "hardware_classes_all":
            if not _match_list_rule(hardware_classes, rule, "all"):
                return False
            continue
        if key == "hardware_classes_none":
            if not _match_list_rule(hardware_classes, rule, "none"):
                return False
            continue
        if key == "policy_classes_any":
            if not _match_list_rule(policy_classes, rule, "any"):
                return False
            continue
        if key == "policy_classes_all":
            if not _match_list_rule(policy_classes, rule, "all"):
                return False
            continue
        if key == "policy_classes_none":
            if not _match_list_rule(policy_classes, rule, "none"):
                return False
            continue
        if key == "runtime_planes_enabled_any":
            if not _match_list_rule(enabled_planes, rule, "any"):
                return False
            continue
        raise ValueError(f"unknown match key: {key}")

    return True


def classify_homelab_host(
    inventory_hostname: str,
    host: dict[str, Any],
    hardware_policy: dict[str, Any],
    execution_policy: dict[str, Any],
    runtime_policy: dict[str, Any],
    k8s_policy: dict[str, Any],
) -> dict[str, Any]:
    """Build host_classification dict from policy + hostvars-like mapping."""
    hw_catalog = (hardware_policy or {}).get("hardware_classes") or {}
    role_catalog = (execution_policy or {}).get("execution_roles") or {}
    plane_catalog = (runtime_policy or {}).get("runtime_planes") or {}
    hw_to_labels = (k8s_policy or {}).get("hardware_to_labels") or {}

    hardware_classes = [str(x) for x in _as_list(host.get("hardware_classes"))]
    unknown_hardware = [h for h in hardware_classes if h not in hw_catalog]

    exclusive_violations: list[str] = []
    for cls in hardware_classes:
        meta = hw_catalog.get(cls) or {}
        for other in _as_list(meta.get("mutually_exclusive_with")):
            if other in hardware_classes:
                exclusive_violations.append(f"{cls} conflicts with {other}")

    matched_roles: list[str] = []
    role_details: dict[str, Any] = {}
    labels: dict[str, str] = {}
    taints: list[dict[str, Any]] = []
    selectors: dict[str, Any] = {}
    allow_workloads: list[str] = []
    deny_workloads: list[str] = []
    tags: list[str] = []

    for role_name, role_def in role_catalog.items():
        if not isinstance(role_def, dict):
            continue
        if host_matches_execution_role(host, role_def.get("match")):
            matched_roles.append(role_name)
            role_details[role_name] = {
                "description": role_def.get("description"),
                "tags": role_def.get("capability_tags") or role_def.get("tags") or [],
            }
            for t in _as_list(role_def.get("capability_tags") or role_def.get("tags")):
                if t not in tags:
                    tags.append(str(t))
            for w in _as_list(role_def.get("allow_workloads")):
                if w not in allow_workloads:
                    allow_workloads.append(str(w))
            for w in _as_list(role_def.get("deny_workloads")):
                if w not in deny_workloads:
                    deny_workloads.append(str(w))
            k8s = role_def.get("k8s") or {}
            for lk, lv in (k8s.get("labels") or {}).items():
                labels[str(lk)] = str(lv)
            for taint in _as_list(k8s.get("taints")):
                if isinstance(taint, dict) and taint not in taints:
                    taints.append(taint)
            for sk, sv in (k8s.get("selectors") or {}).items():
                selectors[str(sk)] = sv

    for cls in hardware_classes:
        for lk, lv in (hw_to_labels.get(cls) or {}).items():
            labels[str(lk)] = str(lv)

    enabled_planes = _enabled_planes(host.get("runtime_planes"))
    unknown_planes = [p for p in enabled_planes if p not in plane_catalog]

    primary_role = matched_roles[0] if matched_roles else None

    return {
        "inventory_hostname": inventory_hostname,
        "hardware_classes": hardware_classes,
        "unknown_hardware_classes": unknown_hardware,
        "hardware_exclusive_violations": exclusive_violations,
        "execution_roles": matched_roles,
        "host_execution_role": primary_role,
        "execution_role_details": role_details,
        "policy_tags": tags,
        "enabled_runtime_planes": enabled_planes,
        "unknown_runtime_planes": unknown_planes,
        "host_runtime_planes": enabled_planes,
        "host_k8s_labels": labels,
        "host_k8s_taints": taints,
        "host_k8s_selectors": selectors,
        "allow_workloads": allow_workloads,
        "deny_workloads": deny_workloads,
        "policy_ok": not unknown_hardware and not exclusive_violations,
    }


class FilterModule:
    def filters(self) -> dict[str, Any]:
        return {
            "classify_homelab_host": classify_homelab_host,
            "host_matches_execution_role": host_matches_execution_role,
        }
