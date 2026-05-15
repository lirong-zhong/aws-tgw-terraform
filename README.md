# AWS Transit Gateway Multi-Region Infrastructure

This Terraform project creates a multi-region AWS infrastructure with Transit Gateway (TGW) inter-region peering between **eu-west-3 (Paris)** and **eu-central-1 (Frankfurt)**.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           AWS Account: 1358-0892-5467                            │
├───────────────────────────────────┬─────────────────────────────────────────────┤
│       eu-west-3 (Paris)           │           eu-central-1 (Frankfurt)          │
├───────────────────────────────────┼─────────────────────────────────────────────┤
│                                   │                                             │
│  ┌─────────────────────────────┐  │  ┌─────────────────────────────┐            │
│  │     VPC: 10.1.0.0/16        │  │  │     VPC: 10.2.0.0/16        │            │
│  │                             │  │  │                             │            │
│  │  ┌───────────────────────┐  │  │  │  ┌───────────────────────┐  │            │
│  │  │ Public Subnets (2 AZ) │  │  │  │  │ Public Subnets (2 AZ) │  │            │
│  │  │ 10.1.0.0/20           │  │  │  │  │ 10.2.0.0/20           │  │            │
│  │  └───────────────────────┘  │  │  │  └───────────────────────┘  │            │
│  │                             │  │  │                             │            │
│  │  ┌───────────────────────┐  │  │  │  ┌───────────────────────┐  │            │
│  │  │ Private Subnets (2 AZ)│  │  │  │  │ Private Subnets (2 AZ)│  │            │
│  │  │ 10.1.16.0/20          │  │  │  │  │ 10.2.16.0/20          │  │            │
│  │  │ [Test EC2 Instance]   │  │  │  │  │ [Test EC2 Instance]   │  │            │
│  │  └───────────────────────┘  │  │  │  └───────────────────────┘  │            │
│  │                             │  │  │                             │            │
│  │  ┌───────────────────────┐  │  │  │  ┌───────────────────────┐  │            │
│  │  │ TGW Subnets (2 AZ)    │  │  │  │  │ TGW Subnets (2 AZ)    │  │            │
│  │  │ 10.1.32.0/20          │  │  │  │  │ 10.2.32.0/20          │  │            │
│  │  └───────────────────────┘  │  │  │  └───────────────────────┘  │            │
│  │                             │  │  │                             │            │
│  └──────────┬──────────────────┘  │  └──────────┬──────────────────┘            │
│             │                     │             │                               │
│  ┌──────────▼──────────────────┐  │  ┌──────────▼──────────────────┐            │
│  │   Transit Gateway           │◄─┼──►   Transit Gateway           │            │
│  │   ASN: 64512                │  │  │   ASN: 64513                │            │
│  └─────────────────────────────┘  │  └─────────────────────────────┘            │
│                                   │                                             │
│              TGW Inter-Region Peering Connection                                │
│                                   │                                             │
└───────────────────────────────────┴─────────────────────────────────────────────┘
```

## Features

- **Multi-AZ Deployment**: Resources spread across 2 Availability Zones per region
- **Transit Gateway Peering**: Cross-region connectivity via TGW peering
- **Dedicated TGW Subnets**: Isolated subnets for TGW attachments (AWS best practice)
- **VPC Flow Logs**: Network traffic monitoring enabled
- **SSM Session Manager**: Secure instance access without SSH keys
- **IMDSv2 Required**: Enhanced instance metadata security
- **Modular Design**: Reusable Terraform modules

## Project Structure

```
AWS-TGW-Terraform/
├── README.md                          # This file
├── .gitignore                         # Git ignore patterns
├── .terraform-version                 # Terraform version constraint
│
├── modules/                           # Reusable Terraform modules
│   ├── vpc/                           # VPC module
│   │   ├── main.tf                    # VPC, subnets, NAT, IGW
│   │   ├── variables.tf               # Input variables
│   │   └── outputs.tf                 # Output values
│   │
│   ├── tgw/                           # Transit Gateway module
│   │   ├── main.tf                    # TGW, attachments, route tables
│   │   ├── variables.tf               # Input variables
│   │   └── outputs.tf                 # Output values
│   │
│   ├── tgw-peering/                   # TGW Peering module
│   │   ├── main.tf                    # Peering attachment, routes
│   │   ├── variables.tf               # Input variables
│   │   └── outputs.tf                 # Output values
│   │
│   └── ec2-test/                      # Test EC2 instance module
│       ├── main.tf                    # EC2, security groups, IAM
│       ├── variables.tf               # Input variables
│       └── outputs.tf                 # Output values
│
├── environments/                      # Environment configurations
│   └── dev/                           # Development environment
│       ├── versions.tf                # Terraform/provider versions
│       ├── providers.tf               # AWS provider configuration
│       ├── variables.tf               # Environment variables
│       ├── locals.tf                  # Local values
│       ├── main.tf                    # Main configuration
│       ├── outputs.tf                 # Environment outputs
│       ├── backend.tf                 # State backend (S3)
│       └── terraform.tfvars.example   # Example variables file
│
└── scripts/                           # Helper scripts
    ├── deploy.sh                      # Deployment script
    ├── cleanup.sh                     # Cleanup script
    └── test-connectivity.sh           # Connectivity test script
```

## Prerequisites

- **Terraform** >= 1.5.0
- **AWS CLI** v2 configured with credentials
- **AWS Account** with permissions for:
  - VPC, Subnets, Route Tables
  - Transit Gateway
  - EC2, IAM
  - CloudWatch Logs

## Quick Start

### 1. Clone and Configure

```bash
# Navigate to the project
cd AWS-TGW-Terraform

# Copy the example variables file
cp environments/dev/terraform.tfvars.example environments/dev/terraform.tfvars

# Edit with your values
# Update aws_account_id with your 12-digit account ID
```

### 2. Configure AWS Credentials

```bash
# Option 1: Environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"

# Option 2: AWS CLI profile
aws configure --profile your-profile
export AWS_PROFILE=your-profile
```

### 3. Deploy Infrastructure

```bash
# Using the deploy script
./scripts/deploy.sh

# Or manually
cd environments/dev
terraform init
terraform plan
terraform apply
```

### 4. Test Connectivity

After deployment, test the TGW peering connectivity:

```bash
# Run the automated test script
./scripts/test-connectivity.sh

# Or manually connect via SSM
aws ssm start-session --target <paris-instance-id> --region eu-west-3

# From the Paris instance, ping Frankfurt
ping <frankfurt-private-ip>
```

## Configuration

### terraform.tfvars

```hcl
# AWS Account
aws_account_id = "135808925467"

# Regions
paris_region     = "eu-west-3"
frankfurt_region = "eu-central-1"

# Network CIDRs (must not overlap)
paris_vpc_cidr     = "10.1.0.0/16"
frankfurt_vpc_cidr = "10.2.0.0/16"

# Transit Gateway ASNs (must be unique)
paris_tgw_asn     = 64512
frankfurt_tgw_asn = 64513

# Test instances
create_test_instances = true
instance_type         = "t3.micro"

# Features
enable_flow_logs   = true
single_nat_gateway = true  # Set false for production
```

## Outputs

After deployment, Terraform provides useful outputs:

```bash
terraform output

# Key outputs:
# - paris_vpc_id / frankfurt_vpc_id
# - paris_tgw_id / frankfurt_tgw_id
# - tgw_peering_attachment_id
# - paris_test_instance_private_ip / frankfurt_test_instance_private_ip
# - connectivity_test_instructions
```

## Testing Connectivity

### Automated Test

```bash
./scripts/test-connectivity.sh
```

### Manual Test

1. **Connect to Paris instance:**
   ```bash
   aws ssm start-session --target <instance-id> --region eu-west-3
   ```

2. **Ping Frankfurt instance:**
   ```bash
   ping 10.2.x.x  # Frankfurt private IP
   ```

3. **Run traceroute:**
   ```bash
   traceroute 10.2.x.x
   ```

4. **Use the built-in test script:**
   ```bash
   ./test-connectivity.sh 10.2.x.x
   ```

## Cleanup

```bash
# Using the cleanup script
./scripts/cleanup.sh

# Or manually
cd environments/dev
terraform destroy
```

## Cost Considerations

This infrastructure incurs AWS charges for:

| Resource | Approximate Cost |
|----------|------------------|
| Transit Gateway (per region) | ~$36/month |
| TGW Peering Attachment | ~$36/month |
| TGW Data Processing | $0.02/GB |
| NAT Gateway (per AZ) | ~$32/month + data |
| EC2 t3.micro | ~$8/month |
| VPC Flow Logs | Variable |

**Estimated Total (dev):** ~$150-200/month

### Cost Optimization Tips

- Use `single_nat_gateway = true` for dev/test
- Set `create_test_instances = false` when not testing
- Disable flow logs if not needed: `enable_flow_logs = false`

## Security Best Practices Implemented

- ✅ IMDSv2 required for EC2 instances
- ✅ SSM Session Manager (no SSH keys)
- ✅ Encrypted EBS volumes
- ✅ VPC Flow Logs enabled
- ✅ Least privilege security groups
- ✅ Dedicated TGW subnets
- ✅ No public IPs on private instances

## Troubleshooting

### TGW Peering Not Working

1. Check peering attachment state:
   ```bash
   aws ec2 describe-transit-gateway-peering-attachments --region eu-west-3
   ```

2. Verify route tables have correct routes:
   ```bash
   aws ec2 describe-transit-gateway-route-tables --region eu-west-3
   ```

### SSM Session Manager Not Connecting

1. Check instance IAM role has `AmazonSSMManagedInstanceCore` policy
2. Verify SSM agent is running:
   ```bash
   aws ssm describe-instance-information --region eu-west-3
   ```
3. Ensure NAT Gateway is working (for private subnets)

### Ping Not Working

1. Check security groups allow ICMP
2. Verify VPC route tables have TGW routes
3. Check TGW route tables have peering routes

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run `terraform fmt` and `terraform validate`
5. Submit a pull request

## License

MIT License - See LICENSE file for details
