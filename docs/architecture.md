# AWS Three-Tier Architecture Documentation

## 1. Project Objective

Design and implement a secure, cost-conscious AWS architecture using a three-tier network model.

The project demonstrates practical knowledge of:

- Amazon VPC design
- Public and private subnet segmentation
- Multi-Availability Zone architecture
- Route table configuration
- Security group management
- EC2 application deployment
- Application Load Balancer testing
- IAM and Systems Manager
- Infrastructure cost optimization

Region: us-east-1 (N. Virginia)

Deployment method: AWS Management Console

## 2. Architecture Overview

The architecture uses three logical tiers:

### Tier 1: Public / Presentation

Designed to provide controlled internet-facing access.

Components:

- Two public subnets
- Internet Gateway
- Public route table
- Application Load Balancer (tested, then deleted)

### Tier 2: Application

Designed to host application workloads separately from the public-facing infrastructure.

Components:

- Two application subnets
- Dedicated application route table
- Application security group

A working EC2 web application was deployed and validated. Its exact subnet placement will be confirmed separately before representing it as a private-tier deployment.

### Tier 3: Database

Designed to isolate database resources from direct internet access.

Components:

- Two database subnets
- Dedicated database route table
- Database security group
- Amazon RDS database subnet group

No RDS database instance was launched to avoid unnecessary charges.

## 3. VPC Configuration

VPC Name: Pelumi-3tier-vpc

CIDR Block: 10.0.0.0/16

Availability Zones:

- us-east-1a
- us-east-1b

The VPC contains six subnets distributed across two Availability Zones.

## 4. Subnet Design

| Subnet | CIDR Block | Availability Zone | Tier |
|---|---|---|---|
| public-subnet-az1 | 10.0.1.0/24 | us-east-1a | Public |
| public-subnet-az2 | 10.0.2.0/24 | us-east-1b | Public |
| app-subnet-az1 | 10.0.11.0/24 | us-east-1a | Application |
| app-subnet-az2 | 10.0.12.0/24 | us-east-1b | Application |
| db-subnet-az1 | 10.0.21.0/24 | us-east-1a | Database |
| db-subnet-az2 | 10.0.22.0/24 | us-east-1b | Database |

This subnet design provides logical separation between internet-facing, application, and database infrastructure.

## 5. Routing Architecture

### Public Route Table

Name: pelumi-public-rt

Routes:

- 10.0.0.0/16 → Local
- 0.0.0.0/0 → Internet Gateway

Associated with both public subnets.

### Application Route Table

Name: pelumi-private-app-rt

Route:

- 10.0.0.0/16 → Local

Associated with both application subnets.

### Database Route Table

Name: pelumi-isolated-db-rt

Route:

- 10.0.0.0/16 → Local

Associated with both database subnets.

No NAT Gateway was deployed.

This decision reduced infrastructure costs while maintaining private subnet isolation.

## 6. Security Architecture

Separate security groups were created for the load balancer, application, and database components.

The design follows a layered security model in which access between tiers is restricted according to application requirements.

A separate test web security group was used for the deployed EC2 application.

AWS Systems Manager Session Manager provided administrative access without requiring a publicly exposed SSH port.

## 7. Application Deployment

A lightweight Python HTTP application was deployed on an existing Amazon Linux 2023 EC2 instance.

Application directory:

/opt/pelumi-test

Service name:

pelumi-test.service

The application uses systemd to start automatically and recover from service failures.

Validation included:

- Successful HTTP 200 response
- Active systemd service
- Listening on TCP port 80
- Successful application access after reboot
- Successful direct browser access

## 8. Load Balancer Testing

An Application Load Balancer and target group were temporarily deployed to validate HTTP routing to the EC2 application.

The target initially reported an unhealthy status.

Application availability, service status, network access, and security group configuration were investigated.

The target subsequently became healthy, and the application was successfully accessed using the ALB DNS endpoint.

After validation, the temporary ALB and target group were deleted to prevent unnecessary ongoing charges.

The EC2 instance and its attached EBS volume were preserved.

## 9. Database Preparation

An Amazon RDS subnet group was created.

Name:

pelumi-db-subnet-group

Subnets:

- db-subnet-az1
- db-subnet-az2

These subnets are distributed across two Availability Zones.

A database instance has not been provisioned.

## 10. Cost Optimization

Cost-control measures included:

- AWS Budget alert configured at $5
- No NAT Gateway
- No running RDS database instance
- Temporary ALB deleted after testing
- Reuse of the existing EC2 instance
- Monitoring AWS billing and usage

AWS Budgets provides alerts and does not automatically impose a hard spending limit.

## 11. Project Status

This project demonstrates a configured three-tier network foundation, a working EC2 application, successful temporary ALB integration, and database infrastructure preparation.

It is not represented as a fully deployed, production-ready, highly available three-tier application.

Future improvements may include:

- Private application-tier deployment
- Auto Scaling
- Managed database deployment
- HTTPS using AWS Certificate Manager
- Infrastructure as Code
- Automated CI/CD
- Enhanced monitoring and observability
docs: add AWS architecture documentation
