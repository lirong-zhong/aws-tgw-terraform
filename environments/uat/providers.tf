# =============================================================================
# AWS Providers - Multi-Region Configuration
# =============================================================================

# -----------------------------------------------------------------------------
# Provider for Paris region (eu-west-3) - Requester
# -----------------------------------------------------------------------------
provider "aws" {
  alias  = "paris"
  region = var.paris_region

  # Use environment variables or AWS CLI profile for credentials
  # AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN
  # Or configure profile: profile = "your-profile-name"

  default_tags {
    tags = local.common_tags
  }
}

# -----------------------------------------------------------------------------
# Provider for Frankfurt region (eu-central-1) - Accepter
# -----------------------------------------------------------------------------
provider "aws" {
  alias  = "frankfurt"
  region = var.frankfurt_region

  default_tags {
    tags = local.common_tags
  }
}
