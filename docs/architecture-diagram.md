
# AWS Three-Tier Architecture Diagram

## Network Architecture

The diagram below represents the configured AWS network foundation in the us-east-1 region.

```mermaid
flowchart TB
    Internet["Internet"]
    IGW["Internet Gateway"]

    Internet --- IGW

    subgraph VPC["Pelumi Three-Tier VPC | 10.0.0.0/16"]
        direction TB

        subgraph AZ1["Availability Zone: us-east-1a"]
            direction TB
            PUB1["Public Subnet AZ1<br/>10.0.1.0/24"]
            APP1["Application Subnet AZ1<br/>10.0.11.0/24"]
            DB1["Database Subnet AZ1<br/>10.0.21.0/24"]
        end

        subgraph AZ2["Availability Zone: us-east-1b"]
            direction TB
            PUB2["Public Subnet AZ2<br/>10.0.2.0/24"]
            APP2["Application Subnet AZ2<br/>10.0.12.0/24"]
            DB2["Database Subnet AZ2<br/>10.0.22.0/24"]
        end
    end

    IGW --- PUB1
    IGW --- PUB2

    classDef public fill:#dcfce7,stroke:#16a34a,color:#14532d
    classDef application fill:#dbeafe,stroke:#2563eb,color:#1e3a8a
    classDef database fill:#fef3c7,stroke:#d97706,color:#78350f

    class PUB1,PUB2 public
    class APP1,APP2 application
    class DB1,DB2 database
```

## Routing Configuration

| Tier | Route Table | Internet Access |
|---|---|---|
| Public | pelumi-public-rt | Via Internet Gateway |
| Application | pelumi-private-app-rt | No direct internet route |
| Database | pelumi-isolated-db-rt | No direct internet route |

All three route tables include the VPC's local route.

## Deployment Status

| Component | Status |
|---|---|
| VPC | Configured |
| Six subnets | Configured |
| Internet Gateway | Attached |
| Route tables | Configured |
| Security groups | Configured |
| EC2 web application | Deployed and validated |
| Application Load Balancer | Successfully tested, then deleted |
| Target group | Successfully tested, then deleted |
| RDS subnet group | Created |
| RDS database instance | Not deployed |
| NAT Gateway | Not deployed |

## Application Deployment Note

The existing EC2 web application is operational.

Its exact subnet placement must be verified before including the instance in a diagram that claims deployment inside the private application tier.

The application is accessible through its public IPv4 address.

## Architecture Design Considerations

- Multi-Availability Zone subnet distribution
- Logical separation of public, application, and database tiers
- Dedicated routing per tier
- Restricted network access using security groups
- No NAT Gateway to reduce costs
- No active RDS database instance
- Temporary load balancer resources removed after validation

This diagram documents the network foundation, not a fully deployed production-ready three-tier application.
