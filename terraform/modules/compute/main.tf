resource "aws_instance" "web_test" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids

  iam_instance_profile = var.instance_profile_name

  associate_public_ip_address = true
  monitoring                  = false
  ebs_optimized               = true
  source_dest_check           = true

  disable_api_termination = false

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "disabled"
  }

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    iops                  = 3000
    throughput            = 125
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = "pelumi-web-test"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [user_data]
  }
}
