# Terraform Import History

The existing VPC, subnets, route tables, route, subnet associations, security groups, selected security-group rules, and EC2 test instance were adopted into Terraform state during the initial migration.

The original import declarations are retained in imports.tf.example for audit history. This is the original import manifest, not a complete inventory of all resources currently in state; the active S3 state is authoritative. The manifest is intentionally outside the active Terraform root configuration. Do not copy it into the root as an active Terraform file or run it against a new state without reviewing every resource ID and confirming ownership.

The active state remains in the existing S3 backend.
