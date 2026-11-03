# Project Evidence

These screenshots and validation records document AWS configuration and implementation checks. Screenshots are point-in-time evidence, not live verification of the current resource state.

| Evidence | Area |
|---|---|
| [vpc sum.png](vpc%20sum.png) | VPC overview |
| [vpc subnets.png](vpc%20subnets.png) | VPC subnet view |
| [Route table.png](Route%20table.png) | Route table configuration |
| [Igw.png](Igw.png) | Internet Gateway |
| [security group (2).png](security%20group%20%282%29.png) | Security group configuration |
| [instance ed.png](instance%20ed.png) | EC2 instance configuration |
| [Screenshot (203).png](Screenshot%20%28203%29.png) | Application/browser evidence |
| [Session manager.png](Session%20manager.png) | Session Manager / instance validation |
| [10-aws-budget-control.png](10-aws-budget-control.png) | AWS Budgets alert configuration |
| [Terraform validation](terraform-validation.md) | Terraform plan, EBS encryption, HTTP response, and SSM validation |

## Interpretation and Limitations

- The temporary Application Load Balancer and target group were tested and subsequently deleted.
- No RDS database instance or NAT Gateway was launched.
- An RDS subnet group was prepared, but a screenshot of it is not currently indexed here.
- The EC2 test instance is in a public subnet.
- The $5 AWS Budgets alert is not a hard spending cap.
- The Terraform and EC2 validation record describes results observed on November 2, 2026.
