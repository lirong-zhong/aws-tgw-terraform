# =============================================================================
# 4-Region Full Mesh TGW Configuration
# =============================================================================
# This adds Ireland and London regions with full mesh peering (6 connections)
# =============================================================================

# =============================================================================
# VPC Module - Ireland Region
# =============================================================================

module "vpc_ireland" {
  source = "../../modules/vpc"

  providers = {
    aws = aws.ireland
  }

  vpc_cidr           = var.ireland_vpc_cidr
  region_name        = "ireland"
  project_name       = var.project_name
  environment        = var.environment
  single_nat_gateway = var.single_nat_gateway
  enable_flow_logs   = var.enable_flow_logs
}

# =============================================================================
# VPC Module - London Region
# =============================================================================

module "vpc_london" {
  source = "../../modules/vpc"

  providers = {
    aws = aws.london
  }

  vpc_cidr           = var.london_vpc_cidr
  region_name        = "london"
  project_name       = var.project_name
  environment        = var.environment
  single_nat_gateway = var.single_nat_gateway
  enable_flow_logs   = var.enable_flow_logs
}

# =============================================================================
# Transit Gateway Module - Ireland Region
# =============================================================================

module "tgw_ireland" {
  source = "../../modules/tgw"

  providers = {
    aws = aws.ireland
  }

  vpc_id          = module.vpc_ireland.vpc_id
  tgw_subnet_ids  = module.vpc_ireland.tgw_subnet_ids
  amazon_side_asn = var.ireland_tgw_asn
  region_name     = "ireland"
  project_name    = var.project_name
  environment     = var.environment

  depends_on = [module.vpc_ireland]
}

# =============================================================================
# Transit Gateway Module - London Region
# =============================================================================

module "tgw_london" {
  source = "../../modules/tgw"

  providers = {
    aws = aws.london
  }

  vpc_id          = module.vpc_london.vpc_id
  tgw_subnet_ids  = module.vpc_london.tgw_subnet_ids
  amazon_side_asn = var.london_tgw_asn
  region_name     = "london"
  project_name    = var.project_name
  environment     = var.environment

  depends_on = [module.vpc_london]
}

# =============================================================================
# TGW Peering #2: Paris <-> Ireland
# =============================================================================

module "tgw_peering_paris_ireland" {
  source = "../../modules/tgw-peering"

  providers = {
    aws.requester = aws.paris
    aws.accepter  = aws.ireland
  }

  requester_tgw_id                  = module.tgw_paris.tgw_id
  requester_tgw_route_table_id      = module.tgw_paris.tgw_route_table_id
  requester_vpc_cidr                = var.paris_vpc_cidr
  requester_region_name             = "paris"
  requester_public_route_table_ids  = [module.vpc_paris.public_route_table_id]
  requester_private_route_table_ids = module.vpc_paris.private_route_table_ids

  accepter_tgw_id                  = module.tgw_ireland.tgw_id
  accepter_tgw_route_table_id      = module.tgw_ireland.tgw_route_table_id
  accepter_vpc_cidr                = var.ireland_vpc_cidr
  accepter_region                  = var.ireland_region
  accepter_region_name             = "ireland"
  accepter_public_route_table_ids  = [module.vpc_ireland.public_route_table_id]
  accepter_private_route_table_ids = module.vpc_ireland.private_route_table_ids

  peer_account_id = var.aws_account_id
  project_name    = var.project_name
  environment     = var.environment

  depends_on = [module.tgw_paris, module.tgw_ireland]
}

# =============================================================================
# TGW Peering #3: Paris <-> London
# =============================================================================

module "tgw_peering_paris_london" {
  source = "../../modules/tgw-peering"

  providers = {
    aws.requester = aws.paris
    aws.accepter  = aws.london
  }

  requester_tgw_id                  = module.tgw_paris.tgw_id
  requester_tgw_route_table_id      = module.tgw_paris.tgw_route_table_id
  requester_vpc_cidr                = var.paris_vpc_cidr
  requester_region_name             = "paris"
  requester_public_route_table_ids  = [module.vpc_paris.public_route_table_id]
  requester_private_route_table_ids = module.vpc_paris.private_route_table_ids

  accepter_tgw_id                  = module.tgw_london.tgw_id
  accepter_tgw_route_table_id      = module.tgw_london.tgw_route_table_id
  accepter_vpc_cidr                = var.london_vpc_cidr
  accepter_region                  = var.london_region
  accepter_region_name             = "london"
  accepter_public_route_table_ids  = [module.vpc_london.public_route_table_id]
  accepter_private_route_table_ids = module.vpc_london.private_route_table_ids

  peer_account_id = var.aws_account_id
  project_name    = var.project_name
  environment     = var.environment

  depends_on = [module.tgw_paris, module.tgw_london]
}

# =============================================================================
# TGW Peering #4: Frankfurt <-> Ireland
# =============================================================================

module "tgw_peering_frankfurt_ireland" {
  source = "../../modules/tgw-peering"

  providers = {
    aws.requester = aws.frankfurt
    aws.accepter  = aws.ireland
  }

  requester_tgw_id                  = module.tgw_frankfurt.tgw_id
  requester_tgw_route_table_id      = module.tgw_frankfurt.tgw_route_table_id
  requester_vpc_cidr                = var.frankfurt_vpc_cidr
  requester_region_name             = "frankfurt"
  requester_public_route_table_ids  = [module.vpc_frankfurt.public_route_table_id]
  requester_private_route_table_ids = module.vpc_frankfurt.private_route_table_ids

  accepter_tgw_id                  = module.tgw_ireland.tgw_id
  accepter_tgw_route_table_id      = module.tgw_ireland.tgw_route_table_id
  accepter_vpc_cidr                = var.ireland_vpc_cidr
  accepter_region                  = var.ireland_region
  accepter_region_name             = "ireland"
  accepter_public_route_table_ids  = [module.vpc_ireland.public_route_table_id]
  accepter_private_route_table_ids = module.vpc_ireland.private_route_table_ids

  peer_account_id = var.aws_account_id
  project_name    = var.project_name
  environment     = var.environment

  depends_on = [module.tgw_frankfurt, module.tgw_ireland]
}

# =============================================================================
# TGW Peering #5: Frankfurt <-> London
# =============================================================================

module "tgw_peering_frankfurt_london" {
  source = "../../modules/tgw-peering"

  providers = {
    aws.requester = aws.frankfurt
    aws.accepter  = aws.london
  }

  requester_tgw_id                  = module.tgw_frankfurt.tgw_id
  requester_tgw_route_table_id      = module.tgw_frankfurt.tgw_route_table_id
  requester_vpc_cidr                = var.frankfurt_vpc_cidr
  requester_region_name             = "frankfurt"
  requester_public_route_table_ids  = [module.vpc_frankfurt.public_route_table_id]
  requester_private_route_table_ids = module.vpc_frankfurt.private_route_table_ids

  accepter_tgw_id                  = module.tgw_london.tgw_id
  accepter_tgw_route_table_id      = module.tgw_london.tgw_route_table_id
  accepter_vpc_cidr                = var.london_vpc_cidr
  accepter_region                  = var.london_region
  accepter_region_name             = "london"
  accepter_public_route_table_ids  = [module.vpc_london.public_route_table_id]
  accepter_private_route_table_ids = module.vpc_london.private_route_table_ids

  peer_account_id = var.aws_account_id
  project_name    = var.project_name
  environment     = var.environment

  depends_on = [module.tgw_frankfurt, module.tgw_london]
}

# =============================================================================
# TGW Peering #6: Ireland <-> London
# =============================================================================

module "tgw_peering_ireland_london" {
  source = "../../modules/tgw-peering"

  providers = {
    aws.requester = aws.ireland
    aws.accepter  = aws.london
  }

  requester_tgw_id                  = module.tgw_ireland.tgw_id
  requester_tgw_route_table_id      = module.tgw_ireland.tgw_route_table_id
  requester_vpc_cidr                = var.ireland_vpc_cidr
  requester_region_name             = "ireland"
  requester_public_route_table_ids  = [module.vpc_ireland.public_route_table_id]
  requester_private_route_table_ids = module.vpc_ireland.private_route_table_ids

  accepter_tgw_id                  = module.tgw_london.tgw_id
  accepter_tgw_route_table_id      = module.tgw_london.tgw_route_table_id
  accepter_vpc_cidr                = var.london_vpc_cidr
  accepter_region                  = var.london_region
  accepter_region_name             = "london"
  accepter_public_route_table_ids  = [module.vpc_london.public_route_table_id]
  accepter_private_route_table_ids = module.vpc_london.private_route_table_ids

  peer_account_id = var.aws_account_id
  project_name    = var.project_name
  environment     = var.environment

  depends_on = [module.tgw_ireland, module.tgw_london]
}

# =============================================================================
# Test EC2 Instance - Ireland Region
# =============================================================================

module "test_instance_ireland" {
  source = "../../modules/ec2-test"
  count  = var.create_test_instances ? 1 : 0

  providers = {
    aws = aws.ireland
  }

  vpc_id        = module.vpc_ireland.vpc_id
  vpc_cidr      = var.ireland_vpc_cidr
  subnet_id     = module.vpc_ireland.private_subnet_ids[0]
  peer_vpc_cidr = var.paris_vpc_cidr
  instance_type = var.instance_type
  key_name      = var.key_name
  region_name   = "ireland"
  project_name  = var.project_name
  environment   = var.environment

  depends_on = [module.tgw_peering_paris_ireland]
}

# =============================================================================
# Test EC2 Instance - London Region
# =============================================================================

module "test_instance_london" {
  source = "../../modules/ec2-test"
  count  = var.create_test_instances ? 1 : 0

  providers = {
    aws = aws.london
  }

  vpc_id        = module.vpc_london.vpc_id
  vpc_cidr      = var.london_vpc_cidr
  subnet_id     = module.vpc_london.private_subnet_ids[0]
  peer_vpc_cidr = var.paris_vpc_cidr
  instance_type = var.instance_type
  key_name      = var.key_name
  region_name   = "london"
  project_name  = var.project_name
  environment   = var.environment

  depends_on = [module.tgw_peering_paris_london]
}
