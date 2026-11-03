resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Pelumi-3tier-vpc"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_subnet" "public_az1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = { Name = "public-subnet-az1" }

  lifecycle { prevent_destroy = true }
}

resource "aws_subnet" "public_az2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = { Name = "public-subnet-az2" }

  lifecycle { prevent_destroy = true }
}

resource "aws_subnet" "app_az1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.11.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = { Name = "app-subnet-az1" }

  lifecycle { prevent_destroy = true }
}

resource "aws_subnet" "app_az2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.12.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = { Name = "app-subnet-az2" }

  lifecycle { prevent_destroy = true }
}

resource "aws_subnet" "db_az1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.21.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = { Name = "db-subnet-az1" }

  lifecycle { prevent_destroy = true }
}

resource "aws_subnet" "db_az2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.22.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = { Name = "db-subnet-az2" }

  lifecycle { prevent_destroy = true }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [tags]
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [tags]
  }
}

resource "aws_route_table" "application" {
  vpc_id = aws_vpc.main.id

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [tags]
  }
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [tags]
  }
}

resource "aws_route_table" "unassociated" {
  vpc_id = aws_vpc.main.id

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [tags]
  }
}

resource "aws_route" "public_default" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route_table_association" "public_az1" {
  subnet_id      = aws_subnet.public_az1.id
  route_table_id = aws_route_table.public.id
  lifecycle { prevent_destroy = true }
}

resource "aws_route_table_association" "public_az2" {
  subnet_id      = aws_subnet.public_az2.id
  route_table_id = aws_route_table.public.id
  lifecycle { prevent_destroy = true }
}

resource "aws_route_table_association" "app_az1" {
  subnet_id      = aws_subnet.app_az1.id
  route_table_id = aws_route_table.application.id
  lifecycle { prevent_destroy = true }
}

resource "aws_route_table_association" "app_az2" {
  subnet_id      = aws_subnet.app_az2.id
  route_table_id = aws_route_table.application.id
  lifecycle { prevent_destroy = true }
}

resource "aws_route_table_association" "db_az1" {
  subnet_id      = aws_subnet.db_az1.id
  route_table_id = aws_route_table.database.id
  lifecycle { prevent_destroy = true }
}

resource "aws_route_table_association" "db_az2" {
  subnet_id      = aws_subnet.db_az2.id
  route_table_id = aws_route_table.database.id
  lifecycle { prevent_destroy = true }
}
