# AWS Naming and Tagging Conventions

## Source

- AWS Tagging Best Practices: https://docs.aws.amazon.com/general/latest/gr/aws_tagging.html
- AWS Well-Architected Tagging: https://docs.aws.amazon.com/prescriptive-guidance/latest/tagging-basics/ (note: specific naming URL 404'd, using general tagging guidance)

## Core Philosophy

**AWS is tag-driven, not name-driven.**

Unlike DNS-based systems (Kubernetes) or hierarchical systems (NetBox), AWS uses:
- **Tags** as the primary organizational mechanism
- **Names** as human-readable identifiers (when supported)
- **ARNs** as the canonical unique identifier

## Hard Requirements (MUST)

### Tag Keys and Values

- **Case sensitivity**: Tag keys and values are case-sensitive
- **Key length**: Maximum 128 Unicode characters
- **Value length**: Maximum 256 Unicode characters
- **Valid characters**: Letters, numbers, spaces, and `+ - = . _ : / @`
- **Prohibited**: Do NOT store PII or sensitive information in tags
- **AWS-reserved prefix**: Tags starting with `aws:` are reserved for AWS use only

**Example valid tags:**
```json
{
  "CostCenter": "111122223333",
  "Environment": "Production",
  "Project": "MyApp",
  "Owner": "team@example.com"
}
```

### Resource Naming Constraints (Varies by Service)

Each AWS service has its own naming rules:

**S3 Buckets:**
- Globally unique
- 3-63 characters
- Lowercase letters, numbers, hyphens
- Must start/end with letter or number
- Cannot contain consecutive hyphens

**EC2 Instances:**
- Name tag is optional but recommended
- No enforced format (it's just a tag value)
- Convention: descriptive, includes environment

**IAM Roles/Policies:**
- Alphanumeric plus `+=,.@-_` characters
- Path notation supported: `/path/to/role`

**RDS Instances:**
- Alphanumeric and hyphens
- Must start with letter
- Unique within account and region

## Recommendations (SHOULD)

### AWS Tagging Strategy

AWS recommends these core tag categories:

#### 1. Technical Tags

| Tag Key | Purpose | Example Values |
|---|---|---|
| `Name` | Human-readable identifier | `web-server-prod-01` |
| `ApplicationID` | Application identifier | `app-12345` |
| `ApplicationRole` | Function in architecture | `web-server`, `database`, `cache` |
| `ClusterName` | Cluster identifier | `k8s-prod-cluster` |
| `Environment` | Deployment environment | `Production`, `Staging`, `Development` |
| `Version` | Application version | `1.2.3`, `v2.0` |

#### 2. Automation Tags

| Tag Key | Purpose | Example Values |
|---|---|---|
| `DateOfBirth` | Resource creation date | `2026-05-19` |
| `ScheduledStop` | Automated shutdown time | `2200` |
| `ScheduledStart` | Automated startup time | `0800` |
| `ManagedBy` | Automation tool | `Terraform`, `Ansible`, `CloudFormation` |
| `OwnedBy` | Automation ownership | `team-platform`, `devops` |

#### 3. Business Tags

| Tag Key | Purpose | Example Values |
|---|---|---|
| `Owner` | Business owner | `john.smith@example.com` |
| `CostCenter` | Cost allocation | `CC-12345` |
| `Project` | Project identifier | `Project-Phoenix` |
| `BusinessUnit` | Organizational unit | `Engineering`, `Marketing` |
| `Customer` | Customer identifier (multi-tenant) | `customer-abc` |

#### 4. Security Tags

| Tag Key | Purpose | Example Values |
|---|---|---|
| `Compliance` | Compliance requirement | `HIPAA`, `PCI-DSS`, `SOC2` |
| `DataClassification` | Data sensitivity | `Public`, `Internal`, `Confidential`, `Restricted` |
| `SecurityZone` | Network security zone | `dmz`, `internal`, `restricted` |

### Common Naming Patterns (When Names Are Used)

**EC2 Instances:**
```
<environment>-<application>-<role>-<sequence>
```

Examples:
- `prod-myapp-web-01`
- `staging-api-worker-02`
- `dev-database-primary`

**S3 Buckets:**
```
<organization>-<environment>-<purpose>-<region>
```

Examples:
- `myorg-prod-logs-us-east-1`
- `myorg-staging-backups-eu-west-1`
- `myorg-dev-artifacts-us-west-2`

**IAM Roles:**
```
<environment>-<application>-<function>-role
```

Examples:
- `prod-myapp-lambda-execution-role`
- `staging-api-ec2-role`
- `dev-batch-job-role`

**Security Groups:**
```
<environment>-<application>-<protocol>-<direction>
```

Examples:
- `prod-web-https-inbound`
- `staging-api-internal-outbound`
- `dev-database-mysql-inbound`

**Load Balancers:**
```
<environment>-<application>-<type>-lb
```

Examples:
- `prod-myapp-application-lb`
- `staging-api-network-lb`

## Tag Standardization

### Required Tags (Enforce via Policy)

Minimum recommended required tags:

```json
{
  "Name": "...",
  "Environment": "...",
  "Owner": "...",
  "CostCenter": "...",
  "Project": "..."
}
```

### Optional But Recommended Tags

```json
{
  "ManagedBy": "Terraform",
  "ApplicationID": "app-12345",
  "Version": "1.2.3",
  "DataClassification": "Internal"
}
```

### Tag Value Standardization

**Environment values (standardize across organization):**
- `Production` (not `prod`, `Prod`, `PRODUCTION`)
- `Staging` (not `stage`, `Stage`)
- `Development` (not `dev`, `Dev`)
- `Testing` (or `Test`)

**Boolean values:**
- `true` / `false` (not `yes`/`no`, `1`/`0`)

**Dates:**
- ISO 8601: `2026-05-19` (not `05/19/2026`, `19-05-2026`)

## Cost Allocation Tags

### Enable in AWS Billing

1. Activate cost allocation tags in AWS Billing Console
2. Wait 24 hours for tags to appear in Cost Explorer
3. Use activated tags for cost reports and budgets

**Common cost allocation tags:**
- `CostCenter`
- `Project`
- `Environment`
- `Team`
- `Application`

## Tag Policies (AWS Organizations)

When using AWS Organizations, enforce tagging via Tag Policies:

```json
{
  "tags": {
    "Environment": {
      "tag_key": {
        "@@assign": "Environment"
      },
      "tag_value": {
        "@@assign": ["Production", "Staging", "Development", "Testing"]
      },
      "enforced_for": {
        "@@assign": ["ec2:instance", "rds:db", "s3:bucket"]
      }
    }
  }
}
```

## Common Patterns

### Multi-Account Strategy Tags

When using multiple AWS accounts:

```json
{
  "AccountType": "Production",
  "AccountOwner": "platform-team",
  "AccountPurpose": "Application Hosting"
}
```

### Auto Scaling Group Tags

Tags propagate to launched instances:

```json
{
  "Name": "prod-web-asg-instance",
  "AutoScalingGroup": "prod-web-asg",
  "Environment": "Production",
  "LaunchedBy": "ASG"
}
```

### Disaster Recovery Tags

```json
{
  "BackupRequired": "true",
  "BackupFrequency": "daily",
  "RPO": "4h",
  "RTO": "1h"
}
```

## Constraints

| Element | Constraint | Notes |
|---|---|---|
| Tag key max length | 128 Unicode characters | Case-sensitive |
| Tag value max length | 256 Unicode characters | Case-sensitive |
| Tags per resource | Varies by service | Typically 50 tags |
| Valid characters | `[a-zA-Z0-9 +=._:/@-]` | Plus spaces |
| Reserved prefix | `aws:` | Cannot be used for user tags |

## Rationale

### Why Tags Over Names

- Not all AWS resources support names
- Tags work uniformly across all services
- Tags enable cost allocation
- Tags support automation and filtering
- Tags allow multi-dimensional organization

### Why Case-Sensitive

- AWS APIs treat tags as case-sensitive
- `Environment` ≠ `environment` ≠ `ENVIRONMENT`
- Standardize on one casing convention

### Why Standardized Values

- Enables consistent filtering
- Supports automation
- Improves cost reporting
- Reduces user error

### Why No PII in Tags

- Tags appear in logs, billing reports, and CloudTrail
- Tags may be visible to multiple teams
- Compliance and privacy requirements
- AWS specifically prohibits PII in tags

## Anti-Patterns to Avoid

- ❌ Inconsistent tag keys: `Environment`, `environment`, `Env`, `env`
- ❌ Inconsistent tag values: `Production`, `prod`, `PROD`, `Prod`
- ❌ Storing PII in tags: `Owner: john.smith.ssn.123-45-6789`
- ❌ Using freeform text: `Purpose: This is my test instance for the new feature`
- ❌ Empty tag values: `Project: ""`
- ❌ Too many tags: Using 45+ tags per resource
- ❌ Not activating cost allocation tags
- ❌ Different tagging schemes across teams
- ❌ Using special characters outside allowed set
- ❌ Trying to use `aws:` prefix for custom tags

## IAM Tag-Based Access Control

Tags enable fine-grained access control:

```json
{
  "Effect": "Allow",
  "Action": "ec2:*",
  "Resource": "*",
  "Condition": {
    "StringEquals": {
      "ec2:ResourceTag/Environment": "Development"
    }
  }
}
```

This policy allows EC2 actions only on resources tagged `Environment: Development`.

## Terraform Integration

```hcl
resource "aws_instance" "web" {
  ami           = "ami-12345678"
  instance_type = "t3.micro"
  
  tags = {
    Name          = "prod-web-01"
    Environment   = "Production"
    ManagedBy     = "Terraform"
    Owner         = "platform-team"
    Project       = "MyApp"
    CostCenter    = "CC-12345"
  }
}
```

## Service-Specific Naming

### S3 Buckets

- Globally unique across all AWS accounts
- DNS-compliant naming
- No uppercase or underscores
- 3-63 characters

### Lambda Functions

- Alphanumeric plus hyphens and underscores
- 1-64 characters
- Case-sensitive

### DynamoDB Tables

- Alphanumeric plus hyphens, dots, underscores
- 3-255 characters
- Case-sensitive

## References

- AWS Tagging Best Practices: https://docs.aws.amazon.com/general/latest/gr/aws_tagging.html
- AWS Resource Tagging: https://aws.amazon.com/answers/account-management/aws-tagging-strategies/
- Tag Editor: https://docs.aws.amazon.com/ARG/latest/userguide/tag-editor.html
- Cost Allocation Tags: https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/cost-alloc-tags.html
- Tag Policies (Organizations): https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_tag-policies.html
