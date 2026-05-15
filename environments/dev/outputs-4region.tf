# =============================================================================
# Outputs - 4-Region Full Mesh Configuration
# =============================================================================

# -----------------------------------------------------------------------------
# VPC Outputs - Ireland
# -----------------------------------------------------------------------------

output "ireland_vpc_id" {
  description = "VPC ID in Ireland region"
  value       = module.vpc_ireland.vpc_id
}

output "ireland_vpc_cidr" {
  description = "VPC CIDR in Ireland region"
  value       = module.vpc_ireland.vpc_cidr
}

output "ireland_tgw_id" {
  description = "Transit Gateway ID in Ireland region"
  value       = module.tgw_ireland.tgw_id
}

# -----------------------------------------------------------------------------
# VPC Outputs - stockholm
# -----------------------------------------------------------------------------

output "stockholm_vpc_id" {
  description = "VPC ID in stockholm region"
  value       = module.vpc_stockholm.vpc_id
}

output "stockholm_vpc_cidr" {
  description = "VPC CIDR in stockholm region"
  value       = module.vpc_stockholm.vpc_cidr
}

output "stockholm_tgw_id" {
  description = "Transit Gateway ID in stockholm region"
  value       = module.tgw_stockholm.tgw_id
}

# -----------------------------------------------------------------------------
# TGW Peering Outputs
# -----------------------------------------------------------------------------

output "peering_paris_ireland_id" {
  description = "TGW peering attachment ID: Paris <-> Ireland"
  value       = module.tgw_peering_paris_ireland.peering_attachment_id
}

output "peering_paris_stockholm_id" {
  description = "TGW peering attachment ID: Paris <-> stockholm"
  value       = module.tgw_peering_paris_stockholm.peering_attachment_id
}

output "peering_frankfurt_ireland_id" {
  description = "TGW peering attachment ID: Frankfurt <-> Ireland"
  value       = module.tgw_peering_frankfurt_ireland.peering_attachment_id
}

output "peering_frankfurt_stockholm_id" {
  description = "TGW peering attachment ID: Frankfurt <-> stockholm"
  value       = module.tgw_peering_frankfurt_stockholm.peering_attachment_id
}

output "peering_ireland_stockholm_id" {
  description = "TGW peering attachment ID: Ireland <-> stockholm"
  value       = module.tgw_peering_ireland_stockholm.peering_attachment_id
}

# -----------------------------------------------------------------------------
# Note: Test instances are only created in Paris and Frankfurt regions
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Full Mesh Summary
# -----------------------------------------------------------------------------

output "full_mesh_summary" {
  description = "Summary of 4-region full mesh TGW configuration"
  value = {
    regions = {
      paris     = { vpc_cidr = var.paris_vpc_cidr, tgw_id = module.tgw_paris.tgw_id }
      frankfurt = { vpc_cidr = var.frankfurt_vpc_cidr, tgw_id = module.tgw_frankfurt.tgw_id }
      ireland   = { vpc_cidr = var.ireland_vpc_cidr, tgw_id = module.tgw_ireland.tgw_id }
      stockholm    = { vpc_cidr = var.stockholm_vpc_cidr, tgw_id = module.tgw_stockholm.tgw_id }
    }
    peering_connections = {
      "1_paris_frankfurt" = module.tgw_peering.peering_attachment_id
      "2_paris_ireland"   = module.tgw_peering_paris_ireland.peering_attachment_id
      "3_paris_stockholm"    = module.tgw_peering_paris_stockholm.peering_attachment_id
      "4_frankfurt_ireland" = module.tgw_peering_frankfurt_ireland.peering_attachment_id
      "5_frankfurt_stockholm"  = module.tgw_peering_frankfurt_stockholm.peering_attachment_id
      "6_ireland_stockholm"    = module.tgw_peering_ireland_stockholm.peering_attachment_id
    }
  }
}
