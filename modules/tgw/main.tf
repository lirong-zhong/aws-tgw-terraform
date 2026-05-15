# =============================================================================
# Transit Gateway Module - AWS Best Practices Implementation
# =============================================================================
# This module creates a Transit Gateway with:
# - Dedicated route tables for isolation
# - VPC attachment with dedicated TGW subnets
# - Proper ASN configuration for BGP
# - Resource sharing support (optional)
# =============================================================================

# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

# -----------------------------------------------------------------------------
# Local Values
# -----------------------------------------------------------------------------

locals {
  common_tags = {
    Module      = "tgw"
    Region      = data.aws_region.current.name
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# -----------------------------------------------------------------------------
# Transit Gateway
# -----------------------------------------------------------------------------

resource "aws_ec2_transit_gateway" "main" {
  description = "Transit Gateway for ${var.project_name} in ${var.region_name}"

  # BGP ASN - Must be unique per TGW for peering
  amazon_side_asn = var.amazon_side_asn

  # Auto accept shared attachments (for RAM sharing)
  auto_accept_shared_attachments = var.auto_accept_shared_attachments

  # Default route table settings
  # AWS Best Practice: Disable default association/propagation for explicit control
  default_route_table_association = var.default_route_table_association
  default_route_table_propagation = var.default_route_table_propagation

  # DNS support
  dns_support = "enable"

  # VPN ECMP support
  vpn_ecmp_support = "enable"

  # Multicast support (if needed)
  multicast_support = var.enable_multicast ? "enable" : "disable"

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-tgw-${var.region_name}-${var.environment}"
  })
}

# -----------------------------------------------------------------------------
# Transit Gateway Route Table
# AWS Best Practice: Create explicit route tables instead of using default
# -----------------------------------------------------------------------------

resource "aws_ec2_transit_gateway_route_table" "main" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-tgw-rt-${var.region_name}-${var.environment}"
    Type = "Main"
  })
}

# -----------------------------------------------------------------------------
# Transit Gateway VPC Attachment
# AWS Best Practice: Use dedicated TGW subnets for attachments
# -----------------------------------------------------------------------------

resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = var.vpc_id
  subnet_ids         = var.tgw_subnet_ids

  # DNS support for the attachment
  dns_support = "enable"

  # IPv6 support
  ipv6_support = var.enable_ipv6 ? "enable" : "disable"

  # Appliance mode for stateful inspection (if using firewall appliances)
  appliance_mode_support = var.enable_appliance_mode ? "enable" : "disable"

  # Disable default route table association - we'll do it explicitly
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-tgw-attach-vpc-${var.region_name}-${var.environment}"
    Type = "VPC"
  })

  depends_on = [aws_ec2_transit_gateway.main]
}

# -----------------------------------------------------------------------------
# Route Table Association
# Explicitly associate VPC attachment with route table
# -----------------------------------------------------------------------------

resource "aws_ec2_transit_gateway_route_table_association" "main" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.main.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}

# -----------------------------------------------------------------------------
# Route Table Propagation
# Enable route propagation from VPC attachment to route table
# -----------------------------------------------------------------------------

resource "aws_ec2_transit_gateway_route_table_propagation" "main" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.main.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}

# -----------------------------------------------------------------------------
# Resource Access Manager Share (Optional)
# For sharing TGW across accounts
# -----------------------------------------------------------------------------

resource "aws_ram_resource_share" "tgw" {
  count = var.enable_ram_sharing ? 1 : 0

  name                      = "${var.project_name}-tgw-share-${var.region_name}-${var.environment}"
  allow_external_principals = var.allow_external_principals

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-tgw-share-${var.region_name}-${var.environment}"
  })
}

resource "aws_ram_resource_association" "tgw" {
  count = var.enable_ram_sharing ? 1 : 0

  resource_arn       = aws_ec2_transit_gateway.main.arn
  resource_share_arn = aws_ram_resource_share.tgw[0].arn
}

resource "aws_ram_principal_association" "tgw" {
  count = var.enable_ram_sharing && length(var.ram_principals) > 0 ? length(var.ram_principals) : 0

  principal          = var.ram_principals[count.index]
  resource_share_arn = aws_ram_resource_share.tgw[0].arn
}
