# =============================================================================
# VPC Module - AWS Best Practices Implementation
# =============================================================================
# This module creates a production-ready VPC with:
# - Multi-AZ deployment for high availability
# - Public, Private, and dedicated TGW subnets
# - NAT Gateways for private subnet internet access
# - VPC Flow Logs for network monitoring
# - Proper tagging for cost allocation and management
# =============================================================================

# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------

# Get available AZs in the region
data "aws_availability_zones" "available" {
  state = "available"
}

# Get current region
data "aws_region" "current" {}

# Get current caller identity
data "aws_caller_identity" "current" {}

# -----------------------------------------------------------------------------
# Local Values
# -----------------------------------------------------------------------------

locals {
  # Use first 2 AZs for Multi-AZ deployment
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  # Common tags for all resources
  common_tags = {
    Module      = "vpc"
    Region      = data.aws_region.current.name
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# -----------------------------------------------------------------------------
# VPC
# -----------------------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Enable IPv6 if required
  assign_generated_ipv6_cidr_block = var.enable_ipv6

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-vpc-${var.region_name}-${var.environment}"
  })
}

# -----------------------------------------------------------------------------
# Internet Gateway
# -----------------------------------------------------------------------------

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-igw-${var.region_name}-${var.environment}"
  })
}

# -----------------------------------------------------------------------------
# Public Subnets (Multi-AZ)
# -----------------------------------------------------------------------------

resource "aws_subnet" "public" {
  count = length(local.azs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 1)
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-public-${local.azs[count.index]}-${var.environment}"
    Type = "Public"
    Tier = "Public"
  })
}

# -----------------------------------------------------------------------------
# Private Subnets (Multi-AZ) - For Application Workloads
# -----------------------------------------------------------------------------

resource "aws_subnet" "private" {
  count = length(local.azs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 11)
  availability_zone = local.azs[count.index]

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-private-${local.azs[count.index]}-${var.environment}"
    Type = "Private"
    Tier = "Application"
  })
}

# -----------------------------------------------------------------------------
# TGW Subnets (Multi-AZ) - Dedicated for Transit Gateway Attachments
# AWS Best Practice: Use dedicated subnets for TGW attachments
# -----------------------------------------------------------------------------

resource "aws_subnet" "tgw" {
  count = length(local.azs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 21)
  availability_zone = local.azs[count.index]

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-tgw-${local.azs[count.index]}-${var.environment}"
    Type = "TGW"
    Tier = "Transit"
  })
}

# -----------------------------------------------------------------------------
# Elastic IPs for NAT Gateways
# -----------------------------------------------------------------------------

resource "aws_eip" "nat" {
  count = var.single_nat_gateway ? 1 : length(local.azs)

  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-nat-eip-${count.index + 1}-${var.region_name}-${var.environment}"
  })

  depends_on = [aws_internet_gateway.main]
}

# -----------------------------------------------------------------------------
# NAT Gateways
# For production: One NAT Gateway per AZ for high availability
# For dev/test: Single NAT Gateway to reduce costs
# -----------------------------------------------------------------------------

resource "aws_nat_gateway" "main" {
  count = var.single_nat_gateway ? 1 : length(local.azs)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-nat-gw-${count.index + 1}-${var.region_name}-${var.environment}"
  })

  depends_on = [aws_internet_gateway.main]
}

# -----------------------------------------------------------------------------
# Public Route Table
# -----------------------------------------------------------------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-public-rt-${var.region_name}-${var.environment}"
    Type = "Public"
  })
}

# Route to Internet Gateway
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public" {
  count = length(local.azs)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# -----------------------------------------------------------------------------
# Private Route Tables (One per AZ for proper NAT Gateway routing)
# -----------------------------------------------------------------------------

resource "aws_route_table" "private" {
  count = var.single_nat_gateway ? 1 : length(local.azs)

  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-private-rt-${count.index + 1}-${var.region_name}-${var.environment}"
    Type = "Private"
  })
}

# Route to NAT Gateway for private subnet internet access
resource "aws_route" "private_nat" {
  count = var.single_nat_gateway ? 1 : length(local.azs)

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[var.single_nat_gateway ? 0 : count.index].id
}

# Associate Private Subnets with Private Route Tables
resource "aws_route_table_association" "private" {
  count = length(local.azs)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[var.single_nat_gateway ? 0 : count.index].id
}

# -----------------------------------------------------------------------------
# TGW Route Tables
# -----------------------------------------------------------------------------

resource "aws_route_table" "tgw" {
  count = var.single_nat_gateway ? 1 : length(local.azs)

  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-tgw-rt-${count.index + 1}-${var.region_name}-${var.environment}"
    Type = "TGW"
  })
}

# Associate TGW Subnets with TGW Route Tables
resource "aws_route_table_association" "tgw" {
  count = length(local.azs)

  subnet_id      = aws_subnet.tgw[count.index].id
  route_table_id = aws_route_table.tgw[var.single_nat_gateway ? 0 : count.index].id
}

# -----------------------------------------------------------------------------
# VPC Flow Logs - AWS Best Practice for network monitoring
# -----------------------------------------------------------------------------

resource "aws_flow_log" "main" {
  count = var.enable_flow_logs ? 1 : 0

  vpc_id                   = aws_vpc.main.id
  traffic_type             = "ALL"
  log_destination_type     = "cloud-watch-logs"
  log_destination          = aws_cloudwatch_log_group.flow_logs[0].arn
  iam_role_arn             = aws_iam_role.flow_logs[0].arn
  max_aggregation_interval = 60

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-flow-logs-${var.region_name}-${var.environment}"
  })
}

# CloudWatch Log Group for Flow Logs
resource "aws_cloudwatch_log_group" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name              = "/aws/vpc/flow-logs/${var.project_name}-${var.region_name}-${var.environment}"
  retention_in_days = var.flow_logs_retention_days

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-flow-logs-${var.region_name}-${var.environment}"
  })
}

# IAM Role for Flow Logs
resource "aws_iam_role" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name = "${var.project_name}-flow-logs-role-${var.region_name}-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-flow-logs-role-${var.region_name}-${var.environment}"
  })
}

# IAM Policy for Flow Logs
resource "aws_iam_role_policy" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name = "${var.project_name}-flow-logs-policy-${var.region_name}-${var.environment}"
  role = aws_iam_role.flow_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# Default Security Group - Restrict all traffic (AWS Best Practice)
# -----------------------------------------------------------------------------

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  # No ingress or egress rules - effectively blocks all traffic
  # This follows AWS best practice of not using the default security group

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-default-sg-restricted-${var.region_name}-${var.environment}"
  })
}

# -----------------------------------------------------------------------------
# Default Network ACL - Allow all (managed by Security Groups)
# -----------------------------------------------------------------------------

resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_vpc.main.default_network_acl_id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-default-nacl-${var.region_name}-${var.environment}"
  })

  lifecycle {
    ignore_changes = [subnet_ids]
  }
}
