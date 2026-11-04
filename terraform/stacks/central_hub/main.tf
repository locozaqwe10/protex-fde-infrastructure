# One hub. Deploy twice (Region A + Region B) behind Route 53
# health-based routing for active/active HA.

module "vpc" {
  source = "../../modules/vpc"

  name       = var.hub_name
  cidr_block = var.hub_cidr
  enable_nat = true

  subnet_tiers = {
    public = {
      cidr_newbits = 4
      az_count     = 3
      public       = true
    }
    private = {
      cidr_newbits = 4
      az_count     = 3
    }
  }
}

module "endpoints" {
  source = "../../modules/vpc_endpoints"

  vpc_id          = module.vpc.vpc_id
  vpc_cidr        = module.vpc.cidr_block
  subnet_ids      = module.vpc.subnet_ids_by_tier["private"]
  route_table_ids = values(module.vpc.route_table_ids_by_tier)
  name_prefix     = var.hub_name
}

# ALB in public subnets, multi-AZ
resource "aws_lb" "api" {
  name               = "${var.hub_name}-api"
  internal           = false
  load_balancer_type = "application"
  subnets            = module.vpc.subnet_ids_by_tier["public"]
  security_groups    = [aws_security_group.alb.id]

  tags = { Name = "${var.hub_name}-api" }
}

resource "aws_security_group" "alb" {
  name_prefix = "${var.hub_name}-alb-"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.hub_name}-alb" }
}

# ElastiCache (Redis) for caching regional data
resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.hub_name}-redis"
  subnet_ids = module.vpc.subnet_ids_by_tier["private"]
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id = "${var.hub_name}-redis"
  description          = "Redis cache for ${var.hub_name}"
  node_type            = var.redis_node_type
  num_cache_clusters   = var.redis_num_nodes
  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  security_group_ids   = [aws_security_group.redis.id]

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  automatic_failover_enabled = var.redis_num_nodes > 1

  tags = { Name = "${var.hub_name}-redis" }
}

resource "aws_security_group" "redis" {
  name_prefix = "${var.hub_name}-redis-"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [var.hub_cidr]
  }

  tags = { Name = "${var.hub_name}-redis" }
}
