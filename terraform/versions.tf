terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Bucket, region, and profile are supplied through the ignored backend.hcl.
  backend "s3" {
    key          = "aws-three-tier-architecture/terraform.tfstate"
    encrypt      = true
    use_lockfile = true
  }
}
