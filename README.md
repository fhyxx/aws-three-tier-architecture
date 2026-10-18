# AWS Three-Tier Architecture on AWS

A cost-conscious AWS networking and application deployment portfolio project built with the AWS Management Console in **us-east-1 (N. Virginia)**.

> **Scope note:** This repository documents a configured three-tier network foundation and a working EC2 web test application. It is not a fully deployed, production-ready, highly available three-tier application. The temporary Application Load Balancer was tested and then deleted; no NAT Gateway or RDS database instance was launched.

## Project at a Glance

- **Network:** Custom VPC `10.0.0.0/16`, six subnets across two Availability Zones.
- **Routing:** Internet Gateway and public routing, with separate local-only route tables for application and database subnets.
- **Application:** Amazon Linux 2023 EC2 instance running a lightweight Python HTTP server managed by systemd.
- **Operations:** AWS Systems Manager Session Manager used for administration and validation.
- **Database preparation:** RDS subnet group created; no database instance provisioned.
- **Cost control:** No NAT Gateway; temporary ALB and target group deleted after testing; AWS Budget alert configured.

## Architecture

[Open the architecture diagram](docs/architecture-diagram.md) · [Read the architecture documentation](docs/architecture.md)

The VPC contains public, application, and database subnets in `us-east-1a` and `us-east-1b`. The EC2 instance's actual subnet should be checked against the console evidence before describing it as deployed in the private application tier.

## Implementation and Validation

| Component | Status |
|---|---|
| VPC and six subnets | Configured |
| Internet Gateway and public route | Configured |
| Separate route tables by tier | Configured |
| Security groups | Configured; review current rules before production use |
| EC2 web test application | Deployed and validated |
| systemd service | Active; tested after reboot |
| Systems Manager Session Manager | Used successfully |
| Application Load Balancer and target group | Tested successfully, then deleted |
| RDS subnet group | Created |
| RDS database instance | Not deployed |
| NAT Gateway | Not deployed |

Validation included a local HTTP `200 OK` response, confirmation that the service was active and listening on TCP port 80, and successful browser access to the web page.

## Technical Documentation

- [Architecture design and routing](docs/architecture.md)
- [Architecture diagram](docs/architecture-diagram.md)
- [EC2 deployment guide](docs/deployment-guide.md)
- [Troubleshooting case study](docs/troubleshooting.md)
- [Evidence index and screenshots](evidence/README.md)

## Cost and Security Considerations

The configured $5 AWS Budget is an alert, **not a hard spending cap**. EC2 and EBS may continue to incur charges while resources exist. Billing data can also be delayed.

Session Manager was used for administrative access instead of relying on publicly exposed SSH. Before production use, review security group rules, verify the EC2 subnet and route table, restrict ingress to intended sources, and add appropriate HTTPS, monitoring, and application hardening.

## Future Improvements

- Verify and document the EC2 subnet placement; move the workload into private application subnets if that is the intended target design.
- Deploy an ALB as the controlled public entry point only when needed and budgeted.
- Add infrastructure as code and CI/CD.
- Evaluate Auto Scaling, HTTPS, observability, and a managed database as future stages.

## Author

Pelumi Oke · AWS Cloud Engineering / Solutions Architecture
