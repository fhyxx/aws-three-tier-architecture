variable "ami_id" {
  description = "AMI ID currently used by the existing EC2 test instance."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID in which the EC2 test instance runs."
  type        = string
}

variable "security_group_ids" {
  description = "Security groups attached to the EC2 test instance."
  type        = list(string)
}

variable "instance_profile_name" {
  description = "Existing IAM instance profile attached to the EC2 test instance."
  type        = string
}

variable "user_data" {
  description = "Non-empty Amazon Linux 2023 startup script for the EC2 web test instance."
  type        = string

  validation {
    condition     = length(trimspace(var.user_data)) > 0
    error_message = "user_data must contain a non-empty startup script."
  }
}
