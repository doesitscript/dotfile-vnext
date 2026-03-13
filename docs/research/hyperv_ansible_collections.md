# Research Brief: Ansible Collections for Hyper-V Management

**Date:** 2026-03-13
**Objective:** Find the best, most mature, and idempotent Ansible solutions for managing Hyper-V on a Windows host.

## Summary of Findings

A review of available Ansible collections was performed to identify the optimal solution for managing Hyper-V. The investigation covered both pre-installed and externally available collections.

Three primary candidates were identified and evaluated:

1.  **`community.windows` / `ansible.windows`**:
    - **Assessment:** These are foundational collections for managing the base Windows operating system. They are essential for preparing the Hyper-V host but do not contain modules for managing the Hyper-V role, VMs, or virtual networks.
    - **Verdict:** Necessary prerequisite, but not the solution for Hyper-V automation.

2.  **`gocallag.hyperv` (Community Collection)**:
    - **Assessment:** A community-developed collection that is already installed in the environment. It provides basic, functional modules for VM and switch management (`vm`, `vm_info`, `switch_info`).
    - **Maturity:** The collection has been available for some time and is a known quantity. However, its last update was approximately one year ago, which raises potential concerns about long-term maintenance.
    - **Verdict:** The most mature and stable option available *today*.

3.  **`microsoft.hyperv` (Official Collection)**:
    - **Assessment:** A new, official collection from Microsoft. In theory, this is the ideal choice for long-term stability and support.
    - **Maturity:** The collection is in a very early development stage (created January 2026) and currently lacks official, comprehensive documentation on the Ansible website.
    - **Verdict:** Too immature and high-risk for immediate production use. It should be monitored for future adoption.

## Recommendation

**Primary Recommendation:**
Proceed with the **`gocallag.hyperv`** collection for the initial implementation of Hyper-V automation. It is the most mature and feature-complete option currently available.

**Secondary Recommendation (Strategic):**
Establish a formal "watch" on the **`microsoft.hyperv`** collection. A future task should be created to re-evaluate this collection in 3-6 months. Once it reaches a stable, well-documented state, a migration from `gocallag.hyperv` should be planned to leverage the benefits of an officially supported solution.

This approach balances the immediate need for a working solution with the long-term goal of using the best-supported tools.
