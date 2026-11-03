variable "vpc_id" {
  description = "ID of the VPC in which the security groups are created."
  type        = string
}

variable "admin_cidr" {
  description = "IPv4 CIDR allowed to reach the temporary test web server."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.admin_cidr))
    error_message = "admin_cidr must be a valid IPv4 CIDR block."
  }
}
