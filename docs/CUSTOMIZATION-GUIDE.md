# AWS TGW Multi-Region Customization Guide

This guide explains how to customize the Terraform project to deploy Transit Gateway infrastructure in different AWS regions with your own naming conventions and CIDR blocks.

## Table of Contents

1. [Quick Start](#quick-start)
2. [File Structure Overview](#file-structure-overview)
3. [Step-by-Step Customization](#step-by-step-customization)
4. [Configuration Reference](#configuration-reference)
5. [Examples](#examples)
6. [Troubleshooting](#troubleshooting)

---

## Quick Start

To deploy TGW in 2 new regions (e.g., Singapore and Tokyo):

1. Copy an existing environment folder
2. Modify `terraform.tfvars` with your values
3. Update `providers.tf` with new regions
4. Update `main.tf` with new region names
5. Run `terraform init` and `terraform apply`

---

## File Structure Overview

```
environments/
├── dev/                          # Development environment
│   ├── terraform.tfvars          # ⭐ YOUR CUSTOM VALUES GO HERE
│   ├── terraform.tfvars.example  # Template file
│   ├── providers.tf              # ⭐ REGION CONFIGURATION
│   ├── main.tf                   # ⭐ MODULE CONFIGURATION
│   ├── variables.tf              # Variable definitions
│   ├── outputs.tf                # Output definitions
│   └── versions.tf               # Terraform version constraints
├── uat/                          # UAT environment (same structure)
└── prod/                         # Production environment (same structure)

modules/
├── vpc/                          # VPC module (no changes needed)
├── tgw/                          # Transit Gateway module (no changes needed)
├── tgw-peering/                  # TGW Peering module (no changes needed)
└── ec2-test/                     # Test instance module (no changes needed)
```

---

## Step-by-Step Customization

### Step 1: Create Your Environment

```bash
# Copy the dev environment as a template
cp -r environments/dev environments/myenv

# Navigate to your new environment
cd environments/myenv
```

### Step 2: Configure terraform.tfvars

This is the **main file** where you customize all values.

**File: `environments/myenv/terraform.tfvars`**

```hcl
# =============================================================================
# AWS Account Configuration
# =============================================================================
aws_account_id = "YOUR-AWS-ACCOUNT-ID"  # e.g., "123456789012"

# =============================================================================
# Region Configuration
# =============================================================================
# Region 1 (Primary/Requester)
paris_region = "ap-southeast-1"  # Change to your first region

# Region 2 (Secondary/Accepter)  
frankfurt_region = "ap-northeast-1"  # Change to your second region

# =============================================================================
# VPC CIDR Configuration
# =============================================================================
# IMPORTANT: CIDRs must NOT overlap!
paris_vpc_cidr     = "10.10.0.0/16"   # Your first VPC CIDR
frankfurt_vpc_cidr = "10.20.0.0/16"   # Your second VPC CIDR

# =============================================================================
# Transit Gateway ASN Configuration
# =============================================================================
# ASN must be unique per TGW (range: 64512-65534 for private ASN)
paris_tgw_asn     = 64512   # ASN for first TGW
frankfurt_tgw_asn = 64513   # ASN for second TGW

# =============================================================================
# Project Naming
# =============================================================================
project_name = "my-project"   # Your project name (used in resource names)
environment  = "dev"          # Environment: dev, uat, prod

# =============================================================================
# EC2 Test Instance Configuration
# =============================================================================
create_test_instances = true           # Set to false if you don't need test instances
instance_type         = "t3.micro"     # Instance type
key_name              = "your-key"     # Your SSH key pair name

# =============================================================================
# Optional Settings
# =============================================================================
single_nat_gateway = true    # true = cost saving, false = HA (one NAT per AZ)
enable_flow_logs   = true    # Enable VPC Flow Logs
```

### Step 3: Configure providers.tf

Update the AWS provider aliases with your regions.

**File: `environments/myenv/providers.tf`**

```hcl
# =============================================================================
# Provider Configuration
# =============================================================================

# Provider for Region 1 (e.g., Singapore)
provider "aws" {
  alias  = "paris"              # Keep alias name (used in main.tf)
  region = var.paris_region     # Will use value from terraform.tfvars
  
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# Provider for Region 2 (e.g., Tokyo)
provider "aws" {
  alias  = "frankfurt"          # Keep alias name (used in main.tf)
  region = var.frankfurt_region # Will use value from terraform.tfvars
  
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
```

### Step 4: Update main.tf (Optional - for custom naming)

If you want to change the internal region names (e.g., from "paris" to "singapore"):

**File: `environments/myenv/main.tf`**

```hcl
# Change region_name in each module call
module "vpc_paris" {
  source = "../../modules/vpc"
  
  providers = {
    aws = aws.paris
  }
  
  region_name = "singapore"  # Change this to your preferred name
  # ... rest of configuration
}

module "vpc_frankfurt" {
  source = "../../modules/vpc"
  
  providers = {
    aws = aws.frankfurt
  }
  
  region_name = "tokyo"  # Change this to your preferred name
  # ... rest of configuration
}
```

### Step 5: Deploy

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

---

## Configuration Reference

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `aws_account_id` | Your AWS Account ID | `"123456789012"` |
| `paris_region` | First AWS region | `"ap-southeast-1"` |
| `frankfurt_region` | Second AWS region | `"ap-northeast-1"` |
| `paris_vpc_cidr` | CIDR for first VPC | `"10.10.0.0/16"` |
| `frankfurt_vpc_cidr` | CIDR for second VPC | `"10.20.0.0/16"` |
| `project_name` | Project name for tagging | `"my-tgw-project"` |
| `environment` | Environment name | `"dev"`, `"uat"`, `"prod"` |

### Optional Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `paris_tgw_asn` | ASN for first TGW | `64512` |
| `frankfurt_tgw_asn` | ASN for second TGW | `64513` |
| `create_test_instances` | Create test EC2 instances | `true` |
| `instance_type` | EC2 instance type | `"t3.micro"` |
| `key_name` | SSH key pair name | `"webnode"` |
| `single_nat_gateway` | Use single NAT Gateway | `true` |
| `enable_flow_logs` | Enable VPC Flow Logs | `true` |

### AWS Region Codes

| Region Name | Region Code |
|-------------|-------------|
| US East (N. Virginia) | `us-east-1` |
| US West (Oregon) | `us-west-2` |
| Europe (Ireland) | `eu-west-1` |
| Europe (Frankfurt) | `eu-central-1` |
| Europe (Paris) | `eu-west-3` |
| Asia Pacific (Singapore) | `ap-southeast-1` |
| Asia Pacific (Tokyo) | `ap-northeast-1` |
| Asia Pacific (Sydney) | `ap-southeast-2` |
| Asia Pacific (Mumbai) | `ap-south-1` |

### CIDR Planning Guidelines

| VPC | Recommended CIDR | Available IPs |
|-----|------------------|---------------|
| VPC 1 | `10.1.0.0/16` | 65,536 |
| VPC 2 | `10.2.0.0/16` | 65,536 |
| VPC 3 | `10.3.0.0/16` | 65,536 |
| VPC 4 | `10.4.0.0/16` | 65,536 |

**Important:** CIDRs must NOT overlap between VPCs!

---

## Examples

### Example 1: Singapore and Tokyo Deployment

**terraform.tfvars:**
```hcl
aws_account_id     = "123456789012"
paris_region       = "ap-southeast-1"    # Singapore
frankfurt_region   = "ap-northeast-1"    # Tokyo
paris_vpc_cidr     = "10.100.0.0/16"
frankfurt_vpc_cidr = "10.200.0.0/16"
paris_tgw_asn      = 65001
frankfurt_tgw_asn  = 65002
project_name       = "apac-network"
environment        = "prod"
```

### Example 2: US East and US West Deployment

**terraform.tfvars:**
```hcl
aws_account_id     = "123456789012"
paris_region       = "us-east-1"         # N. Virginia
frankfurt_region   = "us-west-2"         # Oregon
paris_vpc_cidr     = "172.16.0.0/16"
frankfurt_vpc_cidr = "172.17.0.0/16"
paris_tgw_asn      = 64600
frankfurt_tgw_asn  = 64601
project_name       = "us-backbone"
environment        = "dev"
```

### Example 3: Ireland and Frankfurt Deployment

**terraform.tfvars:**
```hcl
aws_account_id     = "123456789012"
paris_region       = "eu-west-1"         # Ireland
frankfurt_region   = "eu-central-1"      # Frankfurt
paris_vpc_cidr     = "192.168.0.0/16"
frankfurt_vpc_cidr = "192.169.0.0/16"
paris_tgw_asn      = 64700
frankfurt_tgw_asn  = 64701
project_name       = "eu-network"
environment        = "uat"
```

---

## Subnet CIDR Allocation

The VPC module automatically creates subnets with the following CIDR allocation:

For a VPC with CIDR `10.1.0.0/16`:

| Subnet Type | AZ-a | AZ-b |
|-------------|------|------|
| Public | `10.1.1.0/24` | `10.1.2.0/24` |
| Private | `10.1.11.0/24` | `10.1.12.0/24` |
| TGW | `10.1.21.0/24` | `10.1.22.0/24` |

---

## Troubleshooting

### Error: CIDR blocks overlap

**Problem:** You see an error about overlapping CIDR blocks.

**Solution:** Ensure your VPC CIDRs don't overlap:
```hcl
# ❌ Wrong - these overlap
paris_vpc_cidr     = "10.0.0.0/8"
frankfurt_vpc_cidr = "10.1.0.0/16"

# ✅ Correct - no overlap
paris_vpc_cidr     = "10.1.0.0/16"
frankfurt_vpc_cidr = "10.2.0.0/16"
```

### Error: ASN already in use

**Problem:** Transit Gateway ASN conflict.

**Solution:** Use unique ASN values for each TGW:
```hcl
paris_tgw_asn     = 64512
frankfurt_tgw_asn = 64513  # Must be different
```

### Error: Region not supported

**Problem:** Some AWS services aren't available in all regions.

**Solution:** Use major AWS regions that support Transit Gateway:
- All US regions
- All EU regions
- ap-southeast-1, ap-northeast-1, ap-southeast-2, ap-south-1

### Error: Key pair not found

**Problem:** SSH key pair doesn't exist in the target region.

**Solution:** 
1. Create the key pair in both regions, OR
2. Set `create_test_instances = false` if you don't need test instances

---

## Deployment Checklist

Before deploying, verify:

- [ ] AWS credentials are configured
- [ ] `aws_account_id` is correct
- [ ] Both regions support Transit Gateway
- [ ] VPC CIDRs don't overlap
- [ ] TGW ASNs are unique
- [ ] SSH key pair exists in both regions (if using test instances)
- [ ] Project name follows your naming convention

---

## Support

For issues or questions:
1. Check the [Troubleshooting](#troubleshooting) section
2. Review AWS Transit Gateway documentation
3. Check Terraform AWS provider documentation
