# =============================================================================
# Transit Gateway Module Variables
# =============================================================================

# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "vpc_id" {
  description = "ID of the VPC to attach to the Transit Gateway"
  type        = string

  validation {
    condition     = can(regex("^vpc-", var.vpc_id))
    error_message = "The vpc_id must be a valid VPC ID starting with 'vpc-'."
  }
}

variable "tgw_subnet_ids" {
  description = "List of subnet IDs for the TGW VPC attachment (should be dedicated TGW subnets)"
  type        = list(string)

  validation {
    condition     = length(var.tgw_subnet_ids) >= 1
    error_message = "At least one subnet ID must be provided for TGW attachment."
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
# Transit Gateway Configuration
# -----------------------------------------------------------------------------

variable "amazon_side_asn" {
  description = "Amazon side ASN for the Transit Gateway. Must be unique per TGW for peering."
  type        = number
  default     = 64512

  validation {
    condition     = var.amazon_side_asn >= 64512 && var.amazon_side_asn <= 65534
    error_message = "The amazon_side_asn must be between 64512 and 65534 (private ASN range)."
  }
}

variable "auto_accept_shared_attachments" {
  description = "Whether resource attachment requests are automatically accepted"
  type        = string
  default     = "disable"

  validation {
    condition     = contains(["enable", "disable"], var.auto_accept_shared_attachments)
    error_message = "The auto_accept_shared_attachments must be 'enable' or 'disable'."
  }
}

variable "default_route_table_association" {
  description = "Whether resource attachments are automatically associated with the default route table"
  type        = string
  default     = "disable"

  validation {
    condition     = contains(["enable", "disable"], var.default_route_table_association)
    error_message = "The default_route_table_association must be 'enable' or 'disable'."
  }
}

variable "default_route_table_propagation" {
  description = "Whether resource attachments automatically propagate routes to the default route table"
  type        = string
  default     = "disable"

  validation {
    condition     = contains(["enable", "disable"], var.default_route_table_propagation)
    error_message = "The default_route_table_propagation must be 'enable' or 'disable'."
  }
}

# -----------------------------------------------------------------------------
# Feature Flags
# -----------------------------------------------------------------------------

variable "enable_multicast" {
  description = "Enable multicast support on the Transit Gateway"
  type        = bool
  default     = false
}

variable "enable_ipv6" {
  description = "Enable IPv6 support for the VPC attachment"
  type        = bool
  default     = false
}

variable "enable_appliance_mode" {
  description = "Enable appliance mode for stateful inspection (e.g., firewall appliances)"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Resource Access Manager (RAM) Sharing
# -----------------------------------------------------------------------------

variable "enable_ram_sharing" {
  description = "Enable Resource Access Manager sharing for the Transit Gateway"
  type        = bool
  default     = false
}

variable "allow_external_principals" {
  description = "Allow external principals (accounts outside the organization) to access the shared TGW"
  type        = bool
  default     = false
}

variable "ram_principals" {
  description = "List of AWS account IDs or organization ARNs to share the TGW with"
  type        = list(string)
  default     = []
}

# -----------------------------------------------------------------------------
# Additional Tags
# -----------------------------------------------------------------------------

variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
