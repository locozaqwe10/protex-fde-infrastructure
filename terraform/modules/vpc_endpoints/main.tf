# Hub has no IGW or NAT -- these are the only path to AWS APIs.

data "aws_region" "current" {}

locals {
  interface_services = [
    "sts",
    "logs",
    "monitoring",
    "secretsmanager",
    "ecr.api",
    "ecr.dkr",
    "ec2",
  ]
}

resource "aws_security_group" "endpoints" {
  name_prefix = "${var.name_prefix}-vpce-"
  vpc_id      = var.vpc_id
  description = "HTTPS from VPC to interface endpoints"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = { Name = "${var.name_prefix}-vpce" }
}

resource "aws_vpc_endpoint" "interface" {
  for_each = toset(local.interface_services)

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.${each.key}"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = var.subnet_ids
  security_group_ids  = [aws_security_group.endpoints.id]

  tags = { Name = "${var.name_prefix}-${each.key}" }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.route_table_ids

  tags = { Name = "${var.name_prefix}-s3" }
}
