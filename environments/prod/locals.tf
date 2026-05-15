# =============================================================================
# Local Values - Dev Environment
# =============================================================================

locals {
  # Common tags applied to all resources
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "terraform"
    CostCenter  = "infrastructure"
  }

  # Region configurations
  regions = {
    paris = {
      name        = "paris"
      aws_region  = var.paris_region
      vpc_cidr    = var.paris_vpc_cidr
      tgw_asn     = var.paris_tgw_asn
    }
    frankfurt = {
      name        = "frankfurt"
      aws_region  = var.frankfurt_region
      vpc_cidr    = var.frankfurt_vpc_cidr
      tgw_asn     = var.frankfurt_tgw_asn
    }
  }
}
