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
