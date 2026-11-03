# Terraform Import History

The existing VPC, subnets, route tables, route, subnet associations, security groups, security-group rules, and EC2 test instance were adopted into Terraform state during the initial migration.

The original import declarations are retained in imports.tf.example for audit history. They are intentionally outside the active Terraform root configuration. Do not copy this file into the root as an active Terraform file or run it against a new state without reviewing every resource ID and confirming ownership.

The active state remains in the existing S3 backend.
