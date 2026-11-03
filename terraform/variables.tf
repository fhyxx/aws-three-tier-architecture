variable "aws_region" {
  description = "AWS region containing the existing project infrastructure."
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI currently used by the existing EC2 test instance. Change only as part of a planned instance replacement."
  type        = string
  default     = "ami-0ed59cbb87dfa8dba"
}

variable "admin_cidr" {
  description = "Public IPv4 CIDR allowed to reach the temporary test web server, normally your current public IP with /32."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.admin_cidr))
    error_message = "admin_cidr must be a valid IPv4 CIDR block, for example 203.0.113.10/32."
  }
}

variable "instance_profile_name" {
  description = "Existing IAM instance profile attached to the EC2 test instance."
  type        = string
  default     = "pelumi-ec2-ssm-role"
}
