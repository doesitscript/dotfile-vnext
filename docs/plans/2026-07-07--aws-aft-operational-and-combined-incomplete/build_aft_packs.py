from pathlib import Path
import json
import re
import textwrap


REPO = Path("/Users/joshc/develop/dotfile-vnext")
SOURCE_DIR = REPO / "docs/brainstorming_designs/2026-06-07--external-use-aft-operational-doc"
SOURCE_FILE = SOURCE_DIR / "original_page_content_combined.md"
AWS_PACK = Path("/Users/joshc/develop/ai-resource-library/vendors/aws/control_tower")
OPERATIONAL_DIR = Path("/Users/joshc/develop/ai-resource-library/vendors/aws/control_tower_operational")
COMBINED_DIR = Path("/Users/joshc/develop/ai-resource-library/vendors/aws/control_tower_combined")
PLAN_DIR = REPO / "docs/plans/2026-07-07--aws-aft-operational-and-combined-incomplete"

SOURCE_REL = "docs/brainstorming_designs/2026-06-07--external-use-aft-operational-doc/original_page_content_combined.md"
CONTEXT7_LIBRARY_ID = "/websites/aws_amazon_controltower_userguide"
CONTEXT7_TOPICS = [
    "Overview of AWS Control Tower Account Factory for Terraform (AFT)",
    "Configure AFT with Existing VPC",
    "Provision and update accounts using automation",
    "Account Factory for Terraform (AFT) troubleshooting guide",
    "Resource considerations for AWS Control Tower Account Factory for Terraform",
]
CONTEXT7_QUERIED_AT = "2026-07-08T00:11:05Z"
CONTEXT7_PURPOSE = (
    "Validate that the sibling AWS source pack should stay anchored to the AWS Control Tower "
    "user guide surface and confirm topic names for overview, architecture, provisioning, "
    "troubleshooting, VPC, and cost-oriented sections."
)


def source_lines():
    return SOURCE_FILE.read_text(encoding="utf-8").splitlines()


def comment_blocks(lines):
    markers = [idx for idx, line in enumerate(lines, start=1) if line.strip() == "- Josh Castillo:"]
    markers.append(len(lines) + 1)
    blocks = []
    for start, next_start in zip(markers[:-1], markers[1:]):
        title_line = None
        for lineno in range(start + 1, next_start):
            if lines[lineno - 1].strip():
                title_line = lineno
                break
        if title_line is None:
            continue
        end_line = next_start - 1
        while end_line >= title_line and not lines[end_line - 1].strip():
            end_line -= 1
        title = lines[title_line - 1].strip()
        if title.startswith("![image.png]"):
            continue
        blocks.append(
            {
                "title": title,
                "title_line": title_line,
                "end_line": end_line,
            }
        )
    return {block["title"]: block for block in blocks}


def page_specs(block_map):
    specs = [
        {
            "source_title": "Account Factory for Terraform (AFT)",
            "resolved_title": "AFT Overview, Architecture, and Components",
            "slug": "aft-overview-architecture-and-components",
            "output_path": "aft-overview-architecture-and-components.md",
            "source_start_line": 1,
            "source_end_line": 171,
            "screenshot_label": None,
            "hierarchy_group": None,
            "kind": "page",
            "notes": [
                "Derived from the top export block before the OneNote comment stream.",
                "Includes Overview, Architecture, Key Components, Additional Components, and References sections.",
                "Source-linked diagrams were preserved as remote links only.",
            ],
            "normalization_notes": [
                "Removed blank formatting artifacts and normalized non-breaking spaces.",
                "Preserved tables, diagram links, URLs, and operational naming.",
            ],
        },
        {
            "source_title": "Draft: Change enablement",
            "resolved_title": "Draft: Change enablement",
            "slug": "draft-change-enablement",
            "output_path": "draft-change-enablement.md",
            "screenshot_label": "DRAFT: Change Enablement",
            "hierarchy_group": "Runbook / FAQ",
            "notes": [
                "Screenshot label uses all-caps DRAFT; source export uses sentence-case Draft.",
                "Contains one source-linked deployment-flow diagram reference.",
            ],
            "normalization_notes": [
                "Removed a lone formatting heading marker line.",
                "Preserved sequencing, CR guidance, and repo references.",
            ],
        },
        {
            "source_title": "AWS Account Decommissioning Procedure",
            "resolved_title": "AWS Account Decommissioning Procedure",
            "slug": "aws-account-decommissioning-procedure",
            "output_path": "aws-account-decommissioning-procedure.md",
            "screenshot_label": "AWS Account Decommissioning Pro...",
            "hierarchy_group": "Runbook / FAQ",
            "notes": ["Screenshot label is truncated; resolved against the source export title."],
            "normalization_notes": [
                "Preserved account id, PR links, and shell commands.",
                "Left one-line verification commands inline because the source export does not mark them as fenced code.",
            ],
        },
        {
            "source_title": "Vend an AWS Account",
            "resolved_title": "Vend an AWS Account",
            "slug": "vend-an-aws-account",
            "output_path": "vend-an-aws-account.md",
            "screenshot_label": "Vend an AWS Account",
            "hierarchy_group": "Runbook / FAQ",
            "notes": ["Maps 1:1 between screenshot and embedded source title."],
            "normalization_notes": ["Preserved required platform tags and follow-on AD group steps."],
        },
        {
            "source_title": "Add an OU (Organization Unit)",
            "resolved_title": "Add an OU (Organization Unit)",
            "slug": "add-an-ou-organization-unit",
            "output_path": "add-an-ou-organization-unit.md",
            "screenshot_label": "Add an OU (Organization Unit)",
            "hierarchy_group": "Runbook / FAQ",
            "notes": ["Maps 1:1 between screenshot and embedded source title."],
            "normalization_notes": ["Preserved warning, AWS console steps, and WIZ collection note."],
        },
        {
            "source_title": "DRAFT: Cleanup and Retrigger a Failed Account Request",
            "resolved_title": "DRAFT: Cleanup and Retrigger a Failed Account Request",
            "slug": "draft-cleanup-and-retrigger-a-failed-account-request",
            "output_path": "draft-cleanup-and-retrigger-a-failed-account-request.md",
            "screenshot_label": "DRAFT: Cleanup and Retrigger a Fai...",
            "hierarchy_group": "Runbook / FAQ",
            "notes": ["Screenshot label is truncated; resolved against the source export title."],
            "normalization_notes": ["Preserved CLI commands and request-table remediation sequence."],
        },
        {
            "source_title": "DRAFT: Apply AFT Account: Global Terraform at Scale",
            "resolved_title": "DRAFT: Apply AFT Account: Global Terraform at Scale",
            "slug": "draft-apply-aft-account-global-terraform-at-scale",
            "output_path": "draft-apply-aft-account-global-terraform-at-scale.md",
            "screenshot_label": "DRAFT: Apply AFT Account: Global...",
            "hierarchy_group": "Runbook / FAQ",
            "notes": [
                "Screenshot label is truncated; resolved against the source export title.",
                "The include/exclude example contains malformed JSON-like content in the OneNote export and is preserved with an explicit note.",
            ],
            "normalization_notes": [
                "Preserved all CLI examples and target-account/OU examples.",
                "Annotated malformed include/exclude example rather than silently repairing it.",
            ],
        },
        {
            "source_title": "DRAFT: AFT Lambda upgrade release analysis",
            "resolved_title": "DRAFT: AFT Lambda upgrade release analysis",
            "slug": "draft-aft-lambda-upgrade-release-analysis",
            "output_path": "draft-aft-lambda-upgrade-release-analysis.md",
            "screenshot_label": "DRAFT: AFT Lambda upgrade relea...",
            "hierarchy_group": "Runbook / FAQ",
            "notes": ["Screenshot label is truncated; resolved against the source export title."],
            "normalization_notes": [
                "Preserved version-by-version observations, plan excerpts, and release-note links.",
                "Removed blank artifact headings with no content.",
            ],
        },
        {
            "source_title": "DRAFT: AFT Lambda Vulnerability Remediation",
            "resolved_title": "DRAFT: AFT Lambda Vulnerability Remediation",
            "slug": "draft-aft-lambda-vulnerability-remediation",
            "output_path": "draft-aft-lambda-vulnerability-remediation.md",
            "screenshot_label": "DRAFT: AFT Lambda Vulnerability R...",
            "hierarchy_group": "Runbook / FAQ",
            "notes": [
                "Screenshot label is truncated; resolved against the source export title.",
                "The exported body is wrapped inside malformed table cells and Stephen feedback side-notes.",
            ],
            "normalization_notes": [
                "Converted the primary table cell into line-oriented markdown for readability without repairing business content.",
                "Preserved feedback notes as a separate source-quality appendix.",
            ],
        },
        {
            "source_title": "DRAFT: Remediation of Default VPCs in non-governed regions (VPC Flow Logs)",
            "resolved_title": "DRAFT: Remediation of Default VPCs in non-governed regions (VPC Flow Logs)",
            "slug": "draft-remediation-of-default-vpcs-in-non-governed-regions-vpc-flow-logs",
            "output_path": "draft-remediation-of-default-vpcs-in-non-governed-regions-vpc-flow-logs.md",
            "screenshot_label": "DRAFT: Remediation of Default VPC...",
            "hierarchy_group": "Runbook / FAQ",
            "notes": ["Screenshot label is truncated; resolved against the source export title."],
            "normalization_notes": [
                "Preserved policy context, remediation approach, and source-linked images as remote URLs only.",
                "No local screenshots or downloaded image assets were added.",
            ],
        },
    ]
    for spec in specs[1:]:
        block = block_map[spec["source_title"]]
        spec["source_start_line"] = block["title_line"]
        spec["source_end_line"] = block["end_line"]
        spec["kind"] = "page"
    return specs


def dedent_block(lines):
    nonblank = [line for line in lines if line.strip()]
    if not nonblank:
        return lines
    prefixes = []
    for line in nonblank:
        match = re.match(r"^(\s+)", line)
        prefixes.append(len(match.group(1)) if match else 0)
    margin = min(prefixes)
    return [line[margin:] if margin and len(line) >= margin else line for line in lines]


def cleanup_lines(lines):
    cleaned = []
    blank_run = 0
    for raw in lines:
        line = raw.replace("\xa0", " ").rstrip()
        if line.strip() in {"#", "##"}:
            continue
        if not line.strip():
            blank_run += 1
            if blank_run <= 1:
                cleaned.append("")
            continue
        blank_run = 0
        cleaned.append(line)
    while cleaned and cleaned[-1] == "":
        cleaned.pop()
    return cleaned


def normalize_standard_page(lines, spec):
    page_lines = lines[spec["source_start_line"] - 1 : spec["source_end_line"]]
    page_lines = cleanup_lines(dedent_block(page_lines))
    if spec["source_title"] == "DRAFT: Apply AFT Account: Global Terraform at Scale":
        note = (
            "> Source quality note: the include/exclude example below is malformed in the "
            "OneNote export. The content is preserved as-is rather than silently repaired."
        )
        insert_at = 2 if len(page_lines) >= 2 else len(page_lines)
        page_lines = page_lines[:insert_at] + ["", note, ""] + page_lines[insert_at:]
    return "\n".join(page_lines) + "\n"


def normalize_vulnerability_page(lines, spec):
    page_lines = lines[spec["source_start_line"] - 1 : spec["source_end_line"]]
    title = cleanup_lines(dedent_block(page_lines[:2]))[0]
    main_row = next((line for line in page_lines if "# Overview" in line), "")
    feedback_row = next((line for line in page_lines if "Stephen's Feedback" in line), "")

    main_match = re.match(r"^\s*\|\s*[^|]*\|\s*(.*)\|\s*\|\s*\|\s*$", main_row)
    feedback_match = re.match(r"^\s*\|\s*[^|]*\|\s*[^|]*\|\s*(.*)\|\s*$", feedback_row)

    main_cell = main_match.group(1) if main_match else ""
    feedback_cell = feedback_match.group(1) if feedback_match else ""

    section_headings = {
        "1. Pre-flight Activities": "## Pre-flight activities",
        "1. Validate AFT Terraform State": "## Validate AFT Terraform state",
        "1. Prepare Terraform Configuration": "## Prepare Terraform configuration",
        "1. Update Module Source": "## Update module source",
        "1. Run Terraform Plan": "## Run Terraform plan",
        "1. For Version Upgrade": "## Version upgrade review",
        "1. Apply changes and Validate the remediations": "## Apply changes and validate the remediations",
        "1. Post-Implementation Validation": "## Post-implementation validation",
        "1. AFT Release Notes": "## AFT release notes",
        "1. References": "## References",
        "1. Terraform Plan for Upgrading the AFT version from 1.13.4 to 1.18.1": "## Terraform plan for upgrading AFT from 1.13.4 to 1.18.1",
    }
    faq_headings = {
        "1. Can I roll back if something goes wrong?",
        "1. What happens if I lose connection during `terraform apply`?",
        "1. How do I know which version of AFT is currently deployed?",
        "1. How long does AFT take to process account updates?",
    }

    def normalize_cell(cell, feedback=False):
        cell = cell.replace("\xa0", " ")
        cell = cell.replace("<br>", "\n")
        cell = cell.replace("\\`", "`")
        cell = cell.replace("\\-", "-")
        cell = cell.replace("\\.", ".")
        cell = re.sub(r"\[?AFT GitHub Repository\\?\]\(", "[AFT GitHub Repository](", cell)

        raw_lines = []
        for line in cell.split("\n"):
            line = re.sub(r"^\s*>\s?", "", line).strip()
            if line in {"", ">", "#"}:
                raw_lines.append("")
                continue
            if line == "*":
                continue
            if line == "` `":
                continue
            raw_lines.append(line)

        cleaned = []
        previous_blank = True

        def push_heading(text):
            nonlocal previous_blank
            if cleaned and cleaned[-1] != "":
                cleaned.append("")
            cleaned.append(text)
            previous_blank = False

        for line in raw_lines:
            if not line:
                if not previous_blank:
                    cleaned.append("")
                previous_blank = True
                continue

            code_match = re.match(r"^\|\s*`(.*)`\s*\|$", line)
            if code_match:
                inner = code_match.group(1)
                parts = [part.strip() for part in inner.split("``") if part.strip()]
                content = "\n".join(parts)
                if 'provider "aws"' in content or 'module "aft_pipeline"' in content:
                    lang = "hcl"
                elif content.startswith("#module."):
                    lang = "text"
                else:
                    lang = "bash"
                if cleaned and cleaned[-1] != "":
                    cleaned.append("")
                cleaned.extend([f"```{lang}", content, "```", ""])
                previous_blank = True
                continue

            if line == "# Overview":
                push_heading("## Overview")
                continue
            if line == "# FAQs":
                push_heading("## FAQs")
                continue
            if line in section_headings:
                push_heading(section_headings[line])
                continue
            if line in faq_headings:
                push_heading("### " + re.sub(r"^1\.\s*", "", line))
                continue
            if line == "When to Rollback":
                push_heading("### When to rollback")
                continue
            if line.startswith("Pre-flight activities:* "):
                push_heading("### Pre-flight activities")
                cleaned.append("* " + line.split(":* ", 1)[1])
                previous_blank = False
                continue
            if line.startswith("Upgrade steps:* "):
                push_heading("### Upgrade steps")
                cleaned.append("* " + line.split(":* ", 1)[1])
                previous_blank = False
                continue
            if line.startswith("• "):
                cleaned.append("- " + line[2:])
                previous_blank = False
                continue

            cleaned.append(line)
            previous_blank = False

        return "\n".join(cleaned).strip()

    body = normalize_cell(main_cell)
    feedback = normalize_cell(feedback_cell, feedback=True)
    rendered = [
        title,
        "",
        "> Source quality note: this page body was exported from OneNote as a malformed markdown table. This normalization recovers the main body structure and code samples on a best-effort basis, but the source should still be treated as operator-reviewed guidance rather than pristine markdown.",
        "",
        body,
        "",
        "## Source quality appendix",
        "",
        feedback or "Stephen feedback was present in the export but could not be cleanly separated beyond the preserved line-oriented text above.",
        "",
    ]
    return "\n".join(rendered)


def format_page(spec, body):
    lines = [
        f"# {spec['resolved_title']}",
        "",
        "## Provenance",
        f"- Source file: `{SOURCE_REL}`",
        f"- Source title: `{spec['source_title']}`",
        f"- Source line range: `{spec['source_start_line']}-{spec['source_end_line']}`",
        f"- Screenshot label: `{spec['screenshot_label']}`" if spec["screenshot_label"] else "- Screenshot label: none; derived from the top export block",
        "- Hierarchy: `Account Factory for Terraform (AFT)`" + (f" -> `{spec['hierarchy_group']}`" if spec["hierarchy_group"] else ""),
        "- Normalization notes:",
    ]
    lines.extend(f"  - {note}" for note in spec["normalization_notes"])
    lines.extend(["", "## Normalized content", "", body.rstrip(), ""])
    return "\n".join(lines)


def write_operational_pack():
    lines = source_lines()
    specs = page_specs(comment_blocks(lines))
    index_entries = [
        {
            "title": "Account Factory for Terraform (AFT)",
            "slug": "account-factory-for-terraform-aft",
            "output_path": None,
            "source_path": "docs/brainstorming_designs/2026-06-07--external-use-aft-operational-doc/original_page_titles.png",
            "source_start_line": None,
            "source_end_line": None,
            "screenshot_label": "Account Factory for Terraform (AFT)",
            "resolved_title": "Account Factory for Terraform (AFT)",
            "hierarchy_group": None,
            "kind": "group",
            "notes": ["Root notebook label from the screenshot; not emitted as its own markdown page."],
        },
        {
            "title": "Runbook / FAQ",
            "slug": "runbook-faq",
            "output_path": None,
            "source_path": "docs/brainstorming_designs/2026-06-07--external-use-aft-operational-doc/original_page_titles.png",
            "source_start_line": None,
            "source_end_line": None,
            "screenshot_label": "Runbook / FAQ",
            "resolved_title": "Runbook / FAQ",
            "hierarchy_group": "Account Factory for Terraform (AFT)",
            "kind": "group",
            "notes": ["Container label only; used as hierarchy metadata and not emitted as a page."],
        },
    ]

    for spec in specs:
        if spec["source_title"] == "DRAFT: AFT Lambda Vulnerability Remediation":
            body = normalize_vulnerability_page(lines, spec)
        else:
            body = normalize_standard_page(lines, spec)
        (OPERATIONAL_DIR / spec["output_path"]).write_text(format_page(spec, body), encoding="utf-8")
        index_entries.append(
            {
                "title": spec["source_title"],
                "slug": spec["slug"],
                "output_path": spec["output_path"],
                "source_path": SOURCE_REL,
                "source_start_line": spec["source_start_line"],
                "source_end_line": spec["source_end_line"],
                "screenshot_label": spec["screenshot_label"],
                "resolved_title": spec["resolved_title"],
                "hierarchy_group": spec["hierarchy_group"],
                "kind": spec["kind"],
                "notes": spec["notes"],
            }
        )

    readme = textwrap.dedent(
        f"""\
        AWS Control Tower - AFT Operational Pack

        Sources:
        - OneNote export markdown: `{SOURCE_REL}`
        - Screenshot title list: `docs/brainstorming_designs/2026-06-07--external-use-aft-operational-doc/original_page_titles.png`
        - Section list reference: `docs/brainstorming_designs/2026-06-07--external-use-aft-operational-doc/sections.png`
        - Governing repo/workflow: `dotfile-vnext`

        This pack normalizes Bread operational AFT material from the exported OneNote notebook into page-oriented markdown files for AI retrieval and downstream synthesis.

        Context7 record:
        - Library id: `{CONTEXT7_LIBRARY_ID}`
        - Queried at: `{CONTEXT7_QUERIED_AT}`
        - Purpose: {CONTEXT7_PURPOSE}
        - Topics used:
        """
    )
    readme += "".join(f"- {topic}\n" for topic in CONTEXT7_TOPICS)
    readme += textwrap.dedent(
        """\

        Files included:
        - `aft-overview-architecture-and-components.md` - top export block through References
        - `draft-change-enablement.md`
        - `aws-account-decommissioning-procedure.md`
        - `vend-an-aws-account.md`
        - `add-an-ou-organization-unit.md`
        - `draft-cleanup-and-retrigger-a-failed-account-request.md`
        - `draft-apply-aft-account-global-terraform-at-scale.md`
        - `draft-aft-lambda-upgrade-release-analysis.md`
        - `draft-aft-lambda-vulnerability-remediation.md`
        - `draft-remediation-of-default-vpcs-in-non-governed-regions-vpc-flow-logs.md`
        - `page-index.json`
        - `metadata.json`
        """
    )
    metadata = {
        "collection": "AWS Control Tower AFT operational pack",
        "captured_date": "2026-07-07",
        "source_type": "onenote-export-normalization",
        "governing_repo": "dotfile-vnext",
        "output_root": str(OPERATIONAL_DIR),
        "dependencies": {
            "aws_vendor_pack": str(AWS_PACK),
            "plan_packet": str(PLAN_DIR / "README.md"),
        },
        "context7": {
            "library_id": CONTEXT7_LIBRARY_ID,
            "queried_at": CONTEXT7_QUERIED_AT,
            "purpose": CONTEXT7_PURPOSE,
            "topics": CONTEXT7_TOPICS,
        },
        "files": [
            {"path": entry["output_path"], "source_title": entry["resolved_title"]}
            for entry in index_entries
            if entry["kind"] == "page"
        ],
        "index_files": ["page-index.json"],
    }
    (OPERATIONAL_DIR / "README.md").write_text(readme, encoding="utf-8")
    (OPERATIONAL_DIR / "metadata.json").write_text(json.dumps(metadata, indent=2) + "\n", encoding="utf-8")
    (OPERATIONAL_DIR / "page-index.json").write_text(json.dumps(index_entries, indent=2) + "\n", encoding="utf-8")


def write_combined_pack():
    sections = [
        {
            "section_name": "Overview",
            "slug": "overview",
            "output_path": "overview.md",
            "operational_sources": ["aft-overview-architecture-and-components.md"],
            "aws_sources": ["aft-getting-started.md", "aft-components.full.md", "taf-account-provisioning.full.md"],
            "context7_topics": ["Overview of AWS Control Tower Account Factory for Terraform (AFT)"],
            "coverage_notes": ["Operational and AWS source coverage are both strong for this section."],
            "summary": "Bread uses AWS Control Tower plus Account Factory for Terraform to create and manage multi-account AWS environments with a GitOps-style request flow and follow-on account customization stages.",
            "bread": [
                "Bread splits AFT responsibilities across four repositories: account requests, global customizations, account customizations, and account provisioning customizations.",
                "The operational export names the team contact path, resolver group, and the internal expectation that solution-oriented IaC usually lives outside `aft-account-customizations` when possible.",
                "The top export also records the internal diagrams and key runtime components used to vend and customize accounts in Bread-managed AWS organizations.",
            ],
            "aws": [
                "AWS positions AFT as an extension of AWS Control Tower that automates account creation and update workflows from account request Terraform files.",
                "The AWS docs emphasize prerequisites such as a Control Tower landing zone, a dedicated AFT management account, and the repository structure needed after deployment.",
                "AWS component guidance reinforces the core services Bread references operationally: DynamoDB, CodePipeline, Lambda, Step Functions, EventBridge, SQS, SNS, and KMS.",
            ],
            "gaps": [
                "The operational source names internal owners and service identifiers, but it does not show the current live repo inventory for each AFT repository.",
                "The sibling AWS pack currently contains an excerpt for `aft-getting-started.md` rather than a full-page capture.",
            ],
        },
        {
            "section_name": "Update Process",
            "slug": "update-process",
            "output_path": "update-process.md",
            "operational_sources": [
                "draft-change-enablement.md",
                "draft-aft-lambda-upgrade-release-analysis.md",
                "draft-aft-lambda-vulnerability-remediation.md",
            ],
            "aws_sources": ["check-aft-version.full.md", "update-aft-version.full.md", "version-supported.full.md"],
            "context7_topics": [
                "Provision and update accounts using automation",
                "Resource considerations for AWS Control Tower Account Factory for Terraform",
            ],
            "coverage_notes": ["Operational sources dominate process detail; AWS sources mainly validate version, upgrade, and Terraform support constraints."],
            "summary": "Bread treats repo updates and AFT platform upgrades differently: account-request changes are BAU, while account/global customization changes require staged rollout discipline and AFT platform upgrades require explicit plan and validation review.",
            "bread": [
                "Bread deploys sandbox or dev account customizations immediately after merge, then promotes the same change through scheduled nonprod and prod CRs with evidence attached to each change record.",
                "The operational upgrade analysis flags AFT versions 1.13.5, 1.15.0, 1.16.0, and 1.18.1 as especially meaningful because of timeout, cost, runtime, and remediation impact.",
                "The vulnerability-remediation page adds a pre-flight checklist: confirm state storage, run a no-surprise plan, avoid destructive changes, and validate sandbox pipeline plus Step Functions behavior after apply.",
            ],
            "aws": [
                "AWS documents a lightweight version check via `/aft/config/aft/version` in SSM Parameter Store and a standard `terraform get -update` plus plan/apply flow for updating AFT.",
                "AWS also defines supported Terraform distributions and warns that Terraform version and token handling must align with the selected backend model.",
                "The vendor docs do not prescribe Bread change-enablement sequencing, so the operational CR and staged deployment controls remain local process.",
            ],
            "gaps": [
                "The operational vulnerability-remediation export is malformed, so the normalized page is intentionally conservative and may still require human cleanup before reuse as a formal runbook.",
                "The AWS pack does not contain release-note deltas; Bread-specific version-risk analysis comes from the operational export only.",
            ],
        },
        {
            "section_name": "Architecture",
            "slug": "architecture",
            "output_path": "architecture.md",
            "operational_sources": ["aft-overview-architecture-and-components.md"],
            "aws_sources": ["aft-architecture.full.md", "aft-components.full.md", "aft-provisioning-framework.md"],
            "context7_topics": [
                "Overview of AWS Control Tower Account Factory for Terraform (AFT)",
                "Resource considerations for AWS Control Tower Account Factory for Terraform",
            ],
            "coverage_notes": ["Operational and AWS architecture coverage are both strong; operational content adds internal diagrams and AWS content adds service-model framing."],
            "summary": "Bread's architecture view layers internal account-vending diagrams and named event-driven components on top of the AWS AFT service model of queues, pipelines, Lambdas, Step Functions, and customization repositories.",
            "bread": [
                "The operational export records source-linked diagrams for new-account vending and account customizations, and it inventories EventBridge, SQS, Step Functions, Lambda, SNS, and additional support components by name.",
                "Bread explicitly calls out `aft-account-provisioning-framework` as the main provisioning orchestrator and `aft-features` as the feature-flag state machine.",
                "The operational inventory also separates additional components such as audit triggers and event loggers from the main execution path, which is useful when deciding what belongs in troubleshooting versus core architecture.",
            ],
            "aws": [
                "AWS describes the order of operations from account request through Control Tower provisioning, feature execution, and account/global customization stages in the AFT management account.",
                "The AWS component page confirms the breadth of service dependencies and clarifies why KMS, DynamoDB, S3, CodeBuild, CodePipeline, and CloudWatch all appear in the operational inventory.",
                "The provisioning-framework material complements Bread's internal names with the vendor view of how account customization and account provisioning customizations are wired into the end-to-end lifecycle.",
            ],
            "gaps": [
                "The current slice preserves diagram links only; it does not rebuild local copies of the diagrams or validate whether the remote diagrams still exist.",
            ],
        },
        {
            "section_name": "Runbook / Playbook",
            "slug": "runbook-playbook",
            "output_path": "runbook-playbook.md",
            "operational_sources": [
                "aws-account-decommissioning-procedure.md",
                "vend-an-aws-account.md",
                "add-an-ou-organization-unit.md",
                "draft-cleanup-and-retrigger-a-failed-account-request.md",
                "draft-apply-aft-account-global-terraform-at-scale.md",
            ],
            "aws_sources": ["aft-provision-account.full.md", "aft-update-account.full.md", "aft-remove-account.full.md", "account-troubleshooting-guide.md"],
            "context7_topics": [
                "Provision and update accounts using automation",
                "Account Factory for Terraform (AFT) troubleshooting guide",
            ],
            "coverage_notes": ["Operational sources provide the concrete runbook steps; AWS sources provide guardrails and generic lifecycle procedures."],
            "summary": "The runbook slice covers the Bread-specific tasks around vending, updating, cleaning up failed requests, adding OUs, and decommissioning accounts, with AWS docs used to confirm what AFT supports natively.",
            "bread": [
                "Bread vends accounts by adding request files, applying required tags, then following through with Identity Center group provisioning in the separate aws-access workflow.",
                "OU creation requires both Terraform changes and explicit Control Tower registration; failing to register the OU causes account-vending failures that must be cleaned up and retriggered.",
                "Bread's bulk customization guidance relies on `aft-invoke-customizations` and includes explicit examples for all accounts, selected accounts, selected OUs, and mixed include/exclude targeting.",
            ],
            "aws": [
                "AWS documents the request-file fields for new accounts, the limited mutability of `ManagedOrganizationalUnit`, and the irreversible nature of removing an account from AFT.",
                "The troubleshooting guidance reinforces where to look during failures: CloudWatch logs, SNS failure notifications, request metadata tables, and pipeline/workspace setup.",
                "Vendor guidance is broad on removal and update semantics, but Bread's decommission and cleanup sequencing adds the organization-specific GitHub, HCP Terraform, and ServiceNow steps.",
            ],
            "gaps": [
                "The operational cleanup page uses raw CLI commands and assumes management-account context without recording IAM guardrails or wrapper tooling.",
                "The bulk-customization example includes malformed JSON-like content in the exclude example and should be operator-reviewed before direct reuse.",
            ],
        },
        {
            "section_name": "Security",
            "slug": "security",
            "output_path": "security.md",
            "operational_sources": [
                "draft-aft-lambda-vulnerability-remediation.md",
                "draft-remediation-of-default-vpcs-in-non-governed-regions-vpc-flow-logs.md",
            ],
            "aws_sources": ["aft-data-protection.md", "aft-required-roles.md", "aft-feature-options.md"],
            "context7_topics": [
                "Configure AFT with Existing VPC",
                "Resource considerations for AWS Control Tower Account Factory for Terraform",
            ],
            "coverage_notes": ["Operational and AWS sources both contribute, but the operational source is stronger on concrete remediation activity."],
            "summary": "Security guidance in this slice combines Bread-specific remediation workflows with AWS baseline expectations around encryption, IAM roles, feature flags, and protected Terraform state handling.",
            "bread": [
                "Bread's vulnerability-remediation flow treats AFT upgrades as controlled changes and explicitly checks for destructive Terraform actions before any apply.",
                "Bread's default-VPC remediation removes default VPCs outside approved regions and applies that guardrail broadly across existing and future accounts to satisfy Wiz findings.",
                "The operational notes also call out post-change validation in Wiz, sandbox pipelines, and Step Functions execution after remediations land.",
            ],
            "aws": [
                "AWS states that AFT encrypts core data stores and artifacts with KMS, recommends protecting state backends, and notes yearly key rotation by default for AFT-created keys.",
                "The required-roles material identifies the cross-account IAM surfaces that underpin AFT execution, which is important context when reviewing upgrade drift or remediation plans.",
                "Optional feature flags such as CloudTrail data events, Enterprise Support enrollment, and default-VPC deletion map directly to the sorts of hardening actions Bread is already operationalizing.",
            ],
            "gaps": [
                "The operational export does not show the final approved canonical Terraform for Bread's bootstrap configuration; Stephen feedback explicitly questions keeping that config only in the runbook.",
                "The vendor pack contains excerpts for some security topics rather than full native markdown pages.",
            ],
        },
        {
            "section_name": "Disaster Recovery / Multi-region Concerns",
            "slug": "disaster-recovery-multi-region-concerns",
            "output_path": "disaster-recovery-multi-region-concerns.md",
            "operational_sources": ["aft-overview-architecture-and-components.md", "draft-aft-lambda-vulnerability-remediation.md"],
            "aws_sources": ["aft-getting-started.md", "aft-post-deployment.full.md"],
            "context7_topics": [
                "Configure AFT with Existing VPC",
                "Resource considerations for AWS Control Tower Account Factory for Terraform",
            ],
            "coverage_notes": ["This section is intentionally sparse; AWS sources mention secondary-region state and repo setup, but the operational export has little DR-specific narrative."],
            "summary": "The source set only partially addresses disaster recovery, so this section mainly captures state-backend, secondary-region, and repo/bootstrap concerns plus the explicit gaps that still need formal design coverage.",
            "bread": [
                "Bread's operational material mentions a secondary Terraform backend region and treats rollback as a configuration reversion plus repeat plan/apply process with state preserved in versioned storage.",
                "The top export references multiple code repositories and remote diagrams, but it does not describe recovery objectives, failover ownership, or rebuild timelines.",
            ],
            "aws": [
                "AWS documents the secondary-region Terraform backend for Terraform OSS and the post-deployment requirement to populate the AFT repositories after infrastructure bootstrap.",
                "The getting-started guidance also surfaces optional VPC and deployment-shape choices that may influence resilience architecture, but it does not provide Bread-specific DR policy.",
            ],
            "gaps": [
                "No source in this slice defines Bread RTO/RPO, region-failover runbooks, or a tested AFT management-account recovery sequence.",
                "The DR section should be expanded later with explicit backup validation, CodeConnections recovery, and state-bucket restore procedures.",
            ],
        },
        {
            "section_name": "Monitoring and Alerting",
            "slug": "monitoring-and-alerting",
            "output_path": "monitoring-and-alerting.md",
            "operational_sources": ["aft-overview-architecture-and-components.md"],
            "aws_sources": ["account-troubleshooting-guide.md", "aft-provisioning-framework.full.md"],
            "context7_topics": ["Account Factory for Terraform (AFT) troubleshooting guide"],
            "coverage_notes": ["Operational coverage is moderate and mostly component-oriented; AWS coverage is excerpt-based and troubleshooting-oriented."],
            "summary": "Monitoring coverage centers on which AFT components emit state, events, or notifications, and where operators should look first when provisioning or customization workflows fail.",
            "bread": [
                "Bread's operational inventory names the event bus, request queue, dead-letter queue, success/failure SNS topics, control tower event logger, and audit trigger that form the local observability surface.",
                "The additional components section is especially useful for alert routing because it isolates the notification topics and logger Lambdas from the main provisioning flow.",
            ],
            "aws": [
                "The AWS troubleshooting excerpt points operators to CloudWatch logs, SNS failure notifications, and DynamoDB tables when account provisioning or registration fails.",
                "The provisioning-framework documentation complements that by explaining the state-machine-oriented flow that those logs and events correspond to.",
            ],
            "gaps": [
                "Neither source pack currently includes a formal alert catalog, metric thresholds, or escalation matrix.",
                "The operational export does not capture retention, dashboards, or on-call ownership for AFT failures.",
            ],
        },
        {
            "section_name": "Costs",
            "slug": "costs",
            "output_path": "costs.md",
            "operational_sources": ["draft-aft-lambda-upgrade-release-analysis.md", "draft-aft-lambda-vulnerability-remediation.md"],
            "aws_sources": ["aft-pricing.full.md"],
            "context7_topics": ["Resource considerations for AWS Control Tower Account Factory for Terraform"],
            "coverage_notes": ["AWS coverage is minimal but authoritative; operational coverage adds the only concrete Bread-specific cost watch item."],
            "summary": "AFT itself has no additional AWS service fee, but Bread still needs to account for the cost of the deployed infrastructure and for upgrade-driven changes such as DynamoDB billing-mode shifts.",
            "bread": [
                "The operational upgrade analysis identifies AFT 1.15.0 as the most notable cost-impacting release in the observed range because DynamoDB tables move from provisioned to pay-per-request billing.",
                "The vulnerability-remediation page recommends monitoring DynamoDB cost for the first 30 days after the upgrade and calls out the broader update set across Lambda, S3, CodeBuild, and IAM resources.",
            ],
            "aws": [
                "AWS states that there is no separate AFT charge, but customers pay for deployed resources and for default components such as PrivateLink endpoints and the NAT gateway required for CodeBuild support.",
                "The vendor pricing page also implies that cost posture can change if you alter the default network/security settings for the AFT deployment.",
            ],
            "gaps": [
                "No source in this slice includes an actual Bread cost baseline, tag-driven cost allocation model, or post-upgrade spend report.",
            ],
        },
    ]

    index_entries = []
    for section in sections:
        lines = [
            f"# {section['section_name']}",
            "",
            "## Summary",
            section["summary"],
            "",
            "## Bread operational guidance",
        ]
        lines.extend(f"- {item}" for item in section["bread"])
        lines.extend(["", "## AWS vendor guidance"])
        lines.extend(f"- {item}" for item in section["aws"])
        lines.extend(["", "## Source map"])
        lines.append("- Operational sources: " + ", ".join(f"`{src}`" for src in section["operational_sources"]))
        lines.append("- AWS vendor sources: " + ", ".join(f"`{src}`" for src in section["aws_sources"]))
        lines.append("- Context7 library id: " + f"`{CONTEXT7_LIBRARY_ID}`")
        lines.append("- Context7 topics: " + ", ".join(f"`{topic}`" for topic in section["context7_topics"]))
        lines.extend(["", "## Gaps and open questions"])
        lines.extend(f"- {item}" for item in section["gaps"])
        (COMBINED_DIR / section["output_path"]).write_text("\n".join(lines) + "\n", encoding="utf-8")
        index_entries.append(
            {
                "section_name": section["section_name"],
                "slug": section["slug"],
                "output_path": section["output_path"],
                "operational_sources": section["operational_sources"],
                "aws_sources": section["aws_sources"],
                "context7_topics": section["context7_topics"],
                "coverage_notes": section["coverage_notes"],
            }
        )

    readme = textwrap.dedent(
        f"""\
        AWS Control Tower - AFT Combined Pack

        Dependencies:
        - Operational source pack: `{OPERATIONAL_DIR}`
        - AWS vendor source pack: `{AWS_PACK}`
        - Governing repo/workflow: `dotfile-vnext`

        This pack synthesizes Bread operational AFT guidance with the sibling AWS Control Tower source pack into section-oriented markdown files aligned to the section checklist from `sections.png`.

        Context7 record:
        - Library id: `{CONTEXT7_LIBRARY_ID}`
        - Queried at: `{CONTEXT7_QUERIED_AT}`
        - Purpose: {CONTEXT7_PURPOSE}
        - Topics used:
        """
    )
    readme += "".join(f"- {topic}\n" for topic in CONTEXT7_TOPICS)
    metadata = {
        "collection": "AWS Control Tower AFT combined pack",
        "captured_date": "2026-07-07",
        "source_type": "operational-plus-vendor-synthesis",
        "governing_repo": "dotfile-vnext",
        "output_root": str(COMBINED_DIR),
        "dependencies": {
            "operational_pack": str(OPERATIONAL_DIR),
            "aws_vendor_pack": str(AWS_PACK),
            "plan_packet": str(PLAN_DIR / "README.md"),
        },
        "context7": {
            "library_id": CONTEXT7_LIBRARY_ID,
            "queried_at": CONTEXT7_QUERIED_AT,
            "purpose": CONTEXT7_PURPOSE,
            "topics": CONTEXT7_TOPICS,
        },
        "files": [{"path": entry["output_path"], "section_name": entry["section_name"]} for entry in index_entries],
        "index_files": ["section-index.json"],
    }
    (COMBINED_DIR / "README.md").write_text(readme, encoding="utf-8")
    (COMBINED_DIR / "metadata.json").write_text(json.dumps(metadata, indent=2) + "\n", encoding="utf-8")
    (COMBINED_DIR / "section-index.json").write_text(json.dumps(index_entries, indent=2) + "\n", encoding="utf-8")


def main():
    OPERATIONAL_DIR.mkdir(parents=True, exist_ok=True)
    COMBINED_DIR.mkdir(parents=True, exist_ok=True)
    write_operational_pack()
    write_combined_pack()


if __name__ == "__main__":
    main()
