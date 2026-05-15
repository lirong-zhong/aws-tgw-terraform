# =============================================================================
# Transit Gateway Peering Module Outputs
# =============================================================================

# -----------------------------------------------------------------------------
# Peering Attachment Outputs
# -----------------------------------------------------------------------------

output "peering_attachment_id" {
  description = "ID of the Transit Gateway peering attachment"
  value       = aws_ec2_transit_gateway_peering_attachment.requester.id
}

output "peering_attachment_state" {
  description = "State of the Transit Gateway peering attachment"
  value       = aws_ec2_transit_gateway_peering_attachment_accepter.accepter.id
}

# -----------------------------------------------------------------------------
# Route Outputs
# -----------------------------------------------------------------------------

output "requester_to_accepter_route_id" {
  description = "ID of the TGW route from requester to accepter"
  value       = aws_ec2_transit_gateway_route.requester_to_accepter.id
}

output "accepter_to_requester_route_id" {
  description = "ID of the TGW route from accepter to requester"
  value       = aws_ec2_transit_gateway_route.accepter_to_requester.id
}

# -----------------------------------------------------------------------------
# Summary Output
# -----------------------------------------------------------------------------

output "peering_summary" {
  description = "Summary of the TGW peering configuration"
  value = {
    peering_attachment_id = aws_ec2_transit_gateway_peering_attachment.requester.id
    requester = {
      tgw_id      = var.requester_tgw_id
      region_name = var.requester_region_name
      vpc_cidr    = var.requester_vpc_cidr
    }
    accepter = {
      tgw_id      = var.accepter_tgw_id
      region      = var.accepter_region
      region_name = var.accepter_region_name
      vpc_cidr    = var.accepter_vpc_cidr
    }
  }
}
