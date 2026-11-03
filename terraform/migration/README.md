# Terraform Import History

The original AWS network, security groups, individual security-group rules, and EC2 test instance were imported into the Terraform state during the initial adoption of this infrastructure.

The original import declarations are retained in `imports.tf.example` for audit history. They are intentionally outside the active Terraform root configuration so normal plans do not attempt to perform a fresh import.

The active state is stored in the existing S3 backend. Do not use the archived import manifest against a new or empty state without first reviewing every resource ID and confirming ownership.
