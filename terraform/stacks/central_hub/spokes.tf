# One spoke_attachment + vpc_peering per region.
# Can't for_each over providers so each is explicit.

module "spoke_eu" {
  source    = "../../modules/spoke_attachment"
  providers = { aws = aws.eu }

  spoke_name    = var.spokes["eu"].vpc_name
  central_cidrs = module.vpc.subnet_cidrs_by_tier["private"]
}

module "peer_eu" {
  source = "../../modules/vpc_peering"
  providers = {
    aws.requester = aws
    aws.accepter  = aws.eu
  }

  name                      = "${var.hub_name}-eu"
  requester_vpc_id          = module.vpc.vpc_id
  accepter_vpc_id           = module.spoke_eu.vpc_id
  accepter_account_id       = var.spokes["eu"].account_id
  accepter_region           = var.spokes["eu"].region
  requester_route_table_ids = { private = module.vpc.route_table_ids_by_tier["private"] }
  accepter_route_table_ids  = {}
  requester_cidr_blocks     = module.vpc.subnet_cidrs_by_tier["private"]
  accepter_cidr_blocks      = [var.spokes["eu"].cidr]
}

module "spoke_us" {
  source    = "../../modules/spoke_attachment"
  providers = { aws = aws.us }

  spoke_name    = var.spokes["us"].vpc_name
  central_cidrs = module.vpc.subnet_cidrs_by_tier["private"]
}

module "peer_us" {
  source = "../../modules/vpc_peering"
  providers = {
    aws.requester = aws
    aws.accepter  = aws.us
  }

  name                      = "${var.hub_name}-us"
  requester_vpc_id          = module.vpc.vpc_id
  accepter_vpc_id           = module.spoke_us.vpc_id
  accepter_account_id       = var.spokes["us"].account_id
  accepter_region           = var.spokes["us"].region
  requester_route_table_ids = { private = module.vpc.route_table_ids_by_tier["private"] }
  accepter_route_table_ids  = {}
  requester_cidr_blocks     = module.vpc.subnet_cidrs_by_tier["private"]
  accepter_cidr_blocks      = [var.spokes["us"].cidr]
}

module "spoke_ca" {
  source    = "../../modules/spoke_attachment"
  providers = { aws = aws.ca }

  spoke_name    = var.spokes["ca"].vpc_name
  central_cidrs = module.vpc.subnet_cidrs_by_tier["private"]
}

module "peer_ca" {
  source = "../../modules/vpc_peering"
  providers = {
    aws.requester = aws
    aws.accepter  = aws.ca
  }

  name                      = "${var.hub_name}-ca"
  requester_vpc_id          = module.vpc.vpc_id
  accepter_vpc_id           = module.spoke_ca.vpc_id
  accepter_account_id       = var.spokes["ca"].account_id
  accepter_region           = var.spokes["ca"].region
  requester_route_table_ids = { private = module.vpc.route_table_ids_by_tier["private"] }
  accepter_route_table_ids  = {}
  requester_cidr_blocks     = module.vpc.subnet_cidrs_by_tier["private"]
  accepter_cidr_blocks      = [var.spokes["ca"].cidr]
}

module "spoke_apac" {
  source    = "../../modules/spoke_attachment"
  providers = { aws = aws.apac }

  spoke_name    = var.spokes["apac"].vpc_name
  central_cidrs = module.vpc.subnet_cidrs_by_tier["private"]
}

module "peer_apac" {
  source = "../../modules/vpc_peering"
  providers = {
    aws.requester = aws
    aws.accepter  = aws.apac
  }

  name                      = "${var.hub_name}-apac"
  requester_vpc_id          = module.vpc.vpc_id
  accepter_vpc_id           = module.spoke_apac.vpc_id
  accepter_account_id       = var.spokes["apac"].account_id
  accepter_region           = var.spokes["apac"].region
  requester_route_table_ids = { private = module.vpc.route_table_ids_by_tier["private"] }
  accepter_route_table_ids  = {}
  requester_cidr_blocks     = module.vpc.subnet_cidrs_by_tier["private"]
  accepter_cidr_blocks      = [var.spokes["apac"].cidr]
}
