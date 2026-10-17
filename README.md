
# AWS Three-Tier Architecture Project

## Project Overview

This project demonstrates the design and practical implementation of a three-tier AWS architecture, focusing on network isolation, security, application deployment, availability, and cost-conscious infrastructure decisions.

The infrastructure was configured manually using the AWS Management Console in the us-east-1 region.

## Architecture

The architecture separates resources into three logical tiers:

1. Public Tier — Public subnets, Internet Gateway, and Application Load Balancer design.
2. Application Tier — Application subnets and EC2 application deployment.
3. Database Tier — Isolated database subnets and an Amazon RDS subnet group.

The project uses two Availability Zones to demonstrate an architecture designed for high availability.

## AWS Services

- Amazon VPC
- Amazon EC2
- Elastic Load Balancing (ALB)
- AWS IAM
- AWS Systems Manager
- Amazon EBS
- Amazon RDS (subnet group preparation)
- AWS Budgets

## Implementation Status

Completed:
- Custom VPC and six subnets across two Availability Zones
- Public, application, and database route tables
- Internet Gateway and public routing
- Security group configuration
- RDS database subnet group
- EC2 web application deployment
- Systems Manager Session Manager access
- Persistent application service using systemd
- Successful ALB and target group functionality test
- Successful direct HTTP application test

Cost-control decisions:
- No NAT Gateway deployed
- No RDS database instance launched
- Temporary ALB and target group deleted after testing
- AWS Budget alert configured

## Application Validation

The deployed application was verified through:

- HTTP access using the EC2 public IPv4 address
- HTTP 200 response from localhost
- Active systemd service
- Successful application access after an EC2 reboot
- Successful Application Load Balancer test

## Project Documentation

Additional documentation will include:

- Architecture diagram
- Network configuration
- Security design
- Application deployment
- Troubleshooting notes
- Screenshots and validation evidence
- Cost optimization decisions

## Author

Pelumi Oke

AWS Cloud Engineering | Solutions Architecture
docs: initialize AWS three-tier architecture project
