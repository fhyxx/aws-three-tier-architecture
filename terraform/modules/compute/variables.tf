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
