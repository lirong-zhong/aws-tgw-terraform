# =============================================================================
# Transit Gateway Peering Module Variables
# =============================================================================

# -----------------------------------------------------------------------------
# Required Variables - Requester Side
# -----------------------------------------------------------------------------

variable "requester_tgw_id" {
  description = "ID of the Transit Gateway in the requester region"
  type        = string

  validation {
    condition     = can(regex("^tgw-", var.requester_tgw_id))
    error_message = "The requester_tgw_id must be a valid Transit Gateway ID starting with 'tgw-'."
  }
}

variable "requester_tgw_route_table_id" {
  description = "ID of the Transit Gateway route table in the requester region"
  type        = string

  validation {
    condition     = can(regex("^tgw-rtb-", var.requester_tgw_route_table_id))
    error_message = "The requester_tgw_route_table_id must be a valid TGW route table ID starting with 'tgw-rtb-'."
  }
}

variable "requester_vpc_cidr" {
  description = "CIDR block of the VPC in the requester region"
  type        = string

  validation {
    condition     = can(cidrhost(var.requester_vpc_cidr, 0))
    error_message = "The requester_vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "requester_region_name" {
  description = "Friendly name of the requester region (e.g., 'paris')"
  type        = string
}

variable "requester_public_route_table_ids" {
  description = "List of public route table IDs in the requester VPC"
  type        = list(string)
  default     = []
}

variable "requester_private_route_table_ids" {
  description = "List of private route table IDs in the requester VPC"
  type        = list(string)
  default     = []
}

# -----------------------------------------------------------------------------
# Required Variables - Accepter Side
# -----------------------------------------------------------------------------

variable "accepter_tgw_id" {
  description = "ID of the Transit Gateway in the accepter region"
  type        = string

  validation {
    condition     = can(regex("^tgw-", var.accepter_tgw_id))
    error_message = "The accepter_tgw_id must be a valid Transit Gateway ID starting with 'tgw-'."
  }
}

variable "accepter_tgw_route_table_id" {
  description = "ID of the Transit Gateway route table in the accepter region"
  type        = string

  validation {
    condition     = can(regex("^tgw-rtb-", var.accepter_tgw_route_table_id))
    error_message = "The accepter_tgw_route_table_id must be a valid TGW route table ID starting with 'tgw-rtb-'."
  }
}

variable "accepter_vpc_cidr" {
  description = "CIDR block of the VPC in the accepter region"
  type        = string

  validation {
    condition     = can(cidrhost(var.accepter_vpc_cidr, 0))
    error_message = "The accepter_vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "accepter_region" {
  description = "AWS region of the accepter Transit Gateway"
  type        = string
}

variable "accepter_region_name" {
  description = "Friendly name of the accepter region (e.g., 'frankfurt')"
  type        = string
}

variable "accepter_public_route_table_ids" {
  description = "List of public route table IDs in the accepter VPC"
  type        = list(string)
  default     = []
}

variable "accepter_private_route_table_ids" {
  description = "List of private route table IDs in the accepter VPC"
  type        = list(string)
  default     = []
}

# -----------------------------------------------------------------------------
# Account Configuration
# -----------------------------------------------------------------------------

variable "peer_account_id" {
  description = "AWS Account ID of the peer (same account for intra-account peering)"
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.peer_account_id))
    error_message = "The peer_account_id must be a valid 12-digit AWS account ID."
  }
}

# -----------------------------------------------------------------------------
# Project Configuration
# -----------------------------------------------------------------------------

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
# Additional Tags
# -----------------------------------------------------------------------------

variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
