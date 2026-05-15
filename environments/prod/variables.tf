# =============================================================================
# Environment Variables - Dev
# =============================================================================

# -----------------------------------------------------------------------------
# AWS Account Configuration
# -----------------------------------------------------------------------------

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "The aws_account_id must be a valid 12-digit AWS account ID."
  }
}

# -----------------------------------------------------------------------------
# Region Configuration
# -----------------------------------------------------------------------------

variable "paris_region" {
  description = "AWS Region for Paris"
  type        = string
  default     = "eu-west-3"
}

variable "frankfurt_region" {
  description = "AWS Region for Frankfurt"
  type        = string
  default     = "eu-central-1"
}

# -----------------------------------------------------------------------------
# Network Configuration - Paris
# -----------------------------------------------------------------------------

variable "paris_vpc_cidr" {
  description = "CIDR block for VPC in Paris region"
  type        = string
  default     = "10.1.0.0/16"

  validation {
    condition     = can(cidrhost(var.paris_vpc_cidr, 0))
    error_message = "The paris_vpc_cidr must be a valid IPv4 CIDR block."
  }
}

# -----------------------------------------------------------------------------
# Network Configuration - Frankfurt
# -----------------------------------------------------------------------------

variable "frankfurt_vpc_cidr" {
  description = "CIDR block for VPC in Frankfurt region"
  type        = string
  default     = "10.2.0.0/16"

  validation {
    condition     = can(cidrhost(var.frankfurt_vpc_cidr, 0))
    error_message = "The frankfurt_vpc_cidr must be a valid IPv4 CIDR block."
  }
}

# -----------------------------------------------------------------------------
# Transit Gateway Configuration
# -----------------------------------------------------------------------------

variable "paris_tgw_asn" {
  description = "Amazon side ASN for Transit Gateway in Paris"
  type        = number
  default     = 64512

  validation {
    condition     = var.paris_tgw_asn >= 64512 && var.paris_tgw_asn <= 65534
    error_message = "The paris_tgw_asn must be between 64512 and 65534."
  }
}

variable "frankfurt_tgw_asn" {
  description = "Amazon side ASN for Transit Gateway in Frankfurt"
  type        = number
  default     = 64513

  validation {
    condition     = var.frankfurt_tgw_asn >= 64512 && var.frankfurt_tgw_asn <= 65534
    error_message = "The frankfurt_tgw_asn must be between 64512 and 65534."
  }
}

# -----------------------------------------------------------------------------
# EC2 Test Instance Configuration
# -----------------------------------------------------------------------------

variable "instance_type" {
  description = "EC2 instance type for test instances"
  type        = string
  default     = "t3.micro"
}

variable "create_test_instances" {
  description = "Whether to create test EC2 instances"
  type        = bool
  default     = true
}

variable "key_name" {
  description = "Name of the SSH key pair for EC2 instances"
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Feature Flags
# -----------------------------------------------------------------------------

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use single NAT Gateway (cost savings for dev)"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Project Configuration
# -----------------------------------------------------------------------------

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
  default     = "tgw-multi-region"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "DevOps Team"
}
