# Project Evidence

These screenshots document AWS Console configuration and validation at the time they were captured. The updated images below were added directly to `main` during the screenshot review; their links point to that branch until PR #1 is merged.

| Screenshot | Evidence area |
|---|---|
| [vpc sum.png](vpc%20sum.png) | VPC overview |
| [vpc subnets.png](vpc%20subnets.png) | VPC subnet view |
| [Route table.png](Route%20table.png) | Route table configuration |
| [Igw.png](Igw.png) | Internet Gateway |
| [security group (2).png](https://github.com/fhyxx/aws-three-tier-architecture/blob/main/evidence/security%20group%20%282%29.png) | Revised security group evidence |
| [instance ed.png](https://github.com/fhyxx/aws-three-tier-architecture/blob/main/evidence/instance%20ed.png) | Revised EC2 instance evidence |
| [Screenshot (203).png](Screenshot%20(203).png) | Application/browser evidence |
| [Session manager.png](Session%20manager.png) | Session Manager / instance validation |
| [10-aws-budget-control.png](https://github.com/fhyxx/aws-three-tier-architecture/blob/main/evidence/10-aws-budget-control.png) | Updated AWS budget evidence |

## Interpretation and Limitations

- Screenshots are point-in-time evidence, not live verification of the current resource state.
- The temporary Application Load Balancer and target group were tested and subsequently deleted.
- No RDS database instance or NAT Gateway was launched. An RDS subnet group was prepared, but a screenshot of it is not currently indexed here.
- The $5 AWS Budget is an alert, not a hard spending cap.
- Screenshot contents, including account identifiers, IP addresses, and billing details, should be visually checked before public distribution.
- The original `sg.png` remains in the repository but is not linked as the preferred revised security-group evidence.
