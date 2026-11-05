# Terraform Infrastructure

This directory contains the modular Terraform configuration for the VPC foundation, security groups, and EC2 web test instance.

There are **two separate operating paths**. Choose the correct one before initializing Terraform.

## Path A — Manage the existing portfolio deployment

Use this path only when you are the owner/operator of the existing AWS environment and have access to its S3 state bucket.

### Requirements

- Terraform 1.10.0 or later
- AWS CLI credentials for the existing AWS account
- Access to the existing S3 Terraform state bucket and its lockfile
- The existing EC2 AMI ID, administrator CIDR, and IAM instance profile name

Copy the examples:

    Copy-Item backend.hcl.example backend.hcl
    Copy-Item terraform.tfvars.example terraform.tfvars

Edit the local files with the **existing deployment's** values. The files are ignored by Git.

For the existing AWS CLI profile:

    aws sso login --profile portfolio
    $env:AWS_PROFILE = "portfolio"

Initialize and validate from this directory:

    terraform init -reconfigure -backend-config=backend.hcl
    terraform fmt -check -recursive
    terraform validate
    terraform plan

The backend must point to the original S3 bucket, region, and key. Reusing the same bucket and key is essential to manage the existing remote state. Never use this path with another person's credentials or a newly created, unrelated state bucket.

Do not run `terraform apply` or `terraform destroy` against the existing deployment without an explicit change plan, authorization, and recovery plan.

## Path B — Reproduce the project in your own AWS account

If you are a new user or reviewer, **do not use the existing portfolio backend**. Clone the repository, configure your own AWS CLI profile, create a separate S3 state bucket, create the EC2 Systems Manager role/profile, and populate fresh-account variables.

Follow the complete [Independent Fresh-Account Deployment Guide](../docs/independent-deployment-guide.md). It includes credential setup, remote-state bucket configuration, IAM prerequisites, AMI lookup, validation and planning, deployment, **automatic EC2 user-data bootstrap verification**, cost cautions, and cleanup boundaries.

The EC2 user-data script installs Python, creates the lightweight test page and systemd unit, and enables/starts `pelumi-test.service` during first boot. For the bootstrap test, use Systems Manager only to inspect user-data delivery, cloud-init, setup logs, service health, and HTTP response. Do not manually install or repair the application before recording the first-boot result.

The fresh-account guide uses a separate state bucket and does not require access to the repository owner's AWS account or state. The verified November 5, 2026 isolated deployment and bootstrap results are summarized in [fresh user-data test evidence](../evidence/project01-userdata-fresh-test.md).

## Module structure

- `modules/network`: VPC, six subnets, Internet Gateway, route tables, routes, and subnet associations.
- `modules/security-groups`: four security groups and separately managed ingress/egress rules.
- `modules/compute`: EC2 web test instance and first-boot user-data bootstrap.

The original import declarations are retained as migration history under `migration/imports.tf.example`; they are not active Terraform configuration.

## Safety note

The modules include `lifecycle { prevent_destroy = true }` guards to protect the existing portfolio infrastructure. The compute module also ignores subsequent changes to `user_data` with `ignore_changes = [user_data]`. Initial instance creation still receives the configured user-data script, but later edits to that script will not be applied automatically by Terraform or trigger instance replacement.

A destroy plan from an untouched clone will be blocked for protected resources. The independent guide explains how to remove those guards **only in a disposable copy and only after confirming that its backend and AWS profile belong to the new user's account**. Do not remove them from the owner's live configuration.
