# AWS Three-Tier Network and Application Foundation

A cost-conscious AWS networking and application deployment portfolio project demonstrating VPC design, subnet segmentation, security group controls, EC2 operations, infrastructure-as-code practices, remote state management, and storage encryption.

**Region:** `us-east-1` (N. Virginia)

> **Scope:** This repository documents a configured three-tier network foundation and a working EC2 web test application. It is not a fully deployed, production-ready, highly available three-tier application. The temporary Application Load Balancer was tested and deleted. No NAT Gateway or RDS database instance was provisioned.

## Project at a Glance

- **Network:** Custom VPC (`10.0.0.0/16`) with six subnets across two Availability Zones.
- **Routing:** Internet Gateway and public routing, with separate local-only route tables for application and database subnets.
- **Application:** Amazon Linux 2023 EC2 instance running a lightweight Python HTTP server managed by systemd. The independent deployment configuration bootstraps the test application through EC2 user-data on first boot.
- **Infrastructure as Code:** Modular Terraform configuration for the existing network, security groups, and EC2 instance.
- **State management:** Amazon S3 remote state with versioning, server-side encryption, public access blocked, and native S3 lockfile support.
- **Storage security:** Encrypted gp3 EC2 root EBS volume.
- **Operations:** AWS Systems Manager Session Manager for instance administration and read-only bootstrap inspection.
- **Cost control:** No NAT Gateway or persistent ALB; AWS Budgets alert configured.

## Architecture

- [Architecture design and routing](docs/architecture.md)
- [Architecture diagram](docs/architecture-diagram.md)
- [Terraform operations and state design](docs/terraform-operations.md)
- [Terraform source and setup instructions](terraform/README.md)

The VPC contains public, application, and database subnets in `us-east-1a` and `us-east-1b`. The EC2 test instance currently runs in public subnet `10.0.1.0/24` in `us-east-1a`. It is not deployed in the private application tier.

## Infrastructure as Code and State Management

The existing AWS resources were adopted into a modular Terraform configuration organized around networking, security groups, and compute. Module inputs use Terraform outputs and variables rather than embedding VPC, subnet, and security-group IDs throughout the configuration.

The remote state backend for the existing deployment uses the S3 bucket and key configured locally through the ignored `terraform/backend.hcl` file. The backend uses encryption and native S3 state locking with `use_lockfile = true`. Do not commit backend configuration, variable files, state, credentials, or plan files.

**New users must not point Terraform at the existing deployment's state.** The [Independent Fresh-Account Deployment Guide](docs/independent-deployment-guide.md) explains how to create a separate S3 backend, configure credentials and IAM prerequisites in your own AWS account, validate and plan a fresh deployment, and verify automatic EC2 user-data bootstrap. The two workflows are intentionally separate.

The original import declarations are retained as migration history under `terraform/migration/imports.tf.example`; they are not active Terraform configuration.

## Implementation and Validation

| Component | Status |
|---|---|
| VPC and six subnets | Configured |
| Internet Gateway and public route | Configured |
| Separate route tables by tier | Configured |
| Security groups | Configured |
| Original EC2 web test application | Deployed; HTTP `200 OK` verified on 2026-11-02 |
| Independent EC2 user-data bootstrap | Fresh isolated deployment; cloud-init completed, systemd service active, local and external HTTP `200 OK` verified on 2026-11-05 |
| systemd service | Previously confirmed active and enabled on the original instance; reboot persistence validated |
| Systems Manager | Original instance reported `Online` on 2026-11-02; isolated test instance reported `Online` on 2026-11-05 |
| EC2 root EBS volume | Encrypted gp3 replacement volume; in use |
| Terraform refactor | `fmt -check`, `validate`, 32-resource state inventory, and zero-change plan completed on 2026-11-03 |
| Application Load Balancer and target group | Tested successfully, then deleted |
| RDS subnet group | Created in the original environment |
| RDS database instance | Not deployed |
| NAT Gateway | Not deployed |

The November 2 and 3 checks are point-in-time evidence, not a live uptime guarantee. On November 3, 2026, the modular Terraform refactor passed formatting, validation, a 32-resource state inventory check, and a plan against the existing S3 backend with no infrastructure or state changes. On November 5, a separate isolated fresh deployment created 32 resources and verified automatic EC2 user-data bootstrap and HTTP 200. See [Terraform and EC2 validation evidence](evidence/terraform-validation.md) and [isolated fresh user-data test evidence](evidence/project01-userdata-fresh-test.md).

## Technical Documentation

- [Architecture design and routing](docs/architecture.md)
- [Architecture diagram](docs/architecture-diagram.md)
- [EC2 deployment guide for the original environment](docs/deployment-guide.md)
- [Independent fresh-account deployment guide](docs/independent-deployment-guide.md)
- [Troubleshooting case study](docs/troubleshooting.md)
- [Terraform operations and remote state](docs/terraform-operations.md)
- [Evidence index and screenshots](evidence/README.md)
- [Terraform and original EC2 validation record](evidence/terraform-validation.md)
- [Isolated fresh user-data bootstrap verification](evidence/project01-userdata-fresh-test.md)

## Cost and Security Considerations

The configured $5 AWS Budgets alert is **not a hard spending cap**. EC2 and EBS may continue to incur charges while resources exist, and billing data can be delayed.

The EC2 root volume is encrypted and the instance requires IMDSv2. Session Manager is used for administrative access rather than relying on publicly exposed SSH. The original test instance remains in a public subnet and its HTTP port 80 rule allows the configured administrator CIDR; this is a temporary test configuration, not a production security posture. The isolated fresh test also used a public subnet and restricted direct HTTP ingress to the administrator CIDR.

Before production use, move the workload into the intended private application tier, establish controlled ingress, add HTTPS, monitoring, and application hardening.

## Potential Production Enhancements

The following are possible extensions to the current portfolio foundation, not claims about features already deployed:

- **Private application tier:** Move the EC2 workload from the public subnet into the private application subnets and design controlled ingress and outbound connectivity appropriate to the workload.
- **Managed ingress:** Reintroduce an Application Load Balancer when a public entry point is required and the associated cost is justified.
- **Container delivery:** Containerized CI/CD and an ECS/Fargate deployment are demonstrated separately in [Project 02 — Containerized CI/CD](https://github.com/fhyxx/pelumi-containerized-cicd). They are not part of this project's current deployment.
- **Additional production capabilities:** Evaluate Auto Scaling, HTTPS with AWS Certificate Manager, observability, and a managed database according to application requirements.

## Author

Pelumi Oke · AWS Cloud Engineering / Solutions Architecture
