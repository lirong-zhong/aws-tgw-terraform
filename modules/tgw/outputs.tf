# =============================================================================
# Transit Gateway Module Outputs
# =============================================================================

# -----------------------------------------------------------------------------
# Transit Gateway Outputs
# -----------------------------------------------------------------------------

output "tgw_id" {
  description = "ID of the Transit Gateway"
  value       = aws_ec2_transit_gateway.main.id
}

output "tgw_arn" {
  description = "ARN of the Transit Gateway"
  value       = aws_ec2_transit_gateway.main.arn
}

output "tgw_owner_id" {
  description = "Owner ID of the Transit Gateway"
  value       = aws_ec2_transit_gateway.main.owner_id
}

output "tgw_amazon_side_asn" {
  description = "Amazon side ASN of the Transit Gateway"
  value       = aws_ec2_transit_gateway.main.amazon_side_asn
}

# -----------------------------------------------------------------------------
# Route Table Outputs
# -----------------------------------------------------------------------------

output "tgw_route_table_id" {
  description = "ID of the Transit Gateway route table"
  value       = aws_ec2_transit_gateway_route_table.main.id
}

output "tgw_default_route_table_id" {
  description = "ID of the default Transit Gateway route table"
  value       = aws_ec2_transit_gateway.main.association_default_route_table_id
}

# -----------------------------------------------------------------------------
# VPC Attachment Outputs
# -----------------------------------------------------------------------------

output "vpc_attachment_id" {
  description = "ID of the Transit Gateway VPC attachment"
  value       = aws_ec2_transit_gateway_vpc_attachment.main.id
}

output "vpc_attachment_vpc_owner_id" {
  description = "VPC owner ID of the Transit Gateway VPC attachment"
  value       = aws_ec2_transit_gateway_vpc_attachment.main.vpc_owner_id
}

# -----------------------------------------------------------------------------
# RAM Sharing Outputs (if enabled)
# -----------------------------------------------------------------------------

output "ram_resource_share_arn" {
  description = "ARN of the RAM resource share (if enabled)"
  value       = var.enable_ram_sharing ? aws_ram_resource_share.tgw[0].arn : null
}

# -----------------------------------------------------------------------------
# Computed Outputs for Peering
# -----------------------------------------------------------------------------

output "tgw_peering_info" {
  description = "Information needed for TGW peering"
  value = {
    tgw_id              = aws_ec2_transit_gateway.main.id
    tgw_route_table_id  = aws_ec2_transit_gateway_route_table.main.id
    vpc_attachment_id   = aws_ec2_transit_gateway_vpc_attachment.main.id
    amazon_side_asn     = aws_ec2_transit_gateway.main.amazon_side_asn
    owner_id            = aws_ec2_transit_gateway.main.owner_id
  }
}
