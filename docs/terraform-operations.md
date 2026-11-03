# Terraform Operations and State Management

## Purpose

The AWS three-tier network foundation, security groups, and EC2 test instance were adopted into a modular Terraform configuration and reconciled with the existing AWS environment.

The active Terraform source is maintained in the terraform directory. The original one-time import manifest is retained separately under terraform/migration/imports.tf.example and is not loaded as active configuration.

## Managed Infrastructure

The configuration is organized into three modules:

| Module | Responsibility |
|---|---|
| network | VPC, six subnets, Internet Gateway, route tables, routes, and subnet associations |
| security-groups | Four security groups and separately managed ingress/egress rules |
| compute | Existing EC2 web test instance |

The project uses AWS region us-east-1. AWS credentials are supplied through the AWS CLI credential chain or AWS_PROFILE environment variable.

## Remote State Backend

Terraform state remains in the existing S3 backend. Backend-specific values are supplied through the ignored local file terraform/backend.hcl. The active backend key is aws-three-tier-architecture/terraform.tfstate.

The S3 bucket was configured with versioning, server-side encryption, public access blocking, and native S3 lockfile locking. The state was migrated from the local backend to S3. A local pre-migration state backup was retained outside the repository.

Never commit state files, backend.hcl, terraform.tfvars, credentials, or generated plan files.

## EBS Root Volume Encryption Migration

The original EC2 root volume was unencrypted. A recovery snapshot was created before replacing the root volume with an encrypted gp3 volume.

The replacement task completed successfully on November 2, 2026. The replacement volume was confirmed encrypted and in use. The previous root volume was retained during the operation to preserve a rollback option.

The EC2 instance remained running with its original public and private IP addresses. System and instance status checks passed after the migration.

## Baseline Validation

The pre-refactor configuration passed formatting, validation, and a no-change plan against the existing S3 state on November 3, 2026. The refactored source must be revalidated against that same state before merge.

See the detailed historical validation record in evidence/terraform-validation.md.

## Local Setup

From the terraform directory:

1. Copy backend.hcl.example to backend.hcl and set the existing S3 bucket name.
2. Copy terraform.tfvars.example to terraform.tfvars and enter the existing instance AMI ID, current administrator CIDR, and IAM instance profile name.
3. Authenticate with the AWS CLI profile used by the existing deployment.
4. Initialize the existing backend and validate the configuration.

Example PowerShell commands:

    aws sso login --profile portfolio
    $env:AWS_PROFILE = "portfolio"
    terraform init -reconfigure -backend-config=backend.hcl
    terraform fmt -check -recursive
    terraform validate
    terraform plan

The backend file must point to the same existing S3 bucket, region, and state key. Do not initialize against a new bucket or key when intending to manage the existing infrastructure.

Do not run terraform apply or terraform destroy without reviewing the complete plan and understanding its effect on existing infrastructure.

## Current Deployment Limitations

- The EC2 test instance is in a public subnet, not the private application tier.
- No NAT Gateway is deployed.
- The temporary ALB and target group were deleted after testing.
- An RDS subnet group exists, but no RDS database instance was launched.
- The $5 AWS Budget is an alert, not a hard spending cap.
