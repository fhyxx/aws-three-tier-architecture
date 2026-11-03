terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Supply environment-specific bucket and region settings through backend.hcl.
  # This keeps account-specific backend configuration out of version control.
  backend "s3" {
    key          = "aws-three-tier-architecture/terraform.tfstate"
    encrypt      = true
    use_lockfile = true
  }
}
