# =============================================================================
# Outputs - 4-Region Full Mesh TGW
# =============================================================================

# -----------------------------------------------------------------------------
# VPC Outputs
# -----------------------------------------------------------------------------

output "paris_vpc_id" {
  description = "VPC ID in Paris region"
  value       = module.vpc_paris.vpc_id
}

output "frankfurt_vpc_id" {
  description = "VPC ID in Frankfurt region"
  value       = module.vpc_frankfurt.vpc_id
}

output "ireland_vpc_id" {
  description = "VPC ID in Ireland region"
  value       = module.vpc_ireland.vpc_id
}

output "stockholm_vpc_id" {
  description = "VPC ID in Stockholm region"
  value       = module.vpc_stockholm.vpc_id
}

# -----------------------------------------------------------------------------
# Transit Gateway Outputs
# -----------------------------------------------------------------------------

output "paris_tgw_id" {
  description = "Transit Gateway ID in Paris region"
  value       = module.tgw_paris.tgw_id
}

output "frankfurt_tgw_id" {
  description = "Transit Gateway ID in Frankfurt region"
  value       = module.tgw_frankfurt.tgw_id
}

output "ireland_tgw_id" {
  description = "Transit Gateway ID in Ireland region"
  value       = module.tgw_ireland.tgw_id
}

output "stockholm_tgw_id" {
  description = "Transit Gateway ID in Stockholm region"
  value       = module.tgw_stockholm.tgw_id
}

# -----------------------------------------------------------------------------
# TGW Peering Outputs
# -----------------------------------------------------------------------------

output "peering_paris_frankfurt_id" {
  description = "TGW peering attachment ID: Paris <-> Frankfurt"
  value       = module.tgw_peering_paris_frankfurt.peering_attachment_id
}

output "peering_paris_ireland_id" {
  description = "TGW peering attachment ID: Paris <-> Ireland"
  value       = module.tgw_peering_paris_ireland.peering_attachment_id
}

output "peering_paris_stockholm_id" {
  description = "TGW peering attachment ID: Paris <-> Stockholm"
  value       = module.tgw_peering_paris_stockholm.peering_attachment_id
}

output "peering_frankfurt_ireland_id" {
  description = "TGW peering attachment ID: Frankfurt <-> Ireland"
  value       = module.tgw_peering_frankfurt_ireland.peering_attachment_id
}

output "peering_frankfurt_stockholm_id" {
  description = "TGW peering attachment ID: Frankfurt <-> Stockholm"
  value       = module.tgw_peering_frankfurt_stockholm.peering_attachment_id
}

output "peering_ireland_stockholm_id" {
  description = "TGW peering attachment ID: Ireland <-> Stockholm"
  value       = module.tgw_peering_ireland_stockholm.peering_attachment_id
}

# -----------------------------------------------------------------------------
# Summary Output
# -----------------------------------------------------------------------------

output "infrastructure_summary" {
  description = "Summary of 4-region full mesh TGW infrastructure"
  value = {
    regions = {
      paris     = { vpc_id = module.vpc_paris.vpc_id, vpc_cidr = var.paris_vpc_cidr, tgw_id = module.tgw_paris.tgw_id }
      frankfurt = { vpc_id = module.vpc_frankfurt.vpc_id, vpc_cidr = var.frankfurt_vpc_cidr, tgw_id = module.tgw_frankfurt.tgw_id }
      ireland   = { vpc_id = module.vpc_ireland.vpc_id, vpc_cidr = var.ireland_vpc_cidr, tgw_id = module.tgw_ireland.tgw_id }
      stockholm = { vpc_id = module.vpc_stockholm.vpc_id, vpc_cidr = var.stockholm_vpc_cidr, tgw_id = module.tgw_stockholm.tgw_id }
    }
    peering_connections = {
      "1_paris_frankfurt"    = module.tgw_peering_paris_frankfurt.peering_attachment_id
      "2_paris_ireland"      = module.tgw_peering_paris_ireland.peering_attachment_id
      "3_paris_stockholm"    = module.tgw_peering_paris_stockholm.peering_attachment_id
      "4_frankfurt_ireland"  = module.tgw_peering_frankfurt_ireland.peering_attachment_id
      "5_frankfurt_stockholm" = module.tgw_peering_frankfurt_stockholm.peering_attachment_id
      "6_ireland_stockholm"  = module.tgw_peering_ireland_stockholm.peering_attachment_id
    }
  }
}
