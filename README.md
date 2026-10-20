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

The VPC contains public, application, and database subnets in `us-east-1a` and `us-east-1b`. Console inspection confirmed that the existing EC2 test instance is in subnet `10.0.1.0/24` in `us-east-1a`, with a default route to the Internet Gateway. It is currently in a **public subnet**, not the private application tier.

## Implementation and Validation

| Component | Status |
|---|---|
| VPC and six subnets | Configured |
| Internet Gateway and public route | Configured |
| Separate route tables by tier | Configured |
| Security groups | Configured |
| EC2 web test application | Deployed; local HTTP `200 OK` and external browser access confirmed on 2026-10-19 |
| systemd service | `pelumi-test.service` confirmed active and enabled; reboot persistence was validated previously |
| Systems Manager Session Manager | Used successfully |
| Application Load Balancer and target group | Tested successfully, then deleted |
| RDS subnet group | Created |
| RDS database instance | Not deployed |
| NAT Gateway | Not deployed |

Validation includes a local HTTP `200 OK` response, confirmation that `pelumi-test.service` is active and enabled, a listener on TCP port 80, and external browser access confirmed on 2026-10-19. These checks are point-in-time evidence, not a live uptime guarantee.

## Technical Documentation

- [Architecture design and routing](docs/architecture.md)
- [Architecture diagram](docs/architecture-diagram.md)
- [EC2 deployment guide](docs/deployment-guide.md)
- [Troubleshooting case study](docs/troubleshooting.md)
- [Evidence index and screenshots](evidence/README.md)

## Cost and Security Considerations

The configured $5 AWS Budget is an alert, **not a hard spending cap**. EC2 and EBS may continue to incur charges while resources exist. Billing data can also be delayed.

Session Manager was used for administrative access instead of relying on publicly exposed SSH. The current test instance is in a public subnet and its HTTP port 80 rule allows `0.0.0.0/0`. This is suitable only as a temporary test configuration, not a production security posture. Before production use, restrict ingress to intended sources (ideally the ALB security group when an ALB is deployed), add HTTPS, monitoring, and application hardening, and move the workload into the intended private application tier if required by the final design.

## Future Improvements

- Move the workload into the intended private application subnet tier when the required controlled ingress path is implemented.
- Deploy an ALB as the controlled public entry point only when needed and budgeted.
- Add infrastructure as code and CI/CD.
- Evaluate Auto Scaling, HTTPS, observability, and a managed database as future stages.

## Author

Pelumi Oke · AWS Cloud Engineering / Solutions Architecture
