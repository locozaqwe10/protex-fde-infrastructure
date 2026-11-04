# Cross-account, cross-region VPC peering with 2-way routes.

resource "aws_vpc_peering_connection" "this" {
  provider = aws.requester

  vpc_id        = var.requester_vpc_id
  peer_vpc_id   = var.accepter_vpc_id
  peer_owner_id = var.accepter_account_id
  peer_region   = var.accepter_region
  auto_accept   = false

  tags = { Name = var.name }
}

resource "aws_vpc_peering_connection_accepter" "this" {
  provider = aws.accepter

  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
  auto_accept               = true

  tags = { Name = var.name }
}

# DNS: hub resolves spoke private DNS, not the reverse
resource "aws_vpc_peering_connection_options" "requester" {
  provider = aws.requester

  vpc_peering_connection_id = aws_vpc_peering_connection.this.id

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  depends_on = [aws_vpc_peering_connection_accepter.this]
}

resource "aws_vpc_peering_connection_options" "accepter" {
  provider = aws.accepter

  vpc_peering_connection_id = aws_vpc_peering_connection.this.id

  accepter {
    allow_remote_vpc_dns_resolution = false
  }

  depends_on = [aws_vpc_peering_connection_accepter.this]
}

# 2-way routes scoped to specific subnets
locals {
  requester_routes = {
    for pair in setproduct(keys(var.requester_route_table_ids), var.accepter_cidr_blocks) :
    "${pair[0]}-${pair[1]}" => {
      route_table_id = var.requester_route_table_ids[pair[0]]
      cidr           = pair[1]
    }
  }

  accepter_routes = {
    for pair in setproduct(keys(var.accepter_route_table_ids), var.requester_cidr_blocks) :
    "${pair[0]}-${pair[1]}" => {
      route_table_id = var.accepter_route_table_ids[pair[0]]
      cidr           = pair[1]
    }
  }
}

resource "aws_route" "requester" {
  provider = aws.requester
  for_each = local.requester_routes

  route_table_id            = each.value.route_table_id
  destination_cidr_block    = each.value.cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

resource "aws_route" "accepter" {
  provider = aws.accepter
  for_each = local.accepter_routes

  route_table_id            = each.value.route_table_id
  destination_cidr_block    = each.value.cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}
