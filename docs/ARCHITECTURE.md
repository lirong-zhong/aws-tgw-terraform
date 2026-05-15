# AWS Transit Gateway Multi-Region Architecture

## Project Structure Overview

```
AWS-TGW-Terraform/
├── modules/                    # Reusable Terraform modules
│   ├── vpc/                   # VPC with subnets, NAT, IGW
│   ├── tgw/                   # Transit Gateway
│   ├── tgw-peering/           # TGW inter-region peering
│   └── ec2-test/              # Test EC2 instances
├── environments/              # Environment-specific configurations
│   ├── dev/                   # Development environment
│   ├── uat/                   # UAT environment (to create)
│   └── prod/                  # Production environment (to create)
├── scripts/                   # Helper scripts
└── docs/                      # Documentation
```

## Why This Structure?

### 1. Modules (Reusable Code)
- Located in `modules/` folder
- Contains the actual infrastructure logic
- Same code used across all environments
- Changes here affect all environments

### 2. Environments (Configuration)
- Located in `environments/` folder
- Each environment has its own:
  - `terraform.tfvars` - Environment-specific values
  - `backend.tf` - State file location
  - `providers.tf` - AWS credentials/regions
- Isolated Terraform state per environment

## Network Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    AWS Account                               │
├─────────────────────────┬───────────────────────────────────┤
│   eu-west-3 (Paris)     │     eu-central-1 (Frankfurt)      │
├─────────────────────────┼───────────────────────────────────┤
│                         │                                    │
│  VPC: 10.X.0.0/16       │     VPC: 10.Y.0.0/16              │
│  ├─ Public: 10.X.1-2/24 │     ├─ Public: 10.Y.1-2/24        │
│  ├─ Private: 10.X.11-12 │     ├─ Private: 10.Y.11-12        │
│  └─ TGW: 10.X.21-22/24  │     └─ TGW: 10.Y.21-22/24         │
│                         │                                    │
│  Transit Gateway ◄──────┼─────► Transit Gateway             │
│                         │                                    │
│      TGW Peering Attachment (Cross-Region)                  │
└─────────────────────────┴───────────────────────────────────┘
```

## CIDR Allocation Strategy

| Environment | Paris VPC    | Frankfurt VPC |
|-------------|--------------|---------------|
| DEV         | 10.1.0.0/16  | 10.2.0.0/16   |
| UAT         | 10.3.0.0/16  | 10.4.0.0/16   |
| PROD        | 10.5.0.0/16  | 10.6.0.0/16   |
