# 4-Region Full Mesh TGW Design

## Overview

This design creates a 4-region full mesh Transit Gateway architecture with 6 peering connections across European AWS regions.

## Regions

| # | Region | Code | VPC CIDR | TGW ASN |
|---|--------|------|----------|---------|
| 1 | Paris | eu-west-3 | 10.1.0.0/16 | 64512 |
| 2 | Frankfurt | eu-central-1 | 10.2.0.0/16 | 64513 |
| 3 | Ireland | eu-west-1 | 10.3.0.0/16 | 64514 |
| 4 | Stockholm | eu-north-1 | 10.4.0.0/16 | 64515 |

## Full Mesh Peering (6 Connections)

```
                    ┌─────────────┐
                    │   Ireland   │
                    │  eu-west-1  │
                    │ 10.3.0.0/16 │
                    └──────┬──────┘
                          /│\
                         / │ \
                        /  │  \
                       /   │   \
    ┌─────────────┐   /    │    \   ┌─────────────┐
    │    Paris    │──/─────┼─────\──│  Stockholm  │
    │  eu-west-3  │ /      │      \ │  eu-north-1 │
    │ 10.1.0.0/16 │/       │       \│ 10.4.0.0/16 │
    └──────┬──────┘        │        └──────┬──────┘
            \              │              /
             \             │             /
              \            │            /
               \           │           /
                \          │          /
                 \         │         /
                  \        │        /
                   \       │       /
                    \      │      /
                     \     │     /
                      \    │    /
                       \   │   /
                        \  │  /
                         \ │ /
                          \│/
                    ┌──────┴──────┐
                    │  Frankfurt  │
                    │ eu-central-1│
                    │ 10.2.0.0/16 │
                    └─────────────┘
```

## 6 Peering Connections

| # | Requester | Accepter | Route |
|---|-----------|----------|-------|
| 1 | Paris (eu-west-3) | Frankfurt (eu-central-1) | 10.1↔10.2 |
| 2 | Paris (eu-west-3) | Ireland (eu-west-1) | 10.1↔10.3 |
| 3 | Paris (eu-west-3) | Stockholm (eu-north-1) | 10.1↔10.4 |
| 4 | Frankfurt (eu-central-1) | Ireland (eu-west-1) | 10.2↔10.3 |
| 5 | Frankfurt (eu-central-1) | Stockholm (eu-north-1) | 10.2↔10.4 |
| 6 | Ireland (eu-west-1) | Stockholm (eu-north-1) | 10.3↔10.4 |

## Resources Per Region

Each region will have:
- 1 VPC with public, private, and TGW subnets
- 1 Transit Gateway
- 1 NAT Gateway
- 1 Internet Gateway
- Route tables with routes to all other 3 VPCs

**Test EC2 Instances:**
- Paris: Yes (for connectivity testing)
- Frankfurt: Yes (for connectivity testing)
- Ireland: No
- Stockholm: No

## Route Table Configuration

Each TGW route table needs routes to 3 other VPCs:

**Paris TGW Routes:**
- 10.2.0.0/16 → Peering to Frankfurt
- 10.3.0.0/16 → Peering to Ireland
- 10.4.0.0/16 → Peering to Stockholm

**Frankfurt TGW Routes:**
- 10.1.0.0/16 → Peering to Paris
- 10.3.0.0/16 → Peering to Ireland
- 10.4.0.0/16 → Peering to Stockholm

**Ireland TGW Routes:**
- 10.1.0.0/16 → Peering to Paris
- 10.2.0.0/16 → Peering to Frankfurt
- 10.4.0.0/16 → Peering to Stockholm

**Stockholm TGW Routes:**
- 10.1.0.0/16 → Peering to Paris
- 10.2.0.0/16 → Peering to Frankfurt
- 10.3.0.0/16 → Peering to Ireland

## Cost Estimate (Monthly)

| Resource | Qty | Unit Cost | Total |
|----------|-----|-----------|-------|
| Transit Gateway | 4 | $36.50 | $146 |
| TGW Peering Attachments | 6 | $36.50 | $219 |
| NAT Gateway | 4 | $32.40 | $130 |
| VPC Flow Logs | 4 | ~$10 | $40 |
| Test EC2 Instances | 2 | ~$8 | $16 |
| **Total** | | | **~$551/month** |

*Note: Data transfer costs are additional*

## Implementation Status

- [x] Add 2 new providers (Ireland, Stockholm)
- [x] Create 2 new VPCs with TGWs
- [x] Create 5 new peering connections (total 6)
- [x] Update all route tables
- [x] Test instances in Paris and Frankfurt only
- [ ] Deploy and verify connectivity

## Deployment

```bash
cd environments/dev
terraform plan
terraform apply
```

## Files

| File | Description |
|------|-------------|
| `main.tf` | Paris and Frankfurt VPCs, TGWs, and peering |
| `main-4region.tf` | Ireland and Stockholm VPCs, TGWs, and 5 new peerings |
| `outputs.tf` | Outputs for Paris and Frankfurt |
| `outputs-4region.tf` | Outputs for Ireland and Stockholm |
