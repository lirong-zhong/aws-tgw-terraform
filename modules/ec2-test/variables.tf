# =============================================================================
# EC2 Test Instance Module Variables
# =============================================================================

# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "vpc_id" {
  description = "ID of the VPC where the test instance will be created"
  type        = string

  validation {
    condition     = can(regex("^vpc-", var.vpc_id))
    error_message = "The vpc_id must be a valid VPC ID starting with 'vpc-'."
  }
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "The vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "subnet_id" {
  description = "ID of the subnet where the test instance will be created"
  type        = string

  validation {
    condition     = can(regex("^subnet-", var.subnet_id))
    error_message = "The subnet_id must be a valid subnet ID starting with 'subnet-'."
  }
}

variable "peer_vpc_cidr" {
  description = "CIDR block of the peer VPC (for security group rules)"
  type        = string

  validation {
    condition     = can(cidrhost(var.peer_vpc_cidr, 0))
    error_message = "The peer_vpc_cidr must be a valid IPv4 CIDR block."
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

variable "instance_type" {
  description = "EC2 instance type for the test instance"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = can(regex("^[a-z][0-9][a-z]?\\.", var.instance_type))
    error_message = "The instance_type must be a valid EC2 instance type."
  }
}

variable "create_ssm_endpoints" {
  description = "Create VPC endpoints for SSM (required for private subnets without NAT)"
  type        = bool
  default     = false
}

variable "key_name" {
  description = "Name of the SSH key pair to use for the instance"
  type        = string
  default     = null
}

variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
