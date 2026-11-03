output "vpc_id" {
  value = aws_vpc.this.id
}

output "cidr_block" {
  value = aws_vpc.this.cidr_block
}

output "subnet_ids_by_tier" {
  value = {
    for tier in keys(var.subnet_tiers) :
    tier => [for k, s in aws_subnet.this : s.id if local.subnets[k].tier == tier]
  }
}

output "subnet_cidrs_by_tier" {
  value = {
    for tier in keys(var.subnet_tiers) :
    tier => [for k, s in aws_subnet.this : s.cidr_block if local.subnets[k].tier == tier]
  }
}

output "route_table_ids_by_tier" {
  value = { for k, rt in aws_route_table.tier : k => rt.id }
}
