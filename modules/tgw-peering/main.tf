# =============================================================================
# Transit Gateway Peering Module - AWS Best Practices Implementation
# =============================================================================
# This module creates TGW inter-region peering with:
# - Cross-region peering attachment
# - Automatic acceptance
# - Route table entries for both directions
# - Proper tagging
# =============================================================================

# -----------------------------------------------------------------------------
# Local Values
# -----------------------------------------------------------------------------

locals {
  common_tags = {
    Module      = "tgw-peering"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# -----------------------------------------------------------------------------
# Transit Gateway Peering Attachment (Requester Side)
# Created in the requester region
# -----------------------------------------------------------------------------

resource "aws_ec2_transit_gateway_peering_attachment" "requester" {
  provider = aws.requester

  transit_gateway_id      = var.requester_tgw_id
  peer_transit_gateway_id = var.accepter_tgw_id
  peer_region             = var.accepter_region
  peer_account_id         = var.peer_account_id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-tgw-peering-${var.requester_region_name}-to-${var.accepter_region_name}-${var.environment}"
    Side = "Requester"
  })
}

# -----------------------------------------------------------------------------
# Transit Gateway Peering Attachment Accepter (Accepter Side)
# Accepts the peering request in the accepter region
# -----------------------------------------------------------------------------

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "accepter" {
  provider = aws.accepter

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.requester.id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-tgw-peering-${var.accepter_region_name}-from-${var.requester_region_name}-${var.environment}"
    Side = "Accepter"
  })

  depends_on = [aws_ec2_transit_gateway_peering_attachment.requester]
}

# -----------------------------------------------------------------------------
# TGW Route Table Entry - Requester to Accepter
# Add route in requester TGW route table pointing to accepter VPC CIDR
# -----------------------------------------------------------------------------

resource "aws_ec2_transit_gateway_route" "requester_to_accepter" {
  provider = aws.requester

  destination_cidr_block         = var.accepter_vpc_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.requester.id
  transit_gateway_route_table_id = var.requester_tgw_route_table_id

  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.accepter]
}

# -----------------------------------------------------------------------------
# TGW Route Table Entry - Accepter to Requester
# Add route in accepter TGW route table pointing to requester VPC CIDR
# -----------------------------------------------------------------------------

resource "aws_ec2_transit_gateway_route" "accepter_to_requester" {
  provider = aws.accepter

  destination_cidr_block         = var.requester_vpc_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.requester.id
  transit_gateway_route_table_id = var.accepter_tgw_route_table_id

  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.accepter]
}

# -----------------------------------------------------------------------------
# VPC Route Table Entries - Requester Side
# Add routes in VPC route tables to reach accepter VPC via TGW
# -----------------------------------------------------------------------------

resource "aws_route" "requester_public_to_accepter" {
  provider = aws.requester
  count    = length(var.requester_public_route_table_ids)

  route_table_id         = var.requester_public_route_table_ids[count.index]
  destination_cidr_block = var.accepter_vpc_cidr
  transit_gateway_id     = var.requester_tgw_id

  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.accepter]
}

resource "aws_route" "requester_private_to_accepter" {
  provider = aws.requester
  count    = length(var.requester_private_route_table_ids)

  route_table_id         = var.requester_private_route_table_ids[count.index]
  destination_cidr_block = var.accepter_vpc_cidr
  transit_gateway_id     = var.requester_tgw_id

  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.accepter]
}

# -----------------------------------------------------------------------------
# VPC Route Table Entries - Accepter Side
# Add routes in VPC route tables to reach requester VPC via TGW
# -----------------------------------------------------------------------------

resource "aws_route" "accepter_public_to_requester" {
  provider = aws.accepter
  count    = length(var.accepter_public_route_table_ids)

  route_table_id         = var.accepter_public_route_table_ids[count.index]
  destination_cidr_block = var.requester_vpc_cidr
  transit_gateway_id     = var.accepter_tgw_id

  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.accepter]
}

resource "aws_route" "accepter_private_to_requester" {
  provider = aws.accepter
  count    = length(var.accepter_private_route_table_ids)

  route_table_id         = var.accepter_private_route_table_ids[count.index]
  destination_cidr_block = var.requester_vpc_cidr
  transit_gateway_id     = var.accepter_tgw_id

  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.accepter]
}
