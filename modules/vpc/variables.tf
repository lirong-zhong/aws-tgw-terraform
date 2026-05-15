# =============================================================================
# VPC Module Variables
# =============================================================================

# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "vpc_cidr" {
  description = "CIDR block for the VPC. Must be a valid IPv4 CIDR block."
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "The vpc_cidr must be a valid IPv4 CIDR block."
  }

  validation {
    condition     = tonumber(split("/", var.vpc_cidr)[1]) <= 16
    error_message = "The VPC CIDR block must be /16 or larger to accommodate all subnet tiers."
  }
}

variable "region_name" {
  description = "Friendly name of the region (e.g., 'paris', 'frankfurt') for resource naming"
  type        = string

  validation {
    condition     = length(var.region_name) > 0 && length(var.region_name) <= 20
    error_message = "The region_name must be between 1 and 20 characters."
  }
}

variable "project_name" {
  description = "Project name for resource tagging and naming"
  type        = string

  validation {
    condition     = length(var.project_name) > 0 && length(var.project_name) <= 30
    error_message = "The project_name must be between 1 and 30 characters."
  }
}

variable "environment" {
  description = "Environment name (e.g., 'dev', 'staging', 'prod')"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod", "test", "uat"], var.environment)
    error_message = "The environment must be one of: dev, staging, prod, test, uat."
  }
}

# -----------------------------------------------------------------------------
# Optional Variables
# -----------------------------------------------------------------------------

variable "enable_ipv6" {
  description = "Enable IPv6 CIDR block for the VPC"
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for all AZs (cost savings for non-prod environments)"
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs for network monitoring"
  type        = bool
  default     = true
}

variable "flow_logs_retention_days" {
  description = "Number of days to retain VPC Flow Logs in CloudWatch"
  type        = number
  default     = 30

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.flow_logs_retention_days)
    error_message = "The flow_logs_retention_days must be a valid CloudWatch Logs retention period."
  }
}

variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
