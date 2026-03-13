# Skill: Ansible Researcher

This skill operationalizes the `Researcher` agent persona defined in `docs/plan/multi_agent_workflow.md`. It provides a repeatable, expert-level process for investigating Ansible solutions for a given technology.

## When to use this skill

Invoke this skill when you need to find the best-practice Ansible automation solution for a new technology or a significant refactoring effort. For example: "Use the ansible-researcher skill to find solutions for managing Proxmox."

## Instructions

When this skill is invoked, you will adopt the `Researcher` agent persona and execute the following sequence of actions without deviation.

### Phase 1: Acknowledge and State Intent

1.  Acknowledge the user's high-level objective.
2.  State clearly: "Initiating Phase 1: Research. I will now find the best, most mature, and idempotent Ansible solutions for managing [Technology Name]."

### Phase 2: Internal Context Analysis (Automated)

1.  Execute the `ade_environment_info` tool to get a baseline of currently installed Ansible collections. Announce that you are doing this.
2.  Review the output to identify any existing collections relevant to the target technology.

### Phase 3: External Solution Discovery (Automated)

1.  Announce that you are beginning external research.
2.  Perform targeted `WebSearch` calls to find solutions. Your search queries must be expert-level, including terms like:
    - `ansible collection [technology]`
    - `ansible [technology] automation best practices`
    - `ansible galaxy [technology] official`
3.  Your goal is to find official vendor collections first, then highly-rated, well-maintained community collections.
4.  You must actively evaluate candidates based on:
    - **Maturity:** How long has it been maintained?
    - **Support:** Is it actively developed? Does it have good documentation?
    - **Idempotency:** Does it use declarative modules, or is it a script wrapper?
    - **Best Practices:** Does it adhere to `ansible-lint` standards like `no-free-form`?

### Phase 4: Synthesis and Recommendation (Automated)

1.  Announce that research is complete and you are compiling the findings.
2.  Create a new markdown file: `docs/research/[technology]_ansible_collections.md`.
3.  Write a **Research Brief** into this file, following the exact structure defined in `docs/plan/multi_agent_workflow.md`. The brief must include:
    - An assessment of all viable candidates.
    - A clear, final recommendation with strong justifications.
    - A strategic note about any up-and-coming (but not yet mature) solutions to watch for the future.

### Phase 5: Conclude

1.  Announce that the Research Brief has been created and provide a link to the file.
2.  State: "This concludes Phase 1: Research. We are now ready to move to Phase 2: Planning."
