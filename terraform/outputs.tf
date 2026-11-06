output "vpc_id" {
  description = "ID of the three-tier VPC."
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = module.network.public_subnet_ids
}

output "application_subnet_ids" {
  description = "IDs of the application subnets."
  value       = module.network.application_subnet_ids
}

output "database_subnet_ids" {
  description = "IDs of the database subnets."
  value       = module.network.database_subnet_ids
}

output "instance_id" {
  description = "ID of the EC2 web test instance."
  value       = module.compute.instance_id
}

output "instance_public_ip" {
  description = "Public IPv4 address of the EC2 web test instance."
  value       = module.compute.instance_public_ip
}

output "instance_private_ip" {
  description = "Private IPv4 address of the EC2 web test instance."
  value       = module.compute.instance_private_ip
}
