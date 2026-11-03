# Terraform Infrastructure

This directory contains a modular Terraform configuration for the existing AWS three-tier network foundation, security groups, and EC2 web test instance.

## Requirements

- Terraform 1.10.0 or later
- AWS CLI credentials with access to the existing AWS account
- Access to the existing S3 Terraform state bucket

## Configure local files

Copy the examples and fill in the existing deployment values:

    Copy-Item backend.hcl.example backend.hcl
    Copy-Item terraform.tfvars.example terraform.tfvars

Set the bucket in backend.hcl to the existing bucket. Set ami_id, admin_cidr, and instance_profile_name in terraform.tfvars to match the current instance and security-group rule. These local files are ignored by Git.

For the original AWS CLI profile:

    aws sso login --profile portfolio
    $env:AWS_PROFILE = "portfolio"

## Initialize and validate

Run from this directory:

    terraform init -reconfigure -backend-config=backend.hcl
    terraform fmt -check -recursive
    terraform validate
    terraform plan

The backend configuration must point to the existing S3 bucket, region, and key. Reusing the same bucket and key is essential to continue managing the existing remote state.

Do not run terraform apply or terraform destroy without reviewing the complete plan and understanding its effect on the existing AWS resources.

## Module structure

- modules/network: VPC, six subnets, Internet Gateway, route tables, route, and subnet associations.
- modules/security-groups: four security groups and separately managed ingress/egress rules.
- modules/compute: existing EC2 web test instance.

The original import declarations are retained as migration history under migration/imports.tf.example.
