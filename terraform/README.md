# Terraform Infrastructure

This directory contains the Terraform configuration for the existing AWS three-tier network foundation, security groups, and EC2 web test instance.

## Requirements

- Terraform 1.10.0 or later
- AWS CLI configured with access to the existing project account
- Access to the existing S3 state bucket
- The AWS region and state bucket used by the original deployment

## Local configuration

1. Copy `backend.hcl.example` to `backend.hcl` and set the existing state bucket name.
2. Copy `terraform.tfvars.example` to `terraform.tfvars` and set your current public IPv4 CIDR (normally `x.x.x.x/32`).
3. Authenticate using the AWS CLI profile or credential chain available in your environment. For the original setup:

```powershell
aws sso login --profile portfolio
$env:AWS_PROFILE = "portfolio"
```

## Initialize and validate

Run from this directory:

```powershell
terraform init -reconfigure -backend-config=backend.hcl
terraform fmt -check -recursive
terraform validate
terraform plan
```

The backend file must point to the existing S3 bucket and the configured key in `versions.tf`. Reusing the same bucket, key, and region is essential to continue managing the existing remote state.

**Do not run `terraform apply` or `terraform destroy` without reviewing the complete plan and understanding its effect on the existing AWS resources.**

## Module structure

- `modules/network`: VPC, subnets, Internet Gateway, route tables, routes, and associations.
- `modules/security-groups`: security groups and separately managed ingress/egress rules.
- `modules/compute`: existing EC2 web test instance.

The original one-time import declarations are retained under `migration/imports.tf.example` as migration history. They are not loaded as active root configuration.
