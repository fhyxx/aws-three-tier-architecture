
# AWS Three-Tier Architecture

**Region:** us-east-1 (N. Virginia)

```mermaid id="p4n8s2"
flowchart TB
    Internet["Internet"]
    IGW["Internet Gateway"]
    VPC["Pelumi VPC<br/>10.0.0.0/16"]

    Internet --> IGW
    IGW --> VPC

    VPC --> PUB1["Public Subnet AZ1<br/>10.0.1.0/24"]
    VPC --> PUB2["Public Subnet AZ2<br/>10.0.2.0/24"]

    VPC --> APP1["Application Subnet AZ1<br/>10.0.11.0/24"]
    VPC --> APP2["Application Subnet AZ2<br/>10.0.12.0/24"]

    VPC --> DB1["Database Subnet AZ1<br/>10.0.21.0/24"]
    VPC --> DB2["Database Subnet AZ2<br/>10.0.22.0/24"]
```

## Network Design

- One VPC with CIDR 10.0.0.0/16
- Six subnets across two Availability Zones
- Public subnets have routes to the Internet Gateway
- Application subnets use local-only routing
- Database subnets use local-only routing
- No NAT Gateway was deployed

## Deployment Status

- EC2 web application: deployed and tested
- Application Load Balancer: tested, then deleted
- RDS subnet group: created
- RDS database instance: not launched
