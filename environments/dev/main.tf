# =============================================================================
# Main Configuration - Dev Environment
# =============================================================================
# This configuration creates:
# - VPCs in Paris (eu-west-3) and Frankfurt (eu-central-1)
# - Transit Gateways in both regions
# - TGW Inter-region peering
# =============================================================================

# =============================================================================
# VPC Module - Paris Region
# =============================================================================

module "vpc_paris" {
  source = "../../modules/vpc"

  providers = {
    aws = aws.paris
  }

  vpc_cidr           = var.paris_vpc_cidr
  region_name        = "paris"
  project_name       = var.project_name
  environment        = var.environment
  single_nat_gateway = var.single_nat_gateway
  enable_flow_logs   = var.enable_flow_logs
}

# =============================================================================
# VPC Module - Frankfurt Region
# =============================================================================

module "vpc_frankfurt" {
  source = "../../modules/vpc"

  providers = {
    aws = aws.frankfurt
  }

  vpc_cidr           = var.frankfurt_vpc_cidr
  region_name        = "frankfurt"
  project_name       = var.project_name
  environment        = var.environment
  single_nat_gateway = var.single_nat_gateway
  enable_flow_logs   = var.enable_flow_logs
}

# =============================================================================
# Transit Gateway Module - Paris Region
# =============================================================================

module "tgw_paris" {
  source = "../../modules/tgw"

  providers = {
    aws = aws.paris
  }

  vpc_id          = module.vpc_paris.vpc_id
  tgw_subnet_ids  = module.vpc_paris.tgw_subnet_ids
  amazon_side_asn = var.paris_tgw_asn
  region_name     = "paris"
  project_name    = var.project_name
  environment     = var.environment

  depends_on = [module.vpc_paris]
}

# =============================================================================
# Transit Gateway Module - Frankfurt Region
# =============================================================================

module "tgw_frankfurt" {
  source = "../../modules/tgw"

  providers = {
    aws = aws.frankfurt
  }

  vpc_id          = module.vpc_frankfurt.vpc_id
  tgw_subnet_ids  = module.vpc_frankfurt.tgw_subnet_ids
  amazon_side_asn = var.frankfurt_tgw_asn
  region_name     = "frankfurt"
  project_name    = var.project_name
  environment     = var.environment

  depends_on = [module.vpc_frankfurt]
}

# =============================================================================
# Transit Gateway Peering - Paris to Frankfurt
# =============================================================================

module "tgw_peering" {
  source = "../../modules/tgw-peering"

  providers = {
    aws.requester = aws.paris
    aws.accepter  = aws.frankfurt
  }

  # Requester (Paris)
  requester_tgw_id                  = module.tgw_paris.tgw_id
  requester_tgw_route_table_id      = module.tgw_paris.tgw_route_table_id
  requester_vpc_cidr                = var.paris_vpc_cidr
  requester_region_name             = "paris"
  requester_public_route_table_ids  = [module.vpc_paris.public_route_table_id]
  requester_private_route_table_ids = module.vpc_paris.private_route_table_ids

  # Accepter (Frankfurt)
  accepter_tgw_id                  = module.tgw_frankfurt.tgw_id
  accepter_tgw_route_table_id      = module.tgw_frankfurt.tgw_route_table_id
  accepter_vpc_cidr                = var.frankfurt_vpc_cidr
  accepter_region                  = var.frankfurt_region
  accepter_region_name             = "frankfurt"
  accepter_public_route_table_ids  = [module.vpc_frankfurt.public_route_table_id]
  accepter_private_route_table_ids = module.vpc_frankfurt.private_route_table_ids

  # Account
  peer_account_id = var.aws_account_id

  # Project
  project_name = var.project_name
  environment  = var.environment

  depends_on = [module.tgw_paris, module.tgw_frankfurt]
}

