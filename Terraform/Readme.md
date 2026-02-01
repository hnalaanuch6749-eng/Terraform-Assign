------------------------------------------------------------------------------------------------
- **Infrastructure as Code (laC) Tool**
------------------------------------------------------------------------------------------------
Here I used Terraform as IaC to provision networking, IAM, Lambda, and scheduling components
Why Terraform?
- **⁠Cloud-agnostic and widely adopted**
Terraform is not limited to AWS. The same tool and workflow can manage infrastructure across.
•⁠  ⁠AWS
•⁠  ⁠Azure
•⁠  ⁠Google Cloud
•⁠  ⁠Kubernetes
•⁠  ⁠On-prem systems (VMware, networking, etc.)
Practical Example
teams can:
•⁠  ⁠Use Terraform today for AWS
•⁠  ⁠Extend later to Azure or GCP
•⁠  ⁠Keep the same laC patterns and governance

- **Declarative syntax with state management**
declare the desired end state of infrastructure, not the step-by-step process to create it
Terraform figures out:
•⁠  ⁠What already exists
•⁠  ⁠What needs to be created
•⁠  ⁠What needs to be changed or destroyed
This is powered by the Terraform state file.
State Management Explained
Terraform maintains a state file (terraform. tfstate) that:
•⁠  ⁠Maps real AWS resources to Terraform resources
•⁠  ⁠Tracks resource IDs, attributes, and dependencies
•⁠  ⁠Enables safe updates and drift detection
Example
If a Lambda timeout changes from 60 → 120 seconds:
bash
terraform apply
Terraform updates only that attribute - nothing else.

- **⁠Built-in dependency handling**
Terraform automatically determines resource creation order based on references between resources.
we do not need to manually define dependencies in most cases.
How It Works
Terraform builds a dependency graph using:
•⁠  ⁠Resource references (aws_lambda_function role = aws_iam_role.arn)
•⁠  ⁠Implicit dependencies
•⁠  ⁠Explicit depends_on (when needed)
Why it matters
•⁠  ⁠Prevents race conditions
•⁠  ⁠Eliminates fragile scripts
•⁠  ⁠Ensures correct provisioning order

- **⁠Supports modular, reusable infrastructure**
Terraform allows to define modules, which are reusable building blocks for infr
A module is:
•⁠  ⁠Parameterized
•⁠  ⁠Versioned
•⁠  ⁠Portable
Why it matters
•⁠  ⁠Avoids copy-paste configurations
•⁠  ⁠Encourages standardization
•⁠  ⁠Improves maintainability

And reuse it across:
•⁠  ⁠Dev / Test / Prod
•⁠  ⁠Multiple AWS accounts
•⁠  ⁠Different regions

- **⁠Easy integration with C/CD pipelines**

--------------------------------------------------------------------------------------------------------------------
- **How to execute the IaC to create the infrastructure (VPC, subnet, IAM role, CloudWatch Event Rule if included)**
---------------------------------------------------------------------------------------------------------------------
I created a docker image with Terraform and AWS CLI and Federation with AWS Login with IAM Role on every jenkins pipeline run.
Here I created modules folder for re-usability and placed VPC, Lambda IAM Role & Cleanup snapshot lambda function inside it.
The deploy module have provider configuration and module code as well gather.tf to do data calls of existing resources in AWS account.
---------------------------------------------------
- **Deployment process**
---------------------------------------------------
cd deploy-modules

main.tf      -----> modules are located here
variables.tf -----> varaibles are declared here
gather.tf    -----> Data call to fetch exisiting resources from AWS account
provider.tf  -----> Terraform provider configuration
dev.tfvars   -----> tfvars to reuse the exact same codeacross different environments (Dev, QA, Prod).

Run the following commands -
terraform init - Downloads required plugins to run terraform
terraform plan --var-file="vpc.tfvars"  - It will show what resources will create, destory or change
terraform apply --var-file="vpc.tfvars"  - It will deploy the resources in AWS account.

infrastructure lifecycle.
•⁠  ⁠Authenticates to AWS
•⁠  ⁠Validates Terraform code
•⁠  ⁠Creates a plan for review
•⁠  ⁠Applies approved infrastructure changes
This ensures repeatability, security, and auditability.

These are the steps involved in deployment process
Terraform Initialization (terraform init)
Purpose
•⁠  ⁠Downloads AWS provider plugins
•⁠  ⁠Configures the backend (e.g., S3 + DynamoDB)
•⁠  ⁠Prepares the working directory
Jenkins Pipeline Stage
groovy
--------------------------
stage Terraform Init' ) {
steps 1
sh '''
terraform init \
-backend-config-"bucket-my-terraform-state-bucket" \
-backend-config-"key-snapshot-cleanup/terraform.tfstate" \
-backend-config-"region=us-east-1"
'''
}
}
Why This Matters
•⁠  ⁠Ensures remote state management
•⁠  ⁠Prevents concurrent updates
•⁠  ⁠Enables collaboration across teams
 The stage will repeate for Terraform plan and Terraform apply

 ----------------------------------------------------------------------------------------
 - **How the Lambda function is deployed**
 ----------------------------------------------------------------------------------------
The Lambda source code is stored in the lambda/ directory
•⁠  ⁠Terraform uses the archive file data source to zip the code automatically
•⁠  ⁠Any code change triggers a redeployment using source_code hash
•⁠  ⁠No manual zip or upload steps are required

Fully automated deployment
------------------------------------------------
- **Running Lambda Inside a VPC**
------------------------------------------------
Configuration
The Lambda function is configured with:
•⁠ ⁠Subnet IDs (private subnets)
• Security Group IDs
Example (Terraform):
hcl
VP_config {
subnet_ids = var. subnet ids
security_group_ids = var. security_group_ids
}

Notes
•⁠  ⁠The subnets must have NAT Gateway access for AWS API calls
•⁠  ⁠Security group allows outbound HTTPS (443) traffic
Assumptions
•⁠  ⁠Default AWS region: us-east-1
•⁠  ⁠Lambda runtime: Python 3.9
•⁠  ⁠Snapshots older than 365 days are deleted
•⁠  ⁠Lambda runs on a monthly schedule
•  AWS account owns the snapshots (OwnerIds = self)
•⁠  ⁠VPC and subnets are created in the same region as Lambda

-------------------------------------------------------------------------------------------------------
- **How you would monitor the Lambda function's execution (e.g., CloudWatch Logs, CloudWatch Metrics)**
-------------------------------------------------------------------------------------------------------
Each execution of the Lambda function generates structured log entries that capture:
•⁠  ⁠Snapshots evaluated
•⁠  ⁠Total snapshots scanned in the account/region
•⁠  ⁠Snapshots deleted
•⁠  ⁠Snapshot IDs successfully deleted
•⁠  ⁠Errors
•⁠  ⁠API failures (e.g., permission issues, dependency violations)
•⁠  ⁠Partial failures during snapshot deletion
How Logging Works
•⁠  ⁠AWS Lambda automatically streams logs to CloudWatch Logs
•⁠  ⁠A log group is created per Lambda function
•⁠  ⁠Each execution creates a new log stream
Log Group
plaintext
/aws/lambda/snapshot-cleanup

Example Log Entries
plaintext
- INFO Deleting snapshot: snap-0abc123456
- INFO Deleted 5 snapshots
- ERROR Failed to delete snapshot snap-0def456: DependencyViolation
Why This Matters
•⁠  ⁠Enables post-execution troubleshooting
•⁠  ⁠Provides audit trail for snapshot deletion Supports compliance and operational reviews
•⁠  ⁠Allows quick identification of failed executions


End-to-End Observability Flow
EventBridge Schedule
       ↓
Lambda Execution
       ↓
Cloudwatch 
       ↓
Cloudwatch Metrics
       ↓
Cloudwatch Alarms
       ↓
SNS
       ↓
Email / Slack / PagerDuty


----------------------------------------------------------------------------------------
Architecture Diagram 
----------------------------------------------------------------------------------------
+----------------------------------------------------------+
|                                                          |
|                   EventBridge Rule                       |
|                   (Monthly Schedule)                     |
|                                                          |
+--------------------------+-------------------------------+
                           |
                           |
                           ⬇️
+----------------------------------------------------------+
|                                                          |
|                   AWS Lambda                             |
|               Snapshot Cleanup function                  |
|----------------------------------------------------------|
| - Python Runtime                                         |
| - Deletes Old snapshots                                  |
| - Logs to CloudWatch                                     |                      
+--------------------------+-------------------------------+
                           |
                           |
                           ⬇️
+----------------------------------------------------------+
|                                                          |
|                   AWS EC2 API                            |
|                   Describe/ Delete Snapshot              |
|                                                          |
+--------------------------+-------------------------------+
                           |
                           |
                           ⬇️
+----------------------------------------------------------+
|                                                          |
|                   CloudWatch                             |
|- Logs                                                    |
| - Metrics                                                |
|                                                          |
+--------------------------+-------------------------------+
