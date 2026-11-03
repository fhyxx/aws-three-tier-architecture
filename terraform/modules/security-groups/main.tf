resource "aws_security_group" "alb" {
  name        = "pelumi-alb-sg"
  description = "Allow public HTTP traffic to the application load balancer "
  vpc_id      = var.vpc_id

  revoke_rules_on_delete = false

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_security_group" "app" {
  name        = "pelumi-app-sg"
  description = "Allow application traffic only from the ALB"
  vpc_id      = var.vpc_id

  revoke_rules_on_delete = false

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_security_group" "db" {
  name        = "pelumi-db-sg"
  description = "Allow MySQL connections only from application instances "
  vpc_id      = var.vpc_id

  revoke_rules_on_delete = false

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_security_group" "test_web" {
  name        = "pelumi-test-web-sg"
  description = "Temporary HTTP test server"
  vpc_id      = var.vpc_id

  revoke_rules_on_delete = false

  lifecycle {
    prevent_destroy = true
  }
}

# Public HTTP ingress for the ALB.
resource "aws_vpc_security_group_ingress_rule" "alb_public_http" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  description       = "Public HTTP access to portfolio ALB"
}

# HTTPS egress for Systems Manager and instance updates.
resource "aws_vpc_security_group_egress_rule" "test_web_https_egress" {
  security_group_id = aws_security_group.test_web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  description       = "HTTPS for AWS Systems Manager and updates"
}

# ALB egress to the test web server on HTTP.
resource "aws_vpc_security_group_egress_rule" "alb_to_test_web" {
  security_group_id            = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.test_web.id
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
}

# Application ingress from the ALB on HTTP.
resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.alb.id
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
}

# Application egress to the database on MySQL.
resource "aws_vpc_security_group_egress_rule" "app_to_db" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.db.id
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
}

# Database ingress from the application tier on MySQL.
resource "aws_vpc_security_group_ingress_rule" "db_from_app" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.app.id
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
}

# Temporary direct HTTP access for the configured administrator CIDR.
resource "aws_vpc_security_group_ingress_rule" "test_web_from_ip" {
  security_group_id = aws_security_group.test_web.id
  cidr_ipv4         = var.admin_cidr
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

# HTTP ingress to the test server from the ALB security group.
resource "aws_vpc_security_group_ingress_rule" "test_web_from_alb" {
  security_group_id            = aws_security_group.test_web.id
  referenced_security_group_id = aws_security_group.alb.id
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
  description                  = "HTTP from portfolio ALB"
}
