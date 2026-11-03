output "instance_id" {
  description = "ID of the EC2 web test instance."
  value       = aws_instance.web_test.id
}

output "instance_private_ip" {
  description = "Private IPv4 address of the EC2 web test instance."
  value       = aws_instance.web_test.private_ip
}

output "instance_public_ip" {
  description = "Public IPv4 address of the EC2 web test instance."
  value       = aws_instance.web_test.public_ip
}
