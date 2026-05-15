# =============================================================================
# 4-Region Full Mesh TGW Configuration
# =============================================================================
# This adds Ireland and stockholm regions with full mesh peering (6 connections)
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
# VPC Module - stockholm Region
# =============================================================================

module "vpc_stockholm" {
  source = "../../modules/vpc"

  providers = {
    aws = aws.stockholm
  }

  vpc_cidr           = var.stockholm_vpc_cidr
  region_name        = "stockholm"
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
# Transit Gateway Module - stockholm Region
# =============================================================================

module "tgw_stockholm" {
  source = "../../modules/tgw"

  providers = {
    aws = aws.stockholm
  }

  vpc_id          = module.vpc_stockholm.vpc_id
  tgw_subnet_ids  = module.vpc_stockholm.tgw_subnet_ids
  amazon_side_asn = var.stockholm_tgw_asn
  region_name     = "stockholm"
  project_name    = var.project_name
  environment     = var.environment

  depends_on = [module.vpc_stockholm]
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
# TGW Peering #3: Paris <-> stockholm
# =============================================================================

module "tgw_peering_paris_stockholm" {
  source = "../../modules/tgw-peering"

  providers = {
    aws.requester = aws.paris
    aws.accepter  = aws.stockholm
  }

  requester_tgw_id                  = module.tgw_paris.tgw_id
  requester_tgw_route_table_id      = module.tgw_paris.tgw_route_table_id
  requester_vpc_cidr                = var.paris_vpc_cidr
  requester_region_name             = "paris"
  requester_public_route_table_ids  = [module.vpc_paris.public_route_table_id]
  requester_private_route_table_ids = module.vpc_paris.private_route_table_ids

  accepter_tgw_id                  = module.tgw_stockholm.tgw_id
  accepter_tgw_route_table_id      = module.tgw_stockholm.tgw_route_table_id
  accepter_vpc_cidr                = var.stockholm_vpc_cidr
  accepter_region                  = var.stockholm_region
  accepter_region_name             = "stockholm"
  accepter_public_route_table_ids  = [module.vpc_stockholm.public_route_table_id]
  accepter_private_route_table_ids = module.vpc_stockholm.private_route_table_ids

  peer_account_id = var.aws_account_id
  project_name    = var.project_name
  environment     = var.environment

  depends_on = [module.tgw_paris, module.tgw_stockholm]
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
# TGW Peering #5: Frankfurt <-> stockholm
# =============================================================================

module "tgw_peering_frankfurt_stockholm" {
  source = "../../modules/tgw-peering"

  providers = {
    aws.requester = aws.frankfurt
    aws.accepter  = aws.stockholm
  }

  requester_tgw_id                  = module.tgw_frankfurt.tgw_id
  requester_tgw_route_table_id      = module.tgw_frankfurt.tgw_route_table_id
  requester_vpc_cidr                = var.frankfurt_vpc_cidr
  requester_region_name             = "frankfurt"
  requester_public_route_table_ids  = [module.vpc_frankfurt.public_route_table_id]
  requester_private_route_table_ids = module.vpc_frankfurt.private_route_table_ids

  accepter_tgw_id                  = module.tgw_stockholm.tgw_id
  accepter_tgw_route_table_id      = module.tgw_stockholm.tgw_route_table_id
  accepter_vpc_cidr                = var.stockholm_vpc_cidr
  accepter_region                  = var.stockholm_region
  accepter_region_name             = "stockholm"
  accepter_public_route_table_ids  = [module.vpc_stockholm.public_route_table_id]
  accepter_private_route_table_ids = module.vpc_stockholm.private_route_table_ids

  peer_account_id = var.aws_account_id
  project_name    = var.project_name
  environment     = var.environment

  depends_on = [module.tgw_frankfurt, module.tgw_stockholm]
}

# =============================================================================
# TGW Peering #6: Ireland <-> stockholm
# =============================================================================

module "tgw_peering_ireland_stockholm" {
  source = "../../modules/tgw-peering"

  providers = {
    aws.requester = aws.ireland
    aws.accepter  = aws.stockholm
  }

  requester_tgw_id                  = module.tgw_ireland.tgw_id
  requester_tgw_route_table_id      = module.tgw_ireland.tgw_route_table_id
  requester_vpc_cidr                = var.ireland_vpc_cidr
  requester_region_name             = "ireland"
  requester_public_route_table_ids  = [module.vpc_ireland.public_route_table_id]
  requester_private_route_table_ids = module.vpc_ireland.private_route_table_ids

  accepter_tgw_id                  = module.tgw_stockholm.tgw_id
  accepter_tgw_route_table_id      = module.tgw_stockholm.tgw_route_table_id
  accepter_vpc_cidr                = var.stockholm_vpc_cidr
  accepter_region                  = var.stockholm_region
  accepter_region_name             = "stockholm"
  accepter_public_route_table_ids  = [module.vpc_stockholm.public_route_table_id]
  accepter_private_route_table_ids = module.vpc_stockholm.private_route_table_ids

  peer_account_id = var.aws_account_id
  project_name    = var.project_name
  environment     = var.environment

  depends_on = [module.tgw_ireland, module.tgw_stockholm]
}

# =============================================================================
# Note: Test EC2 instances for Ireland and Stockholm are not created
# Only Paris and Frankfurt have test instances for connectivity testing
# =============================================================================
