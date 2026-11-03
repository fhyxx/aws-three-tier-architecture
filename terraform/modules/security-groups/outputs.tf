output "alb_security_group_id" {
  description = "ID of the ALB security group."
  value       = aws_security_group.alb.id
}

output "app_security_group_id" {
  description = "ID of the application security group."
  value       = aws_security_group.app.id
}

output "db_security_group_id" {
  description = "ID of the database security group."
  value       = aws_security_group.db.id
}

output "test_web_security_group_id" {
  description = "ID of the temporary test web security group."
  value       = aws_security_group.test_web.id
}
