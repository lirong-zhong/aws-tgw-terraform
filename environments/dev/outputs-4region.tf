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
# VPC Outputs - London
# -----------------------------------------------------------------------------

output "london_vpc_id" {
  description = "VPC ID in London region"
  value       = module.vpc_london.vpc_id
}

output "london_vpc_cidr" {
  description = "VPC CIDR in London region"
  value       = module.vpc_london.vpc_cidr
}

output "london_tgw_id" {
  description = "Transit Gateway ID in London region"
  value       = module.tgw_london.tgw_id
}

# -----------------------------------------------------------------------------
# TGW Peering Outputs
# -----------------------------------------------------------------------------

output "peering_paris_ireland_id" {
  description = "TGW peering attachment ID: Paris <-> Ireland"
  value       = module.tgw_peering_paris_ireland.peering_attachment_id
}

output "peering_paris_london_id" {
  description = "TGW peering attachment ID: Paris <-> London"
  value       = module.tgw_peering_paris_london.peering_attachment_id
}

output "peering_frankfurt_ireland_id" {
  description = "TGW peering attachment ID: Frankfurt <-> Ireland"
  value       = module.tgw_peering_frankfurt_ireland.peering_attachment_id
}

output "peering_frankfurt_london_id" {
  description = "TGW peering attachment ID: Frankfurt <-> London"
  value       = module.tgw_peering_frankfurt_london.peering_attachment_id
}

output "peering_ireland_london_id" {
  description = "TGW peering attachment ID: Ireland <-> London"
  value       = module.tgw_peering_ireland_london.peering_attachment_id
}

# -----------------------------------------------------------------------------
# Test Instance Outputs - Ireland
# -----------------------------------------------------------------------------

output "ireland_test_instance_id" {
  description = "Test instance ID in Ireland region"
  value       = var.create_test_instances ? module.test_instance_ireland[0].instance_id : null
}

output "ireland_test_instance_private_ip" {
  description = "Test instance private IP in Ireland region"
  value       = var.create_test_instances ? module.test_instance_ireland[0].private_ip : null
}

# -----------------------------------------------------------------------------
# Test Instance Outputs - London
# -----------------------------------------------------------------------------

output "london_test_instance_id" {
  description = "Test instance ID in London region"
  value       = var.create_test_instances ? module.test_instance_london[0].instance_id : null
}

output "london_test_instance_private_ip" {
  description = "Test instance private IP in London region"
  value       = var.create_test_instances ? module.test_instance_london[0].private_ip : null
}

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
      london    = { vpc_cidr = var.london_vpc_cidr, tgw_id = module.tgw_london.tgw_id }
    }
    peering_connections = {
      "1_paris_frankfurt" = module.tgw_peering.peering_attachment_id
      "2_paris_ireland"   = module.tgw_peering_paris_ireland.peering_attachment_id
      "3_paris_london"    = module.tgw_peering_paris_london.peering_attachment_id
      "4_frankfurt_ireland" = module.tgw_peering_frankfurt_ireland.peering_attachment_id
      "5_frankfurt_london"  = module.tgw_peering_frankfurt_london.peering_attachment_id
      "6_ireland_london"    = module.tgw_peering_ireland_london.peering_attachment_id
    }
  }
}
