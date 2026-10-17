
# AWS Three-Tier Architecture

**Region:** us-east-1 (N. Virginia)

```mermaid id="az3tier"
flowchart TB
    Internet["Internet"]
    IGW["Internet Gateway"]

    Internet --> IGW

    subgraph VPC["Pelumi VPC - 10.0.0.0/16"]
        direction TB

        subgraph AZ1["Availability Zone us-east-1a"]
            direction LR
            PUB1["Public Subnet<br/>10.0.1.0/24"]
            APP1["Application Subnet<br/>10.0.11.0/24"]
            DB1["Database Subnet<br/>10.0.21.0/24"]
            PUB1 ~~~ APP1
            APP1 ~~~ DB1
        end

        subgraph AZ2["Availability Zone us-east-1b"]
            direction LR
            PUB2["Public Subnet<br/>10.0.2.0/24"]
            APP2["Application Subnet<br/>10.0.12.0/24"]
            DB2["Database Subnet<br/>10.0.22.0/24"]
            PUB2 ~~~ APP2
            APP2 ~~~ DB2
        end
    end

    IGW --> PUB1
    IGW --> PUB2

    classDef public fill:#dcfce7,stroke:#16a34a,color:#14532d
    classDef application fill:#dbeafe,stroke:#2563eb,color:#1e3a8a
    classDef database fill:#fef3c7,stroke:#d97706,color:#78350f

    class PUB1,PUB2 public
    class APP1,APP2 application
    class DB1,DB2 database
```

## Routing Design

| Tier | Route table | Routing |
|---|---|---|
| Public | `pelumi-public-rt` | Local route and Internet Gateway default route |
| Application | `pelumi-private-app-rt` | Local route only |
| Database | `pelumi-isolated-db-rt` | Local route only |

## Implementation Status

- VPC and six subnets: configured
- Internet Gateway: attached
- Security groups: configured
- EC2 web application: deployed and validated
- Application Load Balancer: tested, then deleted
- RDS subnet group: created
- RDS database instance: not deployed
- NAT Gateway: not deployed

**Note:** The subnet grouping shows the intended network design. The EC2 instance's actual subnet placement must be verified before describing it as deployed in the private application tier.
