# Example — storage Ansible implementation-readiness brief

**Status:** template/example; not approval to apply storage changes.

## Decision to enable

Convert the selected k3s-02 storage outcome into repo-owned, idempotent
automation. This brief must distinguish Hyper-V disk attachment, guest disk
preparation, K3s/local-path migration, and monitoring because they have
different owners and rollback risks.

## Questions for the Ansible knowledge capability

| Question | Required evidence |
| --- | --- |
| Which existing role owns VM hardware attachment? | Repo role/playbook and inventory evidence. |
| Which guest-storage steps can be converged safely? | Candidate Ansible module matrix plus host facts. |
| What data migration sequence protects existing local-path PVC data? | K3s/local-path sources plus backup/restore proof. |
| What is the state/undo boundary? | Explicit irreversible steps, backup, and recovery procedure. |

## Required preflight before implementation

- Current VM disk topology and free space on the Hyper-V host.
- Guest block-device identity, filesystem, mount state, and fstab status.
- K3s/local-path storage configuration and affected PVC/workload inventory.
- Target selection proof for both Hyper-V host and k3s-02 guest.
- Backup or restoration strategy for affected data.

## Acceptance criteria for the Implementer

- Each layer has a named owner role/playbook and an explicit state boundary.
- No raw disk device is selected solely by an unstable name such as `/dev/sdX`.
- A preview precedes each mutating layer.
- The migration plan states service interruption, data protection, verification,
  and rollback boundaries.
- Resulting storage and DiskPressure checks are captured in the receipt.

## Evaluator checks

- The implementation maps to this brief or records an evidence-backed
  deviation.
- The receipt proves the defined acceptance checks rather than only a playbook
  recap.
- Any remaining unverified migration assumption stays open; it is not hidden
  by generic Ansible best-practice citations.
