output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_cidr" {
  value = module.vpc.cidr_block
}

output "alb_dns_name" {
  value = aws_lb.api.dns_name
}

output "alb_zone_id" {
  value = aws_lb.api.zone_id
}

output "redis_endpoint" {
  value = aws_elasticache_replication_group.redis.primary_endpoint_address
}

output "peering_ids" {
  value = {
    eu   = module.peer_eu.peering_connection_id
    us   = module.peer_us.peering_connection_id
    ca   = module.peer_ca.peering_connection_id
    apac = module.peer_apac.peering_connection_id
  }
}
