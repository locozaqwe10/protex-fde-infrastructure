# Looks up an existing regional VPC and outputs what the peering
# module needs. SG rules use CIDRs -- refs don't work cross-region.

data "aws_vpc" "spoke" {
  filter {
    name   = "tag:Name"
    values = [var.spoke_name]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.spoke.id]
  }
  tags = { Tier = "private" }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.spoke.id]
  }
  tags = { Tier = "public" }
}
