# Isolated Fresh-Deployment and User-Data Verification

## Scope

This record summarizes the isolated fresh deployment used to verify that the Project 01 Terraform configuration can create its own AWS network and automatically bootstrap the EC2 web test application.

This deployment is separate from the original portfolio environment and its Terraform state. It is not evidence that an ALB, NAT Gateway, RDS database instance, or production-ready three-tier application was deployed.

**Verification date:** 2026-11-05  
**Region:** `us-east-1`  
**Instance type:** `t3.micro`  
**Terraform state key:** `project01-userdata-fresh-test/terraform.tfstate`

## Terraform deployment

The previously reviewed saved plan was applied successfully in the isolated workspace.

| Result | Value |
|---|---:|
| Resources added | 32 |
| Resources changed | 0 |
| Resources destroyed | 0 |
| Terraform apply exit status | 0 |

- VPC: `vpc-0cabca5949ea90673`
- EC2 instance: `i-00d00ff42e0b0d31a`
- AMI: Amazon Linux 2023 x86-64, `ami-0c230065b91270bc6`
- Existing instance profile: `project01-ec2-ssm-profile`

No IAM resources were part of the Terraform plan; the pre-existing EC2 instance profile was reused.

## EC2 and Systems Manager checks

Read-only AWS CLI inspection confirmed:

- EC2 instance state: `running`.
- EC2 system status check: `ok`.
- EC2 instance status check: `ok`.
- Systems Manager managed-node status: `Online`.
- The expected isolated VPC, public subnet, test-web security group, and instance profile were attached.

## Automatic user-data bootstrap

Read-only inspection through Systems Manager Run Command confirmed:

- User-data retrieved through the EC2 Instance Metadata Service: **1,517 bytes**.
- Cloud-init saved user-data copy: **1,517 bytes**.
- Cloud-init overall status: `done`.
- Cloud-init reported zero module failures.
- `/var/log/pelumi-setup.log` recorded the bootstrap steps and successful setup completion.
- The bootstrap installed Python, created the test application page and systemd unit, and enabled and started the service.

A cloud-init debug message reported that the `rightscale_userdata` module could not obtain raw user-data. The overall cloud-init run nevertheless completed with zero reported module failures, and the application checks below succeeded. This observation is retained rather than omitted.

## Application and service verification

The correct service name is `pelumi-test.service`.

Read-only inspection confirmed:

- Unit loaded.
- Unit enabled.
- Unit active/running.
- Python HTTP server listening on TCP port 80.

| Check | Result |
|---|---|
| Local HTTP request from EC2 | HTTP 200 |
| External HTTP request to the instance | HTTP 200 |
| Expected application title | `AWS Three-Tier Architecture` |
| Expected response text | `EC2 web test application is running.` |

The initial external request timed out once; a subsequent request succeeded with HTTP 200. The successful response and the instance's HTTP access log provide the final availability evidence.

## Architecture boundaries

The isolated test created the VPC, six subnets, route tables, Internet Gateway, security groups, and one EC2 test instance. It did **not** deploy:

- An Application Load Balancer.
- A NAT Gateway.
- An RDS database instance.
- Application-tier or database-tier compute workloads.

The application instance was placed in a public subnet for this test. This is a reproducibility and bootstrap test, not a claim of a complete production three-tier application.

## Cleanup of the original failed deployment

On 2026-11-06, the separately managed original failed deployment was retired using its reviewed 32-resource Terraform destroy plan. Terraform reported 0 resources added, 0 changed, and 32 destroyed; the original cleanup workspace's state now lists no managed resources.

Read-only post-cleanup checks confirmed that the shared S3 backend bucket and shared IAM instance profile and role remain in place. The fresh test instance remained running in its isolated VPC, with both EC2 system and instance status checks reporting `ok`. A read-only external HTTP request after cleanup returned HTTP 200 with the expected test application response.

This cleanup did not target the fresh test deployment.

## Evidence quality and limitations

This file is a sanitized summary of previously observed Terraform, EC2, SSM, cloud-init, systemd, and HTTP results. It is not a raw command transcript or a screenshot bundle. No credentials, SSO tokens, administrator IP address, or full user-data script are included.

The bootstrap checks and HTTP responses are point-in-time observations, not a live uptime guarantee. The original failed deployment was retired on 2026-11-06. The fresh test deployment remains separate and was confirmed running with healthy EC2 status checks after that cleanup; its HTTP endpoint was also rechecked after cleanup and returned HTTP 200.
