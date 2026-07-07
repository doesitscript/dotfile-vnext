Documentation Reviewed and Updated

Overview

Update Process (IaC SDLC, Change Enablement, etc.)

Key Contacts

Architecture (including diagrams)

Runbook / Playbook

Security

Disaster Recovery / Multi-region Concerns

Monitoring and Alerting

Costs

-----


# Account Factory for Terraform (AFT)

# Overview

Bread Financial uses AWS Control Tower to manage the Bread Financial multi-account AWS environment.

 

AWS Control Tower provides features for setting up and governing a secure, compliant, multi-account AWS environment using best-practice blueprints. See [AWS Control Tower Documentation](<https://docs.aws.amazon.com/controltower/>) for additional details.

 

[Account Factory for Terraform (AFT)](<https://docs.aws.amazon.com/controltower/latest/userguide/aft-overview.html>) is an extension of AWS Control Tower for automating AWS account creation and management using Terraform. Using a consistent infrastructure as code (IaC) approach ensures consistency and compliance. Key components include:

 

* Account Provisioning: Automates AWS account creation with predefined configurations
* Networking Setup: Configures VPCs, subnets, and other networking resources
* Security Policies: Implements IAM roles, policies, and security groups
* Governance: Enforces organizational policies and standards

 

The AFT framework is split into four separate code repositories:

 

* [aft-account-request](<https://github.com/Bread-Financial/aft-account-request>)—provisioning new aws accounts
* [aft-global-customizations](<https://github.com/Bread-Financial/aft-global-customizations>)—provisioning infrastructure resources that are foundational and expected to exist in many accounts
* [aft-account-customizations](<https://github.com/Bread-Financial/aft-account-customizations>)—provisioning resources that are specific to a single account
* [aft-account-provisioning-customizations](<https://github.com/Bread-Financial/aft-account-provisioning-customizations>)—for provisioning non-aws account-related resources; (not currently used)

 

**Note:** Generally we prefer to track solution-oriented IaC in repositories other than [aft-account-customizations](<https://github.com/Bread-Financial/aft-account-customizations>).

 

| **Team Manager** | Smith, Stephen |
| -- | -- |
| **Technical contact** | Rawson, Ben benjamin.rawson@breadfinancial.com |
| **Resolver Group** | BFH.AwsInfrastructure |

 

| **ServiceNow CI Identifier Name** | **ServiceNow CI Identifier ID** |
| -- | -- |
| bfhaws-AFT (prod)bfhaws-AFT-customizations (nonprod)bfhaws-AFT-customizations (prod) |   |

 

# Architecture

## New Account

![](https://uploads.linear.app/4758eb12-68d3-4b70-9c38-1741cf1f08bb/0f30ab6d-d95e-47fc-b098-3d3b1c30a595/f798d046-3775-493a-af02-25d42cfa7039)

From <[https://app.diagrams.net/index.html#Wb!X6bdRbG-B0WtfYT3WnnZvu_I6T8x-GpMumnCirVn7uRxdWbVdPXeQ7norQEYNMh1%2F01Y4NIMOI5QDQFB5BLFREYGTYPKCVDYN2M#%7B%22pageId%22%3A%222K-OYkGe0j2da_PkwELb%22%7D](<https://app.diagrams.net/index.html#Wb!X6bdRbG-B0WtfYT3WnnZvu_I6T8x-GpMumnCirVn7uRxdWbVdPXeQ7norQEYNMh1%2F01Y4NIMOI5QDQFB5BLFREYGTYPKCVDYN2M#%7B%22pageId%22%3A%222K-OYkGe0j2da_PkwELb%22%7D>)>

 

## Account Customizations

| ![](https://uploads.linear.app/4758eb12-68d3-4b70-9c38-1741cf1f08bb/c33b7877-a80e-4f6b-9684-389085f89552/3f436e25-62da-4561-9e08-6633bc5ad1d3)From <[https://app.diagrams.net/index.html#Wb!X6bdRbG-B0WtfYT3WnnZvu_I6T8x-GpMumnCirVn7uRxdWbVdPXeQ7norQEYNMh1%2F01Y4NIMOI5QDQFB5BLFREYGTYPKCVDYN2M#%7B%22pageId%22%3A%222YzjXRP458-ypgZTRcfl%22%7D](<https://app.diagrams.net/index.html#Wb!X6bdRbG-B0WtfYT3WnnZvu_I6T8x-GpMumnCirVn7uRxdWbVdPXeQ7norQEYNMh1%2F01Y4NIMOI5QDQFB5BLFREYGTYPKCVDYN2M#%7B%22pageId%22%3A%222YzjXRP458-ypgZTRcfl%22%7D>)> |
| -- |
|   |

 

# Key Components

Below are the key components involved in vending and customizing accounts in our environment:

 

## Event Buses

| **Bus** | **Description** |
| -- | -- |
| **aft-events-from-ct-management** | Custom EventBridge bus in the AFT management account used to ingest selected Control Tower lifecycle events from the CT management account and fan them out to AFT Lambdas. |

 

## SQS Queues

| **Queue** | **Type** | **Purpose** | **Producers** | **Consumers** | **Key behavior** |
| -- | -- | -- | -- | -- | -- |
| **aft-account-request.fifo** | FIFO | Main work queue for account vending/update requests triggered from aft-request table changes | aft-account-request-action-trigger via insert_msg_into_acc_req_queue | aft-account-request-processor (polls and deletes messages) | * Encrypted with AFT KMS key<br>* visibility timeout 240s<br>* redrive to DLQ after 1 failed receive |

 

## Step Functions

| **Name** | **Purpose** |
| -- | -- |
| **aft-account-provisioning-framework** | Main provisioning orchestrator — runs create-role → tag-account → account-metadata-ssm → aft-features → customizations in sequence |
| **aft-features** | Runs the optional feature Lambdas (delete-default-vpc, enroll-support, enable-cloudtrail) based on feature flags |

 

## Lambdas

| **Name** | **Purpose** |
| -- | -- |
| **aft-account-request-action-trigger** | DynamoDB stream trigger on **aft-request** table — inspects the change and routes it to either SQS (new vend / CT update) or the provisioning Step Function (customization-only) |
| **aft-account-request-processor** | CloudWatch Events triggered — reads from the **aft-account-request** SQS queue and calls Service Catalog to create or update the account in Control Tower |
| **aft-invoke-aft-account-provisioning-framework** | Triggered by CT lifecycle events (or directly) — formats the event and starts the aft-account-provisioning-framework Step Function |
| **aft-cleanup-resources** | Removes AFT pipeline resources when an account record is deleted from the AFT request table |
| **aft-account-provisioning-framework-create-aft-execution-role** | Step in provisioning SFN — creates the AFT execution IAM role in the target account |
| **aft-account-provisioning-framework-tag-account** | Step in provisioning SFN — applies tags to the target account |
| **aft-account-provisioning-framework-persist-metadata** | Step in provisioning SFN — writes account metadata to DynamoDB |
| **aft-account-provisioning-framework-account-metadata-ssm** | Step in provisioning SFN — reconciles custom_fields as SSM parameters in the target account |
| **aft-delete-default-vpc** | Feature option — deletes the default VPC in the target account |
| **aft-enroll-support** | Feature option — enrolls the account in AWS Support |
| **aft-enable-cloudtrail** | Feature option — enables CloudTrail in the target account |
| **aft-customizations-identify-targets** | Called from customizations SFN — determines which accounts need customization |
| **aft-customizations-execute-pipeline** | Called from customizations SFN — triggers the CodePipeline for account baselining |
| **aft-customizations-get-pipeline-executions** | Called from customizations SFN — polls CodePipeline execution status |

#  

# Additional Components

Additional components, less relevant to understanding the automation details:

 

## SNS Topics

| **Topic** | **Publishers** | **Purpose** |
| -- | -- | -- |
| aft-notifications | Step Functions (success states in provisioning, features, and customizations SFNs) | General workflow success notifications |
| aft-failure-notifications | All provisioning/feature/customization Lambdas, plus Step Function error/catch states | Lambda and Step Function failure alerts |

 

## SQS Queues

| **Queue** | **Type** | **Purpose** | **Producers** | **Consumers** | **Key behavior** |
| -- | -- | -- | -- | -- | -- |
| aft-account-request-dlq.fifo | FIFO (DLQ) | Dead-letter queue for failed messages from main queue | Automatic redrive from main queue | No automatic consumer | * Encrypted with AFT KMS key<br>* receives messages when main queue processing fails |

 

## Step Functions

| **Name** | **Purpose** |
| -- | -- |
| **aft-invoke-customizations** | Core-framework orchestrator that fans out customization work and invokes downstream provisioning/customization execution.&#10;&#10;**Note:** Not used directly by any automation. Provides a way to execute several customizations pipelines at once |
| **aft-account-provisioning-customizations** | Separate customization repo state machine used for account provisioning customizations. Referenced by name from core framework, not created in the same module.&#10;&#10;**Note:** Related to [aft-account-provisioning-customizations](<https://github.com/Bread-Financial/aft-account-provisioning-customizations>) and not currently used |

##  

## Lambdas

| **Name** | **Purpose** |
| -- | -- |
| **aft-account-request-audit-trigger** | DynamoDB stream trigger on **aft-request** table — copies every change into the aft-request-audit table for audit history |
| **aft-controltower-event-logger** | Receives Control Tower lifecycle events via EventBridge and writes them to the **aft-controltower-events** DynamoDB table |
| **aft-lambda-layer-codebuild-trigger** | Triggers a CodeBuild job to build/publish the AFT common Lambda layer&#10;&#10;**Note:** Used during AFT installation / upgrade to build the python code for Lambdas |

 

# References

| **Reference** | **Description** |
| -- | -- |
| [Provision accounts with AWS Control Tower Account Factory for Terraform (AFT)](<https://docs.aws.amazon.com/controltower/latest/userguide/taf-account-provisioning.html>) | Primary documentation in the AWS Control Tower User Guide |
| [AFT Architecture](<https://docs.aws.amazon.com/controltower/latest/userguide/aft-architecture.html>) | Architecture diagram from the AWS Control Tower User Guide |
| [Deploy and Customize AWS accounts using Account Factory for Terraform in AWS Control Tower](<https://aws.amazon.com/blogs/mt/deploy-and-customize-aws-accounts-using-account-factory-for-terraform-in-aws-control-tower/>) | AWS Cloud Operations Blog post |
| [Manage AWS accounts using Control Tower Account Factory for Terraform](<https://developer.hashicorp.com/terraform/tutorials/aws/aws-control-tower-aft>) | HashiCorp documentation on AFT |


## Metadata
- URL: [https://linear.app/doesitscript/issue/DOE-59/account-factory-for-terraform-aft](https://linear.app/doesitscript/issue/DOE-59/account-factory-for-terraform-aft)
- Identifier: DOE-59
- Status: Backlog
- Priority: No priority
- Assignee: Unassigned
- Created: 2026-07-07T15:23:20.651Z
- Updated: 2026-07-07T15:29:27.365Z

## Comments

- Josh Castillo:

  Draft: Change enablement

  # Overview

  This page describes our team's change enablement process when making changes to:

  * [aft-account-request](<onenote:#DRAFT%20Change%20Enablement&section-id=%7B55790A16-E049-4DBF-8585-AFBECBE32267%7D&page-id=%7B6168A442-A201-4D10-914C-859ADBA4EF55%7D&object-id=%7BB95C82DB-75EE-0127-0E82-4AE89EE9A3C1%7D&1F&base-path=https://alliancedata.sharepoint.com/sites/CloudAgilityTeam/Shared%20Documents/Team%20AWS%20Infrastructure/CA%20AWS%20Infrastructure%20Notebook/AWS%20WS1/AWS%20Administrator's%20Guide.one>)
  * [aft-global-customizations / aft-account-customizations](<onenote:#DRAFT%20Change%20Enablement&section-id=%7B55790A16-E049-4DBF-8585-AFBECBE32267%7D&page-id=%7B6168A442-A201-4D10-914C-859ADBA4EF55%7D&object-id=%7BB95C82DB-75EE-0127-0E82-4AE89EE9A3C1%7D&2D&base-path=https://alliancedata.sharepoint.com/sites/CloudAgilityTeam/Shared%20Documents/Team%20AWS%20Infrastructure/CA%20AWS%20Infrastructure%20Notebook/AWS%20WS1/AWS%20Administrator's%20Guide.one>)

  # aft-account-request

  Primarily used to vend new accounts or update account metadata. Changes to this repo are considered business as usual (BAU) and do not require a change request (CR).

  # aft-global-customizations / aft-account-customizations

  ## Overview

  Changes to these repositories are applied per-account through the **{account-id}-customizations-pipeline** pipeline.

  Key change enablement considerations:

  * per-account pipelines are not triggered automatically except *once* upon creation
  * commits in main should be applied to all accounts
    * ensures consistency
    * catches issues when changes are fresh
  * CR *not* required for sandbox/dev accounts
  * CRs are required for nonprd and prd accounts
  * account type is determined by **bfh:awsinfra:scope**
  * successful nonprd CR is a pre-requisite for scheduling a prd CR
  * use the **aft-invoke-customizations** step function to trigger pipelines
  * prefix all account customizations CRs with **AFT:**

  **Warn:** The **aft-invoke-customizations** step function does *not* support specifying the source versions to be deployed.

  ## When to Merge?

  Since the **aft-invoke-customizations** step function always deploys the latest commit on the **main** branches, it is important to coordinate when pull requests are merged *as a team*.

  *Before* merging changes to either **aft-global-customizations** or **aft-account-customizations**:

  1. check for any in-flight changes with the **AFT:** prefix

  **Note:** New requirement starting 3/19

  1. review the [AFT Changes Coordination](<https://teams.microsoft.com/l/message/19:ml1hicNwc0d45QurmgqpP_6qs7WDVA7eZbOWPN7QhkY1@thread.tacv2/1773923969052?tenantId=7a24eae8-33b9-449a-83f5-361634c821ce&groupId=7f31ea51-0499-4f18-957c-347a5b81500e&parentMessageId=1773923969052&teamName=Cloud%20Agility%20Home&channelName=BFH.AwsInfrastructure&createdTime=1773923969052&ngc=true&allowXTenantAccess=true>) post in our [BFH.AwsInfrastructure](<https://teams.microsoft.com/l/channel/19%3Aml1hicNwc0d45QurmgqpP_6qs7WDVA7eZbOWPN7QhkY1%40thread.tacv2/BFH.AwsInfrastructure?groupId=7f31ea51-0499-4f18-957c-347a5b81500e&tenantId=7a24eae8-33b9-449a-83f5-361634c821ce&ngc=true&allowXTenantAccess=true>) channel in Microsoft Teams

  If there are no in-flight changes, you are free to merge and make new CRs.

  **Note:** Coordinating with the current CR implementer to deploy your changes along with other changes is an option provided that the in-flight changes aren't yet scheduled.

  ## Change Implementation Steps

  1. deploy to all sandbox/dev immediately after merge
  2. deploy to nonprd during a scheduled CR
  3. deploy the same changes to prd during a scheduled CR
     1. reference the successful nonprd CR in the prd CR

  **Note:** Attach screenshot evidence of success to each CR after implementation

  # Tech Debt / Opportunities

  **UPDATE 3-23-2026:**

  See ticket for details:

  [https://bread-financial.atlassian.net/browse/CA-3217](<https://bread-financial.atlassian.net/browse/CA-3217>)

  * Script to be triggered by pipeline that will execute accounts in batches
  * Batches determined by account tags in one of 3 groups:
    * dev/sandbox
    * nonprod (sit,uat,perf,etc.)
    * prd (prd)
  * Dev to run on weekly cadence automatically
  * Nonprod to be a standard change in CAB aiming for weekly cadence
  * Prd TBD
  * Rollback will be based on previous date stamp Git tag, K.I.S.S.
  * Pipeline will be in TFC or in Harness
  * Date stamp Git tags will be created via automation, probably as the first step of the weekly Dev release


  \---

  * create Cis for AFT non-prod and AFT production
  * implement a solution for scoped triggering of pipelines for specific commits
  * create standard change templates
  * implement a pipeline to automate the deployment of changes according to our requirements:

  ![](https://uploads.linear.app/4758eb12-68d3-4b70-9c38-1741cf1f08bb/f2cec2b9-0a86-4555-b5ac-1199a9422670/6223751f-e681-458c-81ba-a7b97b661a97)

  From <[https://app.diagrams.net/index.html#Wb!X6bdRbG-B0WtfYT3WnnZvu_I6T8x-GpMumnCirVn7uRxdWbVdPXeQ7norQEYNMh1%2F01Y4NIMOI5QDQFB5BLFREYGTYPKCVDYN2M#%7B%22pageId%22%3A%22v2BJqpOwjyZO6nqqldJn%22%7D](<https://app.diagrams.net/index.html#Wb!X6bdRbG-B0WtfYT3WnnZvu_I6T8x-GpMumnCirVn7uRxdWbVdPXeQ7norQEYNMh1%2F01Y4NIMOI5QDQFB5BLFREYGTYPKCVDYN2M#%7B%22pageId%22%3A%22v2BJqpOwjyZO6nqqldJn%22%7D>)>

  # Test PR changes in Sandbox account

  #

  For the testing of code in aft-global-customizations/aft-account-customizations, once the code is reviewed and PR is approved, we can test the PR changes in sandbox account before merging the code to main branch by following the below steps.

  * Go to AFT account and choose sandbox account's code pipeline
  * Click on release change -> Click on Source revision overrides
  * Provide the commit id in aft-global-customizations/aft-account-customizations and click release change.

- Josh Castillo:

  AWS Account Decommissioning Procedure

  **AWS Account Decommissioning Reference Document**

  **Account Name: SDLC-DEV-Analytics**

  **Account ID: 397505358192**

  **1. Purpose**

  This document serves as a **reference template** for decommissioning AWS accounts managed under AWS Control Tower and AFT (Account Factory for Terraform).

  It provides a real example of the steps, validations, and ServiceNow/GitHub artifacts involved in the process.

  **2. Overview**

  The AWS account **SDLC-DEV-Analytics (Account ID: 397505358192)** was successfully decommissioned following the organization’s standard AWS account decommissioning process.

  **Steps Performed**

  1. **Remove Terraform Account request file from *AFT-account-request* Repository**
     * Delete .tf files for the target account.
     * Raise & merge PR (Example: [#92](<https://github.com/Bread-Financial/aft-account-request/pull/92>)). Once PR merged, it deletes the AFT pipeline

  **Note** : Before going to step 2,check and confirm if the account state was managed by TFC workspace.

  If **'yes'**, then follow the steps below. Else, proceed with step 2

  * Go to target workspace > settings > Destruction and Deletion. Select 'Queue Destroy Plan' only if you see the resources exist. If no resources, then directly proceed with deleting workspace.
  * To delete workspace, select 'Force delete from HCP terraform'

  1. **Detach/Close Account from AWS Control Tower**
     * Follow [Unenroll an account - AWS Control Tower](<https://docs.aws.amazon.com/controltower/latest/userguide/unmanage-account.html>)

  1. **Remove SSO Group Configuration from AWS Access Repo**
     * Delete group-related Terraform files.
     * Raise & merge PR (Example: [#28](<https://github.com/Bread-Financial/aws-access/pull/28>))

  1. **Execute Terraform to Remove SSO Group and Account Assignment**
     * Run terraform apply.
       **Resources Removed:**
       * SSO Group: App-AWS-AA-SDLC-DEV-Analytics-397505358192-admin
       * Account Assignment: AWS Account 397505358192
     * **Verify Removal:**

  terraform state list | grep SDLC-DEV-Analytics

  terraform output -json groups | jq '."App-AWS-AA-SDLC-DEV-Analytics-397505358192-admin"'

  null

  **Raise ServiceNow Request for AD Group Removal**

  * Example Group: App-AWS-AA-SDLC-DEV-Analytics-397505358192-admin

  **Verification**

  * Confirm the SSO group is deleted in AWS Identity Center.
  * Ensure Terraform state shows no residual resources.
  * Validate the account is no longer visible in AWS Control Tower.

- Josh Castillo:

  Vend an AWS Account

  # Overview

  Accounts are created by adding a file to [aft-account-request/terraform](<https://github.com/Bread-Financial/aft-account-request/tree/main/terraform>). Key inputs:

  * Account Name
  * Organizational Unit (OU)
  * VPC size
  * Apply appropriate tags. The following tags are required and used for platform management:
    * **bfh:awsinfra:scope**—Something like environment, but keeping it separate to support our use cases around change enablement and access
    * **bfh:awsinfra:isrehost**—Indicates if this account is for a rehost migration via [AWS Application Migration Service](<https://aws.amazon.com/application-migration-service/>)
    * **bfh:awsinfra:isunicorn**—Tracks the small set of accounts that are created by Control Tower and should be treated uniquely, including the management, log archive, audit, AFT, and Network Hub accounts
  * Any additional custom fields

  Follow our team's standard (pull request) process for IaC changes.

  Once the PR is approved, be sure to request standard AD groups for the new account and track them in the [sso_groups.yaml](<https://github.com/Bread-Financial/aws-access/blob/live/conf/sso_groups.yaml>) config file. Once the AD groups are created, run terraform apply in the [sso_groups](<https://github.com/Bread-Financial/aws-access/tree/live/sso_groups>) root module.

- Josh Castillo:

  Add an OU (Organization Unit)

  # Overview

  Complete the following steps:

  1. Update [ct-management-customizations](<https://github.com/Bread-Financial/aft-account-customizations/tree/main/ct-management-customizations>) in the [aft-account-customizations](<https://github.com/Bread-Financial/aft-account-customizations>) repository
  2. Run the pipeline (CodePipeline in AFT account) for the management account (739275453939) to apply the terraform and create the new OU
  3. Register the OU through the AWS console in the Control Tower service in the management account
  4. Get account added to the appropriate WIZ collection

  **Warning:** If you forget step (3), registering the OU in Control Tower, vending an account into the new OU will fail and require additional cleanup

  For (1), see [feat: add top-level Governance OU to AWS org structure](<https://github.com/Bread-Financial/aft-account-customizations/pull/58/files>) as an example change.

  For (3), execute the following steps to register the OU in the Control Tower section of the AWS console. (See
  [Register an existing OU](<https://docs.aws.amazon.com/controltower/latest/userguide/how-to-register-existing-ou.html>) for additional details.)

  1. Sign in to the AWS Control Tower console at  [https://console.aws.amazon.com/controltower](<https://console.aws.amazon.com/controltower>).
  2. In the left-pane navigation menu, choose **Organization**.
  3. On the **Organization** page, select the radio button next to the OU you want to register, then select **Register organizational unit** from the **Actions** dropdown menu at the upper right, or alternatively, select the name of the OU so you can view the **OU details** page for that OU.
  4. On the **OU details** page, at the upper right you can select **Register OU** from the **Actions** dropdown menu.

  For (4) adding to WIZ collection, the "Greenfield Non Sandbox" scope is used to review compliance for platform accounts. Add any OU not considered sandbox/nested under sandbox to this scope by contacting cloud security (commonly Sahil.Khan@breadfinancial.com). Similarly, and sub OU of Sandbox should be added to "Greenfield Sandbox"

  **Note:** The registration process takes a minimum of 10 minutes to extend governance to the OU, and up to 2 additional minutes for each additional account.

- Josh Castillo:

  DRAFT: Cleanup and Retrigger a Failed Account Request

  # Overview

  Run the following commands from the **Management Account** when an account vending attempt fails due to an OU not registered in Control Tower.

  1.  Register OU with Control Tower

  aws controltower register-organizational-unit --organizational-unit-id <ou-name>

  1. Terminate Failed Service Catalog Product

  aws servicecatalog list-provisioned-products

  aws servicecatalog terminate-provisioned-product --provisioned-product-name <failed-product-name>

  1. Delete Failed Request from DynamoDB

  aws dynamodb scan --table-name aft-request

  aws dynamodb delete-item --table-name aft-request --key '{"id": {"S": "<account_request_id>"}}'

  1. Re-trigger AFT Account Request

  aws dynamodb put-item --table-name aft-request --item [file://account_request.json](<file:///account_request.json>)

- Josh Castillo:

  DRAFT: Apply AFT Account: Global Terraform at Scale

  Overview

  This document provides instructions for triggering the Account Factory for Terraform (AFT) Step Function (aft-invoke-customizations) in AWS using CLI. It includes:

  AWS CLI commands for different use cases:

  * Run customizations for all accounts.
  * Target specific accounts, organizational units (OUs), or tags.

  #

  # Run all accounts

  `aws stepfunctions start-execution \`

  `--region us-east-2 \`

  `--state-machine-arn arn:aws:states:us-east-2:474668427263:stateMachine:aft-invoke-customizations \`

  `--name aft-run-$(date +%Y%m%dT%H%M%S) \`

  `--input '{`

  `"include": [`

  `{ "type": "all" }`

  `]`

  `}'`

  # Run Specific accounts (CloudOperations)

  `aws stepfunctions start-execution \`

  `--region us-east-2 \`

  `--state-machine-arn arn:aws:states:us-east-2:474668427263:stateMachine:aft-invoke-customizations \`

  `--name aft-run-$(date +%Y%m%dT%H%M%S) \`

  `--input '{`

  `"include": [`

  `{ "type": "accounts", "target_value": ["920411896753"] }`

  `]`

  `}'`

  # Run for AwsInfrastructure-sandbox account

  `aws stepfunctions start-execution \`

  `--region us-east-2 \`

  `--state-machine-arn arn:aws:states:us-east-2:474668427263:stateMachine:aft-invoke-customizations \`

  `--name aft-run-$(date +%Y%m%dT%H%M%S) \`

  `--input '{`

  `"include": [`

  `{ "type": "accounts", "target_value": ["960682159332"] }`

  `]`

  `}'`

  #

  # Run Specific OUs

  `aws stepfunctions start-execution \`

  `--region us-east-2 \`

  `--state-machine-arn arn:aws:states:us-east-2:474668427263:stateMachine:aft-invoke-customizations \`

  `--name aft-run-$(date +%Y%m%dT%H%M%S) \`

  `--input '{`

  `"include": [`

  `{ "type": "ous", "target_value": ["ou-uieo-7akhryi","ou-uieo-07p5fghi"] }`

  `]`

  `}'`

  # Exclude Specific accounts, OU

  `aws stepfunctions start-execution \`

  `--region us-east-2 \`

  `--state-machine-arn arn:aws:states:us-east-2:474668427263:stateMachine:aft-invoke-customizations \`

  `--name aft-run-$(date +%Y%m%dT%H%M%S) \`

  `--input '{`

  `"include": [`

  `{ "type": "all" },`

  `{ "type": "ous",  { "type": "ous", "target_value": ["ou-uieo-7akhryi", "ou-uieo-07p5fghi"] },`

  `{ "type": "tags", "target_value": [ {"key1":"value1"}, {"key2":"value2"} ] },`

  `{ "type": "accounts", "target_value": ["acc1_ID", "acc2_ID"] }`

  `],`

  `"exclude": [`

  `{ "type": "ous", "target_value": ["ou-uieo-7akhryi", "ou-uieo-07p5fghi"] },`

  `{ "type": "tags", "target_value": [ {"key1":"value1"}, {"key2":"value2"} ] },`

  `{ "type": "accounts", "target_value": ["acc1_ID", "acc2_ID"] }`

  `]`

  - Josh Castillo:

    DRAFT: AFT Lambda upgrade release analysis

    # This page documents a version‑by‑version analysis of AWS Account Factory for Terraform (AFT) upgrades.

    #

    # 1.13.4

    Terraform plan output changes for the current version.

    **For AWS code pipeline:**

    * Terraform is removing the explicit trigger { ... } block (push on main) from the pipeline definition.
    * Source action already has BranchName = main and DetectChanges = true (we confirmed via CLI), so commit-based auto-triggering remains enabled.
    * Result: no pipeline replacement, no name change, no downtime event expected, just config normalization on the same resource.

    $ aws codepipeline get-pipeline --name ct-aft-account-provisioning-customizations --region us-east-2 --query "pipeline.stages\[?name=='Source'\].actions\[0\].configuration"

    \[

    {

    "BranchName": "main",

    "ConnectionArn": "arn:aws:codeconnections:us-east-2:474668427263:connection/48174ff9-9cef-42a9-b724-c5b6c36caa84",

    "DetectChanges": "true",

    "FullRepositoryId": "Bread-Financial/aft-account-provisioning-customizations",

    "OutputArtifactFormat": "CODE_ZIP"

    }

    \]

    \~ $ aws codepipeline get-pipeline --name ct-aft-account-request --region us-east-2 --query "pipeline.stages\[?name=='Source'\].actions\[0\].configuration"

    \[

    {

    "BranchName": "main",

    "ConnectionArn": "arn:aws:codeconnections:us-east-2:474668427263:connection/48174ff9-9cef-42a9-b724-c5b6c36caa84",

    "DetectChanges": "true",

    "FullRepositoryId": "Bread-Financial/aft-account-request",

    "OutputArtifactFormat": "CODE_ZIP"

    }

    \]

    Terraform will perform the following actions:

    \# module.aft_pipeline.module.aft_code_repositories.aws_codepipeline.codeconnections_account_provisioning_customizations\[0\] will be updated in-place

    \~ resource "aws_codepipeline" "codeconnections_account_provisioning_customizations" {

    id             = "ct-aft-account-provisioning-customizations"

    name           = "ct-aft-account-provisioning-customizations"

    tags           = {}

    \# (6 unchanged attributes hidden)

    \- trigger {

    \- provider_type = "CodeStarSourceConnection" -> null

    \- git_configuration {

    \- source_action_name = "account-provisioning-customizations" -> null

    \- push {

    \- branches {

    \- excludes = \[\] -> null

    \- includes = \[

    \- "main",

    \] -> null

    }

    }

    }

    }

    #

    **For SSM, this apply changes one parameter value:**
    Parameter name: /aft/config/feature/cloudtrail-data-events-enabled, is currently set to False.

    Terraform detected drift and will update that SSM parameter in place.

    AFT feature flag for CloudTrail data events becomes enabled. No parameter deletion/recreation or downtime expected from this SSM change itself.

    \# module.aft_pipeline.module.aft_ssm_parameters.aws_ssm_parameter.aft_feature_cloudtrail_data_events will be updated in-place

    \~ resource "aws_ssm_parameter" "aft_feature_cloudtrail_data_events" {

    id              = "/aft/config/feature/cloudtrail-data-events-enabled"

    \+ insecure_value  = (known after apply)

    name            = "/aft/config/feature/cloudtrail-data-events-enabled"

    tags            = {}

    \~ value           = (sensitive value)

    \~ version         = 1 -> (known after apply)

    #

    # 1.13.5

    ***Update the check for service dependencies to support deployment in opt-in regions without SSM public parameter support. (#501)***

    Previously, AFT checked for required AWS service dependencies using SSM (AWS Systems Manager) public parameters. However, some AWS regions especially opt-in regions do not support these public SSM parameters.

    With this update, the logic for checking service dependencies has been improved so that AFT can still deploy in opt-in regions even if SSM public parameters are not available.

    ***Increase timeout for aft-account-request-action-trigger Lambda to 10 minutes. (#494)***

    Lambda timeout increase - aft-account-request-action-trigger timeout: 300s → 600s

    Account requests that take longer than 5 minutes, this prevents timeouts.

    # 1.14.0

    ***Add support for customer provided VPCs at the time of deployment. Learn more about deploying AFT in your own VPC here. (#192)***

    The "Custom VPC support infrastructure - Backend changes to support VPC configurations" refers to updates made in the AFT backend that allow users to specify and use their own Virtual Private Clouds (VPCs) when deploying AFT. Previously, AFT would typically create and manage its own VPCs as part of the deployment process. With this change, customers can now provide their own VPC IDs, subnets, and related networking configurations at deployment time.

    ***Update VPC endpoints to support AWS Organizations when deploying in the us-east-1 AWS Region. (#452)***

    AFT’s VPC endpoints in us-east-1 now better support AWS Organizations, enabling smoother integration and management across multiple AWS accounts.

    ***Add support for providing a project name to deploy AFT workspaces into. This functionality is applicable to Terraform Enterprise and HCP Terraform (formerly Terraform Cloud) customers. (#519, #447, #342)***

    We can now assign a project name to AFT workspaces for better organization in Terraform Enterprise or HCP Terraform.

    ***Add support for providing customer-defined tags to AFT resources. (#466)***

    We can now assign custom tags to all AFT-managed resources for better organization and management.

    # 1.14.1

    ***Fix bug, impacting environments with variable aft_enable_vpc=false and no VPCs present, which caused Terraform plan and apply actions to fail.***

    Previously, disabling AFT-managed VPCs (aft_enable_vpc=false) without providing your own VPCs caused errors during deployment.

    AFT now handles cases where VPC creation is disabled and no VPCs are present, preventing Terraform errors during deployment.

    Ensure that when aft_enable_vpc = false and no VPCs are found, Terraform does not attempt to create resources that depend on a VPC.

    # 1.15.0

    ***Add optional KMS encryption for CloudWatch log groups and SNS topics using the AFT-created customer managed key (CMK).(#396)***

    This update adds the option to enable encryption using a customer managed key (CMK) for CloudWatch log groups and SNS topics created by AFT.

    ***Enable changing CodeBuild compute type, using variable aft_codebuild_compute_type (#474, #560)***

    We can now control the size and power of the CodeBuild environment used by AFT by setting the aft_codebuild_compute_type variable.

    ***Add new Terraform outputs for DynamoDB table, IAM role, S3 bucket name, KMS Key, Step Function, and SNS Topic ARNs (#81, #84)***

    The ARNs existed, but we had to look them up manually or reference them indirectly.

    The ARNs for key resources (DynamoDB table, IAM role, S3 bucket, KMS Key, Step Function, SNS Topic) are now directly available as outputs from the AFT Terraform module.

    ***Require SSL for connections to S3 buckets (#300)***

    ***Change DynamoDB tables to on-demand capacity mode, for more efficient utilization (#359, #497)***

    AFT’s DynamoDB tables now use on-demand capacity mode, making them easier to manage and more efficient for changing workloads.

    ***Fix error preventing deployment in regions where the SSM global infrastructure parameter is not supported (#501)***

    AFT can now be deployed in more AWS regions, including those that do not support the SSM global infrastructure parameter, by handling the absence of this parameter gracefully.

    ***Improved error handling for missing Jinja2 templates in account request and customizations pipelines (#349)***

    If a Jinja2 template is missing in AFT pipelines, we now get a clearer, more informative error message, helping you quickly identify and fix the issue.

    ***Update Lambda function dependencies***

    ***requests 2.32.4***

    ***boto3/botocore 1.39.3***

    \---

    What Changes in our Infrastructure:

    4 DynamoDB tables updated with new billing mode (Will get updated instead of recreation)

    Adds bucket policies that DENY any S3 requests that don't use HTTPS/TLS encryption in transit. Five S3 bucket policies added/updated with SSL enforcement.

    All CodeBuild projects get updated buildspecs with better Jinja2 handling

    Lambda layer updated with requests 2.32.4 and boto3 1.39.3

    # 1.15.1

    ***Bug fix: Fix an issue where enabling optional CMK encryption for CloudWatch log groups could fail due to KMS policy propagation delays***

    When we enabled customer managed key (CMK) encryption for CloudWatch log groups, the deployment could sometimes fail because the KMS key policy hadn’t fully propagated yet (a timing issue in AWS).

    This fix improves the process, so such temporary failures are handled better, reducing the chance of errors during deployment.

    ***Improved terraform plan output clarity by removing unnecessary configuration differences for DynamoDB global secondary indexes***

    Previously, the terraform plan output might have shown changes for DynamoDB global secondary indexes even when there were no real configuration differences.

    This update cleans up the plan output, so you only see meaningful changes, making it easier to review and understand what will actually change.

    Terraform will update the DynamoDB table's global secondary indexes (GSIs) named emailIndex and typeIndex. The plan shows both the removal and recreation (or update) of these indexes.

    Downtime: During the recreation, the GSIs will be unavailable for a short period. Any application logic depending on these indexes may fail or return incomplete results until the new GSIs are created and populated.

    Data Repopulation: DynamoDB will rebuild the indexes, which may take time depending on the table size.

    Global secondary index (GSI): An index with a partition key and a sort key that can be different from those on the base table. A global secondary index is considered "global" because queries on the index can span all of the data in the base table, across all partitions. A global secondary index has no size limitations and has its own provisioned throughput settings for read and write activity that are separate from those of the table.

    # 1.16.0

    ***Updated Python runtime to version 3.12***

    ***Updated urllib3 dependency to version 2.5.0***

    Python Runtime Upgrade - All 13 Lambda functions:
    python3.11 to python3.12

    Functions affected: All AFT Lambda functions in our environment

    Risk: All Lambdas update simultaneously

    Lambda Layer Replacement - Layer destroyed and recreated

    Risk: Brief period where layer is unavailable

    ***Improved Step Functions payload size limit by implementing S3 storage for large payloads to support customers with larger organizations and large number of custom fields (#298, #556)***

    Step Functions Architecture Change -
    aft-invoke-customizations-sfn
     changes execution model

    Old: Simple Map Iterator - New: Distributed Map with S3 payload storage

    Risk: May affect in-flight customizations

    Benefit: Supports larger payloads via S3 bucket  aft-customizations-pipeline-474668427263

    Security Updates - urllib3 updated to 2.5.0 (partial CVE fixes)

    \---
    What Changes in our Infrastructure:

    1. All 13 Lambda functions get new runtime and layer
    2. Lambda layer completely replaced (destroy + create)
    3. Step Functions definition completely rewritten
    4. CodeBuild projects updated to Python 3.12
    5. S3 bucket lifecycle policy added for Step Functions payloads

    # 1.16.1

    ***Remove minimum version constraint for setuptools dependency***

    We are no longer restricted to a minimum version of setuptools, making your code more flexible and compatible with a wider range of Python environments.

    The only related change is in the CodeBuild project buildspecs, where the command to install a specific minimum version of setuptools (e.g., pip install --upgrade 'setuptools>=70.0.0') is replaced with a more general upgrade command (pip install -U pip and pip install --upgrade setuptools).

    No infrastructure resources (like Lambda, DynamoDB, S3, etc.) are impacted by this change.

    This change only affects how your build environments install Python dependencies and does not impact your deployed AWS resources or their configuration.

    # 1.17.0

    ***Updated metrics for improved account tracking***

    The metrics collected by AFT have been enhanced to provide better visibility into account creation, status, and activity.

    This helps you monitor and audit account provisioning and lifecycle events more effectively.

    ***Improved deployment reliability by removing build artifacts before packaging***

    Before packaging code for deployment (e.g., Lambda functions or other artifacts), any leftover files from previous builds are now deleted.

    This prevents old or unnecessary files from being included in new deployments,

    # 1.17.1

    ***urllib3 security patch***

    Likely updates to 2.6.0+ (addresses remaining urllib3 CVEs)

    This is the penultimate security fix before 1.18.1 completes the vulnerability remediation

    # 1.18.0

    ***Add support for Azure DevOps as a VCS provider (#114)***

    We can use Azure DevOps repositories for your Terraform code and pipelines, in addition to other supported VCS providers.

    ***Update minimum HashiCorp AWS Provider version to 6.0.0 (#585)***

    This ensures compatibility with new AWS features, bug fixes, and improvements, but may require you to update your provider version if you’re using an older one.

    ***Update filelock dependency***

    This brings in bug fixes, security patches, or performance improvements for file locking operations in the codebase.

    # 1.18.1

    ***urllib3:*** Updates to a newer version, bringing security patches, bug fixes, and improved HTTP handling.

    ***virtualenv:*** Updates to a newer version, improving the creation and management of Python virtual environments.

    ***filelock:*** Updates to a newer version, providing better file locking reliability and bug fixes.

    Completes the fix for all 9 vulnerabilities we are trying to resolve

    # Note:

    The most significant operational risk is 1.16.0 due to simultaneous Lambda updates and Step Functions changes. The cost impact is 1.15.0 due to DynamoDB billing mode change.

    Release with major changes in Bread Environment

    1.13.5, 1.15.0, 1.16.0, 1.18.1

    # Release Notes

    [https://github.com/aws-ia/terraform-aws-control_tower_account_factory/releases](<https://github.com/aws-ia/terraform-aws-control_tower_account_factory/releases>)

    # Terraform Plan output

    [Terraform-plan-output-CA-1922-Executed-from-local.txt](<https://alliancedata.sharepoint.com/:t:/r/sites/CloudAgilityHome-TeamBreadPayInfrastructure/Shared%20Documents/Shared%20Documents/Terraform-plan-output-CA-1922-Executed-from-local.txt?csf=1&web=1&e=6Ygsdy>)

- Josh Castillo:

  DRAFT: AFT Lambda Vulnerability Remediation

  |   |  |  |  |
  | -- | -- | -- | -- |
  |   | * <br>  > # Overview<br>  ><br>  > This document outlines the process for upgrading AWS Account Factory for Terraform (AFT) in the Bread environment. This includes configuration changes, version updates, and vulnerability remediation.<br>  ><br>  > #  <br>  > 1. Pre-flight Activities<br>  > * Create CR (Change Request)<br>  > * Capture and review release notes<br>  > * Run a plan before any changes (Plan should show no changes)<br>  > * PR for the upgrade changes (Usual process, including reviewing the plan, approval, and merge)<br>  ><br>  >  <br>  > 1. Validate AFT Terraform State<br>  ><br>  >  <br>  ><br>  > Confirming that the existing AFT infrastructure state is intact and accessible before making any changes. Log in to the bfh-mgmt (739275453939) account and confirm that both the S3 bucket and DynamoDB table exist and are correctly configured<br>  ><br>  >  <br>  ><br>  > The AFT Terraform state file is stored in:<br>  ><br>  > • S3 Bucket: 739275453939-aftbootstrap-tfstate<br>  ><br>  > • DynamoDB Table: ddb-aftbootstrap-state<br>  ><br>  >  <br>  > 1. Prepare Terraform Configuration<br>  ><br>  >  <br>  ><br>  > Creating a local Terraform workspace that connects to the existing AFT state to make controlled updates.<br>  ><br>  >  <br>  ><br>  > | `mkdir aft-bootstrap && cd aft-bootstrap``touch main.tf` |<br>  ><br>  >  <br>  ><br>  > ## Populate main.tf (replace all {{ }} placeholders with values from our Bread environment):<br>  ><br>  >  <br>  ><br>  > | `provider "aws" {``  region = "us-east-2"``}`` ``terraform {``  backend "s3" {``    bucket         = "739275453939-aftbootstrap-tfstate"``    key            = "state/terraform.tfstate"``    region         = "us-east-2"``    dynamodb_table = "ddb-aftbootstrap-state"``  }``}`` ``module "aft_pipeline" {``  source = "github.com/aws-ia/terraform-aws-control_tower_account_factoryref=1.18.1"`` ``  # Required Variables``  ct_management_account_id                      = "739275453939"``  log_archive_account_id                        = "463470955493"``  audit_account_id                              = "825765384428"``  aft_management_account_id                     = "474668427263"``  ct_home_region                                = "us-east-2"``  tf_backend_secondary_region                   = "us-west-2"`` ``  # Terraform Settings``  terraform_version                             = "1.6.0"``  terraform_distribution                        = "oss"`` ``  # VCS Settings``  vcs_provider                                  = "github"``  account_request_repo_name                     = "Bread-Financial/aft-account-request"``  global_customizations_repo_name               = "Bread-Financial/aft-global-customizations"``  account_customizations_repo_name              = "Bread-Financial/aft-account-customizations"``  account_provisioning_customizations_repo_name = "Bread-Financial/aft-account-provisioning-customizations"`` ``  # AFT Feature Flags``  aft_feature_cloudtrail_data_events            = false``  aft_feature_enterprise_support                = false``  aft_feature_delete_default_vpcs_enabled       = true`` ``  # Additional Configurations``  aft_enable_vpc                                = false``  backup_recovery_point_retention               = 1``  log_archive_bucket_object_expiration_days     = 1``}` |<br>  ><br>  >  <br>  > 1. Update Module Source<br>  ><br>  >  <br>  ><br>  > Update the module source to match the version used during Bread’s AFT deployment:<br>  ><br>  > `source = "github.com/aws-ia/terraform-aws-control_tower_account_factory?ref=1.13.4"`<br>  ><br>  > Note: You can use the latest version, but that would update AFT more broadly. Treat that as a separate task for clarity.<br>  ><br>  >  <br>  > 1. Run Terraform Plan<br>  ><br>  > Execute:<br>  ><br>  > `terraform init`<br>  ><br>  > Connecting to the existing state and previewing changes before applying them.<br>  ><br>  > `terraform plan`<br>  ><br>  > Generating an execution plan to see exactly what will change before applying.<br>  ><br>  > ` `<br>  ><br>  > Verify that only the expected change (SSM parameter update) is shown.<br>  ><br>  > Example reference (cloudtrail data events) :<br>  ><br>  > | `#module.aft_pipeline.module.aft_ssm_parameters.aws_ssm_parameter.aft_feature_cloudtrail_data_events will be updated in-place``  ~ resource "aws_ssm_parameter" "aft_feature_cloudtrail_data_events" {``        id             = "/aft/config/feature/cloudtrail-data-events-enabled"``      + insecure_value = (known after apply)``        name           = "/aft/config/feature/cloudtrail-data-events-enabled"``        tags           = {}``      ~ value          = (sensitive value)``      ~ version        = 1 -> (known after apply)``        # (5 unchanged attributes hidden)``    }`` ``Plan: 0 to add, 1 to change, 0 to destroy.` |<br>  ><br>  >  <br>  > 1. For Version Upgrade<br>  ><br>  >  <br>  ><br>  > May show updates to Lambda functions, Step Functions, IAM roles.<br>  ><br>  > Review carefully as it should not show any resource deletions.<br>  ><br>  >  <br>  > 1. Apply changes and Validate the remediations<br>  ><br>  > Validation Checklist:<br>  > 1. Plan shows only expected changes<br>  > 2. No resources being destroyed<br>  > 3. SSM parameter updates match configuration changes<br>  > 4. No unexpected IAM or networking changes<br>  ><br>  > Issue: Plan shows resource deletions<br>  ><br>  > Cause: State drift or incorrect configuration<br>  ><br>  > Solution: DO NOT APPLY. Review configuration against existing state:<br>  ><br>  >  <br>  ><br>  > Apply the configuration:<br>  ><br>  > `terraform apply`<br>  ><br>  > Confirm that the changes were successfully applied and validate the vulnerability remediation in Wiz (It can take up to 24 hours for Wiz to rescan resources).<br>  > 1. Post-Implementation Validation<br>  > 2. Verify the CodeStar connection in CodePipeline under Developer Tools.<br>  > 3. Trigger and check the \`AwsInfrastructure-sandbox\` CodePipeline and confirm all three stages completed successfully.<br>  > 4. Review \`AwsInfrastructure-sandbox\` pipeline logs to confirm there were no new deployments in the Terraform plan.<br>  > 5. Trigger the Step Functions workflow for the \`AwsInfrastructure-sandbox\` account and verify it was functioning successfully.<br>  ><br>  >  <br>  ><br>  >  <br>  > 1. AFT Release Notes<br>  ><br>  > [Releases · aws-ia/terraform-aws-control_tower_account_factory](<https://github.com/aws-ia/terraform-aws-control_tower_account_factory/releases>)<br>  ><br>  >  <br>  ><br>  > # FAQs<br>  ><br>  >  <br>  > 1. Can I roll back if something goes wrong?<br>  ><br>  > Yes:<br>  ><br>  > 1\. Update main.tf to previous configuration<br>  ><br>  > 2\. Run \`terraform plan\` to verify rollback changes<br>  ><br>  > 3\. Run \`terraform apply\` to revert<br>  ><br>  > 4\. State is preserved in S3 with versioning enabled<br>  ><br>  >  <br>  ><br>  > When to Rollback<br>  ><br>  > \- Unexpected resource deletions occurred<br>  ><br>  > \- AFT pipeline failing for all accounts<br>  ><br>  > \- Critical functionality broken<br>  > 1. What happens if I lose connection during \`terraform apply\`?<br>  ><br>  > Terraform will:<br>  ><br>  > 1\. Hold the state lock in DynamoDB<br>  ><br>  > 2\. Partially apply changes<br>  ><br>  > 3\. You can safely re-run \`terraform apply\` to complete<br>  > 1. How do I know which version of AFT is currently deployed?<br>  ><br>  > Check the state file: aws s3 cp s3://739275453939-aftbootstrap-tfstate/state/terraform.tfstate - | grep -A 5 '"source"'<br>  > 1. How long does AFT take to process account updates?<br>  ><br>  > It takes around five minutes for Terraform to apply all changes to AFT resources.<br>  ><br>  >  <br>  > 1. References<br>  ><br>  > AFT GitHub Repository\](https://github.com/aws-ia/terraform-aws-control_tower_account_factory)<br>  ><br>  >  <br>  > 1. Terraform Plan for Upgrading the AFT version from 1.13.4 to 1.18.1<br>  ><br>  >  <br>  ><br>  > Terraform plan summary:<br>  ><br>  >  <br>  ><br>  > DynamoDB Billing Change Impact<br>  ><br>  > Before: PROVISIONED with 1 RCU/WCU on GSIs<br>  ><br>  > After: PAY_PER_REQUEST (on-demand)<br>  ><br>  > Impact: May increase costs if you have consistently high throughput<br>  ><br>  > Action: Monitor DynamoDB costs for first 30 days after upgrade<br>  ><br>  >  <br>  ><br>  > Lambda Runtime Change<br>  ><br>  > Python 3.11 - 3.12 is supported by AWS Lambda<br>  ><br>  > All Lambda code should be compatible (no breaking changes in Python 3.12 for the AFT codebase)<br>  ><br>  >  <br>  ><br>  > Timeout Increase<br>  ><br>  > aft-account-request-action-trigger timeout: 300s → 600s<br>  ><br>  > Why: Better handling of complex account provisioning scenarios<br>  ><br>  > Impact: Positive - reduces timeout errors<br>  ><br>  >  <br>  ><br>  > Step Functions Distributed Map<br>  ><br>  > Major architectural improvement for parallel processing<br>  ><br>  > Now uses S3-based item reader instead of inline iteration<br>  ><br>  > Benefit: Can process many more accounts simultaneously<br>  ><br>  > Impact: Better scalability for batch account operations<br>  ><br>  >  <br>  ><br>  > CodePipeline Trigger Removal<br>  ><br>  > The trigger block is being removed from CodePipeline resources<br>  ><br>  > Why: AWS is deprecating the old trigger configuration<br>  ><br>  > Triggers will be managed differently (likely via EventBridge)<br>  ><br>  >  <br>  ><br>  > Security Enhancements<br>  ><br>  > All S3 buckets now enforce SSL/TLS-only access<br>  ><br>  > Enhanced KMS permissions<br>  ><br>  > Impact: Positive - improved security posture<br>  ><br>  >  <br>  ><br>  > Script Error Handling<br>  ><br>  > API helper scripts now fail fast with || exit 1<br>  ><br>  > Impact: Failures will be detected sooner<br>  ><br>  >  <br>  ><br>  > Terraform Cloud Project Support<br>  ><br>  > New SSM parameter for Terraform Cloud projects<br>  ><br>  >  <br>  ><br>  > Total 44 Resources Being UPDATED:<br>  ><br>  >  <br>  ><br>  > Lambda Functions (16) - Runtime & Layer Updates<br>  ><br>  > DynamoDB Tables (4) - Billing Mode Changes<br>  ><br>  > All changing from PROVISIONED → PAY_PER_REQUEST<br>  ><br>  > CodeBuild Projects (6) - Buildspec Improvements<br>  ><br>  > All getting improved error handling, Jinja2 template checks, pip upgrades:<br>  ><br>  > CodePipeline (2) - Trigger Removal<br>  ><br>  > S3 Bucket Policies (2) - Adding SSL Enforcement<br>  ><br>  > S3 Lifecycle (1) - Adding Filter<br>  ><br>  > IAM Role Policies (4) - Enhanced Permissions<br>  ><br>  > Step Functions (1) - Distributed Map<br>  ><br>  > Lambda (1) - Runtime Update codebuild_trigger - Python 3.11 → 3.12<br>  ><br>  > SSM Parameters (7) - Value Updates<br>  ><br>  >  <br>  ><br>  > 7 Resources Being CREATED:<br>  ><br>  >  <br>  ><br>  > S3 Security Enhancements (3)<br>  ><br>  > SSM Parameters (2)<br>  ><br>  > S3 Lifecycle Management (1)<br>  ><br>  >  <br>  ><br>  > 1 Resource Being DESTROYED (and recreated):<br>  ><br>  > Lambda Layer (1 - part of replacement): aws_lambda_layer_version.layer_version - New layer version for Python 3.12 and AFT 1.18.1<br>  ><br>  > Replaced with Python 3.12 / AFT 1.18.1 version<br>  ><br>  > Layer name: aft-common-1-13-4 → aft-common-1-18-1<br>  ><br>  >  <br>  ><br>  > All changes are backward compatible with no breaking changes expected. The most significant operational impacts will be:<br>  ><br>  >  <br>  ><br>  > DynamoDB billing mode change (monitor costs)<br>  ><br>  > Lambda timeout increase (fewer timeout errors)<br>  ><br>  > Step Functions distributed map (better scalability)<br>  ><br>  >  <br>  ><br>  >  <br>  ><br>  >   |  |  |
  |   |  | Stephen's Feedback: * Let's just check in the correct config somewhere vs having it our doc<br>* Pranjal-Jain_bfh/aft-account-request -> Bread-Financial/aft-account-request<br><br> Pre-flight activities:* Create CR<br>* Capture and review release notes<br>* Run a plan before any changes<br>  * Plan should show no changes<br>* PR for the upgrade changes<br>  * Usual process, including reviewing the plan, approval, merge<br>* Get CR scheduled<br><br> Upgrade steps:* Terraform apply<br>* Test<br>* Capture SS showing success and move CR to review |
  |   |  |  |


- Josh Castillo:

  DRAFT: Remediation of Default VPCs in non-governed regions (VPC Flow Logs)

  # Background:

  Default VPCs are considered non-compliant, resulting in compliance findings within Wiz for the following reasons

  * VPC Flow Logs are not enabled
  * These VPCs are by-default provisioned by AWS in every available region and control tower has no control on this provisioning.
  * As per Bread policy, only the us-east-2 and us-west-2 regions are approved for resource deployment. Hence, the default VPCs in this region are allowed
  * Default VPCs in rest other regions are unused and no longer required.
  * To maintain compliance, these default VPCs must be removed.

  # Remediation Approach:

  The following steps are designed to ensure default VPCs are removed from all existing accounts and prevented from appearing in newly created accounts, thereby ensuring Wiz stays complaint.

  # Step 1: Automated Deletion of Default VPCs

  A shell script is added to the [pre-api-helpers.sh](<https://github.com/Bread-Financial/aft-global-customizations/blob/main/api_helpers/pre-api-helpers.sh>) file under aft-global-customizations.

  This script runs before Terraform execution and deletes default VPCs in all regions except us-east-2 and us-west-2.

  # Step 2: Apply Changes Across Accounts

  * Trigger the AFT pipeline individually or use [step functions](<onenote:#DRAFT%20Apply%20AFT%20Account%20Global%20Terraform%20at%20Scale&section-id=%7B55790A16-E049-4DBF-8585-AFBECBE32267%7D&page-id=%7B2DC9937F-88A0-414B-AF9E-79FAE16ACA91%7D&end&base-path=https://alliancedata.sharepoint.com/sites/CloudAgilityTeam/Shared%20Documents/Team%20AWS%20Infrastructure/CA%20AWS%20Infrastructure%20Notebook/AWS%20WS1/AWS%20Administrator's%20Guide.one>)  to apply the remediation.
  * This ensures that default VPCs are consistently removed and do not reappear in non‑approved regions

  # Result:

  * Default VPCs are removed from all regions except us-east-2 and us-west-2.
  * Compliance is enforced for both existing and future AWS accounts.
  * Non‑approved regions remain free of unused and non‑compliant VPC resources.

  ![](https://uploads.linear.app/4758eb12-68d3-4b70-9c38-1741cf1f08bb/0ad7baf0-bb9f-4008-91eb-2861bd097f62/2e0e95a6-2684-47b3-be13-a8c28c33a9b4)

  ![](https://uploads.linear.app/4758eb12-68d3-4b70-9c38-1741cf1f08bb/867b03bf-2b74-4cb2-a5f8-78248d1fe98b/f3340bfb-8cd5-45c1-b3b8-8682d1ffa9b5)
