# =============================================================================
# VPC Module Outputs
# =============================================================================

# -----------------------------------------------------------------------------
# VPC Outputs
# -----------------------------------------------------------------------------

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "vpc_arn" {
  description = "ARN of the VPC"
  value       = aws_vpc.main.arn
}

# -----------------------------------------------------------------------------
# Subnet Outputs
# -----------------------------------------------------------------------------

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  value       = aws_subnet.private[*].cidr_block
}

output "tgw_subnet_ids" {
  description = "List of Transit Gateway subnet IDs"
  value       = aws_subnet.tgw[*].id
}

output "tgw_subnet_cidrs" {
  description = "List of Transit Gateway subnet CIDR blocks"
  value       = aws_subnet.tgw[*].cidr_block
}

# -----------------------------------------------------------------------------
# Route Table Outputs
# -----------------------------------------------------------------------------

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "List of private route table IDs"
  value       = aws_route_table.private[*].id
}

output "tgw_route_table_ids" {
  description = "List of TGW route table IDs"
  value       = aws_route_table.tgw[*].id
}

# -----------------------------------------------------------------------------
# Gateway Outputs
# -----------------------------------------------------------------------------

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.main[*].id
}

output "nat_eip_public_ips" {
  description = "List of public IPs of the NAT Gateway EIPs"
  value       = aws_eip.nat[*].public_ip
}

# -----------------------------------------------------------------------------
# Availability Zone Outputs
# -----------------------------------------------------------------------------

output "availability_zones" {
  description = "List of availability zones used"
  value       = local.azs
}

# -----------------------------------------------------------------------------
# Flow Logs Outputs
# -----------------------------------------------------------------------------

output "flow_log_id" {
  description = "ID of the VPC Flow Log"
  value       = var.enable_flow_logs ? aws_flow_log.main[0].id : null
}

output "flow_log_cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for Flow Logs"
  value       = var.enable_flow_logs ? aws_cloudwatch_log_group.flow_logs[0].arn : null
}

# -----------------------------------------------------------------------------
# Computed Outputs for TGW Integration
# -----------------------------------------------------------------------------

output "tgw_attachment_subnet_ids" {
  description = "Subnet IDs to use for Transit Gateway VPC attachment"
  value       = aws_subnet.tgw[*].id
}

output "vpc_route_tables_for_tgw_routes" {
  description = "Map of route table IDs that need TGW routes"
  value = {
    public  = [aws_route_table.public.id]
    private = aws_route_table.private[*].id
    tgw     = aws_route_table.tgw[*].id
  }
}
