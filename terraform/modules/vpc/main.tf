# Per-tier route tables control reachability -- e.g. private subnets
# route through NAT, public subnets get an IGW route.

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = var.name }
}

locals {
  has_public = anytrue([for t in var.subnet_tiers : t.public])

  subnets = merge([
    for tier, cfg in var.subnet_tiers : {
      for i in range(cfg.az_count) :
      "${tier}-${i}" => {
        tier     = tier
        az_index = i
        public   = cfg.public
        cidr     = cidrsubnet(var.cidr_block, cfg.cidr_newbits, i)
      }
    }
  ]...)
}

resource "aws_subnet" "this" {
  for_each = local.subnets

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = data.aws_availability_zones.available.names[each.value.az_index]

  tags = {
    Name = "${var.name}-${each.key}"
    Tier = each.value.tier
  }
}

resource "aws_internet_gateway" "this" {
  count  = local.has_public ? 1 : 0
  vpc_id = aws_vpc.this.id
  tags   = { Name = var.name }
}

resource "aws_route_table" "tier" {
  for_each = var.subnet_tiers
  vpc_id   = aws_vpc.this.id
  tags     = { Name = "${var.name}-${each.key}" }
}

resource "aws_route" "igw" {
  for_each = { for k, v in var.subnet_tiers : k => v if v.public && local.has_public }

  route_table_id         = aws_route_table.tier[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

# Single NAT in the first public subnet. Production would use one per AZ.
resource "aws_eip" "nat" {
  count  = var.enable_nat ? 1 : 0
  domain = "vpc"
  tags   = { Name = "${var.name}-nat" }
}

resource "aws_nat_gateway" "this" {
  count = var.enable_nat ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = [for k, s in aws_subnet.this : s.id if local.subnets[k].public][0]

  tags       = { Name = "${var.name}-nat" }
  depends_on = [aws_internet_gateway.this]
}

resource "aws_route" "nat" {
  for_each = var.enable_nat ? { for k, v in var.subnet_tiers : k => v if !v.public } : {}

  route_table_id         = aws_route_table.tier[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[0].id
}

resource "aws_route_table_association" "this" {
  for_each       = local.subnets
  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.tier[each.value.tier].id
}

resource "aws_default_security_group" "locked" {
  vpc_id = aws_vpc.this.id
  # no rules -- forces all traffic through explicit SGs
}
