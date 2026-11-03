output "alb_security_group_id" {
  description = "Security group ID for the application load balancer."
  value       = aws_security_group.alb.id
}

output "app_security_group_id" {
  description = "Security group ID for application instances."
  value       = aws_security_group.app.id
}

output "db_security_group_id" {
  description = "Security group ID for the database tier."
  value       = aws_security_group.db.id
}

output "test_web_security_group_id" {
  description = "Security group ID for the temporary EC2 web test instance."
  value       = aws_security_group.test_web.id
}
