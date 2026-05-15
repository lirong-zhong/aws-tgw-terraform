# AWS Transit Gateway Multi-Region Infrastructure

This Terraform project creates a **4-region full mesh** AWS infrastructure with Transit Gateway (TGW) inter-region peering.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              AWS Account: 1358-0892-5467                             │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                      │
│    ┌─────────────────┐                              ┌─────────────────┐             │
│    │  Paris (eu-west-3)  │◄────────────────────────►│  Frankfurt (eu-central-1)  │  │
│    │  VPC: 10.1.0.0/16   │                          │  VPC: 10.2.0.0/16           │  │
│    │  TGW ASN: 64512     │                          │  TGW ASN: 64513             │  │
│    └────────┬────────────┘                          └────────┬──────────────────┘   │
│             │                                                │                       │
│             │              Full Mesh Peering                 │                       │
│             │              (6 Connections)                   │                       │
│             │                                                │                       │
│    ┌────────▼────────────┐                          ┌────────▼──────────────────┐   │
│    │  Ireland (eu-west-1)   │◄────────────────────►│  Stockholm (eu-north-1)    │   │
│    │  VPC: 10.3.0.0/16      │                       │  VPC: 10.4.0.0/16          │   │
│    │  TGW ASN: 64514        │                       │  TGW ASN: 64515            │   │
│    └────────────────────────┘                       └────────────────────────────┘   │
│                                                                                      │
└─────────────────────────────────────────────────────────────────────────────────────┘

Full Mesh Peering Connections:
  1. Paris     ◄──► Frankfurt
  2. Paris     ◄──► Ireland
  3. Paris     ◄──► Stockholm
  4. Frankfurt ◄──► Ireland
  5. Frankfurt ◄──► Stockholm
  6. Ireland   ◄──► Stockholm
```

## Features

- **4-Region Full Mesh**: Paris, Frankfurt, Ireland, Stockholm with 6 peering connections
- **Multi-AZ Deployment**: Resources spread across 2 Availability Zones per region
- **Transit Gateway Peering**: Cross-region connectivity via TGW peering
- **Dedicated TGW Subnets**: Isolated subnets for TGW attachments (AWS best practice)
- **VPC Flow Logs**: Network traffic monitoring enabled
- **Modular Design**: Reusable Terraform modules

## Project Structure

```
AWS-TGW-Terraform/
├── README.md                          # This file
├── .gitignore                         # Git ignore patterns
├── .terraform-version                 # Terraform version constraint
│
├── docs/                              # Documentation
│   ├── ARCHITECTURE.md                # Detailed architecture
│   └── DESIGN-4-REGION-FULL-MESH.md   # 4-region design document
│
├── modules/                           # Reusable Terraform modules
│   ├── vpc/                           # VPC module
│   │   ├── main.tf                    # VPC, subnets, NAT, IGW
│   │   ├── variables.tf               # Input variables
│   │   ├── outputs.tf                 # Output values
│   │   └── versions.tf                # Version constraints
│   │
│   ├── tgw/                           # Transit Gateway module
│   │   ├── main.tf                    # TGW, attachments, route tables
│   │   ├── variables.tf               # Input variables
│   │   ├── outputs.tf                 # Output values
│   │   └── versions.tf                # Version constraints
│   │
│   └── tgw-peering/                   # TGW Peering module
│       ├── main.tf                    # Peering attachment, routes
│       ├── variables.tf               # Input variables
│       ├── outputs.tf                 # Output values
│       └── versions.tf                # Version constraints
│
└── environments/                      # Environment configurations
    └── dev/                           # Development environment
        ├── main.tf                    # All 4 regions + 6 peering connections
        ├── outputs.tf                 # Environment outputs
        ├── variables.tf               # Environment variables
        ├── providers.tf               # AWS provider configuration
        ├── versions.tf                # Terraform/provider versions
        ├── locals.tf                  # Local values
        ├── backend.tf                 # State backend (S3)
        ├── terraform.tfvars           # Variable values (gitignored)
        └── terraform.tfvars.example   # Example variables file
```

## Prerequisites

- **Terraform** >= 1.5.0
- **AWS CLI** v2 configured with credentials
- **AWS Account** with permissions for:
  - VPC, Subnets, Route Tables
  - Transit Gateway
  - CloudWatch Logs

## Quick Start

### 1. Clone and Configure

```bash
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
cd environments/dev
terraform init
terraform plan
terraform apply
```

## Configuration

### terraform.tfvars

```hcl
# AWS Account
aws_account_id = "135808925467"

# Regions
paris_region     = "eu-west-3"
frankfurt_region = "eu-central-1"
ireland_region   = "eu-west-1"
stockholm_region = "eu-north-1"

# Network CIDRs (must not overlap)
paris_vpc_cidr     = "10.1.0.0/16"
frankfurt_vpc_cidr = "10.2.0.0/16"
ireland_vpc_cidr   = "10.3.0.0/16"
stockholm_vpc_cidr = "10.4.0.0/16"

# Transit Gateway ASNs (must be unique)
paris_tgw_asn     = 64512
frankfurt_tgw_asn = 64513
ireland_tgw_asn   = 64514
stockholm_tgw_asn = 64515

# Features
enable_flow_logs   = true
single_nat_gateway = true  # Set false for production
```

## Outputs

After deployment, Terraform provides useful outputs:

```bash
terraform output

# Key outputs:
# - paris_vpc_id / frankfurt_vpc_id / ireland_vpc_id / stockholm_vpc_id
# - paris_tgw_id / frankfurt_tgw_id / ireland_tgw_id / stockholm_tgw_id
# - peering_paris_frankfurt_id
# - peering_paris_ireland_id
# - peering_paris_stockholm_id
# - peering_frankfurt_ireland_id
# - peering_frankfurt_stockholm_id
# - peering_ireland_stockholm_id
# - infrastructure_summary
```

## Cleanup

```bash
cd environments/dev
terraform destroy
```

## Cost Considerations

This infrastructure incurs AWS charges for:

| Resource | Approximate Cost |
|----------|------------------|
| Transit Gateway (per region × 4) | ~$144/month |
| TGW Peering Attachment (× 6) | ~$216/month |
| TGW Data Processing | $0.02/GB |
| NAT Gateway (per region) | ~$128/month |
| VPC Flow Logs | Variable |

**Estimated Total (dev):** ~$500-600/month

### Cost Optimization Tips

- Use `single_nat_gateway = true` for dev/test
- Disable flow logs if not needed: `enable_flow_logs = false`
- Consider reducing to 2 regions for testing

## Security Best Practices Implemented

- ✅ VPC Flow Logs enabled
- ✅ Dedicated TGW subnets
- ✅ Least privilege security groups
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

### VPC Routes Missing

1. Check VPC route tables:
   ```bash
   aws ec2 describe-route-tables --region eu-west-3
   ```

2. Verify TGW attachment is active:
   ```bash
   aws ec2 describe-transit-gateway-vpc-attachments --region eu-west-3
   ```

## Documentation

- [Architecture Details](docs/ARCHITECTURE.md)
- [4-Region Full Mesh Design](docs/DESIGN-4-REGION-FULL-MESH.md)

## License

MIT License
