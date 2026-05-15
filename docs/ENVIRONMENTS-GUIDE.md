# Multi-Environment Deployment Guide

## Quick Start

### Step 1: Navigate to Environment
```bash
cd environments/dev    # For DEV
cd environments/uat    # For UAT
cd environments/prod   # For PROD
```

### Step 2: Configure Variables
```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### Step 3: Set AWS Credentials
```bash
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
export AWS_SESSION_TOKEN="your-token"  # If using SSO
```

### Step 4: Deploy
```bash
terraform init
terraform plan
terraform apply
```

---

## Environment Differences

| Setting              | DEV           | UAT           | PROD          |
|---------------------|---------------|---------------|---------------|
| Paris VPC CIDR      | 10.1.0.0/16   | 10.3.0.0/16   | 10.5.0.0/16   |
| Frankfurt VPC CIDR  | 10.2.0.0/16   | 10.4.0.0/16   | 10.6.0.0/16   |
| Instance Type       | t3.micro      | t3.small      | t3.medium     |
| NAT Gateway         | Single        | Single        | Per-AZ        |
| Flow Logs           | Enabled       | Enabled       | Enabled       |
| Test Instances      | Yes           | Yes           | No            |

---

## Creating New Environment

### Copy from DEV
```bash
cp -r environments/dev environments/uat
```

### Update terraform.tfvars
Change these values:
- `environment = "uat"`
- `paris_vpc_cidr = "10.3.0.0/16"`
- `frankfurt_vpc_cidr = "10.4.0.0/16"`
- `paris_tgw_asn = 64514`
- `frankfurt_tgw_asn = 64515`

### Update backend.tf
Change state file path to avoid conflicts.

---

## Workflow: DEV → UAT → PROD

```
1. Develop & Test in DEV
   └── terraform apply (environments/dev)
   
2. Promote to UAT
   └── terraform apply (environments/uat)
   
3. Deploy to PROD
   └── terraform apply (environments/prod)
```

---

## State Management

Each environment has isolated state:
- DEV: `terraform-state-dev/tgw-multi-region/`
- UAT: `terraform-state-uat/tgw-multi-region/`
- PROD: `terraform-state-prod/tgw-multi-region/`

This prevents accidental changes across environments.
