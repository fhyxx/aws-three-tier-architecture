# Terraform Operations and State Management

## Purpose

The AWS three-tier network foundation, security groups, and EC2 test instance were imported into a modular Terraform configuration and reconciled with the existing AWS environment.

The Terraform configuration is currently maintained in the local working copy. The source directory has not yet been published in this repository, so this document describes the implemented operating model and verified state backend rather than providing a clone-and-run Terraform package.

## Managed Infrastructure

The configuration is organized into three modules:

| Module | Responsibility |
|---|---|
| `network` | VPC, six subnets, Internet Gateway, route tables, routes, and subnet associations |
| `security-groups` | Four security groups and separately managed ingress/egress rules |
| `compute` | Existing EC2 web test instance |

The project uses AWS region `us-east-1` and the AWS CLI profile `portfolio`.

## Remote State Backend

Terraform state is stored in:

| Setting | Value |
|---|---|
| Backend | Amazon S3 |
| Bucket | `pelumi-terraform-state-008151431773-2026` |
| Key | `aws-three-tier-architecture/terraform.tfstate` |
| Region | `us-east-1` |
| Encryption | AES-256 server-side encryption |
| Versioning | Enabled |
| Public access | Blocked |
| Locking | Native S3 lockfile (`use_lockfile = true`) |

The state was migrated from the local backend to S3. A local pre-migration state backup was retained outside the repository. State files and credentials must never be committed.

## EBS Root Volume Encryption Migration

The original EC2 root volume was unencrypted. A recovery snapshot was created before replacing the root volume with an encrypted gp3 volume.

The replacement task completed successfully on November 2, 2026. The replacement volume was confirmed encrypted and in use. The previous root volume was retained during the operation to preserve a rollback option.

The EC2 instance remained running with its original public and private IP addresses. System and instance status checks passed after the migration.

## Post-Migration Validation

The following checks passed on November 2, 2026:

- `terraform fmt`
- `terraform validate`
- `terraform plan` — no changes; real infrastructure matched configuration
- EC2 system status — `ok`
- EC2 instance status — `ok`
- HTTP response — `200 OK`
- Systems Manager — `Online`

See [the detailed validation record](../evidence/terraform-validation.md).

## Safe Operating Workflow

Once the Terraform source is published with its backend configuration:

1. Authenticate with the intended AWS profile.
2. Initialize the backend.
3. Format and validate the configuration.
4. Review the complete plan before applying.
5. Apply only changes that are understood and intentionally approved.
6. Keep state, credentials, variable files containing secrets, and generated plan files out of Git.

Example commands from the Terraform root directory:

```powershell
aws sso login --profile portfolio
terraform init
terraform fmt -recursive
terraform validate
terraform plan
```

Do not run `terraform destroy` against this environment without reviewing resource dependencies and the impact on existing infrastructure.

## Current Deployment Limitations

- The EC2 test instance is in a public subnet, not the private application tier.
- No NAT Gateway is deployed.
- The temporary ALB and target group were deleted after testing.
- An RDS subnet group exists, but no RDS database instance was launched.
- The $5 AWS Budget is an alert, not a hard spending cap.
